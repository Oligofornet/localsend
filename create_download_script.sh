#!/bin/bash

echo "=== LocalSend 文件传输脚本 ==="

SOURCE_FILE="/mnt/persist/workspace/localsend-kylin-x86_64-20250716.tar.gz"
OUTPUT_DIR="/mnt/persist/workspace/download_package"

# 创建输出目录
mkdir -p "$OUTPUT_DIR"

# 复制主文件
cp "$SOURCE_FILE" "$OUTPUT_DIR/"

# 创建 Windows 批处理下载脚本
cat > "$OUTPUT_DIR/download_from_wsl.bat" << 'EOF'
@echo off
echo === LocalSend 文件下载脚本 ===
echo.

REM 检查 WSL 是否可用
wsl --version >nul 2>&1
if %errorlevel% neq 0 (
    echo 错误: WSL 未安装或不可用
    pause
    exit /b 1
)

echo 正在从编译环境下载文件...
echo.

REM 创建下载目录
if not exist "%USERPROFILE%\Downloads\LocalSend" (
    mkdir "%USERPROFILE%\Downloads\LocalSend"
)

REM 尝试通过网络下载
echo 方法 1: 尝试通过 HTTP 下载...
curl -L -o "%USERPROFILE%\Downloads\LocalSend\localsend-kylin-x86_64-20250716.tar.gz" "http://localhost:8080/localsend-kylin-x86_64-20250716.tar.gz" 2>nul
if %errorlevel% equ 0 (
    echo ✅ 下载成功！
    echo 文件位置: %USERPROFILE%\Downloads\LocalSend\
    goto :success
)

echo ❌ HTTP 下载失败，尝试其他方法...
echo.

REM 方法 2: 检查是否可以直接访问
echo 方法 2: 检查 WSL 文件系统...
dir "\\wsl$\Ubuntu\mnt\persist\workspace\localsend-kylin-*.tar.gz" >nul 2>&1
if %errorlevel% equ 0 (
    echo ✅ 找到文件，正在复制...
    copy "\\wsl$\Ubuntu\mnt\persist\workspace\localsend-kylin-x86_64-20250716.tar.gz" "%USERPROFILE%\Downloads\LocalSend\" >nul
    if %errorlevel% equ 0 (
        echo ✅ 复制成功！
        echo 文件位置: %USERPROFILE%\Downloads\LocalSend\
        goto :success
    )
)

echo ❌ 所有方法都失败了
echo.
echo 请尝试以下手动方法:
echo 1. 在浏览器中访问: http://localhost:8080
echo 2. 点击下载链接
echo 3. 或者联系技术支持
echo.

:success
echo.
echo === 下载完成 ===
echo 请将文件传输到麒麟系统进行安装
pause
EOF

# 创建 PowerShell 下载脚本
cat > "$OUTPUT_DIR/download_from_wsl.ps1" << 'EOF'
Write-Host "=== LocalSend PowerShell 下载脚本 ===" -ForegroundColor Green
Write-Host ""

# 创建下载目录
$downloadDir = "$env:USERPROFILE\Downloads\LocalSend"
if (!(Test-Path $downloadDir)) {
    New-Item -ItemType Directory -Path $downloadDir -Force | Out-Null
}

# 方法 1: HTTP 下载
Write-Host "方法 1: 尝试通过 HTTP 下载..." -ForegroundColor Yellow
try {
    $url = "http://localhost:8080/localsend-kylin-x86_64-20250716.tar.gz"
    $output = "$downloadDir\localsend-kylin-x86_64-20250716.tar.gz"
    
    Invoke-WebRequest -Uri $url -OutFile $output -ErrorAction Stop
    Write-Host "✅ 下载成功！" -ForegroundColor Green
    Write-Host "文件位置: $downloadDir" -ForegroundColor Cyan
    exit 0
} catch {
    Write-Host "❌ HTTP 下载失败: $($_.Exception.Message)" -ForegroundColor Red
}

# 方法 2: WSL 文件系统
Write-Host "方法 2: 检查 WSL 文件系统..." -ForegroundColor Yellow
$wslPath = "\\wsl$\Ubuntu\mnt\persist\workspace\localsend-kylin-x86_64-20250716.tar.gz"
if (Test-Path $wslPath) {
    try {
        Copy-Item $wslPath $downloadDir -ErrorAction Stop
        Write-Host "✅ 复制成功！" -ForegroundColor Green
        Write-Host "文件位置: $downloadDir" -ForegroundColor Cyan
        exit 0
    } catch {
        Write-Host "❌ 复制失败: $($_.Exception.Message)" -ForegroundColor Red
    }
}

Write-Host "❌ 所有方法都失败了" -ForegroundColor Red
Write-Host ""
Write-Host "请尝试以下手动方法:" -ForegroundColor Yellow
Write-Host "1. 在浏览器中访问: http://localhost:8080"
Write-Host "2. 点击下载链接"
Write-Host "3. 或者联系技术支持"

Read-Host "按回车键退出"
EOF

# 创建说明文件
cat > "$OUTPUT_DIR/README_DOWNLOAD.txt" << EOF
LocalSend for Kylin OS - 下载说明
================================

文件信息:
- 文件名: localsend-kylin-x86_64-20250716.tar.gz
- 大小: 22.6 MB
- 架构: x86_64
- 适用系统: 麒麟 OS (Kylin OS)

下载方法:

方法 1: 浏览器下载 (推荐)
1. 打开浏览器
2. 访问: http://localhost:8080
3. 点击下载链接

方法 2: Windows 批处理脚本
1. 双击运行: download_from_wsl.bat
2. 按照提示操作

方法 3: PowerShell 脚本
1. 右键点击 download_from_wsl.ps1
2. 选择 "使用 PowerShell 运行"

方法 4: 手动命令
在 Windows 命令提示符中运行:
curl -L -o localsend.tar.gz http://localhost:8080/localsend-kylin-x86_64-20250716.tar.gz

安装说明:
1. 将下载的文件传输到麒麟系统
2. 解压: tar -xzf localsend-kylin-x86_64-20250716.tar.gz
3. 安装: sudo ./install.sh
4. 或直接运行: ./localsend

技术支持:
如有问题，请访问: https://github.com/Oligofornet/localsend
EOF

echo "✅ 下载包已创建在: $OUTPUT_DIR"
echo ""
echo "包含文件:"
ls -la "$OUTPUT_DIR"
echo ""
echo "🌐 HTTP 服务器正在运行: http://localhost:8080"
echo "📁 下载脚本已准备就绪"
