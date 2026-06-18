import os

search_dir = 'D:/文档与需求'
target_keywords = ['业务流程', '安拆', '塔机']

found_files = []
for root, dirs, files in os.walk(search_dir):
    for f in files:
        if f.endswith('.png'):
            full_path = os.path.join(root, f)
            # 检查文件名是否包含关键词
            if any(kw in f for kw in target_keywords):
                found_files.append(full_path)
                print(f"找到: {full_path}")

if not found_files:
    print("未找到匹配的文件，列出所有 PNG 文件:")
    for root, dirs, files in os.walk(search_dir):
        for f in files:
            if f.endswith('.png'):
                print(os.path.join(root, f))
