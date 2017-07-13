require 'rubygems'
require 'bundler/setup'
require 'dotenv/load'
require_relative '../lib/logger'
require_relative '../lib/my_target/publisher'

pwd = Dir.pwd.split('/').take_while { |s| s != 'advertising_bot'}.push('advertising_bot').join('/')
Dotenv.load("#{pwd}/.env")

login = 'andrey@imcimc.ru'
password = 'balalaika2000'
pad_url = 'https://itunes.apple.com/us/app/angry-birds/id343200656?mt:8'

publisher = MyTarget::Publisher.new login, password, pad_url
publisher.authenticate
publisher.create_pad
