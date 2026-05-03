FROM nvidia/cuda:12.1.1-cudnn8-devel-ubuntu22.04

ARG VENV_NAME="cosyvoice"
ENV VENV=$VENV_NAME
ENV LANG=C.UTF-8 LC_ALL=C.UTF-8

ENV DEBIAN_FRONTEND=noninteractive
ENV PYTHONUNBUFFERED=1
SHELL ["/bin/bash", "--login", "-c"]

RUN apt-get update -y --fix-missing
RUN apt-get install -y git build-essential curl wget ffmpeg unzip git git-lfs sox libsox-dev && \
    apt-get clean && \
    git lfs install

# ==================================================================
# conda install and conda forge channel as default
# ------------------------------------------------------------------
# Install miniforge
RUN wget --quiet https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-Linux-x86_64.sh -O ~/miniforge.sh && \
    /bin/bash ~/miniforge.sh -b -p /opt/conda && \
    rm ~/miniforge.sh && \
    ln -s /opt/conda/etc/profile.d/conda.sh /etc/profile.d/conda.sh && \
    echo "source /opt/conda/etc/profile.d/conda.sh" >> /opt/nvidia/entrypoint.d/100.conda.sh && \
    echo "source /opt/conda/etc/profile.d/conda.sh" >> ~/.bashrc && \
    echo "conda activate ${VENV}" >> /opt/nvidia/entrypoint.d/110.conda_default_env.sh && \
    echo "conda activate ${VENV}" >> $HOME/.bashrc

ENV PATH=/opt/conda/bin:$PATH

RUN conda config --add channels conda-forge && \
    conda config --set channel_priority strict
# ------------------------------------------------------------------
# ~conda
# ==================================================================

# 关键修复 1：在这里明确要求安装 pip
RUN conda create -y -n ${VENV} python=3.10 pip
ENV CONDA_DEFAULT_ENV=${VENV}

# 将虚拟环境路径放在最前面，确保后续命令默认调用 Python 3.10 的组件
ENV PATH=/opt/conda/envs/${VENV}/bin:/opt/conda/bin:$PATH

WORKDIR /workspace

# 关键修复 2：直接使用绝对路径定义，彻底消除未定义变量的警告
ENV PYTHONPATH=/workspace/CosyVoice:/workspace/CosyVoice/third_party/Matcha-TTS

RUN git clone --recursive https://github.com/FunAudioLLM/CosyVoice.git

RUN conda activate ${VENV} && conda install -y -c conda-forge pynini==2.1.5

# 使用绝对路径强制调用指定虚拟环境的 python 和 pip，并锁定 setuptools 版本
RUN cd CosyVoice && \
    /opt/conda/envs/${VENV}/bin/python -m pip install --upgrade pip "setuptools<70.0.0" wheel && \
    /opt/conda/envs/${VENV}/bin/pip install openai-whisper==20231117 --no-build-isolation && \
    /opt/conda/envs/${VENV}/bin/pip install -r requirements.txt --no-cache-dir

WORKDIR /workspace/CosyVoice