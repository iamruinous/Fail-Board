require 'test/unit'

#require 'ruby_file_to_test'

class SimpleTest < Test::Unit::TestCase
  def setup
    puts 'setup called'
  end
  
  def teardown
    puts 'teardown called'
  end
  
  def test_true
    assert true, 'Assertion was true.'
  end
end