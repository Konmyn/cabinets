FROM docker.io/ubuntu:18.04

ENV TZ Asia/Shanghai
ENV LC_ALL=en_US.UTF-8
ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US.UTF-8

COPY .bashrc /root/.bashrc

# 安装常用工具
RUN sed 's/archive.ubuntu.com/mirrors.aliyun.com/g' -i /etc/apt/sources.list \
 && sed 's/security.ubuntu.com/mirrors.aliyun.com/g' -i /etc/apt/sources.list \
 && apt update
#     && apt install bash-completion vim net-tools tcpdump iproute2 wget ca-certificates unzip bind-utils file telnet gcc -y
RUN rm -rf /var/cache/apt/archives/*
WORKDIR /root