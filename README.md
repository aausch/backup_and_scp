backup_and_scp
==============

A script from my own (occasional) workflows - backs up, then scps, a list of files.
Errata, suggestions, etc... welcome


Install:
========

Download the backup_and_scp.sh file.
Copy the .publish_conf_sample file to .publish_conf, in the same directory as the backup_and_scp.sh
Create a backup, and an archive directory, for example:

mkdir backup
mkdir backup/archive

Edit .publish_conf, and enter values that are appropriate for you (ie, use a directory other than "backup" if that's what you entered above)

try the script like so:

./backup_and_scp

WARNING:
* this script clobbers files on the remote system; make sure you have local backups of them before you first start using it.
