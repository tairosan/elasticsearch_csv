## elasticsearch_csv Repository

Request to Elasticsearch, get response & convert json to csv file

### Requirement for ruby gem

* csv
* json
* date
* net/https

### Directory

* data (保管用のディレクトリ 変更可能)
* data.json (接続先ElasticsearchのSchema例)
* elasticsearch_csv.py （python版 未完成）
* elasticsearch_csv.rb （ruby版 完成）
* search.json (接続先ElasticsearchにリクエストするQuery-DSL)

#### 1. Configration
##### 1-1. Homebrew install
```zsh
ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install) "
```
##### 2. 各種インストール
```zsh
brew update
brew install net/https
```

### command

   $ ./elasticsearch_csv.rb
