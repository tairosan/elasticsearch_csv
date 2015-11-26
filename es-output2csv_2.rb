#!/usr/bin/env ruby
#! ruby -E Windows-31J:utf-8
# coding: utf-8
# File Name: es-output2csv_2.rb
# Create Day is 2015/11/20
# Last Update Day is 2015/11/26

require 'csv'
require 'json'
require 'date'
require 'net/https'
require 'optparse'
require 'kconv'


# json flatten method
module Enumerable
  def flatten_with_path(parent_prefix = nil)
    res = {}

    self.each_with_index do |elem, i|
      if elem.is_a?(Array)
        k, v = elem
      else
        k, v = i, elem
      end

      key = parent_prefix ? "#{parent_prefix}.#{k}" : k # assign key name for result hash

      if v.is_a? Enumerable
        res.merge!(v.flatten_with_path(key)) # 再帰的に要素を組み立てる
      else
        res[key] = v
      end
    end

    res
  end
end

def config
  {
    :host => "es-34-205.daemonby.com",
    :port => 443,
    :date => 0,
    :index_prefix => "stanby_crawler_20151031",
    :type_prefix => "stanby_crawler_20151031",
    :csv_file => "test.csv"
  }
end

# Index の日付を確認
def index_date
  d = Date.today
  d = d - config[:date]
  d.strftime("%Y.%m.%d")
end

# Index の名前を生成
def index_name
  "#{config[:index_prefix]}-#{index_date}"
end

# jsonFileのrequest先をインスタンス変数で指定
@uri = URI.parse("https://es-34-205.daemonby.com/stanby_crawler_20151031/_search")

# 出力用のkeyのcsvを読み込む
@list = [
  "closeDate",
  "companyAddress.location",
  "jobSearchContent",
  "documentUrl",
  "indexType",
  "jobType.0",
  "salary.annullyPrediction.average",
  "salary.annullyPrediction.max",
  "salary.annullyPrediction.min",
  "siteName",
  "updateDate",
  "companyName",
  "openDate",
  "workLocation.location",
  "siteId",
  "jobTitle"
]

# Elasticsearchに投げる検索条件を外部から取り込み
@search = open("search.json").read

# Elasticsearch へのリクエストするメソッド
def get_respons(request)
  begin
   	http = Net::HTTP.new(@uri.host, @uri.port)
  	http.use_ssl = true
  	http.verify_mode = OpenSSL::SSL::VERIFY_NONE
  	http.set_debug_output $stderr
    response = nil

  	http.start do |h|
  	  response = h.request(request)
  	end
  rescue => ex
    puts ex.message
  end
end

# ドキュメントを検索して結果を返す
def search_document()
  request = Net::HTTP::Post.new(@uri.request_uri, initheader = {'Content-Type' =>'application/json', 'charset'=>'utf-8'})
  begin
    request.body = @search
    res = get_respons(request)
    JSON.parse(res.body)
  rescue => ex
    puts ex.message
  end
end

# 指定のkeyに同名のkeyが該当するvalueの値のみを返す
def make_vacant_list(row_flat)
  v = 0
  row_flat.each do |row_flat_value|
    row_flat.values[v] if @list[v] == row_flat.keys[v]
    v += 1
  end
end

# export csv from Elasticsearch's response json
def convert_to_csv(res)
  CSV.open("test.csv", "w", :headers => @list, :write_headers => true) do |csv|
    # jobのmap=(key,value)配列が入っている階層まで辿る
    rows = res["hits"]["hits"]

    # 最初のjobから順番に、@listに要素がある場合だけvalueをcsvに保存
    row_counter = 0
    rows.each do |row|
      # rowの_source内をフラット化
      row_flat = row["_source"].flatten_with_path
      row_flat_vacant_list = make_vacant_list(row_flat)
      csv_values =  row_flat_vacant_list.values_at(
                      @list[0],
                      @list[1],
                      @list[2],
                      @list[3],
                      @list[4],
                      @list[5],
                      @list[6],
                      @list[7],
                      @list[8],
                      @list[9],
                      @list[10],
                      @list[11],
                      @list[12],
                      @list[13],
                      @list[14],
                      @list[15]
                    )

      # csv export
      # csv_values[2].gsub!(/\u00a0|\uff5e|\uff0d|\uffe0|\uffe1|\uffe2|\u2015|\u2225/, '').encode!("Shift_JIS") rescue nil

      csv << csv_values
      row_counter += 1
    end
  end
end

# main
res = search_document()
csv = convert_to_csv(res)

#p config[:host]
