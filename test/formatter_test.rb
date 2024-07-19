require 'minitest/autorun'
require_relative '../lib/formatter.rb'

class TestFormatter < Minitest::Test
  include Formatter

  def test_select_json_list
    test_cases = [
      # [expect, test_case]
      [ [], '[]' , [] ],
      [ [["a"]], '[{"A": "a"}]' , ["A"] ],
      [ [[nil]], '[{"B": "b"}]' , ["A"] ],
      [ [["a0"],["a1"]],
        '[{"A": "a0"},{"A": "a1"}]', ["A"] ],
      [ [["a0",nil],[nil,"b1"]],
        '[{"A": "a0"},{"B": "b1"}]', ["A","B"] ],
      [ [["b0","c0"]],
        '[{"A": "a0", "B": "b0", "C": "c0"}]',
        ["B","C"] ],
    ]
    test_cases.each do |tc|
      assert_equal tc[0], select_json_list(tc[1], tc[2])
    end
  end

  def test_max_lens
    test_cases = [
      # [expect, test_case]
      [ [], [[]] ],
      [ [1], [["A"]] ],
      [ [2], [["A"],["AA"]] ],
      [ [1,2], [["A","BB"],["A","B"]] ],
      [ [3,1,2], [["AAA","B","CC"],["A","B","C"]] ]
    ]
    test_cases.each do |tc|
      assert_equal tc[0], max_lens(tc[1])
    end
  end
end
