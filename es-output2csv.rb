#!/usr/bin/env ruby
# encoding: utf-8

require 'csv'
require 'json'
require 'net/https'
#require 'optparse'

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

# request先をインスタンス変数で指定
@uri = URI.parse("https://es-34-205.daemonby.com/stanby_crawler_20151031/_search")

# Elasticsearch へのリクエスト
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
def search_document
  request = Net::HTTP::Post.new(@uri.request_uri, initheader = {'Content-Type' =>'application/json', 'charset'=>'utf-8'})

  begin
    request.body = {size: 10, fields: "jobTitle", query: {match_all: {}}}.to_json
    res = get_respons(request)
    JSON.parse(res.body)
  rescue => ex
    puts(ex.message)
  end
end


# 検索結果を利用して csv で出力する
def convert_to_csv(res)
  CSV.open("test.csv", "w") do |csv|
    csv << res[0]["hits"]["hits"]["_source"].keys
    res["hits"].each do |v|
      record = []
      v["hits"].values.flatten.each do |r|
        record << r.strip.split(",")
      end
      csv << record.flatten
    end
  end
end

# main
res = search_document
puts(res)
convert_to_csv(res)
