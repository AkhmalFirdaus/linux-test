#! /bin/bash

set -xe

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )" #/home/admin/Nextcloud/client-building/linux
DATE=`date +%Y%m%d`

#appName='Xiddigspace' #maladded for Linux on 20220214, but no need to declare, this mentioned in NEXTCLOUD.cmake

echo $DIR
echo "******* mal checked DIRECTORY in DIR ********** 20220406 1614 ***********"
pwd #maladded to check directory location #/home/admin/Nextcloud/client-building/linux

mkdir -p ~/output/$DATE
pwd #maladded to check directory location #/home/admin/Nextcloud/client-building/linux

#Build
docker run \
    --name desktop-$DATE \
    -v $DIR:/input \
    -v ~/output/$DATE:/output \
    ghcr.io/nextcloud/continuous-integration-client-appimage:client-appimage-2 \
    /input/build-appimage-daily.sh $(id -u)

echo "********* mal checked $DIR/input on 20220406 1614 ************"
pwd #maladded_to_check_directory_location


#Save the logs!
docker logs desktop-$DATE > ~/output/$DATE/log

##to copy files by maladded
#mkdir ~/cpdir-linux/app/usr2
#cp -avr ./usr/* ~/cpdir-linux/usr2/ #maladded_to_check_directory_location
pwd #maladded_to_check_directory_location

#Kill the container!
docker rm desktop-$DATE
pwd #maladded_to_check_directory_location

#Copy to the download server
#scp ~/output/$DATE/*.AppImage daily_desktop_uploader@download.nextcloud.com:/var/www/html/desktop/daily/Linux
#pwd #maladded_to_check_directory_location

# remove all but the latest 5 dailies
/bin/ls -t ~/output | awk 'NR>6' | xargs rm -fr
pwd #maladded_to_check_directory_location


# ====== E N D ======= #

# MALREFERENCES / NO BUILD:
# docker ps -a #check docker files container
# docker rm <file-name> #remove docker <file-name>
# docker rm /desktop-20220214

# Copy files
# Link REF: https://www.cyberciti.biz/faq/copy-folder-linux-command-line/

# Locate Files
#Link REF: https://www.cyberciti.biz/faq/linux-how-can-i-find-a-file-on-my-system/
