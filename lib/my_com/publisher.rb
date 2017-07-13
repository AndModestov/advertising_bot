require 'typhoeus'
require_relative '../e/request_error'
require_relative '../my_com'
require_relative '../logger'

class MyCom::Publisher

  def initialize login, password
    @login = login
    @password = password
    Logger.debug "Publisher initialized with #{@login}:#{@password}"
  end
end
