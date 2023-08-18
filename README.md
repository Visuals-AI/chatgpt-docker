# chatgpt-docker

> docker 一键部署 ChatGPT 服务端

------

## 概要

通过 openai 的 API 调用 ChatGPT 的能力，便于共享给家人使用：

![](./imgs/01.jpg)

历史对话存储在浏览器中，确保个人隐私：

![](./imgs/02.jpg)

优点：

1. Docker 一键部署，任何环境均可使用
2. 模仿 ChatGPT 的操作 UI，保持用户习惯
3. 在个人 VPS 上部署可免处挂梯子麻烦，便于家人共享
4. Web 页面有 BasicAuth 认证，防止未授权访问
5. 自带防爬虫机制，避免被抓取

> 本质就是通过官方 API 使用 ChatGPT 的能力，与直接使用 ChatGPT 是一样的。API 好处是自选模型，价格上比 ChatGPT Plus 包月划算。

## 准备

1. 部署一台 VPS 服务器（可用于直接部署 ChatGPT-Docker、亦可用于本地部署 ChatGPT-Docker 后通过科学上网使用）
2. VPS/本地安装 docker、docker-compose
3. VPS/本地安装 python3
4. 申请一个 openai 账户，同时绑定一张境外银行卡以激活 API 调用权限（费用自负）
5. 生成一个 API key


## 运行环境



## 部署步骤

```
git submodule update --remote --recursive

python3 -m pip install -r py/requirements.txt
python3 py/gen_basicauth.py -u "chatgpt" -p "TPGtahc#654321"

bin/build.sh
bin/run.sh -k "${OPENAI_API_KEY}" -u "${USERNAME}" -p "${PASSWORD}" -s "host.docker.internal" -r 10089
```