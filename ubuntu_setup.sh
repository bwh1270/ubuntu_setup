#!/bin/bash

# Ubuntu 22.04 초기 설정 스크립트
# 작성자: Woohyun Byun
# 날짜: 2025.07.28

set -e  # 에러 발생시 스크립트 중단

# 색상 정의
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 로그 함수
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

# 스크립트 권한 확인
check_permissions() {
    if [[ $EUID -eq 0 ]]; then
        log_error "이 스크립트는 root 권한으로 실행하지 마세요!"
        exit 1
    fi
}

# 스크립트 실행 위치 확인
check_script_location() {
    local script_dir="$(dirname "$(readlink -f "$0")")"
    local current_dir="$(pwd)"
    
    if [[ "$script_dir" != "$current_dir" ]]; then
        log_error "스크립트를 해당 파일이 있는 디렉토리에서 실행해야 합니다."
        log_error "현재 위치: $current_dir"
        log_error "스크립트 위치: $script_dir"
        log_error "다음 명령어로 이동 후 실행하세요:"
        echo "cd $script_dir && ./$(basename "$0")"
        exit 1
    fi
}

# 디렉토리 구조 확인
check_scripts() {
    local script_dir="$(dirname "$(readlink -f "$0")")/common"
    local scripts=("${script_dir}/install_packages.sh" "${script_dir}/install_dev_tools.sh" "${script_dir}/install_code_server.sh")
    local missing_scripts=()
    
    for script in "${scripts[@]}"; do
        if [[ ! -f "$script" ]]; then
            missing_scripts+=("$script")
        fi
    done
    
    if [[ ${#missing_scripts[@]} -gt 0 ]]; then
        log_error "다음 스크립트 파일들이 없습니다:"
        printf '%s\n' "${missing_scripts[@]}"
        exit 1
    fi
}

# 시스템 업데이트
update_system() {
    log_info "시스템 패키지 업데이트 중..."
    sudo apt update && sudo apt upgrade -y
    log_success "시스템 업데이트 완료"
}

# 개인 설정 함수들
setup_git() {
    log_info "Git 사용자 정보 설정"
    read -p "Git 사용자 이름을 입력하세요: " git_name
    read -p "Git 이메일을 입력하세요: " git_email
    
    git config --global user.name "$git_name"
    git config --global user.email "$git_email"
    log_success "Git 설정 완료"
}

# 설정 파일 복사 함수
copy_config_files() {
    log_info "설정 파일 복사 중..."
    
    local script_dir="$(dirname "$(readlink -f "$0")")"
    local copy_path="${script_dir}/to_copy"
    
    # to_copy 디렉토리 존재 확인
    if [[ ! -d "$copy_path" ]]; then
        log_warning "to_copy 디렉토리가 없습니다: $copy_path"
        return 1
    fi
    
    # 각 설정 파일 복사
    if [[ -f "${copy_path}/aliases" ]]; then
        cp "${copy_path}/aliases" "$HOME/.bash_aliases"
        log_success "bash_aliases 복사 완료"
    else
        log_warning "aliases 파일이 없습니다"
    fi
    
    if [[ -f "${copy_path}/vim" ]]; then
        cp "${copy_path}/vim" "$HOME/.vimrc"
        log_success "vimrc 복사 완료"
    else
        log_warning "vim 파일이 없습니다"
    fi
    
    if [[ -f "${copy_path}/tmux" ]]; then
        cp "${copy_path}/tmux" "$HOME/.tmux.conf"
        log_success "tmux.conf 복사 완료"
    else
        log_warning "tmux 파일이 없습니다"
    fi
    
    if [[ -f "${copy_path}/ranger" ]]; then
        mkdir -p "$HOME/.config/ranger"
        cp "${copy_path}/ranger" "$HOME/.config/ranger/rc.conf"
        log_success "ranger 설정 복사 완료"
    else
        log_warning "ranger 파일이 없습니다"
    fi
    
    log_success "설정 파일 복사 완료!"
}

# bashrc 설정 추가 함수 (수정됨)
copy_bashrc_config() {
    log_info "Bashrc 커스텀 설정 추가 중..."
    
    local bashrc_file="$HOME/.bashrc"
    local marker="# Custom terminal settings"

    # 이미 추가되었는지 확인
    if grep -q "$marker" "$bashrc_file"; then
        log_warning "Bashrc 설정이 이미 추가되어 있습니다."
        return 0  # exit 0이 아닌 return 0으로 수정
    fi

    # bashrc에 설정 추가
    cat >> "$bashrc_file" << 'EOF'

# Custom terminal settings
parse_git_branch() {
    git branch 2> /dev/null | grep '^*' | sed 's/* //'
}
export PS1="\[\e[0;32m\][\A] \u@:\w\[\e[0;33m\](\$(parse_git_branch))\[\e[m\]\$ "

# By ctrl+d, prevent shell exit
set -o ignoreeof

# Prevent path extention of * or ? character
#set -o noglob
EOF

    log_success "Bashrc 설정이 완료되었습니다. 새 터미널을 열거나 'source ~/.bashrc'를 실행하세요."
}

# setup_zsh() {
#     log_info "Zsh 및 Oh My Zsh 설정"
#     if ! command -v zsh &> /dev/null; then
#         sudo apt install -y zsh
#     fi
    
#     # Oh My Zsh 설치
#     if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
#         sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
#     fi
    
#     # 기본 쉘 변경
#     if [[ "$SHELL" != "$(which zsh)" ]]; then
#         chsh -s $(which zsh)
#         log_warning "쉘이 zsh로 변경되었습니다. 재로그인 후 적용됩니다."
#     fi
    
#     log_success "Zsh 설정 완료"
# }

# setup_ssh() {
#     log_info "SSH 키 생성"
#     if [[ ! -f "$HOME/.ssh/id_rsa" ]]; then
#         read -p "SSH 키를 생성할 이메일을 입력하세요: " ssh_email
#         ssh-keygen -t rsa -b 4096 -C "$ssh_email" -f "$HOME/.ssh/id_rsa" -N ""
#         log_success "SSH 키가 생성되었습니다: $HOME/.ssh/id_rsa.pub"
#         echo "공개 키 내용:"
#         cat "$HOME/.ssh/id_rsa.pub"
#     else
#         log_warning "SSH 키가 이미 존재합니다."
#     fi
# }

# show_menu() {
#     echo "========================================="
#     echo "     Ubuntu 22.04 초기 설정 스크립트"
#     echo "========================================="
# }

# 메인 로직
main() {
    log_info "============================================="
    log_info "Ubuntu 22.04 초기 설정 스크립트를 시작합니다."
    log_info "============================================="
    
    # 권한 및 스크립트 확인
    check_permissions
    check_script_location
    check_scripts
    log_info "권한 및 스크립트 확인 완료..."

    update_system
    chmod +x common/install_packages.sh && ./common/install_packages.sh
    chmod +x common/install_dev_tools.sh && ./common/install_dev_tools.sh
    chmod +x common/install_code_server.sh && ./common/install_code_server.sh

    setup_git
    copy_config_files
    copy_bashrc_config

    log_success "============================================="
    log_success "모든 설정이 완료되었습니다!"
    log_success "다음 명령어로 bashrc 설정을 즉시 적용하세요:"
    echo "source ~/.bashrc"
    log_success "============================================="
}

# 스크립트 실행
main "$@"