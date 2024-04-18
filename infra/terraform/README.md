# infra/terraform

Terraform ファイル格納用のルートディレクトリ

## 準備

### Terraform

本リポジトリでは実行環境での Terraform のバージョンの差異による実行エラー等を無くすため[tfenv](https://github.com/tfutils/tfenv)を使用。

#### インストール

以下のコマンドで tfenv をインストール。

```bash
 $ brew install tfenv
```

tfenv が正しくインストールされたか確認。

```bash
 $ tfenv -v
```

### Terraform 実行ユーザー作成

AWS のリソースを Terraform で管理するために、Terraform コマンドを実行できる IAM ユーザーを作成。

IAM ユーザーには、全てのリソースを操作できる`AdministratorAccess`ポリシーを付与。

アクセスキーは、パラメータストアに保存してあります。

### AWS CLI

#### インストール

[こちら](https://docs.aws.amazon.com/ja_jp/cli/latest/userguide/getting-started-install.html)を参考にインストール。

#### aws configure

デフォルトユーザーは使用せず、プロファイル名を指定してください。

本リポジトリでは、`terraform`をプロファイル名として使用。

Terraform コマンドを実行する際にこのプロファイル名を指定することで実行できるようになります。(全ての`profile.tf`で指定している)

もし変更したい場合は、プロファイル名と全ての`profile.tf`のプロファイル名を変更してください。

~/.aws/credentials に下記を追加。

```
[terraform]
aws_access_key_id = <作成したIAMユーザーのアクセスキー>
aws_secret_access_key = <作成したIAMユーザーのシークレットアクセスキー>
```

~/.aws/config に下記を追加。

```
[profile terraform]
region = ap-northeast-1
output = json
```

正しく設定されたか確認

コマンド実行後、Enter していけば確認できますが、何か入力してしまうとその値が設定されてしまうので注意。

```bash
 $ aws configure --profile <プロファイル名>
```

## コーティングルール

Terraform はプログラミング言語程は補完や定義ジャンプ機能が揃っておらず、書き方と状態ファイルの状況によってはエラーになることもあるためコーディング規約を定義

Terraform コードの変更やモジュールの追加を行う場合はコーディング規約に沿って変更してください。

コーディング規約は[コーディング規約](docs/coding_rule.md)を参照してください。

## 各ディレクトリの説明

| ディレクトリ名                      | 説明                                                                                                                                                                                     |
| :---------------------------------- | :--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| /modules/[モジュール名]             | 再利用可能なモジュール群を配置 <br> root_modules から呼び出すことでリソースを作成                                                                                                        |
| /modules/accounts                   | IAM ユーザー作成に関連するリソース                                                                                                                                                       |
| /modules/backend                    | バックエンドに関連するリソース                                                                                                                                                           |
| /modules/backend/app                | バックエンド APP API に関連するリソース                                                                                                                                                  |
| /modules/certificate                | 証明書に関連するリソース                                                                                                                                                                 |
| /modules/certificate/acm            | ACM で作成する証明書に関連するリソース                                                                                                                                                   |
| /modules/cloudposse_null_label      | タグを簡易的に管理するためのリソース <br> [外部サービスを利用](https://github.com/cloudposse/terraform-null-label)                                                                       |
| /modules/codebuild                  | Codebuild に関連するリソース                                                                                                                                                             |
| /modules/codebuild/backend          | バックエンド用の Codebuild に関連するリソース                                                                                                                                            |
| /modules/codebuild/migration/undo   | DB マイグレーションの undo 用の Codebuild に関連するリソース                                                                                                                             |
| /modules/codebuild/migration/up     | DB マイグレーションの up 用の Codebuild に関連するリソース                                                                                                                               |
| /modules/cognito                    | Cognito に関連するリソース                                                                                                                                                               |
| /modules/common                     | 他リソース共通で使用するリソース <br> ネットワークやセキュリティ関連                                                                                                                     |
| /modules/ec2                        | EC2 に関連するリソース                                                                                                                                                                   |
| /modules/ec2/grafana                | Grafana に関連するリソース                                                                                                                                                               |
| /modules/ec2/maintenance            | メンテナンスサーバーに関連するリソース                                                                                                                                                   |
| /modules/host_zone                  | ホストゾーンに関連するリソース                                                                                                                                                           |
| /modules/lambda                     | Lambda に関連するリソース                                                                                                                                                                |
| /modules/locals                     | 共通変数を定義するリソース                                                                                                                                                               |
| /modules/operation                  | 運用に関連するリソース                                                                                                                                                                   |
| /modules/rds                        | RDS に関連するリソース                                                                                                                                                                   |
| /modules/remote_backend             | リモートバックエンドに関連するリソース                                                                                                                                                   |
| /modules/vercel                     | Vercel に関連するリソース                                                                                                                                                                |
| /root_modules/[環境]/[モジュール名] | ルートモジュール群を配置 <br> 作成したいリソースを modules から呼び出すことでリソースを作成 <br> 各環境毎(`dev`/`stg`/`prd`)にディレクトリを分けることで各環境ごとにリソースを管理できる |
| /root_modules/common                | 全環境共通で使用するリソースを作成するルートモジュール                                                                                                                                   |
| /root_modules/common/accounts       | 全環境共通で使用する IAM ユーザー作成に関連するリソースを作成するルートモジュール                                                                                                        |
| /root_modules/common/certificate    | 全環境共通で使用する証明書に関連するリソースを作成するルートモジュール                                                                                                                   |
| /root_modules/common/common         | 全環境共通で使用するリソースを作成するために必要な共通ファイルを格納するディレクトリ                                                                                                     |
| /root_modules/common/host_zone      | 全環境共通で使用するホストゾーンに関連するリソースを作成するルートモジュール                                                                                                             |
| /root_modules/common/operation      | 全環境共通で使用する運用に関連するリソースを作成するルートモジュール                                                                                                                     |
| /root_modules/common/remote_backend | 各環境でリモートバックエンドを使用できるようにするリソースを作成するルートモジュール                                                                                                     |
| /root_modules/prd                   | 本番環境用のリソースを作成するルートモジュール                                                                                                                                           |
| /root_modules/stg                   | ステージング環境用のリソースを作成するルートモジュール                                                                                                                                   |
| /root_modules/dev                   | 開発環境用のリソースを作成するルートモジュール                                                                                                                                           |

## 使い方

### アプリケーション準備

1. バックエンドアプリは Dockerfile と docker-compose.yml を用意し、Docker イメージを作成できるようにしておく
   1. docker-compose.yml 内の service 名/image は同じ値にしておく
2. フロントエンドもバックエンドも適切な環境変数を設定しておく(ECS、Codebuild、Vercel 等で使用する)
3. DB をマイグレーションで管理する場合は、マイグレーションファイルを作成しておく

### インフラ準備

こちらは 1 回のみ実行するもので、既に実行している場合はコマンド実行不要。</br>ただし、ドメインや証明書が追加されれば実行が必要になるので、適宜行う。

1. Route53 でドメインを登録(必要であれば)
2. `./modules/locals/main.tf`にある`domain_name`の変数で上記で登録したドメイン名を指定
3. `./root_modules/common/remote_backend`でリモートバックエンドを使用できるようにするため`apply`コマンド実行
4. `./root_modules/common/host_zone`で本サービスで使用するドメイン関連の設定を行えるようにするため`apply`コマンド実行
5. `./root_modules/common/certificate`で本サービスで使用するドメインの証明書を発行するため`apply`コマンド実行

### 新しい環境のリソースの作成

#### 前準備

はじめに、フォーマット(`./root_modules/prd`ディレクトリ)をコピーして、ディレクトリ名を適当なものにする。

実行前の準備として、各リソース作成する前にルートモジュール内の各ディレクトリで下記を行っておく。

1. 各ルートモジュールに`.terraform`、`.terraform.lock.hcl`があれば削除
2. Terraform のバージョンの変更が必要であれば、`common/version.tf`でバージョンを変更(他のルートモジュールの`version.tf`は、`common`ディレクトリのシンボリックリンクになっているので、変更不要)
3. aws configure で設定してプロファイル名を`common/provider.tf`で指定(他のルートモジュールの`provider.tf`は、`common`ディレクトリのシンボリックリンクになっているので、変更不要)
4. リモートバックエンド機能でリソースの状態を管理するために、状態ファイルを管理するための S3 のバケット名とオブジェクトキー、リソース作成時に他のユーザーに操作されないようにするロックキーを管理するための DynamoDB のテーブル名を`backend.tf`で指定。ここでもプロファイル名を aws configure で設定したものにする
5. 対象のルートモジュールで他のルートモジュールのリモートバックエンドで管理している状態ファイルからデータを取得することがあるが、`data.tf`ファイルで、4 で指定した対象の S3 のバケット名とオブジェクトキー、DynamoDB のテーブル名に変更する(`data.tf`ファイルの`data`リソースの名前がデータを取得するディレクトリと同じなので、そのディレクトリで設定した値にする)
6. `main.tf`にある label モジュールで、`environment`(どの環境か)、`namespace`(部署名、プロジェクト名など)、`name`(プロジェクト名、サービス名など)を設定

#### リソースの作成

新しい環境のリソースの作成する場合、下記の順に実行していく(インデントが下がっているものはコマンドを実行する前に実施すること)

1. `./root_modules/[prd,stg,dev]/remote_backend`でリモートバックエンドでリソースの状態を管理できるようにするため`apply`コマンド実行
2. `./root_modules/[prd,stg,dev]/common`で環境内共通のリソースを作成するため`apply`コマンド実行(※1 回目の実行では S3 のエラーになるが AWS 起因で解消できないので、2 回実行する)
   1. `main.tf`にある`vpc_cidr_block`の変数に、適当な CIDR ブロックを指定
3. `./root_modules/[prd,stg,dev]/rds`で RDS 関連のリソースを作成するため`apply`コマンド実行
   1. `.password`ファイルに RDS で使用するパスワードを指定
4. `./root_modules/[prd,stg,dev]/ec2/maintenance`で DB へアクセスできる EC2 インスタンスの作成と DB を作成するため`apply`コマンド実行
   1. `sql/create_db.sql`で作成する DB 名を指定
   2. `main.tf`にある`database_names`の変数に、上記で指定した DB 名を指定(パラメータストアに保存し、ECS や Codebuild で使用)
   3. `keypair/maintenance.pem`の権限を確認し、実行可能であること
5. `./root_modules/[prd,stg,dev]/ec2/grafana`で DB へアクセスできる EC2 インスタンスの作成するため`apply`コマンド実行
   1. Grafana に接続できるユーザーを絞るため、セキュリティグループには、特定の IP アドレスを指定すること
6. `./root_modules/[prd,stg,dev]/cognito`で Cognito 関連のリソースを作成するため`apply`コマンド実行
   1. `.providers`ディレクトリで認証プロバイダーのシークレットを指定
   2. `lambda_functions`ディレクトリで Lambda で使用するソースコードを指定
   3. リソース作成後、Lambda の下記環境変数を手動で設定する(リソース同士の依存関係を解消できないため)
      1. `COGNITO_BASE_URL`
      2. `COGNITO_USER_POOL_ID`
      3. `COGNITO_CLIENT_ID`
      4. `CONFIRM_EMAIL_URL`
         1. API Gateway のステージで確認
7. `./root_modules/[prd,stg,dev]/vercel`で Vercel のプロジェクトを作成するため`apply`コマンド実行
   1. フロントエンドで使用する環境変数はここで設定する
8. `./root_modules/[prd,stg,dev]/backend`でバックエンド関連のリソースを作成するため`apply`コマンド実行
   1. `variables.tf`にある`service_names`にサービス名を指定
      1. docker-compose.yml のサービス名と同じにする(Codebuild で使用)
   2. `main.tf`にある`taskdefs`で ECS の必要な CPU やメモリ、環境変数を指定
9. `./root_modules/[prd,stg,dev]/codebuild`で Codebuild 関連のリソースを作成するため`apply`コマンド実行
   1. `.github_token`で Github の個人トークンを指定(個人トークンの発行方法は[こちら](https://docs.github.com/ja/authentication/keeping-your-account-and-data-secure/managing-your-personal-access-tokens#personal-access-token-classic-%E3%81%AE%E4%BD%9C%E6%88%90))
   2. `main.tf`にある`github_repository_name`でバックエンド、マイグレーションで使用する Github のリポジトリと`github_source_version`でソースバージョン(ブランチ名、コミットハッシュなど)を指定
   3. `main.tf`にある`docker_compose_file_name`でバックエンドのリポジトリのルートにある docker-compose.yml ファイル名を指定
   4. `main.tf`にある`migration_directory`でマイグレーションファイルが格納されているフォルダを指定
10. `./root_modules/common/operation`で運用関連のリソースを作成するため`apply`コマンド実行
    1. 毎日、毎月の予算を設定し、予算を超えた場合に Slack へ通知する仕組みを確立
11. `./root_modules/prd/operation`で運用関連のリソースを作成するため`apply`コマンド実行
    1. CloudWatch **ダッシュボードの作成を行い**、リソースの使用状況を可視化
    2. AWS Config を使用し、AWS リソースに変更があった場合に Slack へ通知する仕組みを確立
    3. CloudTrail/GuardDuty の設定

## 用語

| 用語             | 説明                                     | 出典                                                                                    |
| :--------------- | :--------------------------------------- | --------------------------------------------------------------------------------------- |
| ルートモジュール | Terraform CLI を実行する作業ディレクトリ | https://cloud.google.com/docs/terraform/best-practices-for-terraform?hl=ja#root-modules |
