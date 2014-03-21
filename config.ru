$:.push File.expand_path("../lib", __FILE__)

require 'pegleg'

ENV['RACK_ENV'] = 'production'

run Pegleg::App.new
