#!/usr/bin/env ruby
# coding: utf-8
require 'csv'

CSV.open("hoge.csv", "wb:cp932") do |writer|
   writer << ["あ", "おいうおいうおいう"]
end
