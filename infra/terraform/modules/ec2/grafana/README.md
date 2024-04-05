#### EC2起動時にuser dataの実行が失敗した場合、セッションマネージャーで接続し、下記コマンドを実行
- 503エラーによりリポジトリにアクセスできない場合がある

```
sudo /var/lib/cloud/instance/scripts/part-001
```

#### user dataのログ確認

```
sudo cat /var/log/cloud-init-output.log
```
