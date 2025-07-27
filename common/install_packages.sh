#!/bin/bash

set -e

# 색상 정의
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# 기본 개발 도구
install_dev_essentials() {
    log_info "기본 개발 도구 설치 중..."
    
    sudo apt install -y \
        build-essential \
        cmake \
        git \
        curl \
        wget \
        vim \
        nano \
        htop \
        tree \
        unzip \
        zip \
        p7zip-full \
        software-properties-common \
        apt-transport-https \
        ca-certificates \
        gnupg \
        lsb-release \
        ranger
    
    log_success "기본 개발 도구 설치 완료"
}

# 네트워크 도구
install_network_tools() {
    log_info "네트워크 도구 설치 중..."
    
    sudo apt install -y \
        net-tools \
        openssh-server \
        openssh-client \
        ufw \
        iptables \
        nmap \
        telnet \
        tcpdump \
        wireshark
    
    log_success "네트워크 도구 설치 완료"
}

# 미디어 코덱 및 도구
install_media_tools() {
    log_info "미디어 코덱 및 도구 설치 중..."
    
    sudo apt install -y \
        ubuntu-restricted-extras \
        vlc \
        ffmpeg \
        imagemagick \
        gimp \
        audacity
    
    log_success "미디어 도구 설치 완료"
}

# Python 개발 환경
install_python_env() {
    log_info "Python 개발 환경 설치 중..."
    
    sudo apt install -y \
        python3 \
        python3-pip \
        python3-dev \
        python3-venv \
        python3-setuptools \
        python-is-python3
    
    # 주요 Python 패키지
    pip3 install --user \
        numpy \
        pandas \
        matplotlib \
        jupyter \
        ipython \
        requests \
        flask \
        fastapi \
        pytest
    
    log_success "Python 개발 환경 설치 완료"
}

# Node.js 및 npm
install_nodejs() {
    log_info "Node.js 및 npm 설치 중..."
    
    # NodeSource repository 추가
    curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
    sudo apt install -y nodejs
    
    # 전역 패키지 설치
    sudo npm install -g \
        yarn \
        pnpm \
        typescript \
        ts-node \
        nodemon \
        pm2
    
    log_success "Node.js 및 npm 설치 완료"
}

# 추가 유용한 도구
install_additional_tools() {
    log_info "추가 유용한 도구 설치 중..."
    
    sudo apt install -y \
        snap \
        flatpak \
        neofetch \
        btop \
        fd-find \
        ripgrep \
        bat \
        exa \
        fzf \
        jq \
        yq \
        tmux \
        screen \
        rsync \
        gparted \
        dconf-editor
    
    # Snap 패키지
    sudo snap install code --classic
    sudo snap install discord
    sudo snap install telegram-desktop
    
    log_success "추가 도구 설치 완료"
}

# 폰트 설치
install_fonts() {
    log_info "개발용 폰트 설치 중..."
    
    sudo apt install -y \
        fonts-firacode \
        fonts-hack \
        fonts-powerline \
        fonts-noto \
        fonts-noto-cjk \
        fonts-noto-color-emoji
    
    # Nerd Fonts 설치 (선택사항)
    if [[ ! -d "$HOME/.local/share/fonts/NerdFonts" ]]; then
        mkdir -p "$HOME/.local/share/fonts/NerdFonts"
        cd "$HOME/.local/share/fonts/NerdFonts"
        
        # JetBrains Mono Nerd Font 다운로드
        wget https://github.com/ryanoasis/nerd-fonts/releases/download/v3.0.2/JetBrainsMono.zip
        unzip JetBrainsMono.zip
        rm JetBrainsMono.zip
        
        # 폰트 캐시 업데이트
        fc-cache -fv
    fi
    
    log_success "폰트 설치 완료"
}

# 시스템 설정 최적화
optimize_system() {
    log_info "시스템 설정 최적화 중..."
    
    # Swappiness 설정
    echo 'vm.swappiness=10' | sudo tee -a /etc/sysctl.conf
    
    # 파일 시스템 체크 간격 늘리기
    sudo tune2fs -c -1 -i 0 /dev/sda1 2>/dev/null || true
    
    # 방화벽 설정
    sudo ufw enable
    sudo ufw default deny incoming
    sudo ufw default allow outgoing
    sudo ufw allow ssh
    
    log_success "시스템 최적화 완료"
}

# 정리 작업
cleanup() {
    log_info "시스템 정리 중..."
    
    sudo apt autoremove -y
    sudo apt autoclean
    sudo apt clean
    
    # 오래된 커널 삭제
    sudo apt autoremove --purge -y
    
    log_success "시스템 정리 완료"
}

# 메인 함수
main() {
    log_info "기본 패키지 설치를 시작합니다..."
    
    install_dev_essentials
    install_network_tools
    install_media_tools
    install_python_env
    install_nodejs
    install_additional_tools
    install_fonts
    optimize_system
    cleanup
    
    log_success "모든 기본 패키지 설치가 완료되었습니다!"
    echo
    echo "주요 설치된 도구들:"
    echo "- 개발 도구: gcc, cmake, git, vim"
    echo "- Python: python3, pip3, 주요 라이브러리들"
    echo "- Node.js: node, npm, yarn, typescript"
    echo "- 에디터: VS Code (snap)"
    echo "- 유틸리티: htop, tree, fzf, ripgrep"
    echo "- 폰트: Fira Code, Nerd Fonts"
}

# 스크립트 실행
main "$@"