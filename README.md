# bwrs_backup
script to backup and encrypt bitwarden_rs sqlite database and .env config file

* safely creates a copy of running db.sqlite database
* tars and zips copy of db.sqlite, wal, shm, and .env config files
* gpg encrypts the backup with a passphrase
* saves encrypted backup to a backup directory
* prunes any backups older than (30) days
* use rclone or scp to save backup to remote location

bitwarden_rs on Github: https://github.com/dani-garcia/bitwarden_rs

Syntax:
   bwrs_backup

## ***Requirements***

## ***How To Use***

---

```

```
