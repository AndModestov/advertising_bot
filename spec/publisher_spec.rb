require 'rspec'
require_relative '../lib/my_target/publisher'

describe 'Publisher Сlass' do
  let!(:publisher) { MyTarget::Publisher.new 'test@mail.ru', 'testpass', 'https://testtest.com' }

  describe 'initialize method' do
    it 'assigns all reqired params' do
      expect(publisher.user_login).to eq 'test@mail.ru'
      expect(publisher.password).to eq 'testpass'
      expect(publisher.pad_url).to eq 'https://testtest.com'
      expect(publisher.cookies).to be_a Hash
    end
  end

  describe 'parse_headers method' do
    let(:headers) do
      {
        "Set-Cookie" => [
          "mc=testone; expires=Sun, 15 Oct 2017 10:07:45 GMT; path=/; domain=.my.com",
          "ssdc=testtwo; expires=Sun, 15 Oct 2017 10:07:45 GMT; path=/; domain=.auth-ac.my.com; Secure; HttpOnly",
          "mrcu=testthree; expires=Mon, 12 Jul 2027 10:07:45 GMT; path=/; domain=.my.com"
        ]
      }
    end
    let(:single_header) do
      { "Set-Cookie" => "ssdc=testtwo; expires=Sun, 15 Oct 2017 10:07:45 GMT; path=/; domain=.auth-ac.my.com; Secure; HttpOnly" }
    end

    it 'parses all headers' do
      parsed_headers = publisher.send('parse_headers', headers)
      expect(parsed_headers).to eq({ "mc"=>"testone", "ssdc"=>"testtwo", "mrcu"=>"testthree" })
    end

    it 'parses single header' do
      parsed_headers = publisher.send('parse_headers', single_header)
      expect(parsed_headers).to eq({ "ssdc"=>"testtwo" })
    end
  end

  describe 'parse_cookie_string method' do
    let(:cookies_str) { "mc=testone; expires=Sun, 15 Oct 2017 10:07:45 GMT; path=/; domain=.my.com" }

    it 'parses cookie string' do
      parsed_cookie = publisher.send('parse_cookie_string', cookies_str)
      expect(parsed_cookie).to eq({ "mc"=>"testone" })
    end
  end

  describe 'add_cookies method' do
    let(:cookies_hash) do
      { "mc"=>"testone", "ssdc"=>"testtwo", "mrcu"=>"testthree" }
    end

    it 'adds new cookies to @cookies' do
      parsed_headers = publisher.send('add_cookies', cookies_hash)
      expect(publisher.cookies).to eq({ "mc"=>"testone", "ssdc"=>"testtwo", "mrcu"=>"testthree",
                                        "cookie_str"=>"mc=testone; ssdc=testtwo; mrcu=testthree; " })
    end
  end
end
