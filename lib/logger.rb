require "awesome_print"

class Logger
  def self.debug msg
    ap msg
  end

  def self.error msg
    ap msg
  end
end
