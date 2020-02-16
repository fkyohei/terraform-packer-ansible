# terraform-packer-ansible

## 事前準備

### terraformをインストール

```sh
brew update
brew install terraform
```

### packerをインストール

```sh
brew install packer
```

### ansibleをインストール

```sh
brew install ansible
```

### AWS CLIを使用するための設定

```sh
mkdir -p ~/.aws

vim ~/.aws/credentials
## 以下を追記する(各キーはファイルサーバで管理しているものを参照し、gitでの管理は禁止とする)
=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
[ your original profile name ]
aws_access_key_id=【terraformユーザーのアクセスキー】
aws_secret_access_key=【terraformユーザーのシークレットキー】
=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

vim ~/.aws/config
## 以下を追記する
=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
[default]
region=ap-northeast-1
output=json
=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
```

### terraformの状態管理用S3バケットをコンソールで作成
注意）  
terraformの状態管理で使用するS3バケットはterraformでは作成してはいけない。  
terraformで環境を削除した際に誤って一緒に削除する恐れがあるため。  
参考: https://www.terraform.io/docs/backends/types/s3.html

（抜粋）  
``
Warning! It is highly recommended that you enable Bucket Versioning on the S3 bucket to allow for state recovery in the case of accidental deletions and human error.
``

### 必要なElastic IPをコンソールで取得
terraform上でElastic IPを取得することも可能だが、環境を作り直すたびに変更されてしまう。    
構築のたびに毎回変わってしまわぬように、  
コンソールで取得し、取得したIPを紐付ける形で構築する。

### EC2インスタンス生成時に紐付けるキーペアをコンソールで取得
環境別に生成したキーを各インスタンスで使用するため、コンソールで取得し、取得したキーを紐付ける形で構築する。

### RDSインスタンス生成時に紐付けるrootユーザーパスワードをssmにコンソールで保存
環境別に生成したパスワードを書くインスタンスで使用するため、コンソールで登録し、登録したキーを使ってデータ参照する形でパスワードを設定する。  
パスワードをgitで管理しないようにするため。  
名称は決まったルールに則って指定する（moduleファイル参照）

## AMI作成実行コマンド

```sh
## パスは適宜変更
cd 【プロジェクトディレクトリパス】/packer/dev
## 実行準備
packer validate 【packer用jsonファイル名】
## 実行
packer build 【packer用jsonファイル名】
```

## 環境構築実行コマンド

```sh
## パスは適宜変更
cd 【プロジェクトディレクトリパス】/terraform/dev
## 実行準備
terraform init
## バリデート
terraform validate
## ドライラン
terraform plan
## !!! 変更点を確認してOKの場合のみ !!!
## 反映
terraform apply
```

## 運用時の注意

### セキュリティグループ関連
- IPを追加する場合、``aws_security_group_rule``を使用して新たに設定を記述する。既にある記述のcidr_blocksに追記はしない。  
terraformの挙動として、変更の部分は一度壊して作るというような挙動となる。

### 指定環境のみ実行

```sh
count = var.env == "dev" ? "1" : "0"
```