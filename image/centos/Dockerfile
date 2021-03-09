FROM docker.io/centos:centos7.6.1810

ENV TZ Asia/Shanghai
ENV LC_ALL=en_US.UTF-8
ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US.UTF-8

COPY CentOS-Base.repo /etc/yum.repos.d/
COPY .bashrc /root/.bashrc

# 安装常用工具
RUN sed -i 's/enabled=1/enabled=0/g' /etc/yum/pluginconf.d/fastestmirror.conf \
    && yum install bash-completion vim net-tools tcpdump iproute wget ca-certificates unzip bind-utils file telnet gcc --nogpgcheck -y && yum clean all

WORKDIR /root