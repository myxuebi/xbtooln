#!/usr/bin/env bash
######
#脚本网站:shell.xb6868.com
#论坛:bbs.xb6868.com
#github:https://github.com/myxuebi/xbtooln
#github_url="https://github.com"
######
Y="\e[33m"
G="\e[32m"
R="\e[31m"
E="\e[0m"
######
wget_check(){
if [ $? = 0 ];then
	echo -e "${G}下载完成...${E}"
else
	echo -e "${R}下载失败...${E}"
	electron_
	sleep 5
	exit
fi
}
######
curl_check()
{
if [ $? = 0 ];then
	echo -e "${G}数据拉取完成...${E}"
else
	echo -e "${R}数据拉取失败...${E}"
	sleep 5
	electron_
	exit
fi
}
######
electron_(){
dialog --title "提示:" --yesno "是否启用github镜像站进行下载？（国内用户可能会增加使用体验）" 0 0
if [ $? = 0 ];then
	github_url="https://gh.api.99988866.xyz/https://github.com"
	github_raw="https://gh.api.99988866.xyz/https://raw.githubusercontent.com"
else
	github_url="https://github.com"
	github_raw="https://raw.githubusercontent.com"
	dialog --title "温馨提示" --msgbox "此功能较多的依赖github，国内用户可能出现无法链接的问题\n有能力的用户可自行修改url或采用其他方法" 0 0
fi
system=$(cat /etc/os-release | gawk 'NR==1' | gawk -F '"' '{print $2}' | gawk '{print $1}')
case $(uname -m) in
	aarch64)arch="arm64"
	       arch1="arm64"	;;
	x86_64)arch="x64"
	       arch1="x86_64"	;;
	*)echo "不支持的架构"
	       exit	;;
esac
if [ ! $(command -v electron) ];then
	electron_install
fi
input=$(dialog --title "Install Electron" --menu "选择一项来安装" 0 0 0 1 icalingua++-第三方QQ客户端 2 etcher-仅支持x64 3 netease-cloud-music-第三方网抑云 --output-fd 1)
case $input in
	1)name="icalingua++"
	app_url="Icalingua-plus-plus/Icalingua-plus-plus"
	icon_url="$github_raw/Icalingua-plus-plus/Icalingua-plus-plus/development/icalingua/static/icons/512x512.png"
        Categories="chat;Network;" ;;
        2)name="balenaEtcher"
	app_url="balena-io/etcher"
	icon_url="$github_raw/balena-io/etcher/master/assets/icon.png"
        Categories="Utility;" ;;
        3)name="netease-cloud-music"
	app_url="Rocket1184/electron-netease-cloud-music"
	icon_url="$github_raw/Rocket1184/electron-netease-cloud-music/master/assets/icons/icon.png"
        Categories="AudioVideo;Player;"	;;
        *)exit ;;
esac
mkdir /usr/local/bin/electron/$name
version=$(curl https://github.com/$app_url | grep "max-width" | grep "span" | gawk -F ">" '{print $2}' | gawk -F "<" '{print $1}')
curl_check
case $arch in
    arm64)if [ $name = balenaEtcher ] ;then echo -e "${R}不受软件支持的架构${E}" && exit ;fi ;;
    *)sleep 0.1 ;n
esac
case $name in
	icalingua++)all_name="app-$arch1.asar" ;;
	balenaEtcher)all_name="balenaEtcher-$(echo $version | gawk -F "v" | gwak '{print $2}')-x64.AppImage" ;;
	netease-cloud-music)all_name="electron-netease-cloud-music_$version.asar" ;;
esac
case $name in
	icalingua++)wget $github_url/Icalingua-plus-plus/Icalingua-plus-plus/releases/download/v$version/app-$arch1.asar -t 10 -P /usr/local/bin/electron/$name/ ;;
	*)wget $github_url/$app_url/releases/download/$version/$all_name -t 10 -P /usr/local/bin/electron/$name/ ;;
esac
wget_check
wget $icon_url -t 10 -O ${name}.png
wget_check
mv $name.png /usr/share/icons/
echo "[Desktop Entry]
Categories=$Categories
Exec=electron --no-sandbox /usr/local/bin/electron/$name/$all_name %u
Icon=/usr/share/icons/${name}.png
Name=$name
Terminal=false
Type=Application" >> /usr/share/applications/$name.desktop
chmod 777 /usr/share/applications/$name.desktop
}
electron_install()
{
	electron_url=$(curl https://github.com/electron/electron | grep "electron v" | gawk -F ">" '{print $2}' | gawk -F "<" '{print $1}' | gawk '{print $2}')
	curl_check
	wget $github_url/electron/electron/releases/download/$electron_url/electron-$electron_url-linux-$arch.zip -t 10 -O electron.zip
	wget_check
	mkdir /usr/local/bin/electron
	unzip electron.zip -d /usr/local/bin/electron
	ln -s /usr/local/bin/electron/electron /usr/bin/electron
	rm electron.zip
}
electron_
