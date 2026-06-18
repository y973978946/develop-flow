import os
import sys
import io

# 设置 UTF-8 编码
sys.stdout.reconfigure(encoding='utf-8')

# 文件路径
file_path = r"D:\文档与需求\需求\20260506-塔机安拆\塔机安拆系统对接方案png版\物联管理\物联管理-设备对接【✅】\物联管理-设备对接【✅】.png"

print(f"检查文件: {file_path}")
print(f"文件存在: {os.path.exists(file_path)}")

if os.path.exists(file_path):
    try:
        from PIL import Image
        import pytesseract
        
        print("\n开始 OCR 识别...")
        img = Image.open(file_path)
        text = pytesseract.image_to_string(img, lang='chi_sim+eng')
        
        print("\n=== 解析结果 ===")
        print(text)
        print("=== 解析结束 ===")
    except ImportError as e:
        print(f"\n缺少依赖: {e}")
        print("请运行: pip install pytesseract Pillow")
    except Exception as e:
        print(f"\n解析失败: {e}")
