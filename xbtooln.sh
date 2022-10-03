#!/usr/bin/env bash
######
#脚本网站:shell.xb6868.com
#论坛:bbs.xb6868.com
#github:https://github.com/myxuebi/xbtooln
shell_url="https://raw.githubusercontent.com/myxuebi/xbtooln/master/files"
#shell_url="https://shell.xb6868.com/xbtool"
######
Y="\e[33m"
G="\e[32m"
R="\e[31m"
E="\e[0m"
######
#判断包管理程序并赋值
if [ ! $(command -v pacman) ];then
	if [ ! $(command -v apt) ];then
		echo -e "${R}Error:未检测到支持的包管理器${E}"
		exit
	else
		update_pkg="apt update"
		install_pkg="apt install"
		remove_pkg="apt remove"
		yes="-y"
	fi
else
	update_pkg="pacman -Syy"
	install_pkg="pacman -S"
	remove_pkg="pacman -R"
	yes="--noconfirm"
fi
######
#每日更新源
update_date=`date +"%D"`
if cat .update.log | grep -q $update_date
then
	sleep 0.1
else
	$update_pkg
	echo "$update_date" >>.update.log
fi
######
version(){
echo "beta 0.0.1
只有基础termux功能
2022/9/1

2022/9/30
beta 0.0.2
修复已知bug"
}
######
wget_check(){
if [ $? = 0 ];then
	echo -e "${G}下载成功...${E}"
else
	echo -e "${R}下载失败，请检查网络连接...${E}"
	exit
fi
}
######
#系统判断及依赖安装 
start(){
echo -e "${R}警告！您使用的是初始beta 0.0.1版，功能很少，有bug${E}"
sleep 3
for i in gawk dialog curl wget pulseaudio proot
do if [ ! $(command -v $i) ];then
	$install_pkg $i $yes
fi done
if [ $(uname -o) = Android ];then
	termux
	exit
fi
SYS_V=$(cat /etc/os-release | gawk 'NR==1' | gawk -F '"' '{print $2}' | gawk '{print $1}')
case $SYS_V in
	Debian | Ubuntu)debian ;;
	Arch)echo "arch功能还没写好呢，亲~"
		exit ;;
	*)if [ ! $(command -v gawk) ]; then
		$install_pkg gawk $yes
		echo -e "${Y}尝试安装awk已完成，请重启脚本${E}"
		exit
	fi
	echo -e "${R}不受支持的系统${E}"
	exit ;;
esac
}
######
termux(){
input=$(dialog --title "Xbtooln Menu" --menu "选择一项" 0 0 0 1 termux换源 2 termux备份/恢复选项 3 Proot安装 4 二维码生成 5 关于脚本 --output-fd 1)
case $input in
	1)input=$(dialog --title "Mirror list" --menu "选择一个源地址" 0 0 0 1 北外源bfsu 2 清华源tuna 3 中科大源ustc 4 更多源选项-termux自带 5 返回上级菜单 --output-fd 1)
		case $input in
			1)mirror_url=mirrors.bfsu.edu.cn ;;
			2)mirror_url=mirrors.tuna.tsinghua.edu.cn ;;
			3)mirror_url=mirrors.ustc.edu.cn ;;
			4)termux-change-repo
				exit ;;
			5)termux
			exit ;;
		        *)exit ;;
		esac
		echo "deb https://$mirror_url/termux/apt/termux-main stable main" >$PREFIX/etc/apt/sources.list
		apt update
		echo -e "${G}更换源已完成${E}"
		sleep 3
		termux ;;
	2)input=$(dialog --title "Termux Backup" --menu "注意：恢复数据可能会覆盖当前数据" 0 0 0 1 备份Termux数据 2 恢复Termux数据 3 返回上级菜单 --output-fd 1)
		case $input in
			1)cd /data/data/com.termux
			tar zcvf huifu.tar.gz files
			mv huifu.tar.gz /sdcard
			echo -e "${G}操作已完成,文件已保存至sdcard，如果没有文件请检查是否开启了存储权限${E}"
			sleep 3
			rm -rf huifu.tar.gz
			termux ;;
		2)file=$(dialog --title "选择你的恢复包文件" --fselect /sdcard/ 7 40 --output-fd 1)
			cd /data/data/com.termux/
			cp $file ./huifu.tar.gz
			tar zxvf huifu.tar.gz
			echo -e "${G}恢复完成${E}"
			sleep 3
			termux ;;
		3)termux
		exit ;;
	esac ;;
        3)proot ;;
	4)test=$(dialog --title "QRCode" --inputbox "输入您要转换成二维码的内容（网址要带https://)：" 0 0 0 --output-fd 1)
		echo "${test}" |curl -F-=\<- qrenco.de
		echo "done.."
		sleep 3
		termux ;;
	5)input=$(dialog --title "About Xbtooln" --menu " " 0 0 0 1 更新日志 2 加入Q群 3 访问论坛 4 返回上级菜单 --output-fd 1)
		case $input in
		1)version
			echo 按回车键继续
			read enter
			termux ;;
		2)am start mqqopensdkapi://bizAgent/qm/qr?url=https%3A%2F%2Fqm.qq.com%2Fcgi-bin%2Fqm%2Fqr%3Fk%3DsggIpVFslC89hhAN9SIke6-5nDYOQytZ%26jump_from%3D%26auth%3D%26app_name%3D%26authSig%3DF4hbz11Ha0k86L%2B4u97r0O6iUpJGPoExq8o3LbvCjFUof3YBRzTRkaCeHiUE43LF%26source_id%3D3_40001
			echo "如果termux没有自动跳转，请手动加入qq群，群号：769436389"
			sleep 5
			termux ;;
		3)am start -a android.intent.action.VIEW -d https://bbs.xb6868.com/
			echo "如果没有自动跳转，请手动访问https://bbs.xb6868.com/"
			sleep 4
			termux ;;
		4)termux ;;
		*)exit ;;
	esac
esac
}
######
#Proot安装
proot(){
proot_system=$(dialog --title "Proot Install" --menu "选择你要安装的Proot容器" 0 0 0 ubuntu 乌班图 debian 致力于自由 archlinux YYDS！ --output-fd 1)
case $proot_system in
	ubuntu)proot_ver=$(dialog --title "Proot Install" --menu "选择你要安装的系统" 0 0 0 bionic 1 focal 2 impish 3 jammy 4 hirstue 5 trusty 6 xenial 7 --output-fd 1) ;;
	debian)proot_ver=$(dialog --title "Proot Install" --menu "选择你要安装的系统" 0 0 0 sid 1 bullseye 2 testing 3 buster 4 strecth 5 jessie 6 --output-fd 1) ;;
	archlinux)proot_ver="current" ;;
	*)exit ;;
esac
if [ ! $(echo "$proot_ver") ];then
	exit
fi
if [ ! $(command -v proot) ];then
     apt install proot -y
fi
DOWN_LINE=$(curl https://mirrors.bfsu.edu.cn/lxc-images/images/${proot_system}/${proot_ver}/arm64/default/ | gawk '{print $3}' | tail -n 3 | head -n 1 | gawk -F '"' '{print $2}' | gawk -F '/' '{print $1}')
rm rootfs.tar.xz
wget https://mirrors.bfsu.edu.cn/lxc-images/images/${proot_system}/${proot_ver}/arm64/default/${DOWN_LINE}/rootfs.tar.xz -t 4
wget_check
mkdir -p .${proot_system}-${proot_ver}/etc/proc
tar xvf rootfs.tar.xz -C .${proot_system}-${proot_ver}
rm .${proot_system}-${proot_ver}/etc/resolv.conf
echo "nameserver 114.114.114.114
nameserver 114.114.115.115" >>.${proot_system}-${proot_ver}/etc/resolv.conf
echo "$(uname -a | sed 's/Android/Xbtooln/g')" >>.${proot_system}-${proot_ver}/etc/proc/version
rm proc.tar.gz
wget ${shell_url}/proc.tar.gz -t 4
wget_check
tar zxvf proc.tar.gz -C .${proot_system}-${proot_ver}/etc/proc/
rm rootfs.tar.xz proc.tar.gz
case $proot_system in
     ubuntu)sed -i 's/ports.ubuntu.com/mirrors.ustc.edu.cn/g' .${proot_system}-${proot_ver}/etc/apt/sources.list ;;
	 debian)sed -i 's/deb.debian.org/mirrors.ustc.edu.cn/g' .${proot_system}-${proot_ver}/etc/apt/sources.list ;;
	 archlinux)echo 'Server = https://mirrors.ustc.edu.cn/archlinuxarm/$arch/$repo' >.${proot_system}-${proot_ver}/etc/pacman.d/mirrorlist
	 echo '[archlinuxcn]
    Server = https://mirrors.ustc.edu.cn/archlinuxcn/$arch' >>.${proot_system}-${proot_ver}/etc/pacman.conf ;;
esac
echo ". run.sh" >>.${proot_system}-${proot_ver}/etc/profile
echo "proot_system=${proot_system}" >>.${proot_system}-${proot_ver}/root/run.sh
cat >>.${proot_system}-${proot_ver}/root/run.sh<<-'eof'
echo "开始配置系统"
sleep 3
case $proot_system in
	ubuntu | debian)apt update
	                apt install apt-transport-https
	                perln=$(ls /usr/bin | grep perl | grep "[0-9]$")
	                ln -s /usr/bin/$pern /usr/bin/perl
	                apt install ca-certificates -y
	                sed -i 's/http/https/g' /etc/apt/sources.list
	                apt update
	                touch ${HOME}/.hushlogin
			apt install vim fonts-wqy-zenhei tar pulseaudio curl wget gawk whiptail locales busybox -y
             mv /var/lib/dpkg/info/ /var/lib/dpkg/info_old/&&mkdir /var/lib/dpkg/info/&&apt-get update&&apt-get -f install&&mv /var/lib/dpkg/info/* /var/lib/dpkg/info_old/&&mv /var/lib/dpkg/info /var/lib/dpkg/info_back&&mv /var/lib/dpkg/info_old/ /var/lib/dpkg/info
		apt install ;;
		archlinux)chmod -R 755 /etc
			chmod 440 /etc/sudoers
			chmod -R 755 /usr
			chmod -R 755 /var
			sed -i 's/C/zh_CN.UTF-8/g' /etc/locale.conf
			pacman -Sy curl wget tar pulseaudio curl gawk libnewt dialog wqy-zenhei vim nano busybox --noconfirm ;;
esac
for i in ps pstree top uptime pkill egrep killall ifconfig
do ln -sf /bin/busybox /bin/$i
done
sed -i /zh_CN/s/#// /etc/locale.gen
locale-gen
sed -i 's/. run.sh//g' /etc/profile
echo "export LANG=zh_CN.UTF-8
export PULSE_SERVER=127.0.0.1
pulseaudio --start >/dev/null 2>&1" >>/etc/profile
echo "配置已完成"
eof
echo "pkill -9 pulseaudio 2>/dev/null
pulseaudio --start --load='module-native-protocol-tcp auth-ip-acl=127.0.0.1 auth-anonymous=1' --exit-idle-time=-1 &
unset LD_PRELOAD
proot -l --sysvipc --kill-on-exit -S .${proot_system}-${proot_ver} -b .${proot_system}-${proot_ver}/root:/dev/shm -b .${proot_system}-${proot_ver}/etc/proc/vmstat:/proc/vmstat -b .${proot_system}-${proot_ver}/etc/proc/stat:/proc/stat -b .${proot_system}-${proot_ver}/etc/proc/buddyinfo:/proc/buddyinfo -b .${proot_system}-${proot_ver}/etc/proc/cmdline:/proc/cmdline -b .${proot_system}-${proot_ver}/etc/proc/key-users:/proc/key-users -b .${proot_system}-${proot_ver}/etc/proc/loadavg:/proc/loadavg -b .${proot_system}-${proot_ver}/etc/proc/cgroups:/proc/cgroups -b .${proot_system}-${proot_ver}/etc/proc/fb:/proc/fb -b .${proot_system}-${proot_ver}/etc/proc/keys:/proc/keys -b .${proot_system}-${proot_ver}/etc/proc/version:/proc/version -b /sdcard:/sdcard -b /sdcard:/root/sdcard -w /root /usr/bin/env -i LANG=zh_CN.UTF-8 HOME=/root USER=root TERM=xterm-256color PATH=/usr/local/sbin:/usr/local/bin:/bin:/usr/bin:/sbin:/usr/sbin:/usr/games:/usr/local/games /bin/bash --login" >>${proot_ver}.sh
if [ $proot_ver = current ];then
    mv current.sh arch.sh
    proot_ver="arch"
fi
chmod 777 ${proot_ver}.sh
./${proot_ver}.sh
echo -e "${Y}输入./$proot_ver.sh可再次启动启动容器${E}"
exit
}
######
debian(){
system=$(cat /etc/os-release | grep ^ID | gawk 'NR==1' | gawk -F '=' '{print $2}')
if [ $system = debian ];then
      codename=$(cat /etc/os-release | grep PRETTY | gawk -F '"' '{print $2}' | gawk -F "/" '{print $3}')
else
      codename=$(cat /etc/os-release | grep VERSION_CODENAME | gawk -F '=' '{print $2}')
fi
arch=$(uname -m)
input=$(dialog --title "Debian Menu" --menu "选择一项功能开始" 0 0 0 1 更换软件源 2 设置系统中文语言 3 软件安装 --output-fd 1)
case $input in
     1)input=$(dialog --title "Change Mirror" --menu "选择你要更换的源地址" 0 0 0 1 北外源bfsu 2 中科大源ustc 3 清华源tuna 4 返回上级目录 --output-fd 1)
	 case $input in
	  1)mirror_url="mirrors.bfsu.edu.cn" ;;
	  2)mirror_url="mirrors.ustc.edu.cn" ;;
	  3)mirror_url="mirrors.tuna.tsinghua.edu.cn" ;;
	  4)debian ;;
	  *)exit ;;
     esac
      case $system in
	      [uU]buntu)apt install apt-transport-https ca-certificates
	     if [ $(uname -m) = x86_64 ];then
		     mirror_path="ubuntu"
	     else
		     mirror_path="ubuntu-ports"
	     fi
	     case $codename in
		     trusty | xenial | bionic | focal | hirsute | impish | jammy)sleep 0.1 ;;
		     *)echo -e "${R}不受支持的版本${E}"
			     sleep 3
			     debian
			     exit;;
	     esac
	     echo "deb https://${mirror_url}/${mirror_path}/ ${codename} main restricted universe multiverse
	     deb https://${mirror_url}/${mirror_path}/ ${codename}-updates main restricted universe multiverse
	     deb https://${mirror_url}/${mirror_path}/ ${codename}-backports main restricted universe multiverse
	     deb https://${mirror_url}/${mirror_path}/ ${codename}-security main restricted universe multiverse" >/etc/apt/sources.list
	     apt update
	     echo -e "${G}done...${E}"
	     sleep 3
	     debian ;;
             [Dd]ebian)case $codename in
		     sid)echo "deb http://${mirror_url}/debian/ sid main contrib non-free" >/etc/apt/sources.list ;;
		     jessie)echo "deb http://${mirror_url}/debian/ jessie main contrib non-free
			     deb http://${mirror_url}/debian/ jessie-updates main contrib non-free
			     deb http://${mirror_url}/debian-security jessie/updates main contrib non-free" >/etc/apt/sources.list ;;
		     testing | bullseye | buster | stretch)echo "deb https://${mirror_url}/debian/ ${codename} main contrib non-free
			     deb http://${mirror_url}/debian/ ${codename}-updates main contrib non-free
			     deb http://${mirror_url}/debian/ ${codename}-backports main contrib non-free
			     deb http://${mirror_url}/debian-security ${codename}/updates main contrib non-free" >/etc/apt/sources.list ;;
		     *)echo -e "${R}不支持你的系统${E}"
			     sleep 3
			     debian
			     exit ;;
	     esac
	     apt update
	     perln=$(ls /usr/bin | grep perl)
	     ln -s /usr/bin/$pern /usr/bin/perl
	     apt install ca-certificates
	     sed -i 's/http/https/g' /etc/apt/sources.list
	     apt update
	     echo -e "${G}done..${E}"
	     sleep 3
	     debian ;;
	   esac ;;
     2)apt install fonts-wqy-zenhei
       sed -i /zh_CN/s/#// /etc/locale.gen
       locale-gen
       echo -e "${G}更换完成${E}"
       sleep 3 ;;
     3)app_install ;;
esac
}
######
app_install(){
input=$(dialog --title "App Install" --menu "选择你要安装的软件" 0 0 0 1 安装chroium浏览器 2 安装wine 3 electron软件安装 4 图形化界面安装 5 返回上级菜单 --output-fd 1)
case $input in
	1)case $system in
		[Uu]buntu)apt install xdg-utils -y
		          case $arch in
		       aarch64)wget https://mirrors.ustc.edu.cn/ubuntu-ports/pool/universe/c/chromium-browser/chromium-browser_104.0.5112.101-0ubuntu0.18.04.1_arm64.deb -t 4
			       wget_check
			       wget https://mirrors.ustc.edu.cn/ubuntu-ports/pool/universe/c/chromium-browser/chromium-codecs-ffmpeg_104.0.5112.101-0ubuntu0.18.04.1_arm64.deb -t 4
			       wget_check ;;
		       x86_64)wget https://mirrors.ustc.edu.cn/ubuntu/pool/universe/c/chromium-browser/chromium-browser_104.0.5112.101-0ubuntu0.18.04.1_amd64.deb -t 4
			       wget_check
			       wget https://mirrors.ustc.edu.cn/ubuntu/pool/universe/c/chromium-browser/chromium-codecs-ffmpeg_104.0.5112.101-0ubuntu0.18.04.1_amd64.deb -t 4 ;
			       wget_check;
	                  esac
			  dpkg -i chromium*
			  app_install ;;
		[dD]ebian)apt install chromium-browser -y
		        app_install ;;
	  esac
	  dialog --title "yes/no" --yesno "是否启用--no-sandbox选项\n如果你是使用proot容器或者使用root用户登录的桌面请选择yes\n如果chromium无法正常启动请选择yes" 0 0
	  if [ $? = 0 ];then
	  sed -i '/Exec/s/chromium-browser/chromium-browser --no-sandbox/' /usr/share/appl
ications/chromium-browser.desktop
	  fi
	  echo -e "${G}安装完成...${E}"
	  sleep 3
	  app_install ;;
        2)case $arch in
		aarch64)dialog --title "yes/no" --yesno "安装wine会安装box64、box86，wine\n安装后可能会导致兼容性或系统错误，是否继续？" 0 0
		if [ $? = 0 ];then
			sleep 0.1
		else
			debian
			exit
		fi
		input=$(dialog --title "选择你要安装的wine版本" --menu "Ps：高版本在proot里可能会有bug" 0 0 0 1 wine3.9-推荐 2 wine6.14 --output-fd 1)
		case $input in
			1)down_url="https://shell.xb6868.com/wine/PlayOnLinux-wine-3.9-upstream-linux-amd64.tar.gz" ;;
			2)down_url="https://shell.xb6868.com/wine/PlayOnLinux-wine-6.17-upstream-linux-amd64.tar.gz" ;;
			*)exit ;;
		esac
		dpkg --add-architecture armhf && apt update
		apt install zenity:armhf libstdc++6:armhf gcc-arm-linux-gnueabihf mesa*:armhf libasound*:armhf -y
		apt install git cmake build-essential -y
		git_check(){
		for i in box64 box86
		do if [ -d $i ];then
			sleep 0.1
		else
			git clone http://github.com/ptitSeb/$i
			echo -e "${Y}正在尝试克隆仓库...${E}"
			sleep 2
			git_check
		fi;done
		}
		git_check
		cd box86 && mkdir build && cd build &&cmake .. -DRPI4ARM64=ON -DCMAKE_BUILD_TYPE=RelWithDebInfo; make -j4 && make install
		cd && cd box64 && mkdir build; cd build; cmake .. -DARM_DYNAREC=ON -DCMAKE_BUILD_TYPE=RelWithDebInfo; make -j$(nproc) && make install
		cd && rm -rf box64 box86
		wget $down_url -O wine.tar.gz -t 4
		wget_check
		tar wine.tar.gz -C /usr
		echo -e"${Y}安装已经结束，使用方法如下：${E}
		wine3.9版本启动指令：box64 wine64 winecfg
		box64 wine64 explorer
		box64 wine64 taskmgr
		wine6.14启动指令：
		box64 wine64 taskmgr &
		sleep 5
		pkill services &"
		echo -e "${G}按下回车键继续${E}"
		read enter ;;
	x86_64)apt install wine -y ;;
          esac
	 app_install ;;
        3)echo "此功能还没写好呢“
		按回车键继续"
		read enter
		app_intsall ;;
	4)gui_install ;;
	*)debian ;;
esac
}
######
gui_install(){
input=$(dialog --title "GUI Install" --menu "选择一项来安装图形" 0 0 0 1 xfce 2 kde 3 lxde 4 mate 5 返回上级菜单 --output-fd 1)
case $input in
	1)xstartup="startxfce4"
        apt install xfce4 xfce4-terminal ristretto dbus-x11 lxtask -y ;;
        2)xstartup="startkde"
	apt install kde-plasma-desktop dbus-x11 lxtask -y ;;
        3)xstartup="startlxde"
        apt install lxde-core lxterminal dbus-x11 -y ;;
        4)xstartup="mate-session"
        apt install mate-desktop-environment-core -y ;;
	*)app_install
		exit ;;
esac
mv /var/lib/dpkg/info/ /var/lib/dpkg/info_old/&&mkdir /var/lib/dpkg/info/&&apt-get update&&apt-get -f install&&mv /var/lib/dpkg/info/* /var/lib/dpkg/info_old/&&mv /var/lib/dpkg/info /var/lib/dpkg/info_back&&mv /var/lib/dpkg/info_old/ /var/lib/dpkg/info
dialog --title "yes/no" --yesno "是否安装vnc server服务" 0 0
if [ $? = 0 ];then
	sleep 0.1
else
	echo -e "${G}安装已完成....${E}"
	sleep 3
	app_install
	exit
fi
apt install
apt install tigervnc* -y
mv /var/lib/dpkg/info/ /var/lib/dpkg/info_old/&&mkdir /var/lib/dpkg/info/&&apt-get update&&apt-get -f install&&mv /var/lib/dpkg/info/* /var/lib/dpkg/info_old/&&mv /var/lib/dpkg/info /var/lib/dpkg/info_back&&mv /var/lib/dpkg/info_old/ /var/lib/dpkg/info
mkdir ${HOME}/.vnc
echo "$xstartup" >>${HOME}/.vnc/xstartup
chmod 777 ${HOME}/.vnc/xstartup
echo -e "${Y}设置vnc密码，设置完毕后，输入y再输一次${E}"
vncpasswd
if cat /proc/version | grep -q Xbtooln
then echo "tigervncserver :1" >>/usr/bin/start-vnc
else echo "export PULSE_SERVER=127.0.0.1
pulseaudio --start >/dev/null 2>&1
tigervncserver :1" >>/usr/bin/start-vnc
fi
chmod 777 /usr/bin/start-vnc
echo "安装已完成，输入start-vnc启动vnc"
echo -e "${G}按回车键继续${E}"
read enter
app_install
}
######
start
