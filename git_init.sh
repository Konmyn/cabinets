#! /bin/bash
# my specific git settings

git config --global --list

git config --global user.name 'ethan'
git config --global user.email 'konmyn@gmail.com'
git config --global push.default simple

# status 高亮模式为 auto
git config --global color.status auto
# branch 高亮模式为 auto
git config --global color.branch auto
# ui 高亮模式为 auto
git config --global color.ui auto

git config --global alias.lg "log --color --graph --pretty=format:'%C(bold red)%h%C(reset) - %C(bold green)(%cr)%C(bold blue)<%an>%C(reset) -%C(bold yellow)%d%C(reset) %s' --abbrev-commit"
git config --global alias.st status

# 解决中文文件显示问题
git config --global core.quotepath false
git config core.editor vim

git config --global --list

# you may also set below
# git config --system
# git config --system --list
