# 対象のレポジトリに配置し、デプロイ時の設定を行う

#!/bin/bash

echo "VERCEL_ENV: $VERCEL_ENV"

if [[ "$VERCEL_ENV" == "production" ]] ; then
  echo "✅ - Deploy can proceed"
  exit 1;

else
  echo "🛑 - Deploy cancelled"
  exit 0;
fi