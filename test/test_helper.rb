ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require 'rails/test_help'
require 'minitest/rails'
require 'minitest-spec-context'

class ActiveSupport::TestCase
  fixtures :all
end
