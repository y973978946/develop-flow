---
name: parse-attachment
description: 解析附件文件为纯文本。当用户提供文件路径时自动调用。支持图片OCR、PDF、Excel、Word等格式。
version: 1.2.0
tags: [file, ocr, pdf, excel, image, attachment]
---

# Parse Attachment - 附件解析

## 触发条件

当用户消息中包含文件路径时（如 `D:\xxx\file.png`、`/path/to/file.pdf`），自动调用此 skill。

## 调用方式

**必须使用 Bash 工具直接调用 Python 脚本**，不要使用 Grep/Glob 等文件搜索工具（会触发 ripgrep 下载错误）。

```bash
python "D:\project\A--other\develop-flow\skills\parse-attachment\parse.py" "用户提供的文件路径"
```

## 支持的格式

| 格式 | 扩展名 | 解析方式 |
|------|--------|----------|
| 图片 | .png, .jpg, .jpeg, .bmp, .tiff | OCR 识别（中英文） |
| PDF | .pdf | PyMuPDF 提取 |
| Excel | .xlsx, .xls | pandas → markdown |
| Word | .docx, .doc | python-docx 提取 |
| 文本 | .txt, .md, .csv | 直接读取 |

## 依赖安装

```bash
pip install PyMuPDF pandas python-docx tabulate Pillow
```

可选（图片 OCR）：
```bash
pip install easyocr
```

## 输出格式

脚本输出结构化结果，包含：
- 文件信息（名称、类型、大小）
- 解析内容（纯文本）
- 统计信息（字符数、行数）

## 注意事项

- 图片 OCR 需要安装 easyocr 或 Tesseract
- 如果 OCR 不可用，脚本会返回手动提取文字的提示
- 路径中的中文字符需要使用引号包裹
