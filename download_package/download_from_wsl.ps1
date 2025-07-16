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
