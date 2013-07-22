#!/bin/bash



CONFIGFILE="./.publish_conf" #TODO: make these two options definable by command line
FILES_TO_COPY="./filestocopy"

# expecting config file to define the following:
# REMOTE_SERVER 
# USER_ID
# PASSWORD 
# BACKUP_DIR
#
# TODO: Relevant error checking/handling
# TODO: Make these options definable via command line as well

eval `sed '/^ *#/d;s/:/ /;' < "$CONFIGFILE" | while read key val
do
    str="$key='$val'"
    echo "$str"
done`

TIMESTAMP=$(date "+%b_%d_%Y_%H.%M.%S")
EXISTING_BACKUPS=$(find $BACKUP_DIR -maxdepth 1 -type f )


while read -r line
do
  ! [ -e $line ] && continue
 if [ "$line" == "" ]; then
     continue
 fi
 if [[ ${EXISTING_BACKUPS} == "" ]]; then #empty backup dir
    echo Backing up $line for the first time
    cp $line $BACKUP_DIR/$( basename $line ).$TIMESTAMP
    scp $line $USER_ID@$REMOTE_SERVER:$line
 else
     
     if ! [[ $(echo "${EXISTING_BACKUPS}" | tr ' ' '\n'| grep "$line") ]]; then
	echo Backing up $line for the first time
	cp $line $BACKUP_DIR/$( basename $line ).$TIMESTAMP
        echo Uploading $line
	scp $line $USER_ID@$REMOTE_SERVER:$line
     else
	for i in ${EXISTING_BACKUPS[@]}
	do
            if [[ "$i" == *"$( basename $line )"* ]];then
		 #TODO: Figure out how to do SCP without having to manually enter the password every time
                 #TODO: Figure out how to detect that SCP has failed, and mark file for repeat attempts, when the
                 #local backup has succeeded. For now forcing an scp on all files
		echo Uploading $line
		scp $line $USER_ID@$REMOTE_SERVER:$line
		 ! [ -e $i ] && continue
		if ! diff -q $line $i > /dev/null ; then
		    echo Backing up new version of $line
		    mv $BACKUP_DIR/$( basename $i ) $BACKUP_DIR/archive/$( basename $i )
		    cp $line $BACKUP_DIR/$( basename $line ).$TIMESTAMP
		else
		    echo $line appears to not have changed, not backing up
		fi
		break
            fi	      
	done
    fi
 fi
done < "$FILES_TO_COPY"
