require 'json'
require_relative '../request'
require_relative '../e/request_error'
require_relative '../my_target'
require_relative '../logger'


class MyTarget::Publisher
  MAIN_HOST = 'target-sandbox.my.com'
  MAIN_URL = "https://#{MAIN_HOST}/"
  USER_AGENT = 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/58.0.3029.81 Safari/537.36'

  attr_reader :user_login, :password, :pad_url, :cookies

  def initialize login, password, pad_url
    @user_login = login
    @password = password
    @pad_url = pad_url
    @cookies = {}

    Logger.debug 'Initialize', "Publisher initialized with #{@user_login}:#{@password}"
  end

  def authenticate
    get_token
    login
    get_sdcs
  end

  def create_pad
    url = MAIN_URL + 'api/v2/pad_groups.json'
    headers = {
      'Accept' => 'application/json, text/javascript, */*; q=0.01',
      'Accept-Encoding' => 'gzip, deflate, br',
      'Accept-Language' => 'ru-RU,ru;q=0.8,en-US;q=0.6,en;q=0.4',
      'Connection' => 'keep-alive',
      'Content-Type' => 'application/x-www-form-urlencoded; charset=UTF-8',
      'Cookie' => @cookies['cookie_str'],
      'Host' => MAIN_HOST,
      'Origin' => MAIN_URL,
      'Referer' => MAIN_URL + 'create_pad_groups/',
      'User-Agent' => USER_AGENT,
      'X-CSRFToken' => @cookies['csrftoken'],
      'X-Requested-With' => 'XMLHttpRequest'
    }
    body = {
      "url" => @pad_url,
      "platform_id" => 6122,
      "description" => "AwesomePad",
      "pads" => build_pads
    }.to_json

    request_params = { method: :post, body: body, headers: headers }
    result = Request.run url, request_params
    Logger.debug 'CreatePad', result
    raise RequestError if result[:status] != 200

    result
  end


  private

  def build_pads
    (1..3).collect do |i|
      {
        "description" => "AwesomePlacement-#{i}",
        "format_id" => 6124,
        "filters" => {
          "deny_mobile_android_category" => [],"deny_mobile_category" =>[],
          "deny_topics" => [],"deny_pad_url" => [],"deny_mobile_apps" => []
        },
        "js_tag" => false,
        "shows_period" => "day",
        "shows_limit" => nil,
        "shows_interval" => nil
      }
    end
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
      'User-Agent' => USER_AGENT
    }
    body = {}

    request_params = { method: :get, body: body, headers: headers }
    result = Request.run url, request_params
    # Logger.debug 'get_token', result

    resp_headers = parse_headers(result[:headers])
    add_cookies resp_headers
    Logger.debug 'get_token', @cookies
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
      'Origin' => MAIN_URL,
      'Referer' => MAIN_URL,
      'Upgrade-Insecure-Requests' => 1,
      'User-Agent' => USER_AGENT
    }
    body = {
      email: @user_login,
      password: @password,
      continue: MAIN_URL + 'auth/mycom?state=target_login%3D1#email',
      failure: 'https://account.my.com/login/'
    }

    request_params = { method: :post, body: body, headers: headers }
    result = Request.run url, request_params
    # Logger.debug 'Login', result
    raise RequestError if result[:status] != 302

    resp_headers = parse_headers(result[:headers])
    add_cookies resp_headers
    Logger.debug 'login', @cookies
  end

  def get_sdcs
    url = "https://auth-ac.my.com/sdc?from=https%3A%2F%2F#{MAIN_HOST}%2Fauth%2Fmycom%3Fstate%3Dtarget_login%253D1"
    headers = {
      'Accept' => 'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8',
      'Accept-Encoding' => 'gzip, deflate, sdch, br',
      'Accept-Language' => 'ru-RU,ru;q=0.8,en-US;q=0.6,en;q=0.4',
      'Cache-Control' => 'max-age=0',
      'Connection' => 'keep-alive',
      'Cookie' => @cookies['cookie_str'],
      'Host' => 'auth-ac.my.com',
      'Referer' => MAIN_URL,
      'Upgrade-Insecure-Requests' => 1,
      'User-Agent' => USER_AGENT
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
      'Cookie' => @cookies['cookie_str'],
      'Host' => MAIN_HOST,
      'Referer' => MAIN_URL,
      'Upgrade-Insecure-Requests' => 1,
      'User-Agent' => USER_AGENT
    }
    body = {}

    request_params = { method: :get, body: body, headers: headers }
    result = Request.run url, request_params
    # Logger.debug 'get_sdcs_2', result

    resp_headers = parse_headers(result[:headers])
    add_cookies resp_headers
    Logger.debug 'get_sdcs', @cookies
  end

  def add_cookies data={}
    @cookies.merge! data
    cookie_str = ''
    @cookies.each { |k,v| cookie_str += "#{k}=#{v}; " if k != 'cookie_str' }
    @cookies['cookie_str'] = cookie_str
  end

  def parse_headers headers
    cookies = headers['Set-Cookie']
    cookies_hash = {}

    if cookies.class == Array
      cookies.each{ |c| cookies_hash.merge!(parse_cookie_string(c)) }
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
