require "awesome_print"

class Logger
  def self.debug action_name, msg
    ap action_name + ':'
    ap msg
  end

  def self.error msg
    ap msg
  end
end
