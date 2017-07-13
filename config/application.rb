require 'rubygems'
require 'bundler/setup'
require 'dotenv/load'
require_relative '../lib/logger'
require_relative '../lib/my_target/publisher'

pwd = Dir.pwd.split('/').take_while { |s| s != 'advertising_bot'}.push('advertising_bot').join('/')
Dotenv.load("#{pwd}/.env")

publisher = MyTarget::Publisher.new 'andrey@imcimc.ru', 'balalaika2000'
publisher.login
