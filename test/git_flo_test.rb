require 'test_helper'

class GitFloTest < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::GitFlo::VERSION
  end
end
