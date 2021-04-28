#!/bin/bash

DB_USER=postgres
DB_NAME=cm6

DEST_DIR=/home/petrovaa/cm6outdoc/
SOURCE_DIR=/home/petrovaa/cm6fromdoc/

# строка с "AND (cm6docid = '46865' OR cm6docid = '46858')\" - для отладки только
sudo -u $DB_USER psql -d $DB_NAME -X -A -q -t -c "select toorgid, fromorgid, cm6docid, id from cm6_outdoc WHERE sendstatus = 0 \
AND (cm6docid = '46865' OR cm6docid = '46858')\
" --single-transaction --set AUTOCOMMIT=off --set ON_ERROR_STOP=on --no-align --field-separator ' '\
| while read toorgid fromorgid cm6docid id; do
	sudo mkdir -m a=rwx $DEST_DIR/$toorgid-$cm6docid-$fromorgid
	sudo -u $DB_USER psql -d $DB_NAME -X -A -q -t -c "COPY (SELECT row_to_json(cm6_outdoc) FROM cm6_outdoc WHERE id = $id) to '$DEST_DIR/$toorgid-$cm6docid-$fromorgid/$toorgid-$cm6docid-$fromorgid.json'"
#    echo "SEND: $toorgid-$cm6docid-$fromorgid "
    sudo -u $DB_USER psql -d $DB_NAME -X -A -q -t -c "SELECT path, "name" FROM f_contentfiles_rkk WHERE f_dp_rkkbase=$cm6docid" --single-transaction --set AUTOCOMMIT=off --set ON_ERROR_STOP=on --no-align --field-separator ' '\
    | while read file_path file_name; do
#		echo "File: $file_path $file_name"
        cp "$SOURCE_DIR/$file_path" "$DEST_DIR/$toorgid-$cm6docid-$fromorgid/$file_name"
    done
    sudo -u $DB_USER psql -d $DB_NAME -X -A -q -t -c "UPDATE cm6_outdoc SET sendstatus=1 WHERE cm6docid='$cm6docid'" --single-transaction --set AUTOCOMMIT=off --set ON_ERROR_STOP=on
done
