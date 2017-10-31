#!/bin/bash

SCRIPT_DIR="/root"
NOW=$(date +"%Y%m%d")
TMP_PATH='/tmp'
DOCKER_ID_TTRSS='39cec6a7dcb7'
TTRSS_DB="$TMP_PATH/ttrss.sql"
BAK_FILE_NAME="vps-$NOW.tar.gz"
BAK_FILE="$TMP_PATH/$BAK_FILE_NAME"
DROPBOX_DIR=""

docker exec "$DOCKER_ID_TTRSS" /usr/bin/pg_dump ttrss > "$TTRSS_DB"
echo "数据库备份完成，打包网站数据中..."
tar cfzP "$BAK_FILE" "$TTRSS_DB"
echo "所有数据打包完成，准备上传..."
# 用脚本上传到dropbox
"$SCRIPT_DIR"/dropbox_uploader.sh upload "$BAK_FILE" "$DROPBOX_DIR/$BAK_FILE_NAME"
if [ $? -eq 0 ];then
     echo "上传完成"
else
     echo "上传失败，重新尝试"
fi

# 删除本地的临时文件
rm -f "$TTRSS_DB" "$BAK_FILE"
