#!/usr/bin/env python3
"""
附件解析工具
支持：图片(PNG/JPG/BMP/TIFF)、PDF、Excel、Word、文本文件
"""

import os
import sys
import json
import io

# 设置标准输出编码为 UTF-8（解决 Windows 中文显示问题）
sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding='utf-8')
sys.stderr = io.TextIOWrapper(sys.stderr.buffer, encoding='utf-8')

def get_file_info(file_path: str) -> dict:
    """获取文件信息"""
    if not os.path.exists(file_path):
        return None
    
    stat = os.stat(file_path)
    ext = os.path.splitext(file_path)[1].lower()
    
    return {
        "path": file_path,
        "name": os.path.basename(file_path),
        "ext": ext,
        "size": stat.st_size,
        "size_human": format_size(stat.st_size)
    }

def format_size(size: int) -> str:
    """格式化文件大小"""
    for unit in ['B', 'KB', 'MB', 'GB']:
        if size < 1024:
            return f"{size:.1f} {unit}"
        size /= 1024
    return f"{size:.1f} TB"

def parse_image(file_path: str) -> str:
    """解析图片文件（OCR）"""
    # 方案1: RapidOCR (推荐，轻量级)
    try:
        from rapidocr_onnxruntime import RapidOCR
        
        engine = RapidOCR()
        result, elapse = engine(file_path)
        
        if result:
            # result 格式: [[[bbox], text, confidence], ...]
            texts = [item[1] for item in result]
            return '\n'.join(texts)
    except Exception as e:
        pass
    
    # 方案2: 尝试 pytesseract
    try:
        from PIL import Image
        import pytesseract
        
        img = Image.open(file_path)
        text = pytesseract.image_to_string(img, lang='chi_sim+eng')
        if text.strip():
            return text.strip()
    except ImportError:
        pass
    except Exception:
        pass
    
    # 方案3: 返回文件信息提示
    return f"""[图片OCR不可用]

文件路径: {file_path}
文件大小: {os.path.getsize(file_path) / 1024:.1f} KB

请手动提取文字:

Windows 10/11:
  1. 右键图片 → 打开方式 → 照片
  2. 点击右上角 "..." → "复制图片中的文字"

其他工具:
  - 微信截图 (Alt+A) → 点击"提取文字"
  - QQ 截图 (Ctrl+Alt+A) → 点击"文字识别" """

def parse_pdf(file_path: str) -> str:
    """解析 PDF 文件"""
    try:
        import fitz  # PyMuPDF
        
        text = ""
        with fitz.open(file_path) as doc:
            for page in doc:
                text += page.get_text()
        
        # 如果文本为空，可能是扫描件
        if not text.strip():
            return "PDF 文本为空（可能是扫描件），需要 OCR 支持"
        
        return text.strip()
    except ImportError:
        return "错误：需要安装依赖 pip install PyMuPDF"
    except Exception as e:
        return f"PDF 解析失败: {str(e)}"

def parse_excel(file_path: str) -> str:
    """解析 Excel 文件"""
    try:
        import pandas as pd
        
        df = pd.read_excel(file_path)
        return df.to_markdown(index=False)
    except ImportError:
        return "错误：需要安装依赖 pip install pandas openpyxl"
    except Exception as e:
        return f"Excel 解析失败: {str(e)}"

def parse_word(file_path: str) -> str:
    """解析 Word 文件"""
    try:
        from docx import Document
        
        doc = Document(file_path)
        paragraphs = [para.text for para in doc.paragraphs if para.text.strip()]
        return "\n".join(paragraphs)
    except ImportError:
        return "错误：需要安装依赖 pip install python-docx"
    except Exception as e:
        return f"Word 解析失败: {str(e)}"

def parse_text(file_path: str) -> str:
    """解析文本文件"""
    try:
        encodings = ['utf-8', 'gbk', 'gb2312', 'latin-1']
        for encoding in encodings:
            try:
                with open(file_path, 'r', encoding=encoding) as f:
                    return f.read().strip()
            except UnicodeDecodeError:
                continue
        return "无法识别文件编码"
    except Exception as e:
        return f"文本解析失败: {str(e)}"

def parse_csv(file_path: str) -> str:
    """解析 CSV 文件"""
    try:
        import pandas as pd
        
        df = pd.read_csv(file_path)
        return df.to_markdown(index=False)
    except ImportError:
        return "错误：需要安装依赖 pip install pandas"
    except Exception as e:
        return f"CSV 解析失败: {str(e)}"

def parse_attachment(file_path: str) -> dict:
    """
    解析附件文件
    返回: {"success": bool, "info": dict, "content": str, "error": str}
    """
    # 获取文件信息
    info = get_file_info(file_path)
    if not info:
        return {
            "success": False,
            "error": f"文件不存在: {file_path}"
        }
    
    ext = info["ext"]
    
    # 根据扩展名选择解析方式
    parsers = {
        # 图片
        ".png": parse_image,
        ".jpg": parse_image,
        ".jpeg": parse_image,
        ".bmp": parse_image,
        ".tiff": parse_image,
        # PDF
        ".pdf": parse_pdf,
        # Excel
        ".xlsx": parse_excel,
        ".xls": parse_excel,
        # Word
        ".docx": parse_word,
        ".doc": parse_word,
        # 文本
        ".txt": parse_text,
        ".md": parse_text,
        ".csv": parse_csv,
    }
    
    parser = parsers.get(ext)
    if not parser:
        return {
            "success": False,
            "info": info,
            "error": f"不支持的文件格式: {ext}"
        }
    
    # 解析文件
    content = parser(file_path)
    
    # 统计信息
    lines = content.count('\n') + 1 if content else 0
    chars = len(content)
    
    return {
        "success": True,
        "info": info,
        "content": content,
        "stats": {
            "lines": lines,
            "chars": chars
        }
    }

def main():
    """主函数"""
    if len(sys.argv) < 2:
        print("用法: python parse.py <文件路径>")
        print("示例: python parse.py D:\\project\\需求文档.pdf")
        sys.exit(1)
    
    file_path = sys.argv[1]
    
    # 解析文件
    result = parse_attachment(file_path)
    
    if not result["success"]:
        print(f"错误: {result['error']}")
        sys.exit(1)
    
    info = result["info"]
    content = result["content"]
    stats = result["stats"]
    
    # 输出结果
    print("=== 文件解析结果 ===")
    print(f"文件: {info['name']}")
    print(f"类型: {info['ext']}")
    print(f"大小: {info['size_human']}")
    print()
    print("--- 解析内容 ---")
    print(content)
    print("--- 内容结束 ---")
    print()
    print(f"字符数: {stats['chars']}")
    print(f"行数: {stats['lines']}")

if __name__ == "__main__":
    main()
