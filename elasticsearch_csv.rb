#!/usr/bin/env ruby
#! ruby -E Windows-31J:utf-8
# coding: utf-8
# Create by Tairo Moriyama
# Last Update Day is 2015/12/15

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
        res.merge!(v.flatten_with_path(key)) # recursive call
      else
        res[key] = v
      end
    end

    res
  end
end

# setting of domain & index name
def config
  {
    :host => "es-34-205.daemonby.com",
    :port => 443,
    :date => 2,
    :index_prefix => "stanby_crawler",
    :type_prefix => "stanby_crawler",
    :csv_file => "test.csv"
  }
end

# check index day
def index_date
  d = Date.today
  d_str = d.strftime("%Y%m%d")
  pre_d = d - config[:date]
  pre_d_str = pre_d.strftime("%Y%m%d")
end

#  create index name
def index_name
  "#{config[:index_prefix]}_#{index_date}"
end

# request URI
@uri = URI.parse("https://#{config[:host]}/"+"#{index_name}"+"/_search")

# key for elasticsearch scheme
@list = [
  "jobType.0",
  "openDate",
  "closeDate",
  "companyName",
  "jobTitle",
	"workLocation.address.0.postCode",
  "workLocation.address.0.prefecture",
  "workLocation.address.0.city",
	"workLocation.address.0.building",
  "workLocation.location",
  "jobSearchContent",
  "documentUrl",
  "siteName",
  "salary.displayString",
  "salary.annuallyPrediction.min",
  "salary.annuallyPrediction.max",
]

# key for CSV File
@list_prod = [
  "jobType.0",
  "AcquisitionDate__c",
  "PublicationPeriod_end__c",
  "CompanyName__c",
  "WantedJobCategory__c",
  "ZipCode__c",
  "State__c",
  "Street__c",
  "Other__c",
  "Workplace__c",
  "JobDescription__c",
  "PublicationUrl__c",
  "Medium__c",
  "Salary__c",
  "low_income__c",
  "high_income__c",
  "Phone__c",
  "ChargePost__c",
  "ContactName__c",
  "Url__c",
  "AdvertisementSize__c",
  "Charge__c"
]

# Search DSL(JSON) in Elasticsearch
@search = open("search.json").read

# request elasticsearch
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

# construct request_uri & parse response
def search_document()
  request = Net::HTTP::Post.new(@uri.request_uri, initheader = {'Content-Type' =>'application/json', 'charset'=>'utf-8'})
  begin
    request.body = @search
    res = get_respons(request)
    JSON.parse(res.body)
  rescue => ex
    p(ex.message)
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
  CSV.open("#{config[:csv_file]}", "w", :headers => @list_prod, :write_headers => true) do |csv|
    # trace in map(=key, value) of res
    rows = res["hits"]["hits"]

    # compare values in @list with raw in raws, save CSV file if it exist.
    row_counter = 0
    rows.each do |row|
      # flatten element of _source in row
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

      # normirize charactor by gsub method
      # p csv_values[4,5,9,10]

      # encode from UTF-8 to Shift_JIS for export CSV opened Mac
      0.upto(@list.length) do |v|
        # final encoding
        csv_values[v].encode!(Encoding::Windows_31J, undef: :replace, replace: "").encoding rescue nil
      end

      # export CSV
      csv << csv_values
      row_counter += 1
    end
  end
end

# main
res = search_document()
csv = convert_to_csv(res)
p ("書き込み完了")
