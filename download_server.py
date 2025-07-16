#!/usr/bin/env python3
"""
Simple HTTP download server for LocalSend
"""

import http.server
import socketserver
import os
import sys
from urllib.parse import unquote

class DownloadHandler(http.server.SimpleHTTPRequestHandler):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, directory="/mnt/persist/workspace", **kwargs)
    
    def do_GET(self):
        if self.path == '/':
            self.send_response(200)
            self.send_header('Content-type', 'text/html; charset=utf-8')
            self.end_headers()
            
            html = """
            <!DOCTYPE html>
            <html>
            <head>
                <title>LocalSend 下载</title>
                <meta charset="utf-8">
                <style>
                    body { font-family: Arial, sans-serif; margin: 40px; }
                    .container { max-width: 800px; margin: 0 auto; }
                    .file-item { 
                        background: #f5f5f5; 
                        padding: 20px; 
                        margin: 10px 0; 
                        border-radius: 5px;
                        border: 1px solid #ddd;
                    }
                    .download-btn {
                        background: #4CAF50;
                        color: white;
                        padding: 10px 20px;
                        text-decoration: none;
                        border-radius: 5px;
                        display: inline-block;
                        margin-top: 10px;
                    }
                    .download-btn:hover { background: #45a049; }
                    .info { color: #666; font-size: 14px; }
                </style>
            </head>
            <body>
                <div class="container">
                    <h1>🚀 LocalSend for Kylin OS 下载</h1>
                    <p>编译完成的 LocalSend 应用程序，专为麒麟系统优化。</p>
                    
                    <div class="file-item">
                        <h3>📦 LocalSend 可执行文件</h3>
                        <p><strong>文件名:</strong> localsend-kylin-x86_64-20250716.tar.gz</p>
                        <p><strong>大小:</strong> 22.6 MB</p>
                        <p><strong>架构:</strong> x86_64</p>
                        <p><strong>适用系统:</strong> 麒麟 OS (Kylin OS)</p>
                        <div class="info">
                            <p>✅ 包含所有依赖库</p>
                            <p>✅ 可独立运行</p>
                            <p>✅ 包含安装脚本</p>
                            <p>✅ 支持桌面集成</p>
                        </div>
                        <a href="/localsend-kylin-x86_64-20250716.tar.gz" class="download-btn">
                            📥 点击下载 LocalSend
                        </a>
                    </div>
                    
                    <div class="file-item">
                        <h3>📋 安装说明</h3>
                        <ol>
                            <li>下载完成后，将文件传输到麒麟系统</li>
                            <li>解压文件: <code>tar -xzf localsend-kylin-x86_64-20250716.tar.gz</code></li>
                            <li>进入目录: <code>cd localsend-kylin-x86_64-20250716/</code></li>
                            <li>安装: <code>sudo ./install.sh</code> 或直接运行: <code>./localsend</code></li>
                        </ol>
                    </div>
                    
                    <div class="file-item">
                        <h3>ℹ️ 技术信息</h3>
                        <p><strong>编译时间:</strong> 2025年7月16日</p>
                        <p><strong>Flutter 版本:</strong> 3.24.5</p>
                        <p><strong>Rust 版本:</strong> 1.88.0</p>
                        <p><strong>构建类型:</strong> Release (生产优化)</p>
                    </div>
                </div>
            </body>
            </html>
            """
            self.wfile.write(html.encode('utf-8'))
        else:
            super().do_GET()

def main():
    PORT = 8080
    
    print(f"🌐 启动 LocalSend 下载服务器...")
    print(f"📡 端口: {PORT}")
    print(f"📁 文件目录: /mnt/persist/workspace")
    print(f"🔗 访问地址: http://localhost:{PORT}")
    print(f"📥 直接下载: http://localhost:{PORT}/localsend-kylin-x86_64-20250716.tar.gz")
    print(f"⏹️  按 Ctrl+C 停止服务器")
    print("-" * 60)
    
    try:
        with socketserver.TCPServer(("", PORT), DownloadHandler) as httpd:
            httpd.serve_forever()
    except KeyboardInterrupt:
        print("\n🛑 服务器已停止")
    except Exception as e:
        print(f"❌ 服务器错误: {e}")

if __name__ == "__main__":
    main()
