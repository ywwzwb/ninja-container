# NinjaDesktop

这是某个肥料代理平台开发的软件, 我只是包装为一个容器, 这样方便部署.
主要功能是提供 socks5 代理给局域网使用.

二进制来源于: https://github.com/kachetong1314/ninja/releases 的
`ninjadesktop-lite_<版本>_amd64.deb` / `ninjadesktop-lite_<版本>_arm64.deb`

解包 deb 后提取得来(去掉其中的 `ninja-service`, 只保留 `ninjadesktop-lite` 与 `core/`).

账号安全请找原主.
进去之后, 需要启动自动加速, 然后设置 -> 行为中, 允许局域网链接, 并**保存设置**

## 镜像

- `ghcr.io/ywwzwb/ninja-container:latest`
- `ghcr.io/ywwzwb/ninja-container:v1.0.8` (tag 名即上游 release 版本号)

多架构: `linux/amd64`, `linux/arm64`

## 使用

```bash
docker run -d --name ninja \
  -p 9190:9190 -p 7897:7897 -p 7898:7898 -p 7899:7899 \
  -v ninja-config:/etc/ninja \
  --restart unless-stopped \
  ghcr.io/ywwzwb/ninja-container:latest
```

WebUI: `http://<host>:9190`

## 更新版本(自动构建)

`.github/workflows/build.yml` 会在推送 `v*` tag 时构建并推送镜像,
并把 tag 名去掉 `v` 作为上游版本号传给 Dockerfile:

```bash
git tag v1.0.9
git push origin v1.0.9
```

即可自动下载上游 `ninjadesktop-lite_1.0.9_{amd64,arm64}.deb` 并构建对应镜像.
推 main 分支则使用 Dockerfile 里 `ARG NINJA_VERSION` 的默认值构建 `latest`.

注意: 上游部分 release 只有 Windows 安装包(例如 1.0.10), 那种版本无法用于本容器,
打 tag 前先确认 release 里有 `ninjadesktop-lite_<版本>_amd64.deb`.

## 部署备注(192.168.11.1 路由器 Docker)

现有容器名 `jinkela`, 镜像固定到具体 tag(当前 `ghcr.io/ywwzwb/ninja-container:v1.0.8`).

- **必须写 `--hostname jinkela`**: 登录凭据(`auth.enc` / `device.enc` / `vault.key.enc`)的加密密钥
  由容器主机名派生, hostname 一变应用就会重新生成身份, **登录态直接丢失**.
- 配置和数据必须挂卷, 别留在容器层:
  - `ninja-config:/root/.config/ninjadesktop` (appconfig.yaml)
  - `ninja-data:/root/.local/share/ninjadesktop` (登录凭据、订阅、geodata、bootstrap.yaml)
  - `/etc/ninja` 是旧的空卷, 应用实际不用它
- 该机 docker 拉层时 `pkg-containers.githubusercontent.com` 会被解析成 IPv6 而卡死,
  已在 `/etc/hosts` 固定为 `185.199.108.154 pkg-containers.githubusercontent.com`
- 迁移/升级时不要复制 `kernel.pid`、`kernel_session.json`、`lite-instance.sock`, 让应用重新生成.

```bash
docker create --name jinkela --hostname jinkela --restart unless-stopped \
  -p 9190:9190 -p 7897:7897 -p 7898:7898 -p 7899:7899 \
  -v ninja-config:/root/.config/ninjadesktop \
  -v ninja-data:/root/.local/share/ninjadesktop \
  ghcr.io/ywwzwb/ninja-container:v1.0.8
docker start jinkela
```

验证: `curl http://<host>:9190/api/auth/status` 里 `logged_in` 为 `true`,
`docker exec jinkela ps aux` 里能看到 `core/ninja-linux-<arch>` 内核进程.
