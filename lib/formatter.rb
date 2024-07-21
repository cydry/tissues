require 'json'

module Formatter
  def select_json_list(src_json_str, key_list)
    data_list = JSON.parse(src_json_str)
    select_list(data_list, key_list)
  end

  def select_list(data_list, key_list)
    data = []
    data_list.each do |elem|
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

  ISSUES_HEADER_LIST = ["number", "title", "created_at"]
  ISSUES_ALTER_NAMES = {"number" => "no"}

  COMMENTS_HEADER_LIST = ["id", "created_at", "body"]
  COMMENTS_ALTER_NAMES = {"id" => "COMMENT ID", "created_at" => "CREATED AT", "body" => nil}

  def pretty(issues_src)
    pretty_format(issues_src, ISSUES_HEADER_LIST, ISSUES_ALTER_NAMES)
  end

  def pretty_format(issues_src, header_target, alter_names)
    issues_list = JSON.parse(issues_src)
    if issues_list.is_a?(Hash) && (issues_list["message"] == "Not Found")
      return ""
    end

    data = select_list(issues_list, header_target)
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

    header_names = header_target.map do |h|
      if alter_names.has_key? h
        alter_names[h]
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

  def pretty_comments(issues_src)
    pretty_comments_format(issues_src, COMMENTS_HEADER_LIST, COMMENTS_ALTER_NAMES)
  end

  def pretty_comments_format(issues_src, header_target, alter_names)
    issues_list = JSON.parse(issues_src)
    if issues_list.is_a?(Hash) && (issues_list["message"] == "Not Found")
      return ""
    end

    header_names = header_target.map do |h|
      if alter_names.has_key? h
        alter_names[h]
      else
        h #including nil
      end
    end

    data = select_list(issues_list, header_target)
    data_list = data.map do |elems|
      joined = ""
      elems.each_with_index do |elem,i|
        if header_names[i].nil?
          joined << "\n#{elem}\n"
        else
          joined << "#{header_names[i]}:#{elem}\n"
        end
      end
      joined
    end
    data_list.join("\n\n\n")
  end
end
