import os
import boto3
import PyPDF2
from fpdf import FPDF

# Initialize AWS clients
s3 = boto3.client('s3')
translate_client = boto3.client('translate')

def extract_text_from_pdf(pdf_path):
    """
    Extracts text from a PDF file.
    """
    text = ""
    try:
        with open(pdf_path, "rb") as f:
            pdf_reader = PyPDF2.PdfReader(f)
            for page in pdf_reader.pages:
                page_text = page.extract_text()
                if page_text:
                    text += page_text + "\n"
    except Exception as e:
        print(f"Error extracting text: {e}")
    return text.strip()

def split_text_by_limit(text, max_bytes=10000):
    """
    Splits text into chunks such that each chunk, when encoded in UTF-8,
    is less than max_bytes. This implementation splits text on newline characters.
    """
    chunks = []
    current_chunk = ""
    for line in text.split("\n"):
        candidate = current_chunk + ("\n" if current_chunk else "") + line
        if len(candidate.encode('utf-8')) > max_bytes:
            if current_chunk:
                chunks.append(current_chunk)
                current_chunk = line
            else:
                encoded_line = line.encode('utf-8')
                for i in range(0, len(encoded_line), max_bytes):
                    chunk = encoded_line[i:i+max_bytes].decode('utf-8', errors='ignore')
                    chunks.append(chunk)
                current_chunk = ""
        else:
            current_chunk = candidate
    if current_chunk:
        chunks.append(current_chunk)
    return chunks

def translate_text(text, source_lang="es", target_lang="en"):
    """
    Translates text from the source language to the target language using AWS Translate.
    If the text exceeds AWS Translate's limit, splits it into smaller chunks and translates each.
    """
    if len(text.encode('utf-8')) <= 10000:
        try:
            response = translate_client.translate_text(
                Text=text,
                SourceLanguageCode=source_lang,
                TargetLanguageCode=target_lang
            )
            return response.get("TranslatedText")
        except Exception as e:
            print(f"Error translating text: {e}")
            return None
    else:
        chunks = split_text_by_limit(text, max_bytes=10000)
        translated_chunks = []
        for idx, chunk in enumerate(chunks):
            try:
                response = translate_client.translate_text(
                    Text=chunk,
                    SourceLanguageCode=source_lang,
                    TargetLanguageCode=target_lang
                )
                translated_chunks.append(response.get("TranslatedText"))
            except Exception as e:
                print(f"Error translating chunk {idx}: {e}")
                translated_chunks.append("")
        return "\n".join(translated_chunks)

def save_text_to_pdf(text, output_pdf_path):
    """
    Saves text to a new PDF file using FPDF.
    FPDF uses Latin-1 encoding by default, so we replace characters that cannot be encoded.
    """
    try:
        pdf = FPDF()
        pdf.add_page()
        pdf.set_auto_page_break(auto=True, margin=15)
        pdf.set_font("Arial", size=12)
        # For each line, replace characters that are not in Latin-1 with a replacement character.
        for line in text.split("\n"):
            safe_line = line.encode('latin-1', errors='replace').decode('latin-1')
            pdf.cell(0, 10, txt=safe_line, ln=True)
        pdf.output(output_pdf_path)
    except Exception as e:
        print(f"Error saving PDF: {e}")
        raise

def lambda_handler(event, context):
    results = []
    
    for record in event["Records"]:
        source_bucket = record["s3"]["bucket"]["name"]
        object_key = record["s3"]["object"]["key"]
        target_bucket = os.environ["LAMBDA_S3_BUCKET"]

        # Prepare download path (ensure any subdirectories exist in /tmp)
        download_path = f"/tmp/{object_key}"
        os.makedirs(os.path.dirname(download_path), exist_ok=True)

        try:
            s3.download_file(source_bucket, object_key, download_path)
            print(f"File {object_key} downloaded to {download_path}")
        except Exception as e:
            error_msg = f"Error downloading file {object_key}: {str(e)}"
            print(error_msg)
            results.append({"object": object_key, "status": "error", "message": str(e)})
            continue

        # Extract text from the downloaded PDF
        extracted_text = extract_text_from_pdf(download_path)
        if not extracted_text:
            msg = "No text extracted from PDF."
            print(msg)
            results.append({"object": object_key, "status": "error", "message": msg})
            continue

        # Log the extracted text size for debugging
        text_size = len(extracted_text.encode('utf-8'))
        print(f"Extracted text size: {text_size} bytes")

        # Translate the extracted text (from Spanish to English)
        translated_text = translate_text(extracted_text, source_lang="es", target_lang="en")
        if not translated_text:
            msg = "Translation failed."
            print(msg)
            results.append({"object": object_key, "status": "error", "message": msg})
            continue

        # Save translated text to a new PDF file
        safe_object_key = object_key.replace("/", "_")
        output_pdf_path = f"/tmp/translated_{safe_object_key}"
        try:
            save_text_to_pdf(translated_text, output_pdf_path)
        except Exception as e:
            msg = f"Error saving translated PDF: {e}"
            print(msg)
            results.append({"object": object_key, "status": "error", "message": msg})
            continue

        # Upload the translated PDF to the target S3 bucket
        try:
            s3.upload_file(output_pdf_path, target_bucket, f"translated_{object_key}")
            print(f"Translated PDF uploaded to s3://{target_bucket}/translated_{object_key}")
            results.append({
                "object": object_key,
                "status": "translated",
                "output_pdf": f"s3://{target_bucket}/translated_{object_key}"
            })
        except Exception as e:
            msg = f"Error uploading translated PDF: {e}"
            print(msg)
            results.append({"object": object_key, "status": "error", "message": msg})

    return {"status": "completed", "results": results}
