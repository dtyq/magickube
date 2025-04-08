# MagicKube

MagicKube 是一套增强 Kubernetes 命令行体验的工具集，提供了一系列便捷的命令来简化日常 Kubernetes 操作。这些工具特别关注易用性和交互性，减少了记忆复杂命令的负担。

## 特性

- **交互式选择**：自动列出并选择 Pod、容器等，无需手动复制粘贴长名称
- **智能化处理**：自动检测单容器/多容器场景，简化操作流程
- **便捷的资源管理**：快速查看和编辑 ConfigMap、Secret 等资源
- **上下文切换**：直观的 Kubernetes 上下文切换界面
- **别名支持**：提供简短别名（如 `kpods`、`kcm`）以提高效率

## 先决条件

使用 kubectl-magic 前，您需要满足以下条件：

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

### 手动安装

1. 确保 `plugins` 目录下的所有 `kubectl-magic*` 文件复制到你的 PATH 路径中的某个目录
2. 确保所有文件具有可执行权限 (`chmod +x kubectl-magic*`)

## 使用方法

安装后，你可以通过以下两种方式使用这些命令：

1. 标准方式：`kubectl magic <子命令> [参数]`
2. 别名方式：`k<子命令> [参数]`（如果在安装时选择了添加别名）

> **重要提示**：为简化操作，我们强烈建议在安装时选择添加命令别名。这样你可以使用更简短的命令（如 `kpods` 替代 `kubectl magic pods`）来提高工作效率。若要使用别名，请先执行 `source ~/.bashrc` 或 `source ~/.zshrc`（取决于你的 shell 类型）使别名立即生效。

以下演示将使用别名方式展示命令使用，这是我们推荐的日常使用方式。

### 可用命令

#### 查看 Pod 列表 (pods)

```bash
# 查看指定命名空间的 Pod
kpods default

# 实时监控 Pod 变化
kpods kube-system -w
```

#### 查看和编辑 ConfigMap (cm)

```bash
# 列出命名空间中的所有 ConfigMap
kcm default

# 查看特定 ConfigMap 的内容
kcm default my-config

# 编辑 ConfigMap
kcm default my-config -e
```

#### 查看和编辑 Secret (sc)

```bash
# 列出命名空间中的所有 Secret
ksc default

# 查看特定 Secret 的内容
ksc default my-secret

# 编辑 Secret
ksc default my-secret -e
```

#### 滚动重启资源 (rr)

```bash
# 重启 Deployment
krr default my-deployment

# 重启其他类型的资源
krr default my-statefulset -t statefulset
```

#### 智能查看 Pod 日志 (log)

```bash
# 查看指定命名空间下的 Pod 日志（会提供交互式选择）
klog default

# 查看指定 Pod 的日志
klog default my-pod

# 搜索包含特定关键字的 Pod 并查看日志
klog default nginx

# 查看日志并使用参数
klog default my-pod --tail=100
```

#### 智能进入 Pod Shell (sh)

```bash
# 交互式选择一个 Pod 并进入其 Shell
ksh default

# 直接进入指定 Pod 的 Shell
ksh default my-pod

# 进入 Pod 中特定容器的 Shell
ksh default my-pod -c my-container
```

#### 切换 Kubernetes 上下文 (sw)

```bash
# 启动交互式上下文切换
ksw
```

## 功能演示

> **注意**：以下演示使用的是别名方式。如果你未设置别名，请将命令替换为对应的完整形式（如 `kubectl magic log` 替代 `klog`）。

### 交互式选择 Pod

当你运行 `klog default` 或 `ksh default` 而不指定具体的 Pod 名称时，命令会显示一个交互式列表：

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

`ksw` 命令提供了一个交互式界面来切换 Kubernetes 上下文：

```
Pick the context to use:

  [ ] minikube
  [ ] docker-desktop
> [x] prod-cluster
  [ ] staging-cluster

Press q to quit.
```

## 别名参考

以下是完整的别名对应关系，方便您参考：

| 别名    | 完整命令                 | 功能描述                   |
|--------|-------------------------|---------------------------|
| kpods  | kubectl magic pods     | 查看 Pod 列表              |
| kcm    | kubectl magic cm       | 管理 ConfigMap            |
| ksc    | kubectl magic sc       | 管理 Secret               |
| krr    | kubectl magic rr       | 滚动重启资源               |
| klog   | kubectl magic log      | 查看 Pod 日志              |
| ksh    | kubectl magic sh       | 进入 Pod 的 Shell          |
| ksw    | kubectl magic sw       | 切换 Kubernetes 上下文     |

## 卸载

如果你想卸载这些工具，只需从安装目录删除所有 `kubectl-magic*` 文件即可。如果你添加了别名，则需要从你的 shell 配置文件（如 `~/.bashrc` 或 `~/.zshrc`）中删除相应的别名配置。

## 贡献

欢迎贡献代码、报告问题或提出改进建议！ 
