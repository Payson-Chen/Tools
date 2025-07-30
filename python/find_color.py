import os
import json
import re
import shutil

# 定义要搜索的目录
directory_path = '/Users/cn22-i570454-a/Documents/PSC/Tmp'
output_dir = 'CoreColor.xcassets'

# 用于存储唯一的颜色值及其匹配数量
hex_colors = {}
alpha_colors = {}
total_matches = 0  # 计数器：总的匹配数

# 正则表达式模式，匹配 PSC_HexColor、*hexColor、KHexColor、KHexColorAlpha 和 UIColor.hexColor
pattern_color = re.compile(r'(?:PSC_HexColor|[!][!][^ ]*hexColor|KHexColor|KHexColor)\(\s*(0x[a-fA-F0-9]{6})\s*\)', re.IGNORECASE)
pattern_alpha = re.compile(r'(?:PSC_HexColorAlpha|KHexColorAlpha)\(\s*(0x[a-fA-F0-9]{6})\s*,\s*([0-1](?:\.\d+)?)\s*\)', re.IGNORECASE)
pattern_ui_color = re.compile(r'\[UIColor colorWithRed:(\d+\.?\d*)/255\.f\s+green:(\d+\.?\d*)/255\.f\s+blue:(\d+\.?\d*)/255\.f\s+alpha:(\d+\.?\d*)\]', re.IGNORECASE)
pattern_ui_color_hex = re.compile(r'\[UIColor colorWithHex:(0x[a-fA-F0-9]{6})\s+(?:withAlpha:\s*([0-1](?:\.\d+)?))?\]', re.IGNORECASE)

# 遍历目录
for root, dirs, files in os.walk(directory_path):
    for file in files:
        if file.endswith(('.m', '.swift')):
            file_path = os.path.join(root, file)
            with open(file_path, 'r', encoding='utf-8') as f:
                for line in f:
                    match_color = pattern_color.search(line)
                    if match_color:
                        total_matches += 1  # 增加总匹配计数
                        hex_color = match_color.group(1).upper()  # 转为大写
                        hex_colors[hex_color] = hex_colors.get(hex_color, {'count': 0, 'name': f'kColor_{hex_color[2:].upper()}', 'examples': []})
                        hex_colors[hex_color]['count'] += 1  # 增加匹配数量
                        hex_colors[hex_color]['examples'].append(match_color.group(0))  # 保存所有关键代码

                    match_alpha = pattern_alpha.search(line)
                    if match_alpha:
                        total_matches += 1  # 增加总匹配计数
                        hex_color_alpha = match_alpha.group(1).upper()  # 转为大写
                        alpha_value = float(match_alpha.group(2))  # 获取透明度并转换为浮点数
                        alpha_hex = int(alpha_value * 255)  # 转换为0-255范围的整数
                        alpha_hex = f'{alpha_hex:02X}'  # 转换为两位十六进制
                        alpha_color_name = f'kColor_{hex_color_alpha[2:].upper()}.{int(alpha_value * 100):02}' if alpha_value < 1.0 else f'kColor_{hex_color_alpha[2:].upper()}'
                        alpha_colors[(hex_color_alpha, alpha_value)] = alpha_colors.get((hex_color_alpha, alpha_value), {'count': 0, 'name': alpha_color_name, 'examples': []})
                        alpha_colors[(hex_color_alpha, alpha_value)]['count'] += 1  # 增加匹配数量
                        alpha_colors[(hex_color_alpha, alpha_value)]['examples'].append(match_alpha.group(0))  # 保存所有关键代码

                    # 匹配 UIColor colorWithRed:green:blue:alpha:
                    match_ui_color = pattern_ui_color.search(line)
                    if match_ui_color:
                        red, green, blue, alpha = match_ui_color.groups()
                        hex_color = f'0x{int(float(red) * 255):02X}{int(float(green) * 255):02X}{int(float(blue) * 255):02X}'
                        hex_color = hex_color.upper()  # 转为大写
                        hex_colors[hex_color] = hex_colors.get(hex_color, {'count': 0, 'name': f'kColor_{hex_color[2:].upper()}', 'examples': []})
                        hex_colors[hex_color]['count'] += 1  # 增加匹配数量
                        hex_colors[hex_color]['examples'].append(match_ui_color.group(0))  # 保存所有关键代码
                        total_matches += 1

                    # 匹配 UIColor colorWithHex:
                    match_ui_color_hex = pattern_ui_color_hex.search(line)
                    if match_ui_color_hex:
                        hex_color = match_ui_color_hex.group(1).upper()  # 转为大写
                        alpha = match_ui_color_hex.group(2)  # 获取透明度，如果有的话
                        if alpha is not None:
                            alpha_value = float(alpha)  # 转为浮点数
                            alpha_hex = int(alpha_value * 255)  # 转换为0-255范围的整数
                            alpha_hex = f'{alpha_hex:02X}'  # 转换为两位十六进制
                            alpha_color_name = f'kColor_{hex_color[2:].upper()}.{int(alpha_value * 100):02}' if alpha_value < 1.0 else f'kColor_{hex_color[2:].upper()}'
                            alpha_colors[(hex_color, alpha_value)] = alpha_colors.get((hex_color, alpha_value), {'count': 0, 'name': alpha_color_name, 'examples': []})
                            alpha_colors[(hex_color, alpha_value)]['count'] += 1  # 增加匹配数量
                            alpha_colors[(hex_color, alpha_value)]['examples'].append(match_ui_color_hex.group(0))  # 保存所有关键代码
                            total_matches += 1
                        else:
                            hex_colors[hex_color] = hex_colors.get(hex_color, {'count': 0, 'name': f'kColor_{hex_color[2:].upper()}', 'examples': []})
                            hex_colors[hex_color]['count'] += 1  # 增加匹配数量
                            hex_colors[hex_color]['examples'].append(match_ui_color_hex.group(0))  # 保存所有关键代码
                            total_matches += 1

# 如果 exampleColor.xcassets 已存在，先删除它
if os.path.exists(output_dir):
    shutil.rmtree(output_dir)  # 使用 shutil.rmtree 递归删除

# 创建 exampleColor.xcassets 文件夹
os.makedirs(output_dir)

# 写入颜色集
for hex_value, color_info in hex_colors.items():
    colorset_name = f"{color_info['name']}.colorset"
    colorset_path = os.path.join(output_dir, colorset_name)

    os.makedirs(colorset_path, exist_ok=True)

    # 生成 Contents.json
    contents = {
        "colors": [
            {
                "color": {
                    "color-space": "srgb",
                    "components": {
                        "alpha": "1.000",  # 使用固定的alpha值
                        "blue": f"0x{hex_value[6:8]}",   # 取蓝色部分
                        "green": f"0x{hex_value[4:6]}",  # 取绿色部分
                        "red": f"0x{hex_value[2:4]}",    # 取红色部分
                    }
                },
                "idiom": "universal"
            }
        ],
        "info": {
            "author": "xcode",
            "version": 1
        }
    }

    with open(os.path.join(colorset_path, 'Contents.json'), 'w', encoding='utf-8') as f:
        json.dump(contents, f, indent=2)

for (hex_value, alpha), color_info in alpha_colors.items():
    colorset_name = f"{color_info['name']}.colorset"
    colorset_path = os.path.join(output_dir, colorset_name)

    os.makedirs(colorset_path, exist_ok=True)

    # 生成 Contents.json
    contents = {
        "colors": [
            {
                "color": {
                    "color-space": "srgb",
                    "components": {
                        "alpha": f"{alpha:.3f}",  # 以小数形式使用透明度值
                        "blue": f"0x{hex_value[6:8]}",   # 取蓝色部分
                        "green": f"0x{hex_value[4:6]}",  # 取绿色部分
                        "red": f"0x{hex_value[2:4]}",    # 取红色部分
                    }
                },
                "idiom": "universal"
            }
        ],
        "info": {
            "author": "xcode",
            "version": 1
        }
    }

    with open(os.path.join(colorset_path, 'Contents.json'), 'w', encoding='utf-8') as f:
        json.dump(contents, f, indent=2)

# 输出匹配统计
print(f"\nTotal matches found: {total_matches}")
print(f"Unique colors found: {len(hex_colors)}")
print(f"Unique alpha colors found: {len(alpha_colors)}")

# 输出每个颜色的定义和匹配数量，按照匹配数量升序排列
print("\nDefine statements:")
for hex_value, color_info in sorted(hex_colors.items(), key=lambda item: item[1]['count']):
    print(f"#define {color_info['name']} PSC_HexColor({hex_value}) // Matches: {color_info['count']}")
    if color_info['count'] < 10:
        for example in color_info['examples']:
            print(f"  Found in: {example}")

for (hex_value, alpha), color_info in sorted(alpha_colors.items(), key=lambda item: item[1]['count']):
    print(f"#define {color_info['name']} PSC_HexColorAlpha({hex_value}, {alpha:.3f}) // Matches: {color_info['count']}")
    if color_info['count'] < 10:
        for example in color_info['examples']:
            print(f"  Found in: {example}")
