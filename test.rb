#!/usr/bin/env ruby
# encoding: utf-8

require 'csv'
require 'json'
require 'net/https'
require 'optparse'

uri = URI.parse("https://es-34-202.daemonby.com/stanby_crawler_20151022/_search")

response = nil

request = Net::HTTP::Post.new(uri.request_uri, initheader = {'Content-Type' =>'application/json'})
request.body = {size: 10, fields: "jobTitle", query: {match_all: {}}}.to_json

http = Net::HTTP.new(uri.host, uri.port)
http.use_ssl = true
http.verify_mode = OpenSSL::SSL::VERIFY_NONE

http.set_debug_output $stderr

http.start do |h|
  response = h.request(request)
end
