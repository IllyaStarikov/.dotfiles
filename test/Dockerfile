# Dockerfile for consistent test environment
FROM ubuntu:22.04

# Avoid prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

# Install system dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    cmake \
    curl \
    fd-find \
    fzf \
    gettext \
    git \
    libtool-bin \
    locales \
    ninja-build \
    pkg-config \
    python3 \
    python3-pip \
    ripgrep \
    software-properties-common \
    tmux \
    unzip \
    wget \
    zsh \
    && rm -rf /var/lib/apt/lists/*

# Set locale
RUN locale-gen en_US.UTF-8
ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en
ENV LC_ALL=en_US.UTF-8

# Install Neovim from source (for latest version)
RUN git clone https://github.com/neovim/neovim.git /tmp/neovim && \
    cd /tmp/neovim && \
    git checkout stable && \
    make CMAKE_BUILD_TYPE=Release && \
    make install && \
    rm -rf /tmp/neovim

# Install language servers
RUN pip3 install --no-cache-dir \
    pyright \
    neovim \
    pynvim

# Install lua-language-server
RUN mkdir -p /opt/lua-language-server && \
    cd /opt/lua-language-server && \
    wget https://github.com/LuaLS/lua-language-server/releases/latest/download/lua-language-server-linux-x64.tar.gz && \
    tar -xzf lua-language-server-linux-x64.tar.gz && \
    rm lua-language-server-linux-x64.tar.gz && \
    ln -s /opt/lua-language-server/bin/lua-language-server /usr/local/bin/

# Install Node.js for TypeScript LSP
RUN curl -fsSL https://deb.nodesource.com/setup_lts.x | bash - && \
    apt-get install -y nodejs && \
    npm install -g typescript typescript-language-server

# Create test user
RUN useradd -m -s /bin/zsh testuser
USER testuser
WORKDIR /home/testuser

# Copy dotfiles
COPY --chown=testuser:testuser . /home/testuser/dotfiles

# Set up environment
ENV DOTFILES_DIR=/home/testuser/dotfiles
ENV HOME=/home/testuser

# Entry point
ENTRYPOINT ["/bin/zsh"]