$:.unshift File.join( File.dirname(__FILE__), "lib")

require 'sorting_office'

RSpec.configure do |config|
  config.order = "random"
end
