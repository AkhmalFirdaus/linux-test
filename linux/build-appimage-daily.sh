#! /bin/bash

set -xe

#set user=admin

#useradd users -u ${1:-1000}
useradd admin -u ${1:-1000} #maledited

mkdir /app
mkdir /build

#Set Qt-5.12
#export QT_BASE_DIR=/opt/qt5.12.10
export QT_BASE_DIR=/home/admin/Qt/qt5.12.10
export QTDIR=$QT_BASE_DIR
export PATH=$QT_BASE_DIR/bin:$PATH
export LD_LIBRARY_PATH=$QT_BASE_DIR/lib/x86_64-linux-gnu:$QT_BASE_DIR/lib:$LD_LIBRARY_PATH
export PKG_CONFIG_PATH=$QT_BASE_DIR/lib/pkgconfig:$PKG_CONFIG_PATH

#QtKeyChain 0.10.0
cd /build
git clone https://github.com/frankosterfeld/qtkeychain.git
cd qtkeychain
git checkout v0.10.0
mkdir build
cd build
pwd #maladded_to_check_directory_location
cmake -D CMAKE_INSTALL_PREFIX=/usr ../  #maledited from usr to admin #nope no need #run ./build.sh first
pwd #maladded_to_check_directory_location
make -j4
make install

##to copy files by maladded
#mkdir ~/cpdir-linux
#mkdir ~/cpdir-linux/build
#cp -avr /build ~/cpdir-linux/build


#Build client
cd /build
#git clone --depth 1 https://github.com/nextcloud/desktop.git
#git clone --depth 1 https://github.com/AkhmalFirdaus/desktop.git #mal edited added on 20220407 1249
#cp /../home/admin/Nextcloud/desktop ./ #maladded to copy desktop to current working directory for nafairXcloud on 20220428 0919
git clone --depth 1 https://github.com/AkhmalFirdaus/nsync.git #mal edited added on 20220428 1142
mv nsync desktop

mkdir build-client
cd build-client
cmake -D CMAKE_INSTALL_PREFIX=/usr \
    -D BUILD_TESTING=OFF \
    -D BUILD_UPDATER=ON \
    -D QTKEYCHAIN_LIBRARY=/app/usr/lib/x86_64-linux-gnu/libqt5keychain.so \
    -D QTKEYCHAIN_INCLUDE_DIR=/app/usr/include/qt5keychain/ \
    -DMIRALL_VERSION_SUFFIX=daily \
    -DMIRALL_VERSION_BUILD=`date +%Y%m%d` \
    /build/desktop
make -j4
make DESTDIR=/app install

##to copy files by maladded
#mkdir ~/cpdir-linux/app
#cp -avr /app ~/cpdir-linux/app
#mkdir ~/cpdir-linux/build/build-client
#cp -avr /build/build-client ~/cpdir-linux/build/build-client
#mkdir ~/cpdir-linux/build/desktop
#cp -avr /build/desktop ~/cpdir-linux/build/desktop


## Move stuff around
cd /app

mv ./usr/lib/x86_64-linux-gnu/* ./usr/lib/

##to copy files by maladded
#mkdir ~/cpdir-linux/app/usr
#mkdir ~/cpdir-linux/app/usr/lib0 #0 is the initial one
#cp -avr ./usr/lib/* ~/cpdir-linux/usr/lib0/ #maladded_to_check_directory_location

rm -rf ./usr/lib/cmake
rm -rf ./usr/include
rm -rf ./usr/mkspecs
rm -rf ./usr/lib/x86_64-linux-gnu/

# Don't bundle nextcloudcmd as we don't run it anyway
rm -rf ./usr/bin/nextcloudcmd

# Don't bundle the explorer extentions as we can't do anything with them in the AppImage
rm -rf ./usr/share/caja-python/
rm -rf ./usr/share/nautilus-python/
rm -rf ./usr/share/nemo-python/

##to copy files by maladded
#mkdir ~/cpdir-linux/app/usr/lib #0 is the initial one
#cp -avr ./usr/lib/* ~/cpdir-linux/usr/lib/ #maladded_to_check_directory_location

# Move sync exclude to right location
#mv ./etc/Nextcloud/sync-exclude.lst ./usr/bin/ #malcommented out as it gives error file not found for Linux on 20220412 1642
#mv ./etc/Xiddigspace/sync-exclude.lst ./usr/bin/ #maladded for Linux on 20220412 1642
mv ./etc/nafairXcloud/sync-exclude.lst ./usr/bin/ #maladded for Linux nafairXcloud on 20220428 0920
rm -rf ./etc

##to copy files by maladded
#mkdir ~/cpdir-linux/app/usr2
#cp -avr ./usr/* ~/cpdir-linux/usr2/ #maladded_to_check_directory_location

# com.nextcloud.desktopclient.nextcloud.desktop
DESKTOP_FILE=$(ls /app/usr/share/applications/*.desktop)

#sed -i -e 's|Icon=nextcloud|Icon=Nextcloud|g' ${DESKTOP_FILE} # Bug in desktop file?
#sed -i -e 's|Icon=xiddigspace|Icon=Xiddigspace|g' ${DESKTOP_FILE} # Bug in desktop file?
sed -i -e 's|Icon=nafairXcloud|Icon=nafairXcloud|g' ${DESKTOP_FILE} # Bug in desktop file?
#cp ./usr/share/icons/hicolor/512x512/apps/Nextcloud.png . # Workaround for linuxeployqt bug, FIXME
#cp ./usr/share/icons/hicolor/512x512/apps/Xiddigspace.png . # Workaround for linuxeployqt bug, FIXME #maladded 20220407 0938
cp ./usr/share/icons/hicolor/512x512/apps/nafairXcloud.png . # Workaround for linuxeployqt bug, FIXME #maladded 20220428 0922


# Because distros need to get their shit together
cp -R /usr/lib/x86_64-linux-gnu/libssl.so* ./usr/lib/
cp -R /usr/lib/x86_64-linux-gnu/libcrypto.so* ./usr/lib/
cp -P /usr/local/lib/libssl.so* ./usr/lib/
cp -P /usr/local/lib/libcrypto.so* ./usr/lib/

# NSS fun
cp -P -r /usr/lib/x86_64-linux-gnu/nss ./usr/lib/

# Use linuxdeployqt to deploy
cd /build
wget --ca-directory=/etc/ssl/certs -c "https://github.com/probonopd/linuxdeployqt/releases/download/continuous/linuxdeployqt-continuous-x86_64.AppImage"
chmod a+x linuxdeployqt*.AppImage
./linuxdeployqt-continuous-x86_64.AppImage --appimage-extract
rm ./linuxdeployqt-continuous-x86_64.AppImage
unset QTDIR; unset QT_PLUGIN_PATH ; unset LD_LIBRARY_PATH
export LD_LIBRARY_PATH=/app/usr/lib/
./squashfs-root/AppRun ${DESKTOP_FILE} -bundle-non-qt-libs -qmldir=/build/desktop/src/gui

# Set origin
#./squashfs-root/usr/bin/patchelf --set-rpath '$ORIGIN/' /app/usr/lib/libXiddigspacesync.so.0 #maledited from libnextcloudsync.so.0 to libXiddigspacesync.so.0 on 20220412 1642
./squashfs-root/usr/bin/patchelf --set-rpath '$ORIGIN/' /app/usr/lib/libnafairXcloudsync.so.0 #maledited from libXiddigspacesync.so.0 to libnafairXcloudsync.so.0 on 20220428 0927

# Build AppImage
./squashfs-root/AppRun ${DESKTOP_FILE} -appimage

export VERSION_MAJOR=$(cat build-client/version.h | grep MIRALL_VERSION_MAJOR | cut -d ' ' -f 3)
export VERSION_MINOR=$(cat build-client/version.h | grep MIRALL_VERSION_MINOR | cut -d ' ' -f 3)
export VERSION_PATCH=$(cat build-client/version.h | grep MIRALL_VERSION_PATCH | cut -d ' ' -f 3)
export VERSION_BUILD=$(cat build-client/version.h | grep MIRALL_VERSION_BUILD | cut -d ' ' -f 3)

#mv Nextcloud*.AppImage Nextcloud-${VERSION_MAJOR}.${VERSION_MINOR}.${VERSION_PATCH}.${VERSION_BUILD}-daily-x86_64.AppImage #malcommented to change app name on 20220412
#mv Xiddigspace*.AppImage Xiddigspace-${VERSION_MAJOR}.${VERSION_MINOR}.${VERSION_PATCH}.${VERSION_BUILD}-daily-x86_64.AppImage #maladded to change app name on 20220412 #maledited from Nextcloud*.AppImage to Xiddigspace*.AppImage on 20220412 1642
mv nafairXcloud*.AppImage nafairXcloud-${VERSION_MAJOR}.${VERSION_MINOR}.${VERSION_PATCH}.${VERSION_BUILD}-daily-x86_64.AppImage #maladded to change app name on 20220412 #maledited from Nextcloud*.AppImage to Xiddigspace*.AppImage to nafairXcloud*.AppImage on 20220428 0925

#mv Nextcloud*.AppImage /output/  #malcommented to change app name on 20220412
#mv Xiddigspace*.AppImage /output/  #maladded to change app name on 20220412
mv nafairXcloud*.AppImage /output/  #maladded to change app name on 20220428
cd /output #maladded
#chown admin Nextcloud*.AppImage #maladded #malcommented to change app name on 20220412
#chown admin Xiddigspace*.AppImage #maladded #maladded to change app name on 20220412
chown admin nafairXcloud*.AppImage #maladded #maladded to change app name on 20220428
##sudo chown admin Nextcloud*.AppImage #maladded
##chown users /output/Nextcloud*.AppImage #maledited from user to admin #but no effect #by default here is root, hence, they change to user, but user doesn't exists
