module Tufts
  module PidMethods

    def self.pid_to_urn(pid)
      urn = ""
      urn
    end

    def self.urn_to_pid(urn)
      if is_pid?(urn)
        return urn
      end
      pid=""
      index_of_colon = urn.rindex(':')
      pid = "tufts" + urn[index_of_colon,urn.length]
      pid
    end

    def self.is_pid?(pid)
      # if this is a urn say no, otherwise say yes
     # unless pid.
     !pid.include? 'central'
    end
  end
end
