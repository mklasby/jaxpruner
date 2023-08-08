FROM nvcr.io/nvidia/tensorflow:23.07-tf2-py3

ARG USERNAME=user
ARG WORKSPACE_DIR=/home/${USERNAME}/jaxpruner
ARG BUILD_DIR=/home/${USERNAME}/build
ARG VIRTUAL_ENV=${BUILD_DIR}/.venv
ARG USER_UID=1000003
ARG USER_GID=1000001
SHELL ["/bin/bash", "-c"]

# Create the user
RUN groupadd --gid $USER_GID ${USERNAME} \
    && useradd --uid $USER_UID --gid $USER_GID -m ${USERNAME}

# Install git/ssh/tmux
RUN apt-get update \
    && apt-get install -y git ssh tmux vim curl htop sudo \
    python3.10 python3.10-venv python3.10-dev python3.10-distutils

RUN echo ${USERNAME} ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/${USERNAME} \
    && chmod 0440 /etc/sudoers.d/${USERNAME}

USER ${USERNAME}

RUN mkdir ${BUILD_DIR}
WORKDIR ${BUILD_DIR}

COPY ./* ./
RUN python3 -m venv .venv && \
    source .venv/bin/activate && \
    pip3 install --upgrade pip && \
    pip3 install -r requirements.txt && \
    pip3 install --upgrade jax[cuda12_pip] -f https://storage.googleapis.com/jax-releases/jax_cuda_releases.html
RUN echo "source ${VIRTUAL_ENV}/bin/activate" >> /home/$USERNAME/.bashrc
ENV PATH="${VIRTUAL_ENV}/bin:${PATH}"
ENV VIRTUAL_ENV=${VIRTUAL_ENV}
WORKDIR ${WORKSPACE_DIR}
