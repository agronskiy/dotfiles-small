# Tmux Binaries

This directory contains pre-built tmux 3.5 binaries for different architectures:
- `tmux.linux-amd64.tar.gz` - for x86_64/amd64 systems
- `tmux.linux-aarch64.tar.gz` - for ARM64/aarch64 systems

## Building tmux for aarch64

To rebuild the aarch64 binary, use the provided build script. The build uses cross-compilation with musl toolchain to avoid QEMU emulation issues.

### Prerequisites

- Docker (for isolated build environment)
- Alpine Linux base image (automatically pulled)

### Build Commands

**Quick build (one-liner):**

```bash
mkdir -p /tmp/tmux-build && cd /tmp/tmux-build && \
cp /path/to/dotfiles-small/tmux/build-tmux-aarch64.sh . && \
docker run --rm --platform linux/amd64 \
  -v $(pwd):/tmp/tmux-build \
  -w /tmp/tmux-build \
  alpine:latest sh -c '
    apk add --no-cache build-base gcc musl-dev perl wget file bison pkgconf >/dev/null 2>&1 && \
    if [ ! -d aarch64-linux-musl-cross ]; then \
      wget -q https://musl.cc/aarch64-linux-musl-cross.tgz && \
      tar xzf aarch64-linux-musl-cross.tgz && \
      rm aarch64-linux-musl-cross.tgz; \
    fi && \
    export PATH=$PATH:$(pwd)/aarch64-linux-musl-cross/bin && \
    sh build-tmux-aarch64.sh
  ' && \
tar -czf tmux.linux-aarch64.tar.gz tmux.linux-aarch64 && \
cp tmux.linux-aarch64.tar.gz /path/to/dotfiles-small/tmux/
```

**Step-by-step:**

```bash
# 1. Create build directory
mkdir -p /tmp/tmux-build
cd /tmp/tmux-build

# 2. Copy build script
cp /path/to/dotfiles-small/tmux/build-tmux-aarch64.sh .

# 3. Run build in Docker container (takes 15-30 minutes)
docker run --rm --platform linux/amd64 \
  -v $(pwd):/tmp/tmux-build \
  -w /tmp/tmux-build \
  alpine:latest sh -c '
    apk add --no-cache build-base gcc musl-dev perl wget file bison pkgconf >/dev/null 2>&1 && \
    if [ ! -d aarch64-linux-musl-cross ]; then \
      wget -q https://musl.cc/aarch64-linux-musl-cross.tgz && \
      tar xzf aarch64-linux-musl-cross.tgz && \
      rm aarch64-linux-musl-cross.tgz; \
    fi && \
    export PATH=$PATH:$(pwd)/aarch64-linux-musl-cross/bin && \
    sh build-tmux-aarch64.sh
  '

# 4. Create archive
cd /tmp/tmux-build
tar -czf tmux.linux-aarch64.tar.gz tmux.linux-aarch64

# 5. Copy to dotfiles directory
cp tmux.linux-aarch64.tar.gz /path/to/dotfiles-small/tmux/
```

### Build Process

The build script (`build-tmux-aarch64.sh`) performs the following steps:

1. **Downloads musl cross-compiler** for aarch64 from musl.cc
2. **Builds OpenSSL 1.1.1w** statically (if not already built)
3. **Builds libevent 2.1.12** statically (if not already built)
4. **Builds ncurses 6.4** statically
5. **Builds tmux 3.5** statically linked against all dependencies

### Key Build Options

- **Single-threaded builds** (`make -j1`): Avoids QEMU emulation crashes and compiler ICEs
- **Static linking** (`-static`): Creates portable binaries with no external dependencies
- **Cross-compilation**: Uses `aarch64-linux-musl-gcc` instead of native compilation to avoid emulation issues
- **Verbose output** (`V=1`): Helps debug build issues

### Notes

- The build takes approximately 15-30 minutes depending on system resources
- All dependencies are built from source to ensure static linking
- The resulting binary is statically linked and should work on any Linux aarch64 system
- If build fails with compiler crashes, the script will retry with `-O0` optimization

### Troubleshooting

If the build fails:
1. Ensure Docker has enough memory allocated (recommended: 2GB+)
2. Check that the musl.cc toolchain downloaded successfully
3. Verify all source tarballs downloaded correctly
4. Try running with `-O0` optimization if compiler crashes occur
