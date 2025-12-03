#!/bin/sh
set -e

# Continue build - rebuild OpenSSL if needed, then build ncurses and tmux
# Using single-threaded builds to avoid QEMU emulation issues

cd /tmp/tmux-build

# Set up cross-compiler path
export PATH=$PATH:$(pwd)/aarch64-linux-musl-cross/bin

# Rebuild OpenSSL if libraries don't exist
if [ ! -f /tmp/libs/lib/libssl.a ] || [ ! -f /tmp/libs/lib/libcrypto.a ]; then
    echo "Building OpenSSL..."
    if [ -d openssl-1.1.1w ]; then
        cd openssl-1.1.1w
        make install_sw
        cd ..
    else
        wget -q https://www.openssl.org/source/openssl-1.1.1w.tar.gz
        tar xzf openssl-1.1.1w.tar.gz
        cd openssl-1.1.1w
        CC=aarch64-linux-musl-gcc ./Configure linux-aarch64 --prefix=/tmp/libs --openssldir=/tmp/libs no-shared
        make -j1
        make install_sw
        cd ..
    fi
fi

# Build libevent statically if needed
if [ ! -f /tmp/libs/lib/libevent.a ]; then
    echo "Building libevent..."
    wget -q https://github.com/libevent/libevent/releases/download/release-2.1.12-stable/libevent-2.1.12-stable.tar.gz
    tar xzf libevent-2.1.12-stable.tar.gz
    cd libevent-2.1.12-stable
    CC=aarch64-linux-musl-gcc \
    PKG_CONFIG_PATH=/tmp/libs/lib/pkgconfig \
    ./configure --host=aarch64-linux-musl --prefix=/tmp/libs --enable-static --disable-shared \
        CFLAGS="-I/tmp/libs/include" LDFLAGS="-L/tmp/libs/lib"
    make -j1
    make install
    cd ..
    rm -rf libevent-2.1.12-stable libevent-2.1.12-stable.tar.gz
fi

# Build ncurses statically (single-threaded)
# Include terminfo database so tmux can find terminal capabilities
echo "Building ncurses with terminfo database..."
wget -q https://invisible-mirror.net/archives/ncurses/ncurses-6.4.tar.gz
tar xzf ncurses-6.4.tar.gz
cd ncurses-6.4
CC=aarch64-linux-musl-gcc \
STRIP=aarch64-linux-musl-strip \
./configure --host=aarch64-linux-musl --prefix=/tmp/libs --enable-static --disable-shared --without-shared \
CFLAGS="-I/tmp/libs/include" LDFLAGS="-L/tmp/libs/lib"
make -j1 V=1 2>&1 | tail -20 || {
    echo "Build failed, trying with -O0..."
    make clean
    CC=aarch64-linux-musl-gcc \
    STRIP=aarch64-linux-musl-strip \
    CFLAGS="-O0 -I/tmp/libs/include" LDFLAGS="-L/tmp/libs/lib" \
    ./configure --host=aarch64-linux-musl --prefix=/tmp/libs --enable-static --disable-shared --without-shared
    make -j1 V=1
}
# Install libraries and includes only
# Note: We skip terminfo database installation because:
# 1. Cross-compiled tic can't run on host
# 2. TERMINFO env var points to system terminfo locations (set in path.rc.post.bash)
make install.libs install.includes || {
    (cd ncurses && make install) && \
    (cd include && make install)
}
cd ..
rm -rf ncurses-6.4 ncurses-6.4.tar.gz

# Build tmux
echo "Building tmux..."
wget -q https://github.com/tmux/tmux/releases/download/3.5/tmux-3.5.tar.gz
tar xzf tmux-3.5.tar.gz
cd tmux-3.5

export PKG_CONFIG_PATH=/tmp/libs/lib/pkgconfig

# Check if pkg-config exists, if not we'll configure manually
if command -v aarch64-linux-musl-pkg-config >/dev/null 2>&1; then
    aarch64-linux-musl-pkg-config --exists openssl || {
        echo "Warning: pkg-config cannot find OpenSSL, but continuing..."
    }
else
    echo "pkg-config not found in toolchain, configuring manually..."
    # Verify OpenSSL files exist
    [ -f /tmp/libs/lib/libssl.a ] && [ -f /tmp/libs/lib/libcrypto.a ] && [ -f /tmp/libs/include/openssl/ssl.h ] || {
        echo "Error: OpenSSL libraries/headers not found"
        exit 1
    }
fi

# Configure tmux with explicit include paths and terminfo database path
CC=aarch64-linux-musl-gcc \
CFLAGS="-static -O2 -I/tmp/libs/include -I/tmp/libs/include/ncurses" \
LDFLAGS="-static -L/tmp/libs/lib -lncurses -levent -lssl -lcrypto" \
TERMINFO=/tmp/libs/share/terminfo \
./configure --host=aarch64-linux-musl --prefix=/tmp/install

# Build with verbose output and single-threaded
echo "Compiling tmux (this may take a while)..."
make -j1 V=1 2>&1 | grep -E "(gcc|error|Error|warning)" | tail -30 || {
    echo "Build failed, trying with -O0..."
    make clean
    CC=aarch64-linux-musl-gcc \
    CFLAGS="-static -O0 -I/tmp/libs/include" \
    LDFLAGS="-static -L/tmp/libs/lib" \
    ./configure --host=aarch64-linux-musl --prefix=/tmp/install
    make -j1 V=1
}

make install

# Copy and verify
cp /tmp/install/bin/tmux /tmp/tmux-build/tmux.linux-aarch64
chmod +x /tmp/tmux-build/tmux.linux-aarch64
file /tmp/tmux-build/tmux.linux-aarch64
ls -lh /tmp/tmux-build/tmux.linux-aarch64
echo "Build complete!"
