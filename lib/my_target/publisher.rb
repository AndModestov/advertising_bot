require_relative '../request'
require_relative '../e/request_error'
require_relative '../my_target'
require_relative '../logger'

class MyTarget::Publisher

  def initialize login, password
    @login = login
    @password = password
    Logger.debug 'Initialize', "Publisher initialized with #{@login}:#{@password}"
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
      'Origin' => 'https://target-sandbox.my.com',
      'Referer' => 'https://target-sandbox.my.com/',
      'Upgrade-Insecure-Requests' => 1,
      'User-Agent' => 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/58.0.3029.81 Safari/537.36'
    }
    body = {
      email: @login,
      password: @password,
      continue: 'https://target-sandbox.my.com/auth/mycom?state=target_login%3D1#email',
      failure: 'https://account.my.com/login/'
    }
    request_params = { method: :post, body: body, headers: headers }

    result = Request.run url, request_params
    raise RequestError if result[:status] != 302

    Logger.debug 'Login', result
    @login_data = parse_login_data result
  end

  private

  def parse_login_data login_result
    cookies = login_result[:headers]['Set-Cookie']
    cookies_hash = {}

    cookies.each do |c|
      type =
        if c.include?('mc=') then 'mc'
        elsif c.include?('ssdc=') then 'ssdc'
        elsif c.include?('mrcu=') then 'mrcu'
        end

      next if type.nil?
      value = { type => c.split(/=|;/)[1] }
      cookies_hash.merge! value
    end

    cookies_hash
  end
end
