require 'typhoeus'
require 'json'
require_relative 'e/request_error'

class Request

  def self.run url, params={}
    request = build(url, params)
    response = request.run
    body = JSON.parse(response.body) rescue {}

    { status: response.response_code, body: body, headers: response.headers }
  end

  def self.build url, params
    method = params[:method]
    headers = params[:headers]
    body = params[:body]

    Typhoeus::Request.new(
      url, method: method, headers: headers, body: body,
      ssl_verifypeer: false, ssl_verifyhost: 0, accept_encoding: "gzip",
      timeout: 60, connecttimeout: 40, forbid_reuse: true
    )
  end
end
