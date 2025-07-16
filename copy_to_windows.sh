#!/bin/bash

echo "正在尝试将文件复制到 Windows 可访问的位置..."

# 文件源路径
SOURCE_FILE="/mnt/persist/workspace/localsend-kylin-x86_64-20250716.tar.gz"

# 尝试多个可能的 Windows 路径
WINDOWS_PATHS=(
    "/mnt/c/Users/HP/Downloads"
    "/mnt/c/Users/HP/Desktop" 
    "/mnt/c/Users/HP/Documents"
    "/mnt/c/Users/HP"
    "/mnt/c/Users/Public/Desktop"
    "/mnt/c/Users/Public/Downloads"
    "/mnt/c/Users/Public/Documents"
    "/mnt/c/temp"
    "/mnt/c/tmp"
)

echo "源文件: $SOURCE_FILE"
echo "文件大小: $(du -h "$SOURCE_FILE" | cut -f1)"
echo ""

# 检查源文件是否存在
if [ ! -f "$SOURCE_FILE" ]; then
    echo "错误: 源文件不存在!"
    exit 1
fi

# 尝试每个路径
for path in "${WINDOWS_PATHS[@]}"; do
    echo "尝试复制到: $path"
    
    if [ -d "$path" ]; then
        if cp "$SOURCE_FILE" "$path/" 2>/dev/null; then
            echo "✅ 成功复制到: $path"
            echo "Windows 路径: $(echo "$path" | sed 's|/mnt/c|C:|')"
            echo ""
            echo "请在 Windows 文件资源管理器中查看:"
            echo "$(echo "$path" | sed 's|/mnt/c|C:|')"
            exit 0
        else
            echo "❌ 复制失败: 权限不足或路径不可写"
        fi
    else
        echo "❌ 路径不存在: $path"
    fi
    echo ""
done

echo "所有路径都失败了。让我们创建一个临时目录..."

# 创建临时目录
TEMP_DIR="/tmp/localsend_download"
mkdir -p "$TEMP_DIR"
cp "$SOURCE_FILE" "$TEMP_DIR/"

echo "✅ 文件已复制到临时目录: $TEMP_DIR"
echo "文件完整路径: $TEMP_DIR/localsend-kylin-x86_64-20250716.tar.gz"
echo ""
echo "请在 WSL 中运行以下命令来访问文件:"
echo "cd $TEMP_DIR"
echo "ls -la"
