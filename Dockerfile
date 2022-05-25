FROM mcr.microsoft.com/vscode/devcontainers/base:ubuntu-20.04

ARG USERNAME=vscode

SHELL ["/bin/bash", "-oeux", "pipefail", "-c"]

# install development tools
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        acpica-tools \
        build-essential \
        lld-7 \
        clang-7 \
        dosfstools \
        git \
        nasm \
        qemu-system-gui \
        qemu-system-x86 \
        qemu-utils \
        xauth \
        unzip \
        uuid-dev \
    && apt-get clean -y \
    && rm -rf /var/lib/apt/lists

USER ${USERNAME}
WORKDIR /home/${USERNAME}

# clone mikanos devenv
RUN git clone https://github.com/uchan-nos/mikanos-build.git osbook \
    && curl -L https://github.com/uchan-nos/mikanos-build/releases/download/v2.0/x86_64-elf.tar.gz | tar xzvf - -C osbook/devenv

RUN curl https://sh.rustup.rs -sSf | sh -s -- --default-toolchain nightly -y

ENV CARGO_MAKE_VERSION='0.35.12'
ENV CARGO_MAKE_BIN="cargo-make-v${CARGO_MAKE_VERSION}-x86_64-unknown-linux-musl"
ENV CARGO_MAKE_ZIP="${CARGO_MAKE_BIN}.zip"

RUN wget -q "https://github.com/sagiegurari/cargo-make/releases/download/${CARGO_MAKE_VERSION}/${CARGO_MAKE_ZIP}" \
    && unzip "${CARGO_MAKE_ZIP}" \
    && mkdir -p "${HOME}/.local/bin" \
    && cp ${CARGO_MAKE_BIN}/{cargo-make,makers} "${HOME}/.local/bin" \
    && rm -rf "${CARGO_MAKE_BIN}" \
    && rm -f "${CARGO_MAKE_ZIP}"

ENV PATH="/home/${USERNAME}/.cargo/bin:/home/${USERNAME}/osbook/devenv:${PATH}"

# set X11 server address
ENV DISPLAY=host.docker.internal:0

# override startup command, taken from VSCode Devcontainer logs
CMD ["/bin/sh", "-c", "echo Container started ; trap \"exit 0\" 15; while sleep 1 & wait $!; do :; done"]
