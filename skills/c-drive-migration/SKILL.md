---
name: c-drive-migration
description: Windows C 盘空间清理与符号链接迁移。将 C 盘中占用空间大的目录迁移到 D 盘，通过符号链接（Junction）保持软件正常访问。可独立调用。
version: 1.0.0
tags: [windows, migration, symlink, cleanup, disk-space]
---

# C 盘迁移工具

Windows C 盘空间清理与符号链接迁移。将 C 盘中占用空间大的目录迁移到 D 盘，通过符号链接（Junction）保持软件正常访问。

## 使用场景

- C 盘空间不足（<20% 可用）
- 需要将 AppData 目录迁移到 D 盘
- 需要清理临时文件和更新缓存
- 需要验证符号链接状态

## 环境变量

以下命令中的路径需要根据实际情况替换：

| 变量 | 说明 | 获取方式 |
|------|------|----------|
| `$HOME` | 用户 home 目录 | `echo $HOME` |
| `$USER` | 用户名 | `echo $USER` |
| `APPDATA` | AppData\Roaming 路径 | `echo $APPDATA` |
| `LOCALAPPDATA` | AppData\Local 路径 | `echo $LOCALAPPDATA` |

## 工作流程

```
1. 分析    扫描 C 盘，找出占用空间大的目录
2. 规划    生成迁移计划（哪些目录迁移、哪些清理）
3. 执行    迁移目录 + 创建符号链接 + 清理缓存
4. 验证    检查符号链接状态 + 确认空间释放
```

## 命令

### 分析 C 盘空间

```bash
# 获取用户目录
USER_HOME=$(cygpath -w "$HOME" | sed 's/\\/\//g')

# 扫描 AppData 目录大小
du -sh "$LOCALAPPDATA"/* 2>/dev/null | sort -hr | head -20
du -sh "$APPDATA"/* 2>/dev/null | sort -hr | head -20
```

### 迁移单个目录

```bash
# 设置变量
SRC_DIR="$LOCALAPPDATA/目录名"  # 源目录
DST_DIR="D:/AppData/Local/目录名"  # 目标目录

# 1. 移动目录到 D 盘
mv "$SRC_DIR" "$DST_DIR"

# 2. 创建 Junction 符号链接（不需要管理员权限）
mklink /J "$SRC_DIR" "$DST_DIR"

# 3. 验证符号链接
python -c "import os; print(os.path.islink('$SRC_DIR'))"
```

### 批量迁移

使用 `check_symlinks.py` 脚本验证：

```bash
python ~/.agents/skills/c-drive-migration/check_symlinks.py
```

### 清理缓存

```bash
# 清理临时文件
rm -rf "$LOCALAPPDATA/Temp"/*

# 清理更新缓存
rm -rf "$LOCALAPPDATA"/*-updater

# 配置 npm 缓存到 D 盘
npm config set cache "D:/dev/cache/npm"

# 配置 pip 缓存到 D 盘
pip config set global.cache-dir "D:/dev/cache/pip"
```

### 验证迁移结果

```bash
# 检查 C 盘可用空间
df -h /c

# 验证所有符号链接
python ~/.agents/skills/c-drive-migration/check_symlinks.py
```

## 符号链接类型

| 类型 | 命令 | 权限要求 | 推荐度 |
|------|------|----------|--------|
| Junction | `mklink /J` | 普通用户 | **推荐** |
| Symbolic Link | `mklink /D` | 管理员 | 中 |

**推荐使用 Junction**：不需要管理员权限，更可靠。

## 常见问题

### Q: 文件被占用无法删除？

```cmd
# 查找占用文件的进程
tasklist /FI "IMAGENAME eq 进程名.exe"

# 强制结束进程
taskkill /f /im 进程名.exe

# 对于 WPS DLL 注入 explorer.exe 的情况
taskkill /f /im explorer.exe
rd /s /q "%APPDATA%\kingsoft"
explorer.exe
```

### Q: 符号链接创建失败？

1. 检查目标路径是否存在
2. 检查源路径是否已存在
3. 使用 Junction（`mklink /J`）代替 Symbolic Link（`mklink /D`）

### Q: 如何恢复原始目录？

```cmd
# 1. 删除符号链接（不会删除 D 盘数据）
rmdir "%LOCALAPPDATA%\目录名"

# 2. 移回数据
mv "D:/AppData/Local/目录名" "$LOCALAPPDATA/"
```

## 生成的文件

| 文件 | 用途 |
|------|------|
| `check_symlinks.py` | 验证符号链接状态 |

## 注意事项

1. **备份重要数据**：迁移前确保 D 盘有足够的空间
2. **关闭相关软件**：迁移前必须关闭所有使用目标目录的软件
3. **使用 Junction**：`mklink /J` 不需要管理员权限，比 `mklink /D` 更可靠
4. **验证迁移**：迁移后必须验证符号链接是否创建成功
5. **记录迁移目录**：将所有迁移的目录记录到文件中，便于后续维护
