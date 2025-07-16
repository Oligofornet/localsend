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
