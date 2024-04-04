#!/usr/bin/env bash
#
# DBリストアスクリプト

################################################################
# 変数定義
################################################################
# リストア用ダンプファイル格納ディレクトリ
RESTORE_DIR="/home/ec2-user/db_restore/"
# DB接続用情報保存ファイルのフルパス
DB_CONF_FILE="/home/ec2-user/config/.db.cnf"

# データベース名を取得
dbs=$(echo "show databases" | mysql --defaults-extra-file=${DB_CONF_FILE} | grep -Ev "^(Database|performance_schema|information_schema|sys|mysql)$")

# 各データベースに対してリストアを行う
for db in $dbs; do
    # データベースを削除
    echo "Dropping database: $db"
    mysql --defaults-extra-file=${DB_CONF_FILE} -e "DROP DATABASE IF EXISTS $db"

    # データベースを追加
    echo "Creating database: $db"
    mysql --defaults-extra-file=${DB_CONF_FILE} -e "CREATE DATABASE IF NOT EXISTS $db DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci"

    # ダンプファイルをリストア
    echo "Restoring database: $db"
    mysql --defaults-extra-file=${DB_CONF_FILE} -D $db < ${RESTORE_DIR}${db}.sql
done
