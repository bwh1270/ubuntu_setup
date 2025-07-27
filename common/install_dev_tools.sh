#!/bin/bash

# Ubuntu 22.04 개발 도구 설치 스크립트 (ROS2, Docker, Nvidia)

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

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# ROS2 Humble 설치
install_ros2() {
    log_info "ROS2 Humble 설치 시작..."
    
    # 로케일 설정
    sudo apt update && sudo apt install -y locales
    sudo locale-gen en_US en_US.UTF-8
    sudo update-locale LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8
    export LANG=en_US.UTF-8
    
    # Universe 저장소 활성화
    sudo apt install -y software-properties-common
    sudo add-apt-repository universe -y
    
    # ROS2 GPG 키 추가
    sudo apt update && sudo apt install -y curl gnupg lsb-release
    sudo curl -sSL https://raw.githubusercontent.com/ros/rosdistro/master/ros.key -o /usr/share/keyrings/ros-archive-keyring.gpg
    
    # ROS2 저장소 추가
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/ros-archive-keyring.gpg] http://packages.ros.org/ros2/ubuntu $(. /etc/os-release && echo $UBUNTU_CODENAME) main" | sudo tee /etc/apt/sources.list.d/ros2.list > /dev/null
    
    # ROS2 패키지 설치
    sudo apt update
    sudo apt install -y ros-humble-desktop-full
    
    # 개발 도구 설치
    sudo apt install -y \
        python3-flake8-docstrings \
        python3-pip \
        python3-pytest-cov \
        ros-dev-tools
    
    # Python 의존성 설치
    python3 -m pip install -U \
        argcomplete \
        flake8-blind-except \
        flake8-builtins \
        flake8-class-newline \
        flake8-comprehensions \
        flake8-deprecated \
        flake8-import-order \
        flake8-quotes \
        pytest-repeat \
        pytest-rerunfailures
    
    # colcon 설치
    python3 -m pip install -U colcon-common-extensions
    
    # ROS2 환경 설정
    echo "source /opt/ros/humble/setup.bash" >> ~/.bashrc
    if [[ -f ~/.zshrc ]]; then
        echo "source /opt/ros/humble/setup.zsh" >> ~/.zshrc
    fi
    
    # rosdep 초기화
    sudo rosdep init || true
    rosdep update
    
    log_success "ROS2 Humble 설치 완료"
}

# Docker 설치
install_docker() {
    log_info "Docker 설치 시작..."
    
    # 기존 Docker 제거
    sudo apt remove -y docker docker-engine docker.io containerd runc 2>/dev/null || true
    
    # 필요한 패키지 설치
    sudo apt update
    sudo apt install -y \
        ca-certificates \
        curl \
        gnupg \
        lsb-release
    
    # Docker GPG 키 추가
    sudo mkdir -p /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    
    # Docker 저장소 추가
    echo \
        "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
        $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    
    # Docker 설치
    sudo apt update
    sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
    
    # 사용자를 docker 그룹에 추가
    sudo usermod -aG docker $USER
    
    # Docker 서비스 시작 및 활성화
    sudo systemctl start docker
    sudo systemctl enable docker
    
    # Docker Compose 설치 (standalone)
    sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose
    
    log_success "Docker 설치 완료"
    log_warning "Docker 그룹 변경사항을 적용하려면 재로그인이 필요합니다."
}

# NVIDIA 드라이버 설치
install_nvidia_driver() {
    log_info "NVIDIA 드라이버 설치 시작..."
    
    # NVIDIA GPU 확인
    if ! lspci | grep -i nvidia > /dev/null; then
        log_warning "NVIDIA GPU가 감지되지 않았습니다. 설치를 건너뜁니다."
        return
    fi
    
    # 기존 드라이버 제거
    sudo apt purge -y nvidia-* libnvidia-*
    sudo apt autoremove -y
    
    # 새 드라이버 설치
    sudo apt update
    sudo apt install -y ubuntu-drivers-common
    
    # 권장 드라이버 자동 설치
    sudo ubuntu-drivers autoinstall
    
    log_success "NVIDIA 드라이버 설치 완료"
    log_warning "드라이버 적용을 위해 재부팅이 필요합니다."
}

# NVIDIA Container Toolkit 설치 (Docker에서 GPU 사용)
install_nvidia_docker() {
    log_info "NVIDIA Container Toolkit 설치 시작..."
    
    # Docker가 설치되어 있는지 확인
    if ! command -v docker &> /dev/null; then
        log_error "Docker가 설치되어 있지 않습니다. Docker를 먼저 설치하세요."
        return 1
    fi
    
    # NVIDIA Container Toolkit 저장소 추가
    distribution=$(. /etc/os-release;echo $ID$VERSION_ID) \
        && curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey | sudo gpg --dearmor -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg \
        && curl -s -L https://nvidia.github.io/libnvidia-container/$distribution/libnvidia-container.list | \
            sed 's#deb https://#deb [signed-by=/usr/share/keyrings/nvidia-container-toolkit-keyring.gpg] https://#g' | \
            sudo tee /etc/apt/sources.list.d/nvidia-container-toolkit.list
    
    # NVIDIA Container Toolkit 설치
    sudo apt update
    sudo apt install -y nvidia-container-toolkit
    
    # Docker 데몬 재시작
    sudo systemctl restart docker
    
    log_success "NVIDIA Container Toolkit 설치 완료"
}

# CUDA 설치
install_cuda() {
    log_info "CUDA Toolkit 설치 시작..."
    
    # NVIDIA GPU 확인
    if ! lspci | grep -i nvidia > /dev/null; then
        log_warning "NVIDIA GPU가 감지되지 않았습니다. CUDA 설치를 건너뜁니다."
        return
    fi
    
    # CUDA 저장소 추가
    wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2204/x86_64/cuda-keyring_1.0-1_all.deb
    sudo dpkg -i cuda-keyring_1.0-1_all.deb
    sudo apt update
    
    # CUDA Toolkit 설치
    sudo apt install -y cuda-toolkit-12-3
    
    # 환경 변수 설정
    echo 'export PATH=/usr/local/cuda/bin:$PATH' >> ~/.bashrc
    echo 'export LD_LIBRARY_PATH=/usr/local/cuda/lib64:$LD_LIBRARY_PATH' >> ~/.bashrc
    
    if [[ -f ~/.zshrc ]]; then
        echo 'export PATH=/usr/local/cuda/bin:$PATH' >> ~/.zshrc
        echo 'export LD_LIBRARY_PATH=/usr/local/cuda/lib64:$LD_LIBRARY_PATH' >> ~/.zshrc
    fi
    
    # cuDNN 설치 (선택사항)
    sudo apt install -y libcudnn8 libcudnn8-dev
    
    # 정리
    rm -f cuda-keyring_1.0-1_all.deb
    
    log_success "CUDA Toolkit 설치 완료"
}

# 개발 도구 추가 설정
setup_development_environment() {
    log_info "개발 환경 추가 설정 중..."
    
    # ROS2 작업공간 생성
    mkdir -p ~/workspace/ros2_ws/src
    cd ~/workspace/ros2_ws
    colcon build 2>/dev/null || true
    echo "source ~/workspace/ros2_ws/install/setup.bash" >> ~/.bashrc
    if [[ -f ~/.zshrc ]]; then
        echo "source ~/workspace/ros2_ws/install/setup.zsh" >> ~/.zshrc
    fi
    
    # Docker 테스트 컨테이너 실행
    if command -v docker &> /dev/null; then
        log_info "Docker 설치 테스트 중..."
        # newgrp docker를 사용하여 현재 세션에서 docker 그룹 적용
        newgrp docker << EONG
docker run --rm hello-world
EONG
        log_success "Docker 테스트 완료"
    fi
    
    log_success "개발 환경 설정 완료"
}

# 설치 확인
verify_installations() {
    log_info "설치 확인 중..."
    
    echo "========== 설치된 버전 정보 =========="
    
    # ROS2 확인
    if command -v ros2 &> /dev/null; then
        echo "ROS2: $(ros2 --version 2>/dev/null || echo 'source 필요')"
    fi
    
    # Docker 확인
    if command -v docker &> /dev/null; then
        echo "Docker: $(docker --version)"
        echo "Docker Compose: $(docker-compose --version)"
    fi
    
    # NVIDIA 드라이버 확인
    if command -v nvidia-smi &> /dev/null; then
        echo "NVIDIA Driver: $(nvidia-smi --version | head -1)"
    fi
    
    # CUDA 확인
    if command -v nvcc &> /dev/null; then
        echo "CUDA: $(nvcc --version | grep release)"
    fi
    
    echo "===================================="
}

# 메뉴 출력
show_menu() {
    echo
    echo "========================================="
    echo "        개발 도구 설치 스크립트"
    echo "========================================="
    echo "1) ROS2 Humble 설치"
    echo "2) Docker 설치"
    echo "3) NVIDIA 드라이버 설치"
    echo "4) NVIDIA Container Toolkit 설치"
    echo "5) CUDA Toolkit 설치"
    echo "6) 개발 환경 설정"
    echo "7) 전체 설치 (ROS2 + Docker + NVIDIA)"
    echo "8) 설치 확인"
    echo "0) 종료"
    echo "========================================="
}

# 메인 함수
main() {
    if [[ $# -eq 0 ]]; then
        # 인터랙티브 모드
        while true; do
            show_menu
            read -p "선택하세요 (0-8): " choice
            
            case $choice in
                1) install_ros2 ;;
                2) install_docker ;;
                3) install_nvidia_driver ;;
                4) install_nvidia_docker ;;
                5) install_cuda ;;
                6) setup_development_environment ;;
                7)
                    log_info "전체 설치를 시작합니다..."
                    install_ros2
                    install_docker
                    install_nvidia_driver
                    install_nvidia_docker
                    install_cuda
                    setup_development_environment
                    verify_installations
                    log_success "모든 개발 도구 설치가 완료되었습니다!"
                    ;;
                8) verify_installations ;;
                0) 
                    log_info "설치를 종료합니다."
                    exit 0 
                    ;;
                *) log_error "잘못된 선택입니다." ;;
            esac
            
            echo
            read -p "계속하려면 Enter를 누르세요..."
        done
    else
        # 자동 실행 모드
        log_info "개발 도구 자동 설치를 시작합니다..."
        install_ros2
        install_docker
        install_nvidia_driver
        install_nvidia_docker
        install_cuda
        setup_development_environment
        verify_installations
        log_success "모든 개발 도구 설치가 완료되었습니다!"
    fi
}

# 스크립트 실행
main "$@"