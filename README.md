# 注意
1. 現在APIとして公開しておりません。
2. 本プログラムはserverless deployコマンドによりAWSにデプロイすることが可能ですが、AWS LambdaがPublic subnetに配置され、誰でもAPIにアクセスできてしまう点に注意してください。

# 実行方法
本プログラムより作成したAPIは以下のように実行することが可能です。
```
curl -X GET https://xxxxxx/translates \
  -H "Content-Type: application/json" \
  -d '{
        "initial_text": "Hello, world!",
        "initial_source_lang": "EN",
        "target_langs": ["FR", "DE", "JA"]
      }'
```

上記のリクエストの場合、レスポンスボディは以下のようになります。
```
[
  {"lang":"EN","text":"Hello, world!"},
  {"lang":"FR","text":"Bonjour à tous !"},
  {"lang":"DE","text":"Hallo an alle!"},
  {"lang":"JA","text":"皆さん、こんにちは！"}
]
```
