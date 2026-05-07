import shutil
import os

src_dir = r"C:\Users\Albiorix Technology\.gemini\antigravity\brain\4a185a4e-e918-493c-b11c-742bf2b28704"
dst_dir = r"d:\kids_pro\assets\images"

files = {
    "colors_adventure_icon_1777549200842.png": "colors_adventure.png",
    "number_magic_icon_1777549220907.png": "number_magic.png",
    "alphabet_fun_icon_1777549243193.png": "alphabet_fun.png"
}

for src_name, dst_name in files.items():
    src_path = os.path.join(src_dir, src_name)
    dst_path = os.path.join(dst_dir, dst_name)
    try:
        shutil.copy2(src_path, dst_path)
        print(f"Copied {src_name} to {dst_name}")
    except Exception as e:
        print(f"Failed to copy {src_name}: {e}")
