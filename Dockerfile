FROM jupyter/scipy-notebook:latest

USER root

# Add NVIDIA repositories to apt-get [1].
#
# [1] https://gitlab.com/nvidia/cuda/blob/ubuntu18.04/10.0/base/Dockerfile
RUN apt-get update && apt-get install -y --no-install-recommends gnupg2 curl ca-certificates && \
    curl -fsSL https://developer.download.nvidia.com/compute/cuda/repos/ubuntu1804/x86_64/7fa2af80.pub | apt-key add - && \
    echo "deb https://developer.download.nvidia.com/compute/cuda/repos/ubuntu1804/x86_64 /" > /etc/apt/sources.list.d/cuda.list && \
    echo "deb https://developer.download.nvidia.com/compute/machine-learning/repos/ubuntu1804/x86_64 /" > /etc/apt/sources.list.d/nvidia-ml.list && \
    apt-get purge --autoremove -y curl && \
    rm -rf /var/lib/apt/lists/*
ENV CUDA_VERSION 10.2.89
ENV CUDA_COMPAT_VERSION cuda10.2
ENV CUDA_PKG_VERSION 10-2=$CUDA_VERSION-1
RUN wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu1804/x86_64/cuda-ubuntu1804.pin
RUN mv cuda-ubuntu1804.pin /etc/apt/preferences.d/cuda-repository-pin-600
RUN apt-get update && apt-get install -y --no-install-recommends \
        cuda \
        cuda-compat-10-2 && \
    rm -rf /var/lib/apt/lists/*
RUN echo "/usr/local/nvidia/lib" >> /etc/ld.so.conf.d/nvidia.conf && \
    echo "/usr/local/nvidia/lib64" >> /etc/ld.so.conf.d/nvidia.conf
ENV PATH /usr/local/nvidia/bin:/usr/local/cuda/bin:${PATH}
ENV LD_LIBRARY_PATH /usr/local/nvidia/lib:/usr/local/nvidia/lib64
ENV NVIDIA_VISIBLE_DEVICES all
ENV NVIDIA_DRIVER_CAPABILITIES compute,utility
ENV NVIDIA_REQUIRE_CUDA "cuda>=10.2 brand=tesla,driver>=384,driver<385 brand=tesla,driver>=410,driver<411"

# Install TensorFlow dependencies [1], [2].
#
# [1] https://www.tensorflow.org/install/gpu#ubuntu_1804_cuda_10
# [2] https://github.com/tensorflow/tensorflow/blob/r2.0/tensorflow/tools/dockerfiles/dockerfiles/gpu.Dockerfile
RUN apt-get update && apt-get install -y --no-install-recommends \
        cuda \
        libcudnn7=7.6.5.32-1+${CUDA_COMPAT_VERSION} \
        libcudnn7-dev=7.6.5.32-1+${CUDA_COMPAT_VERSION}
RUN apt-get update && apt-get install -y --no-install-recommends \
        libnvinfer7=7.0.0-1+${CUDA_COMPAT_VERSION} \
        libnvinfer-dev=7.0.0-1+${CUDA_COMPAT_VERSION}

RUN conda install -y cudatoolkit
RUN apt-get update && apt-get install -y --no-install-recommends \
	rcs subversion
RUN pip install jupytext --upgrade
RUN jupyter notebook --generate-config -y

COPY addl_config.py /
RUN cat /addl_config.py >> ~/.jupyter/jupyter_notebook_config.py
RUN cat ~/.jupyter/jupyter_notebook_config.py
RUN pip install -U memory_profiler
RUN pip install -U Xlwt Openpyxl xlsxwriter
USER $NB_USER
