import os
import stat
import sys

def get_user_home():
    """获取当前用户 home 目录"""
    return os.path.expanduser("~")

def get_appdata_dirs():
    """获取 AppData 目录路径"""
    home = get_user_home()
    return {
        "local": os.path.join(home, "AppData", "Local"),
        "roaming": os.path.join(home, "AppData", "Roaming"),
    }

def check_symlink(src):
    """检查单个符号链接状态"""
    src_exists = os.path.exists(src)
    is_link = os.path.islink(src) if src_exists else False
    is_junction = False
    
    if src_exists:
        try:
            st = os.lstat(src)
            is_junction = bool(st.st_file_attributes & stat.FILE_ATTRIBUTE_REPARSE_POINT)
        except:
            pass
    
    if is_link or is_junction:
        try:
            target = os.readlink(src)
            return "OK", target
        except:
            return "OK", "unknown"
    elif src_exists:
        return "EXISTS", None
    else:
        return "MISSING", None

def scan_directory(base_dir, d_drive_base="D:/AppData"):
    """扫描目录，查找符号链接"""
    results = []
    
    if not os.path.exists(base_dir):
        return results
    
    for item in os.listdir(base_dir):
        src_path = os.path.join(base_dir, item)
        if not os.path.isdir(src_path):
            continue
        
        # 检查是否是符号链接
        status, target = check_symlink(src_path)
        
        # 计算对应的 D 盘路径
        rel_path = os.path.relpath(src_path, get_user_home())
        d_path = os.path.join(d_drive_base, rel_path)
        
        results.append({
            "src": src_path,
            "dst": d_path,
            "status": status,
            "target": target,
            "size": get_dir_size(src_path) if status != "MISSING" else 0,
        })
    
    return results

def get_dir_size(path):
    """获取目录大小（简化版，只返回 0）"""
    # 为了避免扫描时间过长，这里返回 0
    # 实际使用时可以用 du 命令获取
    return 0

def format_size(size_bytes):
    """格式化文件大小"""
    if size_bytes == 0:
        return "unknown"
    for unit in ['B', 'KB', 'MB', 'GB']:
        if size_bytes < 1024:
            return f"{size_bytes:.1f} {unit}"
        size_bytes /= 1024
    return f"{size_bytes:.1f} TB"

def main():
    print("=== Symlink Status ===")
    print(f"User: {get_user_home()}")
    print()
    
    appdata = get_appdata_dirs()
    
    # 扫描 AppData\Local
    print("--- AppData\\Local ---")
    local_results = scan_directory(appdata["local"])
    
    ok_count = 0
    error_count = 0
    missing_count = 0
    
    for r in local_results:
        if r["status"] == "OK":
            print(f"OK  {r['src']} -> {r['target']}")
            ok_count += 1
        elif r["status"] == "EXISTS":
            print(f"    {r['src']} (not a symlink)")
        # 跳过 MISSING（不存在且不是符号链接的目录不显示）
    
    print()
    print("--- AppData\\Roaming ---")
    roaming_results = scan_directory(appdata["roaming"])
    
    for r in roaming_results:
        if r["status"] == "OK":
            print(f"OK  {r['src']} -> {r['target']}")
            ok_count += 1
        elif r["status"] == "EXISTS":
            print(f"    {r['src']} (not a symlink)")
    
    # 扫描 D:\AppData 目录，查找缺失的符号链接
    print()
    print("--- D:\\AppData (missing symlinks) ---")
    d_drive_base = "D:/AppData"
    if os.path.exists(d_drive_base):
        for category in ["Local", "Roaming"]:
            d_category = os.path.join(d_drive_base, category)
            if not os.path.exists(d_category):
                continue
            for item in os.listdir(d_category):
                d_path = os.path.join(d_category, item)
                if not os.path.isdir(d_path):
                    continue
                # 对应的 C 盘路径
                c_path = os.path.join(get_user_home(), "AppData", category, item)
                if not os.path.exists(c_path):
                    print(f"MISSING {c_path} (D drive data exists)")
                    missing_count += 1
    
    print()
    print("=== Summary ===")
    print(f"OK: {ok_count}")
    print(f"MISSING: {missing_count}")
    print(f"ERROR: {error_count}")

if __name__ == "__main__":
    main()
