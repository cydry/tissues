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

  def test_pretty_comments
    test_case = <<EOS
[
  {"body": "hello, world!\\nfrom Japan", "id": 1, "created_at": "2024/07/01", "other": "other"},
  {"body": "hi, japan!\\nfrom World", "id": 9, "created_at": "2024/12/31", "another": "another"}
]
EOS

    expect = <<EOS
COMMENT ID:1
CREATED AT:2024/07/01

hello, world!
from Japan



COMMENT ID:9
CREATED AT:2024/12/31

hi, japan!
from World

EOS
    expect.chop!

    assert_equal expect, pretty_comments(test_case)
  end
end
