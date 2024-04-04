# ec2/maintenance/scripts

DBダンプ設定とDBリストア実行用のディレクトリ

ec2-userを使用する場合または既に存在する場合、不要

もし、ubuntuなど別のユーザーを使用する場合、root_modules/<env>/ec2/maintenance/scripts配下のスクリプトで設定しているディレクトリを全てec2-user→ubuntuに変更する必要がある


## 準備

### DBメンテナンス用のユーザー作成

#### ユーザー作成

```bash
sudo adduser ubuntu
sudo usermod -aG sudo ubuntu

cat /etc/passwd
```

#### sudo実行時にパスワードの要求を無効化

/etc/sudoersを編集
```bash
sudo visudo
```

下記入力
```
ubuntu ALL=(ALL) NOPASSWD:ALL
```

#### 接続コマンド

```bash
sudo su - ubuntu
```

## 定期DBダンプの設定

### 準備

#### ec2-userの公開鍵情報を作成したユーザーにコピー

```bash
mkdir ~/.ssh
chmod 700 ~/.ssh
vim ~/.ssh/authorized_keys
~ copy & paste ~

sudo chmod 600 ~/.ssh/authorized_keys
```

#### ダンプ用とリストア用のスクリプトをコピー

EC2のIPアドレスは適宜変更してください

```bash
scp -i ~/src/github.com/<repository_name>/infra/terraform/modules/ec2/maintenance/keypair/maintenance.pem -r ~/src/github.com/<repository_name>/infra/terraform/root_modules/prd/ec2/maintenance/scripts ubuntu@<EC2 IP Address>:/home/ubuntu/
```

#### DB設定とダンプ用の設定ファイルをコピー

EC2のIPアドレスは適宜変更してください

```bash
scp -i ~/src/github.com/<repository_name>/infra/terraform/modules/ec2/maintenance/keypair/maintenance.pem -r ~/src/github.com/<repository_name>/infra/terraform/modules/ec2/maintenance/config ubuntu@<EC2 IP Address>:/home/ubuntu/
```

#### ダンプファイルとスクリプトのログを格納するディレクトリを作成

```bash
mkdir -p /home/ubuntu/dbdump/logs
```

### 定期DBダンプcron設定

```bash
crontab -e
0 0 * * * /usr/bin/bash /home/ubuntu/scripts/mysql_dump.sh >> /home/ubuntu/dbdump/logs/dbdump.cron.log 2>&1

crontab -l
```

## DBリストアの実行

### 準備

#### ダンプファイルをコピー

- リストアするファイルをS3からダウンロードしてください
- 現在のDB名を取得し、そのDB名を元にDBを削除して、リストアするのでダンプファイルのファイル名は、DB名に変更してください
  - RDBを再構築した場合、DBが存在しないので作成しておく
  ```
  CREATE Database IF NOT EXISTS <DB name> DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;
  ```
```bash
scp -i ~/src/github.com/<repository_name>/infra/terraform/root_modules/<env>/ec2/maintenance/keypair/maintenance.pem -r ~/src/github.com/<repository_name>/infra/terraform/root_modules/<env>/ec2/maintenance/db_restore ubuntu@<EC2 IP Address>:/home/ubuntu/db_restore
```

### DBリストア実行

```bash
/usr/bin/bash /home/ubuntu/scripts/db_restore.sh
```
