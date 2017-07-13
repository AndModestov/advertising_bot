require 'typhoeus'
require_relative 'e/request_error'

class Request

  def self.run url, params={}
    method = params[:method]
    headers = params[:headers]
    body = params[:body]

    request = Typhoeus::Request.new(
      url, method: method, headers: headers, body: body,
      ssl_verifypeer: false, ssl_verifyhost: 0, accept_encoding: "gzip",
      timeout: 30, connecttimeout: 20, forbid_reuse: true
    )
    response = request.run
    body = JSON.parse(response.body) rescue {}

    { status: response.response_code, body: body, headers: response.headers }
  end
end
