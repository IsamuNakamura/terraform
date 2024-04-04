#!/usr/bin/env bash
#
# DB定期ダンプスクリプト

################################################################
# 変数定義
################################################################
# バックアップ先ディレクトリ
BACKUP_DIR="/home/ec2-user/dbdump/"
# s3アップロードが済んだファイルを格納するディレクトリ
ARCHIVE_DIR="${BACKUP_DIR}archive"
# ログ出力ディレクトリ
LOG_DIR="${BACKUP_DIR}logs/"
# ログファイルのフルパス
LOGFILE="${LOG_DIR}/dbdump.log"
# mysqldumpの機能で使う接続作情報ファイルのフルパス
CONF_FILE="/home/ec2-user/config/.dbdump.cnf"
# DB接続用情報保存ファイルのフルパス
DB_CONF_FILE="/home/ec2-user/config/.db.cnf"
# mysqldumpのオプション提示された物からバージョンが古くて廃止になったオプションを除いたもの
MYSQLDUMP_OPTION="--quick --default-character-set=utf8mb4 --set-gtid-purged=OFF --skip-column-statistics"
# S3のアップロード先のパスに使う日付文字列
YYYYMMDD="$(date "+%Y%m%d")"
# ダンプファイルの時刻部分に使う文字列
HHMM="$(date "+%H%M")"
YYYYMMDDHHMM="$(date "+%Y%m%d%H%M")"
# ダンプファイルの先頭部分の文字列
FILENAME="mysqldump.${YYYYMMDDHHMM}"
# 定期削除期間（分で指定）
#  指定した時間以上経過したファイルを削除する
#  <例> DELETE_MIN=60とした場合は60分以上のファイルはサーバ内から削除対象
DELETE_MIN=1440

# s3 cpコマンドはデフォルトで"us-east-1"のリージョンが設定されるので、環境変数に対象のリージョンを設定
export AWS_DEFAULT_REGION=ap-northeast-1


################################################################
# 関数定義
################################################################
# init
function init {
  # create directory if not exists
  if [ ! -d "${BACKUP_DIR}" ]; then
    mkdir -p ${BACKUP_DIR}
  fi

  if [ ! -d "${ARCHIVE_DIR}" ]; then
    mkdir -p ${ARCHIVE_DIR}
  fi

  if [ ! -d "${LOG_DIR}" ]; then
    mkdir -p ${LOG_DIR}
  fi

  # ダンプ用ディレクトリがあるか
  if [ ! -d "${BACKUP_DIR}" ]; then
    customlog "[ERROR] backup directory not exists."
    exit 1
  fi

  # アーカイブ保存用ディレクトリがあるか
  if [ ! -d "${ARCHIVE_DIR}" ]; then
    customlog "[ERROR] archive directory not exists."
    exit 1
  fi

  # .dbdump.cnfが存在しているかどうか
  if [ -f ${CONF_FILE} ]; then
    source ${CONF_FILE}
  else
    customlog "[ERROR] ${CONF_FILE} not found."
    exit 1
  fi

  # .db.cnfが存在しているかどうか
  if [ ! -f ${DB_CONF_FILE} ]; then
    customlog "[ERROR] ${DB_CONF_FILE} not found."
    exit 1
  fi

  if [ ! -d "${LOG_DIR}" ]; then
    customlog "[ERROR] log directory not exists."
    exit 1
  fi
}

# 指定した文字列にタイムスタンプとかプロセス名とかファイル中のどこで発生したメッセージかとかをログに吐き出すカスタムロガー
function customlog() {
  local fname=${BASH_SOURCE[1]##*/}
  echo -e "$(date '+%Y-%m-%d %H:%M:%S') ${LOCALTIMEZONE} [$$] ${PROCNAME} (${fname}:${BASH_LINENO[0]}:${FUNCNAME[1]}) $@" >> ${LOGFILE}
}

# アーカイブファイルの定期削除スクリプト
function delete_archive() {
  find ${ARCHIVE_DIR} -mmin +${DELETE_MIN} -delete
}

# 以下メイン処理
################################################################
# main()
################################################################
# 初期チェック
init

# ログに開始したことを記録する
customlog "[INFO] ==== Dump database is start. ===="
# cronから実行されたか、ユーザーシェルから実行されたかを記録する
if [ -z "${USER}" ]; then
  customlog "[INFO] execute from cron."
else
  customlog "[INFO] execute user is ${USER}."
fi

# どのIAMロールで実行されたかを記録するAWS CLIが正常終了した場合は返ってきたJSONをログに記録正常終了しなかった場合は後のAWS CLI実行時に失敗する恐れがあるので即エラー終了
AWSSTS_RESULT=$(aws sts get-caller-identity)
RESULTCODE=$?
if [ ${RESULTCODE} -eq 0 ]; then
  customlog "[INFO] aws sts get-caller-identity success."
  for i in ${AWSSTS_RESULT}; do
    customlog "[INFO] result; $i"
  done
else
  customlog "[ERROR] aws sts get-caller-identity failed."
  customlog "[ERROR] aborted."
  exit 255
fi

# バックアップしても復元には使わないDBを除外して、バックアップするDBの一覧を作成する一覧が取得できた場合はログに順次記録取得できなかった場合は異常が発生しているので即エラー終了
dbs=$(echo "show databases" | mysql --defaults-extra-file=${DB_CONF_FILE} | grep -Ev "^(Database|performance_schema|information_schema|sys|mysql)$")
RESULTCODE=$?
if [ ${RESULTCODE} -eq 0 ]; then
  customlog "[INFO] database listup success."
  array=(${dbs// / })
  e=""
  i=0
  for e in ${array[@]}; do
    customlog "[INFO] database list: ${array[$i]}"
    let i++
  done
else
  customlog "[ERROR] database listup failed."
  customlog "[ERROR] aborted."
  exit 255
fi

# ループで使う一時変数を初期化
e=""
i=0
UPLOAD_MISS_COUNT=0

# DB毎にダンプしてS3にコピー途中で失敗したアップロードが有ってもとりあえず全DB分実行して、後でエラー終了する
for e in ${array[@]}; do
  mysqldump --defaults-extra-file=${DB_CONF_FILE} ${MYSQLDUMP_OPTION} -B ${array[$i]} > ${BACKUP_DIR}${FILENAME}_${array[$i]}.sql 2>> $LOGFILE
  RESULTCODE=$?
  if [ ${RESULTCODE} -eq 0 ]; then
    customlog "[INFO] Database ${array[$i]} is dump to ${BACKUP_DIR}${FILENAME}_${array[$i]}.sql"
    gzip ${BACKUP_DIR}${FILENAME}_${array[$i]}.sql
  else
    customlog "[ERROR] Database ${array[$i]} dump was failed"
    \rm -f $BACKUP_DIR$FILENAME\_${array[$i]}.sql
  fi
  source ${CONF_FILE}
  aws s3 cp --quiet ${BACKUP_DIR}${FILENAME}_${array[$i]}.sql.gz ${UPLOAD_BACKET}/${YYYYMMDD}/${HHMM}/
  RESULTCODE=$?
  if [ ${RESULTCODE} -eq 0 ]; then
    customlog "[INFO] ${BACKUP_DIR}${FILENAME}_${array[$i]}.sql.gz S3 copy done."
    # アップロード成功したらアーカイブディレクトリに移動する
    mv ${BACKUP_DIR}${FILENAME}_${array[$i]}.sql.gz ${ARCHIVE_DIR}/.
  else
    customlog "[ERROR] ${BACKUP_DIR}${FILENAME}_${array[$i]}.sql S3 copy failed."
    let UPLOAD_MISS_COUNT++
  fi
  let i++
done

# アーカイブ削除する
delete_archive

# 失敗したアップロードが有った場合はその件数をログに記録してエラー終了する
if [ ${UPLOAD_MISS_COUNT} -eq 0 ]; then
  customlog "[INFO] ==== All works are finished. ===="
else
  customlog "[ERROR] Copying to S3 failed ${UPLOAD_MISS_COUNT} times."
  customlog "[ERROR] aborted."
  exit 255
fi
