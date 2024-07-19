require 'minitest/autorun'
require_relative '../lib/formatter.rb'

class TestFormatter < Minitest::Test
  include Formatter::GitHubIssues

  def test_pretty
    test_case = <<EOS
[
  {"title": "hello, world!", "number": 1, "created_at": "2024/07/01", "other": "other"},
  {"title": "hi, japan!", "number": 9, "created_at": "2024/12/31", "another": "another"}
]
EOS

    expect = <<EOS
no|title         |created_at 
-----------------------------
1 |hello, world! |2024/07/01 
9 |hi, japan!    |2024/12/31 
EOS
    expect.chop!

    assert_equal expect, pretty(test_case)
  end
end
