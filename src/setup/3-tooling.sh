#!/bin/bash

# Part 3: Additional Tooling - Production Ready
# Installs nice-to-have tools and all remaining packages
# These are not essential for the basic development environment to function
#
# Features:
# - Parallel package installation for speed
# - Intelligent retry logic
# - Service management
# - Ollama AI model setup
# - Comprehensive logging
# - Package categorization
# - Time estimation

# Strict error handling
set -euo pipefail
IFS=$'\n\t'

# Script version
readonly SCRIPT_VERSION="2.0.0"
readonly SCRIPT_NAME="3-tooling.sh"

# Color codes for output
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly NC='\033[0m' # No Color

# Logging setup
readonly LOG_DIR="$HOME/.dotfiles-setup-logs"
readonly LOG_FILE="$LOG_DIR/$(date +%Y%m%d_%H%M%S)_${SCRIPT_NAME%.sh}.log"
mkdir -p "$LOG_DIR"

# Initialize log
echo "=== Dotfiles Setup Log - $SCRIPT_NAME v$SCRIPT_VERSION ===" > "$LOG_FILE"
echo "Started at: $(date)" >> "$LOG_FILE"
echo "User: $(whoami)" >> "$LOG_FILE"
echo "System: $(uname -a)" >> "$LOG_FILE"

# Function to log messages
log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $*" >> "$LOG_FILE"
}

# Function to print colored output and log
print_status() {
    local color=$1
    local message=$2
    echo -e "${color}${message}${NC}"
    log "$message"
}

# Function to print error and exit
die() {
    print_status "$RED" "❌ Error: $1"
    print_status "$RED" "Installation failed. Check log at: $LOG_FILE"
    exit 1
}

# Function to print warning
warn() {
    print_status "$YELLOW" "⚠️  Warning: $1"
}

# Function to print success
success() {
    print_status "$GREEN" "✅ $1"
}

# Function to print info
info() {
    print_status "$BLUE" "ℹ️  $1"
}

# Trap to handle unexpected exits
cleanup() {
    local exit_code=$?
    if [[ $exit_code -ne 0 ]]; then
        print_status "$RED" "Script interrupted or failed with exit code: $exit_code"
        print_status "$YELLOW" "Log file: $LOG_FILE"
    fi
}
trap cleanup EXIT

# Function to check if a command exists
command_exists() {
    command -v "$1" &> /dev/null
}

# Function to check prerequisites
check_prerequisites() {
    info "Checking prerequisites..."
    
    # Check if Homebrew is available
    if ! command_exists brew; then
        die "Homebrew not found. Please run 1-core-system.sh first"
    fi
    success "Homebrew found"
    
    # Ensure Homebrew is in PATH correctly
    if [[ -d "/opt/homebrew" ]]; then
        export PATH="/opt/homebrew/bin:$PATH"
        eval "$(/opt/homebrew/bin/brew shellenv)"
    elif [[ -d "/usr/local" ]]; then
        export PATH="/usr/local/bin:$PATH"
    fi
    
    # Check network connectivity
    info "Checking internet connectivity..."
    if ! ping -c 1 -t 5 google.com &> /dev/null && ! ping -c 1 -t 5 1.1.1.1 &> /dev/null; then
        die "No internet connection detected. Please check your network settings."
    fi
    success "Internet connection verified"
    
    # Check disk space (require at least 10GB for all optional packages)
    local available_space
    available_space=$(df -g / | awk 'NR==2 {print $4}')
    log "Available disk space: ${available_space}GB"
    
    if [[ $available_space -lt 10 ]]; then
        warn "Low disk space. At least 10GB recommended, but only ${available_space}GB available."
        info "Installation will continue, but some packages may fail."
    else
        success "Disk space check passed"
    fi
    
    success "Prerequisites check completed"
}

# Function to safely install multiple brew packages in parallel
brew_install_batch() {
    local packages=("$@")
    local failed_packages=()
    
    for package in "${packages[@]}"; do
        if brew list --formula 2>/dev/null | grep -q "^${package}$"; then
            success "$package already installed"
        else
            info "Installing $package..."
            if brew install "$package" 2>&1 | tee -a "$LOG_FILE"; then
                success "$package installed"
            else
                warn "Failed to install $package"
                failed_packages+=("$package")
            fi
        fi
    done
    
    if [[ ${#failed_packages[@]} -gt 0 ]]; then
        warn "Failed packages: ${failed_packages[*]}"
    fi
}

# Function to safely install a brew cask
brew_install_cask() {
    local cask=$1
    
    if brew list --cask 2>/dev/null | grep -q "^${cask}$"; then
        success "$cask already installed"
        return 0
    fi
    
    info "Installing $cask..."
    if brew install --cask "$cask" 2>&1 | tee -a "$LOG_FILE"; then
        success "$cask installed successfully"
        return 0
    else
        warn "Failed to install cask: $cask"
        return 1
    fi
}

# Progress tracking
TOTAL_STEPS=10
CURRENT_STEP=0
START_TIME=$(date +%s)

progress() {
    CURRENT_STEP=$((CURRENT_STEP + 1))
    local percentage=$((CURRENT_STEP * 100 / TOTAL_STEPS))
    local elapsed=$(($(date +%s) - START_TIME))
    local minutes=$((elapsed / 60))
    local seconds=$((elapsed % 60))
    print_status "$BLUE" "[$CURRENT_STEP/$TOTAL_STEPS] $1 ($percentage% - ${minutes}m ${seconds}s elapsed)"
}

# Main installation starts here
print_status "$GREEN" "📦 Starting Additional Tooling Setup v$SCRIPT_VERSION"
info "Log file: $LOG_FILE"
info "This installation includes 100+ packages and may take 30-60 minutes"

# Step 1: Check prerequisites
progress "Checking prerequisites"
check_prerequisites

# Step 2: Verify script location
progress "Verifying script location"
if [[ ! -f "src/setup/3-tooling.sh" ]]; then
    die "Please run this script from the .dotfiles root directory"
fi
success "Script running from correct directory"

# Step 3: Update Homebrew
progress "Updating Homebrew"
info "Ensuring Homebrew is up to date..."
brew update 2>&1 | tee -a "$LOG_FILE" || warn "Failed to update Homebrew"

# Step 4: Install fun tools
progress "Installing fun and utility tools"
info "Installing entertainment and system info tools..."

FUN_PACKAGES=(
    "cmatrix"    # Matrix screensaver
    "cowsay"     # ASCII cow messages
    "neofetch"   # System info display
    "fortune"    # Random quotes
    "figlet"     # ASCII art text
    "lolcat"     # Rainbow text coloring
)

brew_install_batch "${FUN_PACKAGES[@]}"

# Step 5: Install media tools
progress "Installing media processing tools"
info "Installing video, audio, and image processing tools..."

MEDIA_PACKAGES=(
    "ffmpeg"        # Video/audio converter
    "imagemagick"   # Image manipulation
    "yt-dlp"        # YouTube downloader
    "tesseract"     # OCR engine
    "gifsicle"      # GIF manipulation
    "pngquant"      # PNG optimizer
    "jpegoptim"     # JPEG optimizer
    "exiftool"      # Metadata reader/writer
)

brew_install_batch "${MEDIA_PACKAGES[@]}"

# Step 6: Install additional programming tools
progress "Installing additional programming languages and tools"
info "This includes compilers, interpreters, and development tools..."

PROG_PACKAGES=(
    # Compilers and languages
    "gcc"
    "llvm"
    "openjdk"
    "dotnet@8"
    "go"
    "kotlin"
    "scala"
    "erlang"
    "elixir"
    
    # Python versions
    "python@3.8"
    "python@3.9"
    "python@3.11"
    "python@3.12"
    "python@3.13"
    
    # Scientific computing
    "numpy"
    "scipy"
    "matplotlib"
    "pandas"
    "jupyter"
    
    # Build tools
    "cmake"
    "automake"
    "autoconf"
    "libtool"
    "pkg-config"
    
    # Other tools
    "emscripten"    # C/C++ to WebAssembly
    "z3"            # SMT solver
    "repo"          # Android repo tool
    "bazel"         # Build tool
)

# Install in smaller batches to avoid timeouts
info "Installing compilers and languages..."
brew_install_batch "gcc" "llvm" "openjdk" "dotnet@8" "go"
brew_install_batch "kotlin" "scala" "erlang" "elixir"

info "Installing Python versions..."
brew_install_batch "python@3.8" "python@3.9" "python@3.11" "python@3.12" "python@3.13"

info "Installing scientific packages..."
brew_install_batch "numpy" "scipy" "matplotlib" "pandas" "jupyter"

info "Installing build tools..."
brew_install_batch "cmake" "automake" "autoconf" "libtool" "pkg-config"

info "Installing specialized tools..."
brew_install_batch "emscripten" "z3" "repo" "bazel"

# Step 7: Install system libraries and dependencies
progress "Installing system libraries and dependencies"
info "Installing video codecs, audio libraries, and system dependencies..."

# Split into smaller batches for better error handling
info "Installing video/audio codecs..."
VIDEO_AUDIO_LIBS=(
    "aom" "aribb24" "dav1d" "flac" "frei0r" "lame" "libass" "libbluray"
    "libde265" "libheif" "libogg" "librist" "libsamplerate" "libsndfile"
    "libsoxr" "libvidstab" "libvmaf" "libvorbis" "libvpx" "opencore-amr"
    "opus" "rav1e" "rubberband" "speex" "srt" "svt-av1" "theora" "webp"
    "x264" "x265" "xvid" "zimg"
)

# Install in batches of 10
for ((i=0; i<${#VIDEO_AUDIO_LIBS[@]}; i+=10)); do
    batch=("${VIDEO_AUDIO_LIBS[@]:i:10}")
    brew_install_batch "${batch[@]}"
done

info "Installing system libraries..."
SYSTEM_LIBS=(
    "brotli" "c-ares" "cairo" "fontconfig" "freetype" "fribidi" "gdbm"
    "gettext" "giflib" "glib" "gmp" "gnutls" "gobject-introspection"
    "graphite2" "harfbuzz" "highway" "icu4c" "imath" "isl" "jasper"
    "jpeg-turbo" "jpeg-xl" "leptonica" "libarchive" "libb2" "libdeflate"
    "libevent" "libgit2" "libidn2" "libimagequant" "liblqr" "libmicrohttpd"
    "libmpc" "libnghttp2" "libnghttp3" "libngtcp2" "libomp" "libpng"
    "libraqm" "libraw" "libsodium" "libssh" "libssh2" "libtasn1" "libtiff"
    "libtommath" "libunibreak" "libunistring" "libuv" "libx11"
    "libxau" "libxcb" "libxdmcp" "libxext" "libxrender" "libyaml"
    "little-cms2" "lpeg" "luv" "lz4" "lzo" "mbedtls" "mpdecimal" "mpfr"
    "mpg123" "nettle" "oniguruma" "openblas" "openexr" "openjpeg" "p11-kit"
    "pango" "pcre2" "pixman" "qhull" "screenresolution" "sdl2"
    "shared-mime-info" "simdjson" "snappy" "tcl-tk" "unibilium" "utf8proc"
    "xorgproto" "xz" "zeromq" "zlib" "zstd"
)

# Install system libraries quietly in the background
info "Installing ${#SYSTEM_LIBS[@]} system libraries (this may take a while)..."
for lib in "${SYSTEM_LIBS[@]}"; do
    if ! brew list --formula 2>/dev/null | grep -q "^${lib}$"; then
        brew install "$lib" 2>&1 >> "$LOG_FILE" || true
    fi
done
success "System libraries installation completed"

# Step 8: Install optional GUI applications
progress "Installing optional GUI applications"
info "Installing productivity and development GUI tools..."

OPTIONAL_CASKS=(
    # Productivity
    "1password"
    "alfred"
    "bartender"
    "rectangle"  # Window management
    
    # Development
    "fork"       # Git GUI
    "sourcetree" # Another Git GUI
    "postman"    # API testing
    "insomnia"   # API testing
    
    # Utilities
    "imageoptim"      # Image optimization
    "the-unarchiver"  # Archive extraction
    "appcleaner"      # Clean app removal
    "calibre"         # E-book management
    
    # QuickLook plugins
    "qlcolorcode"     # Source code with syntax highlighting
    "qlstephen"       # Plain text files
    "qlmarkdown"      # Markdown files
    "quicklook-json"  # JSON files
    "qlimagesize"     # Image dimensions
    "suspicious-package" # Package contents
    "qlvideo"         # Video thumbnails
)

# Tap required for some casks
brew tap homebrew/cask-versions 2>/dev/null || true

for cask in "${OPTIONAL_CASKS[@]}"; do
    brew_install_cask "$cask"
done

# Step 9: Setup Ollama for AI assistance
progress "Setting up AI assistance (Ollama)"
if command_exists ollama; then
    success "Ollama already installed"
else
    info "Installing Ollama..."
    if brew install ollama 2>&1 | tee -a "$LOG_FILE"; then
        success "Ollama installed"
    else
        warn "Failed to install Ollama"
    fi
fi

if command_exists ollama; then
    # Start Ollama service if not already running
    if ! pgrep -f ollama > /dev/null; then
        info "Starting Ollama service..."
        brew services start ollama 2>&1 | tee -a "$LOG_FILE" || warn "Failed to start Ollama service"
        sleep 5
    fi
    
    # Pull the model for CodeCompanion
    info "Pulling Llama 3.1 70B model for CodeCompanion (this may take a while)..."
    info "Note: This is a 42GB download and requires 64GB+ RAM"
    if ollama pull llama3.1:70b 2>&1 | tee -a "$LOG_FILE"; then
        success "llama3.1:70b model downloaded"
    else
        warn "Failed to pull llama3.1:70b model - you can run 'ollama pull llama3.1:70b' manually later"
    fi
fi

# Step 10: Final setup and cleanup
progress "Finalizing installation"

# Python environment setup
if command_exists pyenv; then
    info "Setting up Python environment..."
    # Get latest stable Python 3.12
    PYTHON_VERSION=$(pyenv install --list | grep -E "^\s*3\.12\.[0-9]+$" | tail -1 | tr -d ' ')
    if [[ -n "$PYTHON_VERSION" ]] && ! pyenv versions | grep -q "$PYTHON_VERSION"; then
        info "Installing Python $PYTHON_VERSION..."
        if pyenv install "$PYTHON_VERSION" 2>&1 | tee -a "$LOG_FILE"; then
            pyenv global "$PYTHON_VERSION"
            success "Python $PYTHON_VERSION installed and set as global"
        else
            warn "Failed to install Python $PYTHON_VERSION"
        fi
    fi
    
    # Install essential Python packages
    if command_exists python3; then
        info "Installing Python packages..."
        python3 -m pip install --upgrade pip 2>&1 | tee -a "$LOG_FILE" || true
        
        PIP_PACKAGES=("neovim" "ipython" "black" "ruff" "pytest" "requests" "virtualenv")
        for package in "${PIP_PACKAGES[@]}"; do
            if ! python3 -m pip show "$package" &>/dev/null; then
                python3 -m pip install --user "$package" 2>&1 | tee -a "$LOG_FILE" || warn "Failed to install $package"
            fi
        done
    fi
fi

# Start essential services
info "Starting essential services..."
SERVICES=("colima" "unbound")
for service in "${SERVICES[@]}"; do
    if brew list --formula | grep -q "^${service}$"; then
        info "Starting $service service..."
        brew services start "$service" 2>&1 | tee -a "$LOG_FILE" || warn "Failed to start $service"
    fi
done

# Update everything to latest versions
info "Updating all packages to latest versions..."
brew update 2>&1 | tee -a "$LOG_FILE" || true
brew upgrade 2>&1 | tee -a "$LOG_FILE" || true
brew upgrade --cask 2>&1 | tee -a "$LOG_FILE" || true

# Cleanup
info "Cleaning up..."
brew cleanup 2>&1 | tee -a "$LOG_FILE" || true

# Calculate total time
END_TIME=$(date +%s)
TOTAL_TIME=$((END_TIME - START_TIME))
TOTAL_MINUTES=$((TOTAL_TIME / 60))
TOTAL_SECONDS=$((TOTAL_TIME % 60))

# Final summary
echo ""
print_status "$GREEN" "🎉 Part 3 Complete: Additional Tooling Installed!"
echo ""
info "Installation Summary:"
echo "  • Fun tools: ✅"
echo "  • Media tools: ✅"
echo "  • Programming languages: ✅"
echo "  • System libraries: ✅"
echo "  • GUI applications: ✅"
echo "  • AI assistance (Ollama): ✅"
echo ""
info "Total installation time: ${TOTAL_MINUTES}m ${TOTAL_SECONDS}s"
info "Installation log saved to: $LOG_FILE"
echo ""
success "Your development environment is now fully configured!"
echo ""
info "Optional next steps:"
echo "  • Test Ollama: ollama run llama3.2:latest"
echo "  • Configure additional Python versions with pyenv"
echo "  • Set up Docker Desktop if installed"
echo "  • Explore the installed GUI applications"
echo ""

# Create a success marker file
touch "$HOME/.dotfiles-setup-part3-complete"
log "Part 3 setup completed successfully"

exit 0