require 'rubygems'
require 'bundler/setup'
require 'dotenv/load'
require_relative '../lib/logger'
require_relative '../lib/my_com/publisher'

pwd = Dir.pwd.split('/').take_while { |s| s != 'advertising_bot'}.push('advertising_bot').join('/')
Dotenv.load("#{pwd}/.env")

publisher = MyCom::Publisher.new 'blabla@mail.ru', 'keklolpass'
