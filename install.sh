#!/bin/bash
# kubectl-magic 插件安装脚本
# 该脚本将安装 kubectl-magic 及其相关子命令

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # 无颜色

# 打印彩色信息
print_info() {
  echo -e "${BLUE}[信息]${NC} $1"
}

print_success() {
  echo -e "${GREEN}[成功]${NC} $1"
}

print_warning() {
  echo -e "${YELLOW}[警告]${NC} $1"
}

print_error() {
  echo -e "${RED}[错误]${NC} $1"
}

# 获取用户的 shell 配置文件
get_shell_config_file() {
  local shell_config_file
  if [[ "$SHELL" == */zsh ]]; then
    shell_config_file="$HOME/.zshrc"
  elif [[ "$SHELL" == */bash ]]; then
    if [[ "$(uname)" == "Darwin" ]]; then  # macOS
      shell_config_file="$HOME/.bash_profile"
    else
      shell_config_file="$HOME/.bashrc"
    fi
  else
    # 默认使用 bashrc
    shell_config_file="$HOME/.bashrc"
    print_warning "未能识别的 shell 类型，将使用 $shell_config_file 作为配置文件"
  fi
  
  echo "$shell_config_file"
}

# 检查 kubectl 是否安装
check_kubectl() {
  if ! command -v kubectl &> /dev/null; then
    print_error "未找到 kubectl 命令。请先安装 kubectl 后再继续。"
    exit 1
  fi
  
  # 获取 kubectl 版本，兼容新旧版本
  local kubectl_version=""
  if kubectl version --client -o yaml &>/dev/null; then
    # 新版本 kubectl
    kubectl_version=$(kubectl version --client -o yaml 2>/dev/null | grep -o "gitVersion: .*" | head -1 | cut -d' ' -f2 | tr -d '"')
  elif kubectl version --client &>/dev/null; then
    # 旧版本 kubectl
    kubectl_version=$(kubectl version --client 2>/dev/null | grep -o "Client Version:.*" | head -1 | sed 's/Client Version: //')
  else
    kubectl_version="未知版本"
  fi
  
  print_info "找到 kubectl: $(which kubectl) (${kubectl_version})"
}

# 确定安装目录
determine_install_dir() {
  # 检查可能的安装位置
  local possible_dirs=(
    "/usr/local/bin"
    "$HOME/.local/bin"
    "$HOME/bin"
  )
  
  local install_dir=""
  
  # 检查这些目录是否在 PATH 中并且可写
  for dir in "${possible_dirs[@]}"; do
    if [[ ":$PATH:" == *":$dir:"* ]]; then
      if [[ -d "$dir" && -w "$dir" ]]; then
        install_dir="$dir"
        break
      elif [[ ! -d "$dir" && -w "$(dirname "$dir")" ]]; then
        mkdir -p "$dir"
        install_dir="$dir"
        break
      fi
    fi
  done
  
  # 如果没有找到合适的目录，提示用户
  if [[ -z "$install_dir" ]]; then
    print_warning "未找到在 PATH 中的可写目录。"
    
    # 建议在 ~/.local/bin 创建目录
    if [[ ! -d "$HOME/.local/bin" ]]; then
      print_info "正在创建目录 $HOME/.local/bin"
      mkdir -p "$HOME/.local/bin"
    fi
    
    install_dir="$HOME/.local/bin"
    print_warning "将使用 $install_dir 作为安装目录。"
    print_warning "使用前请确保该目录在您的 PATH 中。您可以通过以下命令添加:"
    
    local shell_config_file=$(get_shell_config_file)
    print_info "检测到您的 shell 配置文件为: $shell_config_file"
    
    echo "    echo 'export PATH=\"\$HOME/.local/bin:\$PATH\"' >> $shell_config_file"
    echo "    source $shell_config_file"
  fi
  
  print_info "将安装到: $install_dir"
  INSTALL_DIR="$install_dir"
}

# 检查命令或别名是否已存在
check_alias_exists() {
  local alias_name="$1"
  
  # 检查是否为系统命令
  if command -v "$alias_name" &> /dev/null; then
    return 0
  fi
  
  # 检查是否为已定义的别名
  if alias "$alias_name" &> /dev/null; then
    return 0
  fi
  
  return 1
}

# 添加命令别名到 shell 配置文件
add_aliases() {
  local shell_config_file=$(get_shell_config_file)
  local conflict_found=0
  local conflict_list=""
  
  print_info "正在检查别名冲突..."
  
  # 检查所有别名是否有冲突
  local all_aliases=("kmpods" "kmcm" "kmsc" "kmrr" "kmlog" "kmsh" "kmsw")
  for alias_name in "${all_aliases[@]}"; do
    if check_alias_exists "$alias_name"; then
      conflict_found=1
      conflict_list="${conflict_list} ${alias_name}"
      print_warning "发现冲突: '$alias_name' 已经被使用"
    fi
  done
  
  # 如果有冲突，询问用户如何处理
  if [ $conflict_found -eq 1 ]; then
    echo ""
    print_warning "检测到以下别名可能与现有命令或别名冲突: $conflict_list"
    echo ""
    echo "您有以下选择："
    echo "1. 继续使用这些别名 (可能覆盖现有命令)"
    echo "2. 使用替代前缀 'k8' (如 'k8pods' 替代 'kmpods')"
    echo "3. 使用替代前缀 'kube-' (如 'kube-pods' 替代 'kmpods')"
    echo "4. 自定义前缀"
    echo "5. 不添加任何别名"
    echo ""
    
    read -p "请选择 [1-5]: " alias_choice
    
    case "$alias_choice" in
      1)
        print_info "将继续使用原定别名"
        ;;
      2)
        print_info "将使用 'k8' 前缀"
        all_aliases=("k8pods" "k8cm" "k8sc" "k8rr" "k8log" "k8sh" "k8sw")
        ;;
      3)
        print_info "将使用 'kube-' 前缀"
        all_aliases=("kube-pods" "kube-cm" "kube-sc" "kube-rr" "kube-log" "kube-sh" "kube-sw")
        ;;
      4)
        read -p "请输入您想使用的前缀: " custom_prefix
        if [[ -z "$custom_prefix" ]]; then
          print_warning "前缀不能为空，将使用默认前缀 'k8'"
          custom_prefix="k8"
        fi
        print_info "将使用自定义前缀 '$custom_prefix'"
        all_aliases=("${custom_prefix}pods" "${custom_prefix}cm" "${custom_prefix}sc" "${custom_prefix}rr" "${custom_prefix}log" "${custom_prefix}sh" "${custom_prefix}sw")
        ;;
      5)
        print_info "跳过添加别名"
        return 0
        ;;
      *)
        print_warning "无效选择，将使用 'k8' 前缀作为默认值"
        all_aliases=("k8pods" "k8cm" "k8sc" "k8rr" "k8log" "k8sh" "k8sw")
        ;;
    esac
  else
    # 没有冲突，但仍询问用户是否要自定义别名
    echo ""
    print_info "默认将使用 'km' 前缀作为别名 (如 'kmpods')"
    echo "您想使用默认前缀还是自定义前缀？"
    echo "1. 使用默认前缀 'km'"
    echo "2. 使用替代前缀 'k8'"
    echo "3. 使用替代前缀 'kube-'"
    echo "4. 自定义前缀"
    echo ""
    
    read -p "请选择 [1-4] (默认: 1): " prefix_choice
    
    case "$prefix_choice" in
      2)
        print_info "将使用 'k8' 前缀"
        all_aliases=("k8pods" "k8cm" "k8sc" "k8rr" "k8log" "k8sh" "k8sw")
        ;;
      3)
        print_info "将使用 'kube-' 前缀"
        all_aliases=("kube-pods" "kube-cm" "kube-sc" "kube-rr" "kube-log" "kube-sh" "kube-sw")
        ;;
      4)
        read -p "请输入您想使用的前缀: " custom_prefix
        if [[ -z "$custom_prefix" ]]; then
          print_warning "前缀不能为空，将使用默认前缀 'km'"
          custom_prefix="km"
        fi
        print_info "将使用自定义前缀 '$custom_prefix'"
        all_aliases=("${custom_prefix}pods" "${custom_prefix}cm" "${custom_prefix}sc" "${custom_prefix}rr" "${custom_prefix}log" "${custom_prefix}sh" "${custom_prefix}sw")
        ;;
      1|"")
        print_info "将使用默认前缀 'km'"
        # 使用默认别名，无需更改
        ;;
      *)
        print_warning "无效选择，将使用默认前缀 'km'"
        # 使用默认别名，无需更改
        ;;
    esac
  fi
  
  print_info "正在将别名添加到 $shell_config_file ..."
  
  # 准备别名内容
  local aliases_content="
# kubectl-magic 插件别名 - 由安装脚本自动添加
alias ${all_aliases[0]}='kubectl magic pods'
alias ${all_aliases[1]}='kubectl magic cm'
alias ${all_aliases[2]}='kubectl magic sc'
alias ${all_aliases[3]}='kubectl magic rr'
alias ${all_aliases[4]}='kubectl magic log'
alias ${all_aliases[5]}='kubectl magic sh'
alias ${all_aliases[6]}='kubectl magic sw'
# kubectl-magic 插件别名结束
"
  
  # 检查文件中是否已经存在别名部分
  if grep -q "# kubectl-magic 插件别名 - 由安装脚本自动添加" "$shell_config_file"; then
    # 如果存在，则替换整个别名部分
    local start_line=$(grep -n "# kubectl-magic 插件别名 - 由安装脚本自动添加" "$shell_config_file" | cut -d: -f1)
    local end_line=$(grep -n "# kubectl-magic 插件别名结束" "$shell_config_file" | cut -d: -f1)
    
    if [[ -n "$start_line" && -n "$end_line" ]]; then
      # 创建临时文件
      local tmp_file=$(mktemp)
      
      # 提取别名部分之前的内容
      head -n $((start_line - 1)) "$shell_config_file" > "$tmp_file"
      
      # 添加新的别名部分
      echo "$aliases_content" >> "$tmp_file"
      
      # 添加别名部分之后的内容
      tail -n +$((end_line + 1)) "$shell_config_file" >> "$tmp_file"
      
      # 替换原文件
      mv "$tmp_file" "$shell_config_file"
      
      print_success "已更新现有的别名"
    else
      print_warning "找到别名标记但格式不完整，将追加新的别名"
      echo "$aliases_content" >> "$shell_config_file"
    fi
  else
    # 如果不存在，则直接追加
    echo "$aliases_content" >> "$shell_config_file"
    print_success "已添加别名到 $shell_config_file"
  fi
  
  # 记录使用的别名类型，用于显示说明
  ALIAS_PREFIX="${all_aliases[0]%pods}"
  
  print_info "请运行以下命令使别名立即生效："
  echo "    source $shell_config_file"
}

# 安装插件
install_plugins() {
  local current_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  local plugins_dir="${current_dir}/plugins"
  
  # 检查插件目录是否存在
  if [[ ! -d "$plugins_dir" ]]; then
    print_error "插件目录 ${plugins_dir} 不存在！"
    exit 1
  fi
  
  # 获取所有插件文件
  local plugins=($(ls ${plugins_dir}/kubectl-magic*))
  
  if [[ ${#plugins[@]} -eq 0 ]]; then
    print_error "在 ${plugins_dir} 目录下未找到任何插件文件！"
    exit 1
  fi
  
  print_info "找到 ${#plugins[@]} 个插件文件。"
  print_info "开始安装插件..."
  
  for src_file in "${plugins[@]}"; do
    local plugin_name=$(basename "$src_file")
    local dst_file="${INSTALL_DIR}/${plugin_name}"
    
    # 复制文件
    cp "$src_file" "$dst_file"
    chmod +x "$dst_file"
    print_success "已安装 ${plugin_name}"
  done
}

# 验证安装
verify_installation() {
  print_info "验证安装..."
  
  if ! command -v kubectl-magic &> /dev/null; then
    print_error "验证失败：无法找到 kubectl-magic 命令。请检查安装目录是否在 PATH 中。"
    return 1
  fi
  
  print_success "验证成功：kubectl-magic 已正确安装！"
  return 0
}

# 显示使用说明
show_instructions() {
  echo ""
  echo "======================================================"
  echo "               kubectl-magic 安装完成                "
  echo "======================================================"
  echo ""
  echo "您现在可以通过以下命令使用 kubectl-magic 插件:"
  echo ""
  echo "  kubectl magic pods NAMESPACE [-w]              # 查看指定命名空间的Pod，支持watch模式"
  echo "  kubectl magic cm NAMESPACE [NAME] [-e]         # 查看或编辑ConfigMap"
  echo "  kubectl magic sc NAMESPACE [NAME] [-e]         # 查看或编辑Secret"
  echo "  kubectl magic rr NAMESPACE NAME [-t TYPE]      # 滚动重启资源(默认为deployment)"
  echo "  kubectl magic log NAMESPACE [POD_NAME] [参数]   # 智能查看Pod日志"
  echo "  kubectl magic sh NAMESPACE [POD_NAME] [-c 容器] # 智能进入Pod容器shell"
  echo "  kubectl magic sw                               # 交互式切换 Kubernetes 上下文"
  echo "  kubectl magic help                             # 显示帮助信息"
  echo ""
  
  if [[ -n "$ALIASES_ADDED" && "$ALIASES_ADDED" -eq 1 ]]; then
    echo "您现在也可以使用以下别名快速访问这些命令:"
    echo ""
    echo "  ${ALIAS_PREFIX}pods NAMESPACE [-w]              # kubectl magic pods 的别名"
    echo "  ${ALIAS_PREFIX}cm NAMESPACE [NAME] [-e]         # kubectl magic cm 的别名"
    echo "  ${ALIAS_PREFIX}sc NAMESPACE [NAME] [-e]         # kubectl magic sc 的别名"
    echo "  ${ALIAS_PREFIX}rr NAMESPACE NAME [-t TYPE]      # kubectl magic rr 的别名"
    echo "  ${ALIAS_PREFIX}log NAMESPACE [POD_NAME] [参数]   # kubectl magic log 的别名"
    echo "  ${ALIAS_PREFIX}sh NAMESPACE [POD_NAME] [-c 容器] # kubectl magic sh 的别名"
    echo "  ${ALIAS_PREFIX}sw                               # kubectl magic sw 的别名"
    echo ""
    echo "请运行以下命令使别名立即生效："
    echo "    source $(get_shell_config_file)"
  fi
}

# 主函数
main() {
  # 初始化变量
  ALIAS_PREFIX="km"
  
  echo "======================================================="
  echo "           kubectl-magic 插件安装                      "
  echo "======================================================="
  echo ""
  
  # 检查 kubectl
  check_kubectl
  
  # 确定安装目录
  determine_install_dir
  
  # 安装插件
  install_plugins
  
  # 验证安装
  verify_installation
  
  # 询问是否要添加别名
  echo ""
  read -p "是否添加命令别名到 shell 配置文件？(y/n): " add_aliases_choice
  if [[ "$add_aliases_choice" =~ ^[Yy]$ ]]; then
    add_aliases
    ALIASES_ADDED=1
  else
    print_info "跳过添加别名。"
    ALIASES_ADDED=0
  fi
  
  # 显示使用说明
  show_instructions
  
  echo "感谢使用 kubectl-magic 插件！"
}

# 如果直接调用脚本则运行主函数
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  main "$@"
fi 