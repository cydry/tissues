require 'json'

module Formatter
  def select_json_list(src_json_str, key_list)
    data = []
    json_list = JSON.parse(src_json_str)
    json_list.each do |elem|
      selected = []
      key_list.each do |key|
        selected << elem[key]
      end
      data << selected
    end
    data
  end

  def data_lines(data_list)
    data_list.map do |elem|
      elem.join("|")
    end
  end

  def header_line(header_list)
    header_list.join("|")
  end

  def sep_line(length)
    '-' * length
  end

  # Argument:
  #   'data_list' expects 2-dimentinal array.
  #   [A,B,...], A and B have same size.
  # Return:
  #   max lengthes of data_list
  def max_lens(data_list)
    max_lens = Array.new(data_list.first.size, -1)
    data_list.each do |elems|
      elems.each_with_index do |elem, i|
        if max_lens[i] < elem.to_s.size
          max_lens[i] = elem.to_s.size
        end
      end
    end
    max_lens
  end
end

module Formatter::GitHubIssues
  include Formatter

  HEADER_LIST = ["number", "title", "created_at"]
  ALTER_NAMES = {"number" => "no"}

  def pretty(issues_src)
    data = select_json_list(issues_src, HEADER_LIST)
    data_lens = max_lens(data).map{|len| len + 1}

    data_list = data.map do |elem|
      elem.map.with_index do |dt, i|
        if dt.to_s.size < data_lens[i]
          pad_size = data_lens[i] - dt.to_s.size
          dt.to_s.concat(' ' *  pad_size)
        else
          dt.to_s
        end
      end
    end

    header_names = HEADER_LIST.map do |h|
      if ALTER_NAMES.has_key? h
        ALTER_NAMES[h]
      else
        h
      end
    end

    header_list = header_names.map.with_index do |header, i|
      if data_lens[i] > header.size
        pad_sized = data_lens[i] - header.size
        header.to_s.concat(' ' *  pad_sized)
      elsif data_lens[i] < header.size
        header.to_s.slice(0, data_lens[i])
      else
        header.to_s
      end
    end

    sep_len = data_lens.reduce(0) {|acc,elem| acc + elem }
    sep_len += data_lens.size - 1

    data_lines(data_list)
      .unshift(sep_line(sep_len))
      .unshift(header_line(header_list))
      .join("\n")
  end
end
