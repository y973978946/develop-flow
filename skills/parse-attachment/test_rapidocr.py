from rapidocr_onnxruntime import RapidOCR

file_path = r'D:\文档与需求\需求\20260506-塔机安拆\塔机安拆系统对接方案png版\整体功能业务流程介绍\整体功能业务流程介绍.png'

engine = RapidOCR()
result, elapse = engine(file_path)

print('Result:', result)
print('Elapse:', elapse)

if result:
    texts = [item[0] for item in result]
    print('\n'.join(texts))
