#!/bin/bash

if [ "$EUID" -ne 0 ]
  then echo "Please run use sudo "
  exit
fi

whoami
id
echo $EUID
echo "home:" $HOME

# change apt source manually
# apt update && apt install git -y
#ls /etc/apt/sources.list.backup &> /dev/null || ( echo "backup apt sources" && cp /etc/apt/sources.list /etc/apt/sources.list.backup )
#grep -E "security.ubuntu.com|cn.archive.ubuntu.com" /etc/apt/sources.list && ( sed -i 's/cn.archive.ubuntu.com/mirrors.cn99.com/g' /etc/apt/sources.list && sed -i 's/security.ubuntu.com/mirrors.cn99.com/g' /etc/apt/sources.list )

apt update && apt upgrade -y
apt autoclean
apt clean
apt autoremove
apt install open-vm-tools-desktop vim openssh-server curl zsh python3-pip tree htop glances -y

# https://linuxconfig.org/how-to-change-welcome-message-motd-on-ubuntu-18-04-server
# disable login message for user
touch $HOME/.hushlogin

sh -c "$(wget https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh -O -)" exit

# https://github.com/wting/autojump
sudo -u matrix git clone git://github.com/wting/autojump.git
cd autojump
./install.py
echo '[[ -s /home/matrix/.autojump/etc/profile.d/autojump.sh ]] && source /home/matrix/.autojump/etc/profile.d/autojump.sh' >> ~/.zshrc
echo 'autoload -U compinit && compinit -u' >> ~/.zshrc

sed -i 's/#force_color_prompt/force_color_prompt/g' ~/.bashrc && sed -i 's/alF/lh/g' ~/.bashrc

# https://github.com/zsh-users/zsh-autosuggestions/blob/master/INSTALL.md
sudo -u matrix git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
# plugins=(zsh-autosuggestions)

# https://github.com/zsh-users/zsh-syntax-highlighting/blob/master/INSTALL.md
sudo -u matrix git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
# plugins=( [plugins...] zsh-syntax-highlighting)
sed -i 's/robbyrussell/ys/g' ~/.zshrc
sed -i 's/(git)/(git zsh-autosuggestions zsh-syntax-highlighting)/g' ~/.zshrc

cat > /etc/pip.conf << EOF
[global]
index-url = https://mirrors.aliyun.com/pypi/simple/
EOF

pip3 install ipython

