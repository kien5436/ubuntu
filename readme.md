## Some setup for new ubuntu

##### Uninstall
```
sudo apt purge --auto-remove aisleriot gnome-sudoku mahjongg ace-of-penguins gnomine gbrainy
# remove amazon
sudo rm /usr/share/applications/ubuntu-amazon-default.desktop /usr/share/unity-webapps/userscripts/unity-webapps-amazon/Amazon.user.js /usr/share/unity-webapps/userscripts/unity-webapps-amazon/manifest.json
```

##### Install
1. git
```
sudo apt install git
```

2. curl
```
sudo apt install curl
```

3. Node.js
- [NodeSource](https://github.com/nodesource/distributions/blob/master/README.md#debmanual)
```
curl -sL https://deb.nodesource.com/setup_10.x | sudo -E bash -
sudo apt-get install -y nodejs
```
- Or go to [download page](https://nodejs.org/en/download/) then [follow 2 first steps](https://github.com/nodejs/help/wiki/Installation)

4. vscode
```
sudo snap install --classic code
```
Follow this page if failed: [https://code.visualstudio.com/docs/setup/linux](https://code.visualstudio.com/docs/setup/linux)

5. fcitx-unikey
```
sudo apt-get install fcitx-unikey
im-config -n fcitx
```
Restart computer to fcitx work. Add unikey into config and double click on it to choose kinds of typing

6. Google Chrome
```
curl --ouput /tmp/chrome.deb https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb 
sudo dpkg -i /tmp/chrome.deb
```

7. Postman
```
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
```
sudo apt install copyq
```

##### Automatically mount a partition
```
sudo blkid # get partitions's UUID
sudo nano /etc/fstab
```

Paste the following line and replace the `UUID` and `mount point` you want:
```
UUID=<uuid> /mnt/<uuid or dir_name> ntfs-3g async,auto,exec,nouser,rw,nosuid,nodev,nofail 0 0
```
Use `nautilus` to bookmarks this location for easy access

##### Dock
```
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
