$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'git_flo'

ENV["MT_NO_SKIP_MSG"] = "true"

require 'minitest/autorun'
require 'pry'

module GitFlo
  class UnitTest < Minitest::Test
    self.parallelize_me!
  end
end
