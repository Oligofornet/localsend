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
