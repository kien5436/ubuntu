# Some setup for new ubuntu (GNOME)

- [Uninstall](#uninstall)
- [Install](#install)
- [Automatically mount a partition](#automatically-mount-a-partition)
- [Tweaks](#dock)

##### Uninstall
```
sudo apt purge -y aisleriot gnome-sudoku gnome-mahjongg ace-of-penguins gnome-mines gbrainy cheese thunderbird libreoffice* gedit
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
curl -sL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
sudo apt-get install -y nodejs
```
- Or go to [download page](https://nodejs.org/en/download/) then [follow 2 first steps](https://github.com/nodejs/help/wiki/Installation)

4. vscode

Use `vscodium` instead https://github.com/VSCodium/vscodium
```sh
sudo snap install --classic code
```
Follow this page if failed: [https://code.visualstudio.com/docs/setup/linux](https://code.visualstudio.com/docs/setup/linux)

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

11.1 Dash to dock

https://micheleg.github.io/dash-to-dock/download.html

11.2 Dash to panel

https://extensions.gnome.org/extension/1160/dash-to-panel/

```sh
unzip /tmp/hide-dash@xenatt.github.com.v8.shell-extension.zip -d ~/.local/share/gnome-shell/extensions/hide-dash@xenatt.github.com # directory name is the uuid in metadata.json file
```
Press `Alt+F2` and enter `r` to restart GNOME Shell

11.3 Deskchanger

https://extensions.gnome.org/extension/1131/desk-changer/

12. Android Studio
```sh
sudo snap install android-studio --classic
```

13. WPS Office
```sh
# download .deb package from https://linux.wps.com
sudo dpkg -i wps-office*.deb
```

14. Firefox dev
```sh
# first, uninstall the default firefox
sudo apt purge firefox
# download the latest version
cd ~/Downloads
curl -Lo firefox.tar.bz2 'https://download.mozilla.org/?product=firefox-devedition-latest-ssl&os=linux64&lang=en-US'
sudo tar -xvf firefox.tar.bz2 -C /opt
# grant read-write permission for updating
sudo chown -R $USER:$USER /opt/firefox
# create symbolic link so you can use `firefox` anywhere
ln -s /opt/firefox/firefox-bin /usr/bin/firefox
# create quick launch icon
cat > ~/.local/share/applications/firefox.desktop <<EOL
[Desktop Entry]
Encoding=UTF-8
Name=Firefox
Exec=/opt/firefox/firefox-bin %u
Icon=/opt/firefox/browser/chrome/icons/default/default128.png
Terminal=false
Type=Application
Categories=Application
StartupWMClass=Firefox Developer Edition
EOL
```
15. Ibus bamboo
```sh
sudo add-apt-repository ppa:bamboo-engine/ibus-bamboo
sudo apt-get update
sudo apt-get install -y ibus-bamboo
ibus restart
```

16.1. Fluent icon

```sh
git clone https://github.com/vinceliuice/Fluent-icon-theme
cd Fluent-icon-theme
./install red -b
```

16.2. Fluent theme

```sh
git clone https://github.com/vinceliuice/Fluent-gtk-theme
cd Fluent-gtk-theme
./install.sh -t red -c dark -s standard -i popos --tweaks noborder
```

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

##### Change login background
```sh
subl /usr/share/gnome-shell/theme/ubuntu.css
```
Find `lockDialogGroup` and replace whatever you want. Restart computer for applying change.

##### Make top bar transparent
Change css in `/usr/share/gnome-shell/theme/ubuntu.css` or `/usr/share/themes/<themes name>/gnome-shell/gnome-shell.css`:
```css
#panel,
#panel.solid {
  ...
  background-color: transparent;
}
```

#### Hide long path in terminal
Find `if [ "$color_prompt" = yes ]; then` in `~/.bashrc` and change `\w` to `\W`

#### Backup and restore terminal profile
```sh
# profiles list
dconf dump /org/gnome/terminal/legacy/profiles:/ | grep -e "\[\:\|visible-name"
# backup
dconf dump /org/gnome/terminal/legacy/profiles:/<profile id>/ > <profile name>.dconf
# restore
dconf load /org/gnome/terminal/legacy/profiles:/<profile id>/ < <profile name>.dconf
# apply changes
dconf write /org/gnome/terminal/legacy/profiles:/default "'<profile id>'"
dconf write /org/gnome/terminal/legacy/profiles:/list "['<profile id>']"
# delete
dconf reset -f /org/gnome/terminal/legacy/profiles:/<profile id>/
```
