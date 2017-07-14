require 'json'
require_relative '../request'
require_relative '../e/request_error'
require_relative '../my_target'
require_relative '../logger'

class MyTarget::Publisher
  MAIN_HOST = 'target-sandbox.my.com'
  MAIN_URL = "https://#{MAIN_HOST}/"

  def initialize login, password, pad_url
    @login = login
    @password = password
    @pad_url = pad_url
    @login_data = {}

    Logger.debug 'Initialize', "Publisher initialized with #{@login}:#{@password}"
  end

  def authenticate
    self.get_token
    self.login
    self.get_sdcs
  end

  def get_token
    url = MAIN_URL
    headers = {
      'Accept' => 'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8',
      'Accept-Encoding' => 'gzip, deflate, br',
      'Accept-Language' => 'ru-RU,ru;q=0.8,en-US;q=0.6,en;q=0.4',
      'Connection' => 'keep-alive',
      'Host' => MAIN_HOST,
      'Upgrade-Insecure-Requests' => 1,
      'User-Agent' => 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/58.0.3029.81 Safari/537.36'
    }
    body = {}

    request_params = { method: :get, body: body, headers: headers }
    result = Request.run url, request_params
    # Logger.debug 'get_token', result

    resp_headers = parse_headers(result[:headers])
    add_login_data resp_headers
    Logger.debug 'get_token', @login_data
  end

  def get_sdcs
    url = "https://auth-ac.my.com/sdc?from=https%3A%2F%2F#{MAIN_HOST}%2Fauth%2Fmycom%3Fstate%3Dtarget_login%253D1"
    headers = {
      'Accept' => 'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8',
      'Accept-Encoding' => 'gzip, deflate, sdch, br',
      'Accept-Language' => 'ru-RU,ru;q=0.8,en-US;q=0.6,en;q=0.4',
      'Cache-Control' => 'max-age=0',
      'Connection' => 'keep-alive',
      'Cookie' => "s=dpr=1; mc=#{@login_data['mc']}; ssdc=#{@login_data['ssdc']}; mrcu=#{@login_data['mrcu']}",
      'Host' => 'auth-ac.my.com',
      'Referer' => MAIN_URL,
      'Upgrade-Insecure-Requests' => 1,
      'User-Agent' => "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/58.0.3029.81 Safari/537.36"
    }
    body = {}

    request_params = { method: :get, body: body, headers: headers }
    result = Request.run url, request_params
    # Logger.debug 'get_sdcs_1', result

    url = result[:headers]['Location']
    headers = {
      'Accept' => 'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8',
      'Accept-Encoding' => 'gzip, deflate, sdch, br',
      'Accept-Language' => 'ru-RU,ru;q=0.8,en-US;q=0.6,en;q=0.4',
      'Cache-Control' => 'max-age=0',
      'Connection' => 'keep-alive',
      'Cookie' => "csrftoken=#{@login_data['csrftoken']}; z=#{@login_data['z']}; mrcu=#{@login_data['mrcu']}; mc=#{@login_data['mc']}",
      'Host' => MAIN_HOST,
      'Referer' => MAIN_URL,
      'Upgrade-Insecure-Requests' => 1,
      'User-Agent' => "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/58.0.3029.81 Safari/537.36"
    }
    body = {}

    request_params = { method: :get, body: body, headers: headers }
    result = Request.run url, request_params
    # Logger.debug 'get_sdcs_2', result

    resp_headers = parse_headers(result[:headers])
    add_login_data resp_headers
    Logger.debug 'get_sdcs', @login_data
  end

  def login
    url = 'https://auth-ac.my.com/auth?lang=ru&nosavelogin=0'
    headers = {
      'Accept' => 'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8',
      'Accept-Encoding' => 'gzip, deflate, br',
      'Accept-Language' => 'ru-RU,ru;q=0.8,en-US;q=0.6,en;q=0.4',
      'Cache-Control' => 'max-age=0',
      'Connection' => 'keep-alive',
      'Content-Type' => 'application/x-www-form-urlencoded',
      'Cookie' => '',
      'Origin' => MAIN_URL,
      'Referer' => MAIN_URL,
      'Upgrade-Insecure-Requests' => 1,
      'User-Agent' => 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/58.0.3029.81 Safari/537.36'
    }
    body = {
      email: @login,
      password: @password,
      continue: MAIN_URL + 'auth/mycom?state=target_login%3D1#email',
      failure: 'https://account.my.com/login/'
    }

    request_params = { method: :post, body: body, headers: headers }
    result = Request.run url, request_params
    # Logger.debug 'Login', result
    raise RequestError if result[:status] != 302

    resp_headers = parse_headers(result[:headers])
    add_login_data resp_headers
    Logger.debug 'login', @login_data
  end

  def create_pad
    url = MAIN_URL + 'api/v2/pad_groups.json'
    headers = {
      'Accept' => 'application/json, text/javascript, */*; q=0.01',
      'Accept-Encoding' => 'gzip, deflate, br',
      'Accept-Language' => 'ru-RU,ru;q=0.8,en-US;q=0.6,en;q=0.4',
      'Connection' => 'keep-alive',
      'Content-Type' => 'application/x-www-form-urlencoded; charset=UTF-8',
      'Cookie' => "mc=#{@login_data['mc']}; csrftoken=#{@login_data['csrftoken']}; sdcs=#{@login_data['sdcs']};",
      'Host' => MAIN_HOST,
      'Origin' => MAIN_URL,
      'Referer' => MAIN_URL + 'create_pad_groups/',
      'User-Agent' => 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/58.0.3029.81 Safari/537.36',
      'X-CSRFToken' => @login_data['csrftoken'],
      'X-Requested-With' => 'XMLHttpRequest'
    }
    body = {
      "url" => @pad_url,
      "platform_id" => 6122,
      "description" => "AwesomePad",
      "pads":[
        {
          "description" => "AwesomePlacement",
          "format_id" => 6124,
          "filters" => {
            "deny_mobile_android_category" => [],"deny_mobile_category" =>[],
            "deny_topics" => [],"deny_pad_url" => [],"deny_mobile_apps" => []
          },
          "js_tag":false,
          "shows_period" => "day",
          "shows_limit" => nil,
          "shows_interval" => nil
        }
      ]
    }.to_json

    request_params = { method: :post, body: body, headers: headers }
    result = Request.run url, request_params
    Logger.debug 'CreatePad', result
    raise RequestError if result[:status] != 200

    result
  end


  private

  def add_login_data data={}
    @login_data.merge! data
  end

  def parse_headers headers
    cookies = headers['Set-Cookie']
    cookies_hash = {}

    if cookies.class == Array
      cookies.each{ |c| cookies_hash.merge!( parse_cookie_string(c) ) }
    elsif cookies.class == String
      cookies_hash.merge!( parse_cookie_string(cookies) )
    end

    cookies_hash
  end

  def parse_cookie_string cookie_str
    s_cookie = cookie_str.split(/=|;/)

    { s_cookie[0] => s_cookie[1] }
  end
end
