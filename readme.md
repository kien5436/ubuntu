## Some setup for new ubuntu

##### Uninstall
```
sudo apt purge --remove -y aisleriot gnome-sudoku gnome-mahjongg ace-of-penguins gnome-mines gbrainy cheese thunderbird
# remove amazon
sudo rm /usr/share/applications/ubuntu-amazon-default.desktop /usr/share/unity-webapps/userscripts/unity-webapps-amazon/Amazon.user.js /usr/share/unity-webapps/userscripts/unity-webapps-amazon/manifest.json
```

##### Install
1. git
```sh
sudo apt install -y git
```

2. curl
```sh
sudo apt install -y curl
```

3. Node.js
- [NodeSource](https://github.com/nodesource/distributions/blob/master/README.md#debmanual)
```sh
curl -sL https://deb.nodesource.com/setup_10.x | sudo -E bash -
sudo apt-get install -y nodejs
```
- Or go to [download page](https://nodejs.org/en/download/) then [follow 2 first steps](https://github.com/nodejs/help/wiki/Installation)

4. vscode
```sh
sudo snap install --classic code
```
Follow this page if failed: [https://code.visualstudio.com/docs/setup/linux](https://code.visualstudio.com/docs/setup/linux)

5. fcitx-unikey
```sh
sudo apt-get install -y fcitx-unikey
im-config -n fcitx
```
Restart computer to fcitx work. Add unikey into config and double click on it to choose kinds of typing

6. Google Chrome
```sh
curl --output /tmp/chrome.deb https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
sudo dpkg -i /tmp/chrome.deb
```

7. Postman
```sh
wget https://dl.pstmn.io/download/latest/linux64 -O /tmp/postman.tar.gz
sudo tar -xzf /tmp/postman.tar.gz -C /opt/postman
# Create a Desktop Entry
cat > ~/.local/share/applications/postman.desktop <<EOL
[Desktop Entry]
Encoding=UTF-8
Name=Postman
Exec=/opt/postman/Postman
Icon=/opt/postman/app/resources/app/assets/icon.png
Terminal=false
Type=Application
Categories=Development;
EOL
```

8. Copyq
```sh
sudo apt install -y copyq
```

9. LAMP stack

[DigitalOcean guide](https://www.digitalocean.com/community/tutorials/how-to-install-linux-apache-mysql-php-lamp-stack-ubuntu-18-04)

[phpMyAdmin](https://www.digitalocean.com/community/tutorials/how-to-install-and-secure-phpmyadmin-on-ubuntu-18-04)

10. Tweak tools
```sh
sudo apt install -y gnome-tweaks
sudo apt install -y gnome-shell-extensions
```

11. Hide dash X: Hide the ugly dash of built-in gnome
```sh
wget https://extensions.gnome.org/extension-data/hide-dash%40xenatt.github.com.v8.shell-extension.zip -P /tmp/
unzip /tmp/hide-dash@xenatt.github.com.v8.shell-extension.zip -d ~/.local/share/gnome-shell/extensions/hide-dash@xenatt.github.com # directory name is the uuid in metadata.json file
```
Press `Alt+F2` and enter `r` to restart GNOME Shell

##### Automatically mount a partition
```sh
sudo blkid # get partitions's UUID
sudo nano /etc/fstab
```

Paste the following line and replace the `UUID` and `mount point` you want:
```sh
UUID=<uuid> /mnt/<uuid or dir_name> ntfs-3g async,auto,exec,nouser,rw,nosuid,nodev,nofail 0 0
```
Use `nautilus` to bookmarks this location for easy access

##### Dock
```sh
gsettings set org.gnome.shell.extensions.dash-to-dock dock-fixed false
gsettings set org.gnome.shell.extensions.dash-to-dock autohide true
gsettings set org.gnome.shell.extensions.dash-to-dock click-action 'minimize'
gsettings set org.gnome.shell.extensions.dash-to-dock extend-height false

# optional
# gsettings set org.gnome.shell.extensions.dash-to-dock intellihide true
## transparency
# gsettings set org.gnome.shell.extensions.dash-to-dock customize-alphas true
# gsettings set org.gnome.shell.extensions.dash-to-dock min-alpha 0
# gsettings set org.gnome.shell.extensions.dash-to-dock max-alpha 0

```

##### Change login background
```sh
code /usr/share/gnome-shell/theme/ubuntu.css
```
Find `lockDialogGroup` and replace whatever you want. Restart computer for applying change.

##### Make top bar transparent
Use a theme, change its css:
```css
#panel,
#panel.solid {
  ...
  background-color: transparent;
}
```