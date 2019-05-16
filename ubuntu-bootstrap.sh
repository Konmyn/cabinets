#!/bin/bash

echo "user:" $(id)
echo "home:" $HOME

# https://linuxconfig.org/how-to-change-welcome-message-motd-on-ubuntu-18-04-server
# disable login message for user
touch $HOME/.hushlogin

sh -c "$(wget https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh -O -)"

# https://github.com/wting/autojump
mkdir -p workspace/github
cd workspace/github
git clone git://github.com/wting/autojump.git
cd autojump
./install.py
cd ~
echo '[[ -s /home/matrix/.autojump/etc/profile.d/autojump.sh ]] && source /home/matrix/.autojump/etc/profile.d/autojump.sh' >> ~/.zshrc
echo 'autoload -U compinit && compinit -u' >> ~/.zshrc

sed -i 's/#force_color_prompt/force_color_prompt/g' ~/.bashrc && sed -i 's/alF/lh/g' ~/.bashrc

# https://github.com/zsh-users/zsh-autosuggestions/blob/master/INSTALL.md
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
# plugins=(zsh-autosuggestions)

# https://github.com/zsh-users/zsh-syntax-highlighting/blob/master/INSTALL.md
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
# plugins=( [plugins...] zsh-syntax-highlighting)
sed -i 's/robbyrussell/ys/g' ~/.zshrc
sed -i 's/(git)/(git zsh-autosuggestions zsh-syntax-highlighting)/g' ~/.zshrc
