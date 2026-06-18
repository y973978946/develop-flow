import sys
sys.path.insert(0, r'D:\project\A--other\develop-flow\skills\parse-attachment')
from parse import parse_attachment

file_path = r'D:\文档与需求\需求\20260506-塔机安拆\塔机安拆系统对接方案png版\整体功能业务流程介绍\整体功能业务流程介绍.png'
result = parse_attachment(file_path)

if result['success']:
    print("=== 文件解析结果 ===")
    print(f"文件: {result['info']['name']}")
    print(f"类型: {result['info']['ext']}")
    print(f"大小: {result['info']['size_human']}")
    print()
    print("--- 解析内容 ---")
    print(result['content'])
    print("--- 内容结束 ---")
    print()
    print(f"字符数: {result['stats']['chars']}")
    print(f"行数: {result['stats']['lines']}")
else:
    print(f"错误: {result['error']}")
