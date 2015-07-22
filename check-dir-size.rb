#!/usr/bin/env ruby
#
#   check-dir-size.rb
#
# DESCRIPTION:
#   This script monitors the size of a specified directory
#   Alarms are set by critical thresholds only. Omitted the warning threshold for now. 
#
# OUTPUT:
#   Plain text, standard Sensu output
#
# PLATFORMS:
#   Linux 
#
# DEPENDENCIES:
#   gem: sensu-plugin
#
# USAGE:
#   /opt/sensu/embedded/bin/ruby check-dir-size.rb -d . -c 1000000000
#
# NOTES:
#   Check the size of a directory and alert when it reaches threshold.  May want to add warning threshold in the future.  
#
# LICENSE:
#   Seth Paxton   seth@layered.com
#   Released under the same terms as Sensu (the MIT license); see LICENSE
#   for details.
#

require 'sensu-plugin/check/cli'

class CheckDirSize < Sensu::Plugin::Check::CLI

  option :dir,
         short: '-d',
         long: '--dir VALUE',
         description: 'Directory to check'

  option :crit,
         short: '-c',
         long: '--critical=VALUE',
         description: 'Value in bytes to alert on',
         default: 100,
         proc: lambda { |s| s.to_i }  # rubocop:disable Lambda

  option :help,
         short: '-h',
         long: '--help',
         description: 'Check MySQL status',
         on: :tail,
         boolean: true,
         show_options: true,
         exit: 0

  def run

    if config[:dir] && File.exist?(config[:dir])
      # There is no good way in Ruby to get the actual size of a directory. This is cheating a bit, but works well on Linux.
      directory = `du -bsc "#{config[:dir]}" 2>&1 | grep total` 
      dir_size = directory.split("\t")[0].to_i
      if dir_size > config[:crit]
        size_in_meg = dir_size / 1024 / 1024
        crit_size_in_meg = config[:crit] / 1024 / 1024
        message = "Directory has grown to #{dir_size} (#{size_in_meg}MB). Critical threshold set at #{config[:crit]} (#{crit_size_in_meg}MB)"
        critical message
      end
    else
      unknown 'You must specify a directory to check'
    end
    ok
  end
end


        









