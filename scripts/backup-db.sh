#!/usr/bin/env bash

artifacts_dir=backup_artifacts
backup_prefix="${ARANGO_DB_NAME}-${BAKCUP_NAME_SUFFIX}-backup"
s3_backup_dir=${ARANGO_S3_BACKUP_DIR}

current_date_time=$(date '+%Y-%m-%d-%H-%M-%S')
backup_name=$backup_prefix-$current_date_time.tar.gz

mkdir -p $artifacts_dir && cd $artifacts_dir

print_log () {
    echo
    echo $(date '+%Y-%m-%dT%H:%M:%SZ') "|" $1
}

print_log "Prepare $ARANGO_DB_NAME $BAKCUP_NAME_SUFFIX database backup"
arangodump \
    --server.username ${ARANGO_USER} \
    --server.password ${ARANGO_ROOT_PASSWORD} \
    --server.database ${ARANGO_DB_NAME} \
    --output-directory ${backup_prefix} \
    --compress-output

print_log "Compress $ARANGO_DB_NAME $BAKCUP_NAME_SUFFIX database backup"
tar -zcvf $backup_name $backup_prefix/

print_log "Upload backup to S3"
aws s3 cp $backup_name s3://$s3_backup_dir/

print_log "Remove $ARANGO_DB_NAME $BAKCUP_NAME_SUFFIX database backup artifacts"
rm -rf $backup_prefix

/remove-obsolete-backup-files.sh

print_log "Done!"
