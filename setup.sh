#!/bin/bash

# Escalate the script to sudo
if [ "$EUID" != 0 ]; 
then
  sudo "$0" "$@"
  exit $?
fi

clear;

update_packages() {
  printf "\n====================================================\n"
  echo "Updating Packages"
  printf "====================================================\n\n"

  sudo apt update
  sudo apt -y upgrade
  sudo apt -y autoremove

  sudo apt -y install compizconfig-settings-manager
}

create_dirs () {
  printf "\n====================================================\n"
  echo "Creating Directories"
  printf "====================================================\n\n"

  if [ ! -d "/home/$SUDO_USER/Desktop/Repositories" ];
  then 
    sudo -u $SUDO_USER mkdir "/home/$SUDO_USER/Desktop/Repositories"
    echo "The \"Repositories\" directory was created on your desktop"; 
  else 
    echo "The \"Repositories\" directory already exists";
  fi
}

install_node() {
  printf "\n====================================================\n"
  echo "Installing NodeJS"
  printf "====================================================\n\n"
  
  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.35.3/install.sh | sudo -u $SUDO_USER bash
  export NVM_DIR="/home/$SUDO_USER/.nvm"
  [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
  [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
  nvm install lts/fermium
	sudo chown -R $SUDO_USER:$(id -gn $SUDO_USER) /home/potrottier/.config
}

install_docker() {
  printf "\n====================================================\n"
  echo "Installing Docker"
  printf "====================================================\n\n"
  
  sudo apt remove docker docker-engine docker.io containerd runc
  sudo apt update
  sudo apt -y install apt-transport-https ca-certificates curl gnupg lsb-release
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
  echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
  sudo apt update
  sudo apt -y install docker-ce docker-ce-cli containerd.io
  sudo usermod -aG docker $SUDO_USER
}

install_edge() {
  printf "\n====================================================\n"
  echo "Installing Microsoft Edge"
  printf "====================================================\n\n"

  curl https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > microsoft.gpg
  sudo install -o root -g root -m 644 microsoft.gpg /etc/apt/trusted.gpg.d/
  sudo sh -c 'echo "deb [arch=amd64] https://packages.microsoft.com/repos/edge stable main" > /etc/apt/sources.list.d/microsoft-edge-beta.list'
  sudo rm microsoft.gpg
  sudo apt update
  sudo apt -y install microsoft-edge-beta
}

install_gitui() {
  printf "\n====================================================\n"
  echo "Installing GitKraken"
  printf "====================================================\n\n"

  version=$(snap --version)
  if [ $? = 0 ]; 
  then
    sudo snap install --classic gitkraken
  else
    wget https://release.gitkraken.com/linux/gitkraken-amd64.deb
    sudo dpkg -i gitkraken-amd64.deb
    sudo rm gitkraken-amd64.deb
  fi
}

install_pia() {
  printf "\n====================================================\n"
  echo "Installing Private Internet Access"
  printf "====================================================\n\n"

  wget https://installers.privateinternetaccess.com/download/pia-linux-2.8.1-06335.run
  sudo -u $SUDO_USER sh pia-linux-2.8.1-06335.run
  sudo rm pia-linux-2.8.1-06335.run
}

install_jetbrains() {
  printf "\n====================================================\n"
  echo "Installing JetBrains Toolbox"
  printf "====================================================\n\n"

  wget https://download.jetbrains.com/toolbox/jetbrains-toolbox-1.20.8352.tar.gz
  sudo mkdir /opt/jetbrains
  sudo tar -C /opt/jetbrains -zxvf jetbrains-toolbox-1.20.8352.tar.gz
  rm jetbrains-toolbox-1.20.8352.tar.gz
  /opt/jetbrains/jetbrains-toolbox-1.20.8352/jetbrains-toolbox
}

install_tweaks() {
  printf "\n====================================================\n"
  echo "Installing Gnome Tweaks"
  printf "====================================================\n\n"

  sudo apt -y install gnome-tweaks
}

install_spotify() {
  printf "\n====================================================\n"
  echo "Installing Spotify"
  printf "====================================================\n\n"

  version=$(snap --version)
  if [ $? = 0 ]; 
  then
    sudo sudo snap install spotify
  else
    sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 4773BD5E130D1D45
    echo "deb http://repository.spotify.com stable non-free" | sudo tee /etc/apt/sources.list.d/spotify.list
    sudo apt update
    sudo apt install spotify-client
  fi
}

install_vscode() {
  printf "\n====================================================\n"
  echo "Installing VSCode"
  printf "====================================================\n\n"

  version=$(snap --version)
  if [ $? = 0 ]; 
  then
    sudo snap install --classic code
  else
    sudo apt install software-properties-common apt-transport-https wget
    wget -q https://packages.microsoft.com/keys/microsoft.asc -O- | sudo apt-key add -
    sudo add-apt-repository "deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main"
    sudo apt install code
  fi
}

install_onedrive() {
  printf "\n====================================================\n"
  echo "Installing OneDrive"
  printf "====================================================\n\n"

  echo -e "deb http://ppa.launchpad.net/mmozeiko/rclone-browser/ubuntu xenial main\ndeb-src http://ppa.launchpad.net/mmozeiko/rclone-browser/ubuntu xenial main" | sudo tee /etc/apt/sources.list.d/rclonebrowser.list
  sudo apt update
  sudo apt -y install rclone-browser
  curl https://rclone.org/install.sh | sudo bash
  rclone config
  
  echo "To setup automount use the following tutorial: https://itsfoss.com/use-onedrive-linux-rclone/"
}

install_onepass() {
  printf "\n====================================================\n"
  echo "Installing 1Password"
  printf "====================================================\n\n"

  version=$(snap --version)
  if [ $? = 0 ]; 
  then
    sudo snap install 1password
  else
    curl -sS https://downloads.1password.com/linux/keys/1password.asc | sudo apt-key add -
    echo 'deb [arch=amd64] https://downloads.1password.com/linux/debian/amd64 beta main' | sudo tee /etc/apt/sources.list.d/1password-beta.list
    sudo mkdir -p /etc/debsig/policies/AC2D62742012EA22/
    curl -sS https://downloads.1password.com/linux/debian/debsig/1password.pol | sudo tee /etc/debsig/policies/AC2D62742012EA22/1password.pol
    sudo mkdir -p /usr/share/debsig/keyrings/AC2D62742012EA22
    curl -sS https://downloads.1password.com/linux/keys/1password.asc | sudo gpg --dearmor --output /usr/share/debsig/keyrings/AC2D62742012EA22/debsig.gpg
    sudo apt update && sudo apt install 1password
  fi
}

install_discord() {
  printf "\n====================================================\n"
  echo "Installing Discord"
  printf "====================================================\n\n"

  version=$(snap --version)
  if [ $? = 0 ]; 
  then
    sudo snap install discord
  else
    sudo apt install gdebi-core wget
    $ wget -O ~/discord.deb "https://discordapp.com/api/download?platform=linux&format=deb"
    sudo gdebi -y ~/discord.deb 
  fi
}

install_office() {
  printf "\n====================================================\n"
  echo "Installing Office"
  printf "====================================================\n\n"

  version=$(snap --version)
  if [ $? = 0 ]; 
  then
    sudo snap install onlyoffice-desktopeditors
  else
    echo "COULD NOT INSTALL OnlyOffice" 
  fi
}

install_teams() {
  printf "\n====================================================\n"
  echo "Installing Microsoft Teams"
  printf "====================================================\n\n"

  # TODO
  echo "TODO"
}

cleanup() {
  printf "\n====================================================\n"
  echo "Cleaning Up"
  printf "====================================================\n\n"

  sudo apt update
  sudo apt -y autoremove
  newgrp docker
}

# Display multiselect menu
options=(
  "Update Packages" 
  "Create Directories" 
  "Install NodeJS" 
  "Install Docker" 
  "Install Microsoft Edge" 
  "Install GitKraken" 
  "Install PIA" 
  "Install JetBrains Toolbox" 
  "Install Gnome Tweaks" 
  "Install Spotify" 
  "Install VS Code"
  "Install OneDrive"
  "Install 1Password"
  "Install Discord"
  "Install Office"
  "Install Microsoft Teams [TODO]"
)

for i in ${!options[@]}; do
  choices[i]="✓"
done

menu() {
  echo "Avaliable options:"
  for i in ${!options[@]}; do
      printf " %s%3d) %s\n" "${choices[i]:- }" $((i+1)) "${options[i]}"
  done
  [[ "$msg" ]] && printf "\n$msg\n"; :
}
 
prompt=$'\nCheck an option (again to uncheck, ENTER when done):'
while menu && read -rp "$prompt" num && [[ "$num" ]]; do
  clear &&
  [[ "$num" != *[![:digit:]]* ]] &&
  (( num > 0 && num <= ${#options[@]} )) ||
  { msg="Invalid option: $num"; continue; }
  ((num--)); msg="${options[num]} was ${choices[num]:+de}selected"
  [[ "${choices[num]}" ]] && choices[num]="" || choices[num]="✓"
done

if [ ${#choices[@]} -eq 0 ]; 
then
  printf "\nYou selected nothing.\n\n"
  exit 1
fi

clear;

# Run the functions
if [ "${choices[0]}" != "" ]; 
then
  # Update Packages
  update_packages
fi
if [ "${choices[1]}" != "" ]; 
then
  # Create Directories
  create_dirs
fi
if [ "${choices[2]}" != "" ]; 
then
  # Install NodeJS
  install_node
fi
if [ "${choices[3]}" != "" ]; 
then
  # Install Docker
  install_docker
fi
if [ "${choices[4]}" != "" ]; 
then
  # Install Microsoft Edge
  install_edge
fi
if [ "${choices[5]}" != "" ]; 
then
  # Install Git Kraken
  install_gitui
fi
if [ "${choices[6]}" != "" ]; 
then
  # Install PIA
  install_pia
fi
if [ "${choices[7]}" != "" ]; 
then
  # Install JetBraind Toolbox
  install_jetbrains
fi
if [ "${choices[8]}" != "" ]; 
then
  # Install Gnome Tweaks
  install_tweaks
fi
if [ "${choices[9]}" != "" ]; 
then
  # Install Spotify
  install_spotify
fi
if [ "${choices[10]}" != "" ]; 
then
  # Install VSCode
  install_vscode
fi
if [ "${choices[11]}" != "" ]; 
then
  # Install OneDrive Sync
  install_onedrive
fi
if [ "${choices[12]}" != "" ]; 
then
  # Install 1Password
  install_onepass
fi
if [ "${choices[13]}" != "" ]; 
then
  # Install Discord
  install_discord
fi
if [ "${choices[14]}" != "" ]; 
then
  # Install Office
  install_office
fi
if [ "${choices[15]}" != "" ]; 
then
  # Install MS Teams
  install_teams
fi

cleanup

printf "\n====================================================\n"
echo "Script has executed successfully..."
printf "====================================================\n\n"

