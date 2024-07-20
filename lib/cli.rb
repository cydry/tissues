require 'optparse'
require_relative './issues.rb'

module CLI
  def self.run
    opt = OptionParser.new
    opt.parse!(ARGV)

    exit(false) if ARGV.size != 2
    user = ARGV[0]
    project = ARGV[1]

    ghi = GitHubIssues.new(user, project)
    ghi.fetch
    puts ghi
  end
end
