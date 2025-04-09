# MagicKube

MagicKube 是一套增强 Kubernetes 命令行体验的工具集，提供了一系列便捷的命令来简化日常 Kubernetes 操作。这些工具特别关注易用性和交互性，减少了记忆复杂命令的负担。

## 特性

- **交互式选择**：自动列出并选择 Pod、容器等，无需手动复制粘贴长名称
- **智能化处理**：自动检测单容器/多容器场景，简化操作流程
- **便捷的资源管理**：快速查看和编辑 ConfigMap、Secret 等资源
- **上下文切换**：直观的 Kubernetes 上下文切换界面
- **自定义别名支持**：提供可配置的别名前缀（如 `kmpods`、`k8pods` 等），避免命令冲突

## 先决条件

使用 MagicKube 前，您需要满足以下条件：

1. 已安装 kubectl 命令行工具
   ```bash
   # 可通过以下命令验证安装
   kubectl version
   ```

2. 已配置好 Kubernetes 集群的访问凭证
   ```bash
   # 确认能够访问集群
   kubectl cluster-info
   ```

如果您尚未安装 kubectl，请参考 [Kubernetes 官方文档](https://kubernetes.io/zh-cn/docs/tasks/tools/) 完成安装。

## 安装

### 快速安装

1. 克隆本仓库：
   ```bash
   git clone https://github.com/dtyq/magickube.git
   cd magickube
   ```

2. 运行安装脚本：
   ```bash
   ./install.sh
   ```

3. 按照提示操作，脚本会自动：
   - 检测 kubectl 安装情况
   - 找到合适的安装目录
   - 安装所有插件
   - 可选择添加命令别名到 shell 配置文件

<details>
<summary>点击查看安装示例</summary>

```bash
$ sh ./install.sh
=======================================================
           kubectl-magic 插件安装                      
=======================================================

[信息] 找到 kubectl: /usr/local/bin/kubectl (v1.32.3)
[信息] 将安装到: /Users/username/.local/bin
[信息] 找到 8 个插件文件。
[信息] 开始安装插件...
[成功] 已安装 kubectl-magic
[成功] 已安装 kubectl-magic-cm
[成功] 已安装 kubectl-magic-log
[成功] 已安装 kubectl-magic-pods
[成功] 已安装 kubectl-magic-rr
[成功] 已安装 kubectl-magic-sc
[成功] 已安装 kubectl-magic-sh
[成功] 已安装 kubectl-magic-sw
[信息] 验证安装...
[成功] 验证成功：kubectl-magic 已正确安装！

是否添加命令别名到 shell 配置文件？(y/n): y
[信息] 正在检查别名冲突...

[信息] 默认将使用 'km' 前缀作为别名 (如 'kmpods')
您想使用默认前缀还是自定义前缀？
1. 使用默认前缀 'km'
2. 使用替代前缀 'k8'
3. 使用替代前缀 'kube-'
4. 自定义前缀

请选择 [1-4] (默认: 1):  
[信息] 将使用默认前缀 'km'
[信息] 正在将别名添加到 /Users/username/.zshrc ...
[成功] 已更新现有的别名
[信息] 请运行以下命令使别名立即生效：
    source /Users/username/.zshrc

======================================================
               kubectl-magic 安装完成                
======================================================

您现在可以通过以下命令使用 kubectl-magic 插件:

  kubectl magic pods NAMESPACE [-w]              # 查看指定命名空间的 Pod，支持 watch 模式
  kubectl magic cm NAMESPACE [NAME] [-e]         # 查看或编辑 ConfigMap
  kubectl magic sc NAMESPACE [NAME] [-e]         # 查看或编辑 Secret
  kubectl magic rr NAMESPACE NAME [-t TYPE]      # 滚动重启资源(默认为 deployment)
  kubectl magic log NAMESPACE [POD_NAME] [参数]   # 智能查看 Pod 日志
  kubectl magic sh NAMESPACE [POD_NAME] [-c 容器] # 智能进入 Pod 容器 shell
  kubectl magic sw                               # 交互式切换 Kubernetes 上下文
  kubectl magic help                             # 显示帮助信息

您现在也可以使用以下别名快速访问这些命令:

  kmpods NAMESPACE [-w]              # kubectl magic pods 的别名
  kmcm NAMESPACE [NAME] [-e]         # kubectl magic cm 的别名
  kmsc NAMESPACE [NAME] [-e]         # kubectl magic sc 的别名
  kmrr NAMESPACE NAME [-t TYPE]      # kubectl magic rr 的别名
  kmlog NAMESPACE [POD_NAME] [参数]   # kubectl magic log 的别名
  kmsh NAMESPACE [POD_NAME] [-c 容器] # kubectl magic sh 的别名
  kmsw                               # kubectl magic sw 的别名

请运行以下命令使别名立即生效：
    source /Users/username/.zshrc
感谢使用 kubectl-magic 插件！
```

</details>

### 手动安装

1. 确保 `plugins` 目录下的所有 `kubectl-magic*` 文件复制到你的 PATH 路径中的某个目录
2. 确保所有文件具有可执行权限 (`chmod +x kubectl-magic*`)

## 使用方法

安装后，你可以通过以下两种方式使用这些命令：

1. 标准方式：`kubectl magic <子命令> [参数]`
2. 别名方式：`<前缀><子命令> [参数]`（默认为 `km<子命令>`，如 `kmpods`）

> **重要提示**：为简化操作，我们强烈建议在安装时选择添加命令别名。这样你可以使用更简短的命令（如 `kmpods` 替代 `kubectl magic pods`）来提高工作效率。若要使用别名，请先执行 `source ~/.bashrc` 或 `source ~/.zshrc`（取决于你的 shell 类型）使别名立即生效。
>
> 在安装过程中，您可以选择使用默认前缀、替代前缀或完全自定义前缀。该功能有助于避免与系统命令冲突。

以下演示将使用默认别名前缀 `km` 展示命令使用，这是我们推荐的日常使用方式。

### 可用命令

#### 查看 Pod 列表 (pods)

```bash
# 查看指定命名空间的 Pod
kmpods default

# 实时监控 Pod 变化
kmpods kube-system -w
```

#### 查看和编辑 ConfigMap (cm)

```bash
# 列出命名空间中的所有 ConfigMap
kmcm default

# 查看特定 ConfigMap 的内容
kmcm default my-config

# 编辑 ConfigMap
kmcm default my-config -e
```

#### 查看和编辑 Secret (sc)

```bash
# 列出命名空间中的所有 Secret
kmsc default

# 查看特定 Secret 的内容
kmsc default my-secret

# 编辑 Secret
kmsc default my-secret -e
```

#### 滚动重启资源 (rr)

```bash
# 重启 Deployment
kmrr default my-deployment

# 重启其他类型的资源
kmrr default my-statefulset -t statefulset
```

#### 智能查看 Pod 日志 (log)

```bash
# 查看指定命名空间下的 Pod 日志（会提供交互式选择）
kmlog default

# 查看指定 Pod 的日志
kmlog default my-pod

# 搜索包含特定关键字的 Pod 并查看日志
kmlog default nginx

# 查看日志并使用参数
kmlog default my-pod --tail=100
```

#### 智能进入 Pod Shell (sh)

```bash
# 交互式选择一个 Pod 并进入其 Shell
kmsh default

# 直接进入指定 Pod 的 Shell
kmsh default my-pod

# 进入 Pod 中特定容器的 Shell
kmsh default my-pod -c my-container
```

#### 切换 Kubernetes 上下文 (sw)

```bash
# 启动交互式上下文切换
kmsw
```

## 功能演示

> **注意**：以下演示使用的是别名方式。如果你未设置别名，请将命令替换为对应的完整形式（如 `kubectl magic log` 替代 `kmlog`）。

### 交互式选择 Pod

当你运行 `kmlog default` 或 `kmsh default` 而不指定具体的 Pod 名称时，命令会显示一个交互式列表：

```
当前命名空间: default
请选择 Pod:
1   nginx-deployment-66b6c48dd5-2d6j7    Running     1d
2   redis-master-58797f744f-dpn6j        Running     3d
3   web-app-5d76f4b5b9-pt2jz             Running     12h
输入编号 (1-3): 
```

这让你无需记忆或复制长长的 Pod 名称，只需选择一个数字即可。

### 自动容器检测

在多容器 Pod 中，命令会自动列出所有容器供你选择：

```
Pod 有多个容器，请选择一个:
1) web
2) sidecar
#? 
```

而当 Pod 只有一个容器时，会自动选择该容器而不需要额外操作。

### 上下文切换

`kmsw` 命令提供了一个交互式界面来切换 Kubernetes 上下文：

```
Pick the context to use:

  [ ] minikube
  [ ] docker-desktop
> [x] prod-cluster
  [ ] staging-cluster

Press q to quit.
```

## 别名参考

以下是完整的别名对应关系，方便您参考（以默认前缀 `km` 为例）：

| 别名       | 完整命令                 | 功能描述                   |
|-----------|-------------------------|---------------------------|
| kmpods    | kubectl magic pods     | 查看 Pod 列表              |
| kmcm      | kubectl magic cm       | 管理 ConfigMap            |
| kmsc      | kubectl magic sc       | 管理 Secret               |
| kmrr      | kubectl magic rr       | 滚动重启资源               |
| kmlog     | kubectl magic log      | 查看 Pod 日志              |
| kmsh      | kubectl magic sh       | 进入 Pod 的 Shell          |
| kmsw      | kubectl magic sw       | 切换 Kubernetes 上下文     |

> **注意**：如果您在安装时选择了不同的前缀，您的实际别名会有所不同。例如，使用 `k8` 前缀时，别名将是 `k8pods`、`k8cm` 等。

## 卸载

如果你想卸载这些工具，只需从安装目录删除所有 `kubectl-magic*` 文件即可。如果你添加了别名，则需要从你的 shell 配置文件（如 `~/.bashrc` 或 `~/.zshrc`）中删除相应的别名配置。

## 自定义别名

### 安装时选择别名前缀

安装脚本现在提供了别名自定义功能，您可以在安装过程中选择：

1. 安装脚本将首先检测是否存在别名冲突（例如与系统命令冲突）
2. 无论是否存在冲突，您都可以选择以下别名前缀：
   - 默认前缀 `km`（如 `kmpods`、`kmsh`）
   - 替代前缀 `k8`（如 `k8pods`、`k8sh`）
   - 替代前缀 `kube-`（如 `kube-pods`、`kube-sh`）
   - 完全自定义前缀（您可以输入任何想要的前缀）

这种灵活的配置可以避免与系统命令冲突，特别是避免与 `ksh`（Korn Shell）等重要命令冲突。

### 安装后修改别名

如果您想在安装后更改别名，您可以：

1. 编辑您的 shell 配置文件（如 `~/.bashrc` 或 `~/.zshrc`）
2. 找到 "kubectl-magic 插件别名" 部分
3. 将现有别名修改为您喜欢的格式，例如：

```bash
# kubectl-magic 插件别名 - 由安装脚本自动添加
alias k8pods='kubectl magic pods'
alias k8cm='kubectl magic cm'
alias k8sc='kubectl magic sc'
# ... 其他别名
```

修改后运行 `source ~/.bashrc` 或 `source ~/.zshrc` 使变更生效。

### 安装前修改别名

如果您在运行安装脚本前已有特定的别名偏好：

1. 直接在安装过程中选择"自定义前缀"选项
2. 输入您想要的前缀
3. 安装脚本将使用您的自定义前缀创建所有别名

### 别名命名建议

设计您的别名时，请注意避免与系统现有命令冲突。一些安全的前缀建议：

- `k8xxx` - Kubernetes 的数字缩写格式
- `kmxxx` - kubectl-magic 的缩写
- `kube-xxx` - 更明确的前缀
- `km-xxx` - 带连字符的 kubectl-magic 缩写

## 贡献

欢迎贡献代码、报告问题或提出改进建议！ 
