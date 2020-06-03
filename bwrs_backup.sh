#!/bin/sh
###############################################################################################
#
# bwrs_backup - script to backup and encrypt bitwarden_rs sqlite database and .env config file
#
# * safely creates a copy of running db.sqlite database
# * tars and zips copy of db.sqlite, wal, shm, and .env config files
# * gpg encrypts the backup with a passphrase
# * saves encrypted backup to a backup directory
# * prunes any backups older than (30) days
# * use rclone or scp to save backup to remote location
#
# bitwarden_rs on Github: https://github.com/dani-garcia/bitwarden_rs
#
# Ayitaka
#
###############################################################################################
#
# Syntax:
#   bwrs_backup
#
###############################################################################################

BASE_DIR="/home/bitwarden/bw"
#BACKUP_DIR="/home/bitwarden/bw/backup"
BACKUP_DIR="/backup"
TMP_DIR="${BACKUP_DIR}/tmp";

DB_FILE="${BASE_DIR}/data/db.sqlite3"
WAL_FILE="${DB_FILE}-wal"
SHM_FILE="${DB_FILE}-shm"
CONFIG_FILE="${BASE_DIR}/bitwarden_rs.env"
BACKUP_FILE="${BACKUP_DIR}/backup.sqlite3.$(date "+%F-%H%M%S").tgz"

umask 0077

mkdir -p $TMP_DIR

sqlite3 $DB_FILE ".backup ${TMP_DIR}/db.sqlite3" >/dev/null

if [ -f "$WAL_FILE" ]; then
	cp -p $WAL_FILE $TMP_DIR
fi

if [ -f "$SHM_FILE" ]; then
	cp -p $SHM_FILE $TMP_DIR
fi

cp -p $CONFIG_FILE $TMP_DIR

#chown -R bitwarden:bitwarden ${TMP_DIR}
#chmod -R go-rwx ${TMP_DIR}

cd $BACKUP_DIR
tar cfz $BACKUP_FILE tmp/*

#chown bitwarden:bitwarden $BACKUP_FILE
#chmod go-rwx $BACKUP_FILE

rm -rf $TMP_DIR

gpg --batch --passphrase-file ~/.gnupg/passphrase --symmetric --cipher-algo AES256 $BACKUP_FILE

rm $BACKUP_FILE

find $BACKUP_DIR -type f -name 'backup.sqlite3.*' -mtime +30 -exec rm {} \;

#scp -i /home/bitwarden/.ssh/id_rsa ${BACKUP_DIR}/${BACKUP_FILE}.gpg bitwarden@192.168.1.100:/storage/bitwarden/ >/dev/null

rclone sync /backup/ google:/
rclone --drive-trashed-only --drive-use-trash=false delete google:/
