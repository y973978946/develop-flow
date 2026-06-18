import { type Plugin, tool } from "@opencode-ai/plugin"
import { execSync } from "child_process"
import { existsSync } from "fs"
import path from "path"

// 支持的文件扩展名
const SUPPORTED_EXTENSIONS = [
  ".png", ".jpg", ".jpeg", ".bmp", ".tiff",  // 图片
  ".pdf",                                       // PDF
  ".xlsx", ".xls",                             // Excel
  ".docx", ".doc",                             // Word
  ".txt", ".md", ".csv"                        // 文本
]

// 检查路径是否是文件
function isFilePath(text: string): string | null {
  // 匹配 Windows 路径或 Unix 路径
  const patterns = [
    /([A-Z]:\\[^\s]+\.[a-zA-Z]{2,5})/i,  // Windows: D:\path\to\file.ext
    /(\/[^\s]+\.[a-zA-Z]{2,5})/,          // Unix: /path/to/file.ext
  ]
  
  for (const pattern of patterns) {
    const match = text.match(pattern)
    if (match) {
      const filePath = match[1]
      const ext = path.extname(filePath).toLowerCase()
      if (SUPPORTED_EXTENSIONS.includes(ext) && existsSync(filePath)) {
        return filePath
      }
    }
  }
  return null
}

// 解析文件
function parseFile(filePath: string): string {
  try {
    const scriptPath = path.join(
      process.env.HOME || process.env.USERPROFILE || "",
      ".agents",
      "skills",
      "parse-attachment",
      "parse.py"
    )
    
    // 尝试多个可能的路径
    const possiblePaths = [
      scriptPath,
      "D:/project/A--other/develop-flow/skills/parse-attachment/parse.py",
      path.join(process.cwd(), "skills", "parse-attachment", "parse.py"),
    ]
    
    for (const script of possiblePaths) {
      if (existsSync(script)) {
        const result = execSync(`python "${script}" "${filePath}"`, {
          encoding: "utf-8",
          timeout: 60000,
        })
        return result
      }
    }
    
    return "错误：找不到 parse.py 脚本"
  } catch (error: any) {
    return `解析失败: ${error.message}`
  }
}

export const AttachmentParserPlugin: Plugin = async (ctx) => {
  return {
    // 创建自定义工具
    tool: {
      "parse-attachment": tool({
        description: "解析附件文件为纯文本。当用户提供文件路径（图片、PDF、Excel、Word等）时，使用此工具提取文字内容。支持格式：.png, .jpg, .pdf, .xlsx, .docx, .txt, .md",
        args: {
          file_path: tool.schema.string({
            description: "要解析的文件路径",
          }),
        },
        async execute(args) {
          const filePath = args.file_path
          
          if (!existsSync(filePath)) {
            return `文件不存在: ${filePath}`
          }
          
          const result = parseFile(filePath)
          return result
        },
      }),
    },
    
    // 监听消息事件，自动检测附件
    "message.updated": async (input, output) => {
      // 这里可以添加自动检测逻辑
      // 但目前 opencode 的 plugin 机制可能不支持修改消息内容
    },
  }
}
