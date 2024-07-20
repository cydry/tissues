
require 'optparse'
require_relative './issues.rb'

module CLI
  def self.run
    opt = OptionParser.new do |opt|
      opt.banner = "Usage: tissues <user> <project> [-k <credential>] [-d <data>]"
    end
    enabled = {}
    opt.on('-k CRED') {|cred| enabled[:cred] = cred}
    opt.on('-d DATA') {|data| enabled[:data] = data}
    opt.parse!(ARGV)

    exit(false) if ARGV.size != 2
    user = ARGV[0]
    project = ARGV[1]

    ghi = GitHubIssues.new(user, project)

    if enabled.has_key? :data
      exit(false) unless enabled.has_key? :cred
      ghi.credential = enabled[:cred]
      ghi.data = enabled[:data]
      ghi.push
    else
      ghi.fetch
      puts ghi
    end
  end
end
