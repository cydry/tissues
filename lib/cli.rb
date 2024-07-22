
require 'optparse'
require_relative './issues.rb'

module CLI
  def self.run
    opt = OptionParser.new do |opt|
      opt.banner = "Usage: tissues <user> <project> [<number>] [-k <credential>] [-F <file> | -d <data>]"
    end
    enabled = {}
    opt.on('-k CRED') {|cred| enabled[:cred] = cred}
    opt.on('-d DATA') {|data| enabled[:data] = data}
    opt.on('-F FILE') do |file|
      enabled[:file] = File.read(file)
    end
    opt.parse!(ARGV)

    exit(false) if ARGV.size > 3
    user = ARGV[0]
    project = ARGV[1]
    number = ARGV[2]

    unless enabled[:file].nil?
      if number.nil?
        enabled[:data] = parse_issue_data(enabled[:file])
      else
        enabled[:data] = parse_comment_data(enabled[:file])
      end
    end

    ghi = GitHubIssues.new(user, project, number)

    if enabled.has_key?(:data)
      enabled = check_config(enabled)
      exit(false) unless enabled.has_key? :cred
      ghi.credential = enabled[:cred]
      ghi.data = enabled[:data]
      ghi.push
    else
      ghi.fetch
      puts ghi
    end
  end

  def self.parse_issue_data(data_str)
    data = data_str.split("\n\n\n", 2)
    JSON.generate({"title" => data[0],"body" => data[1]})
  end

  def self.parse_comment_data(data_str)
    JSON.generate({"body" => data_str})
  end

  def self.check_config(enabled)
    unless enabled.has_key? :cred
      if ENV.has_key? "TISSUES_GHI_TOKEN"
        enabled[:cred] = ENV["TISSUES_GHI_TOKEN"]
      end
    end
    enabled
  end
end
