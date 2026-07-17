import urllib.request
import zipfile
import os
import subprocess
import sys

# 配置
INSTALL_DIR = os.path.expanduser("~/.local/bin")
ZIP_URLS = [
    'https://github.com/BurntSushi/ripgrep/releases/download/15.1.0/ripgrep-15.1.0-x86_64-pc-windows-msvc.zip',
    'https://ghproxy.com/https://github.com/BurntSushi/ripgrep/releases/download/15.1.0/ripgrep-15.1.0-x86_64-pc-windows-msvc.zip',
]
ZIP_FILE = os.path.join(INSTALL_DIR, "ripgrep.zip")

def check_ripgrep():
    """检查 ripgrep 是否已安装"""
    try:
        result = subprocess.run(["rg", "--version"], capture_output=True, text=True)
        if result.returncode == 0:
            print(f"ripgrep 已安装: {result.stdout.strip()}")
            return True
    except FileNotFoundError:
        pass
    
    # 检查常见安装目录（动态获取用户目录）
    home = os.path.expanduser("~")
    common_dirs = [
        os.path.join(home, ".local", "bin"),
        os.path.join(home, ".local", "share", "opencode", "bin"),
    ]
    
    for dir in common_dirs:
        rg_path = os.path.join(dir, "rg.exe")
        if os.path.exists(rg_path):
            print(f"ripgrep 已安装在: {rg_path}")
            print(f"但未在 PATH 中，需要配置 PATH")
            return False
    
    return False

def download_ripgrep():
    """下载 ripgrep"""
    print("正在下载 ripgrep...")
    
    os.makedirs(INSTALL_DIR, exist_ok=True)
    
    for url in ZIP_URLS:
        try:
            print(f"尝试: {url[:60]}...")
            urllib.request.urlretrieve(url, ZIP_FILE)
            print("下载完成!")
            return True
        except Exception as e:
            print(f"失败: {e}")
            continue
    
    print("所有下载源都失败")
    return False

def extract_ripgrep():
    """解压 ripgrep"""
    print("正在解压...")
    
    try:
        with zipfile.ZipFile(ZIP_FILE, 'r') as zip_ref:
            zip_ref.extractall(INSTALL_DIR)
        
        # 查找 rg.exe 并移动到安装目录
        for root, dirs, files in os.walk(INSTALL_DIR):
            for f in files:
                if f == "rg.exe":
                    src = os.path.join(root, f)
                    dst = os.path.join(INSTALL_DIR, f)
                    if src != dst:
                        os.rename(src, dst)
                    print(f"已安装到: {dst}")
        
        # 清理临时文件
        if os.path.exists(ZIP_FILE):
            os.remove(ZIP_FILE)
        
        # 清理解压的子目录
        for root, dirs, files in os.walk(INSTALL_DIR):
            for d in dirs:
                if d.startswith("ripgrep-"):
                    import shutil
                    shutil.rmtree(os.path.join(root, d))
        
        return True
    except Exception as e:
        print(f"解压失败: {e}")
        return False

def add_to_path():
    """将安装目录添加到 PATH"""
    print(f"正在配置 PATH...")
    
    # 检查是否已在 PATH 中
    current_path = os.environ.get("PATH", "")
    if INSTALL_DIR in current_path:
        print(f"已在 PATH 中: {INSTALL_DIR}")
        return True
    
    # 添加到当前会话的 PATH
    os.environ["PATH"] = current_path + ";" + INSTALL_DIR
    print(f"已添加到当前会话 PATH: {INSTALL_DIR}")
    
    # 提示用户永久配置
    print("\n要永久配置 PATH，请执行以下命令:")
    print(f'  setx PATH "%PATH%;{INSTALL_DIR}"')
    print("\n或添加到 ~/.bashrc:")
    print(f'  echo \'export PATH="$PATH:{INSTALL_DIR}"\' >> ~/.bashrc')
    
    return True

def verify_installation():
    """验证安装"""
    print("\n正在验证安装...")
    
    rg_path = os.path.join(INSTALL_DIR, "rg.exe")
    if not os.path.exists(rg_path):
        print(f"错误: {rg_path} 不存在")
        return False
    
    try:
        result = subprocess.run([rg_path, "--version"], capture_output=True, text=True)
        if result.returncode == 0:
            print(f"安装成功!")
            print(f"版本: {result.stdout.strip()}")
            print(f"路径: {rg_path}")
            return True
    except Exception as e:
        print(f"验证失败: {e}")
    
    return False

def main():
    print("=== ripgrep 安装工具 ===\n")
    
    # 1. 检查是否已安装
    if check_ripgrep():
        print("\nripgrep 已安装，无需操作")
        return
    
    # 2. 下载
    if not download_ripgrep():
        print("\n下载失败，请手动下载:")
        print("1. 访问 https://github.com/BurntSushi/ripgrep/releases")
        print("2. 下载 ripgrep-15.1.0-x86_64-pc-windows-msvc.zip")
        print(f"3. 解压到 {INSTALL_DIR}")
        return
    
    # 3. 解压
    if not extract_ripgrep():
        print("\n解压失败")
        return
    
    # 4. 配置 PATH
    add_to_path()
    
    # 5. 验证
    if verify_installation():
        print("\n=== 安装完成 ===")
        print("请重启 opencode 以使 PATH 配置生效")
    else:
        print("\n=== 安装可能有问题，请手动验证 ===")

if __name__ == "__main__":
    main()
