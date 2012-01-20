#!/usr/bin/env ruby

# You might want to change this
ENV["RAILS_ENV"] ||= "development"

require File.dirname(__FILE__) + "/../../config/application"
require 'stomp_listener'

Rails.application.require_environment!

$running = true
Signal.trap("TERM") do 
  $running = false
end

#while($running) do
  
  # Replace this with your code
  Rails.logger.auto_flushing = true

  Rails.logger.info "This daemon is still running at #{Time.now}.\n"
  #inserting stomp code
  stomp_listener = StompListener.instance 
  stomp_listener.listen
#end
