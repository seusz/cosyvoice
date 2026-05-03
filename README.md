CosyVoice Docker 高性能部署指南
本仓库提供了一个基于 Docker 的 CosyVoice 语音合成系统部署方案。该方案针对 NVIDIA GPU（支持 P104/P106 等 Pascal 架构及更新架构）进行了深度优化，解决了 CUDA 驱动匹配、Python 依赖编译冲突等常见问题。

🚀 核心特性
镜像版本：基于 CUDA 12.1.1 开发版镜像，兼容性极佳。

环境隔离：使用 Conda (Miniforge) 构建 Python 3.10 独立环境。

稳定编译：解决了 openai-whisper 等包在安装时缺失 pkg_resources 的顽固报错。

即插即用：集成 Docker Compose，一键启动 WebUI 面板。

🛠️ 前置要求
宿主机系统：Linux (建议 Ubuntu 22.04+)

硬件：NVIDIA 显卡（建议显存 >= 8GB）

驱动：已安装 NVIDIA Driver (版本 >= 530)

工具：已安装 Docker、Docker Compose 以及 NVIDIA Container Toolkit

📂 目录结构
建议按照以下结构存放文件：

Plaintext
CosyVoice-Docker/
├── Dockerfile              # 镜像构建文件
├── docker-compose.yml      # 容器编排文件
├── pretrained_models/      # (自动生成) 模型存放目录
└── output/                 # (自动生成) 音频输出目录
📦 部署步骤
1. 构建镜像
在当前目录下运行命令开始构建。由于涉及底层编译，首次构建可能需要 10-20 分钟：

Bash
docker build -t cosyvoice:latest .
2. 配置与启动
确保 docker-compose.yml 已配置好 GRADIO_SERVER_NAME=0.0.0.0 和正确的 model_dir。

一键启动：

Bash
docker compose up -d
3. 查看日志
模型首次启动会自动下载（约数 GB），可以通过日志查看进度：

Bash
docker logs -f cosyvoice_node
🖥️ 访问方式
当日志显示 Running on local URL: http://0.0.0.0:50000 时，通过浏览器访问：

本地访问：http://localhost:50000

局域网访问：http://服务器IP:50000

❓ 常见问题排查 (Troubleshooting)
Q: 为什么构建时报错 No module named 'pkg_resources'？
A: 这是因为最新版 setuptools 删除了该模块。本项目的 Dockerfile 已通过锁定 setuptools<70.0.0 并使用 --no-build-isolation 参数解决了此问题。

Q: 为什么启动后报 404 找不到模型？
A: 默认的 model_dir 参数必须指向 ModelScope 的完整 ID。请确保启动命令中包含 --model_dir iic/CosyVoice2-0.5B。

Q: 显卡无法被识别？
A: 请检查宿主机是否安装了 nvidia-container-toolkit，并确保 docker-compose.yml 中包含 deploy.resources.reservations.devices 配置。

🔗 相关资源
CosyVoice 官方项目地址

ModelScope 模型库

💡 维护建议：
备份模型：模型下载在 ~/.cache/modelscope 和当前目录的 pretrained_models 中，建议不要轻易删除这些挂载目录。

显存管理：如果遇到显存溢出（OOM），可以在 docker-compose.yml 中尝试指定单张显卡，或在 WebUI 中降低推理的长句分段长度。
