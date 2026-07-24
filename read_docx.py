import os
import zipfile
import xml.etree.ElementTree as ET

def docx_to_text(docx_path):
    try:
        with zipfile.ZipFile(docx_path) as docx:
            # Read word/document.xml
            xml_content = docx.read('word/document.xml')
            root = ET.fromstring(xml_content)
            
            paragraphs = []
            # Find all paragraph elements
            for paragraph in root.iter('{http://schemas.openxmlformats.org/wordprocessingml/2006/main}p'):
                texts = []
                # For each paragraph, find all text elements
                for text_elem in paragraph.iter('{http://schemas.openxmlformats.org/wordprocessingml/2006/main}t'):
                    if text_elem.text:
                        texts.append(text_elem.text)
                paragraphs.append("".join(texts))
            
            return "\n\n".join(paragraphs)
    except Exception as e:
        return f"Error reading {docx_path}: {e}"

def convert_all():
    src_dir = r"c:\Users\ArchBrain\Desktop\REAL\NEW FOLDERS"
    dest_dir = r"c:\Users\ArchBrain\Desktop\REAL\markdown_docs"
    
    if not os.path.exists(dest_dir):
        os.makedirs(dest_dir)
        
    for filename in os.listdir(src_dir):
        if filename.endswith(".docx"):
            docx_path = os.path.join(src_dir, filename)
            text = docx_to_text(docx_path)
            
            md_filename = filename.replace(".docx", ".md")
            md_path = os.path.join(dest_dir, md_filename)
            
            with open(md_path, 'w', encoding='utf-8') as f:
                f.write(f"# {filename[:-5]}\n\n")
                f.write(text)
            print(f"Converted: {filename} -> {md_filename}")

if __name__ == "__main__":
    convert_all()
