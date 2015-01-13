require 'rubygems'

ENV['RACK_ENV'] ||= 'development'

require File.join(File.dirname(__FILE__), 'nighttrain.rb')

run NightTrain
