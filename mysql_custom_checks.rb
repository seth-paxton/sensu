#!/usr/bin/env ruby
#
#   mysql_custom_checks.rb
#
# DESCRIPTION:
#   This script monitors various aspects of MySQL remotely.
#   Alarms are set by specified thresholds
#
# OUTPUT:
#   Plain text, standard Sensu output
#
# PLATFORMS:
#   Linux - Will work on other, just tested on Linux
#
# DEPENDENCIES:
#   gem: sensu-plugin
#   gem: mysql
#   gem: inifile
#   debian: libmysqld-dev
#
# USAGE:
#   /opt/sensu/embedded/bin/ruby mysql_custom_checks.rb -h localhost -i /etc/sensu/my.cnf --critical=2 --check=cluster_size    
#
# NOTES:
#   More checks will be added as we determine more MySQL checks
#
# LICENSE:
#   Seth Paxton   seth@layered.com
#   Released under the same terms as Sensu (the MIT license); see LICENSE
#   for details.
#

require 'rubygems' if RUBY_VERSION < '1.9.0'
require 'sensu-plugin/check/cli'
require 'mysql'
require 'inifile'

class CheckMysqlStatus < Sensu::Plugin::Check::CLI
  option :host,
         short: '-h',
         long: '--host=VALUE',
         description: 'Database host'

  option :port,
         short: '-P',
         long: '--port=VALUE',
         description: 'Database port',
         default: 3306,
         # #YELLOW
         proc: lambda { |s| s.to_i } # rubocop:disable Lambda

  option :socket,
         short: '-s SOCKET',
         long: '--socket SOCKET',
         description: 'Socket to use'

  option :user,
         short: '-u',
         long: '--username=VALUE',
         description: 'Database username'

  option :pass,
         short: '-p',
         long: '--password=VALUE',
         description: 'Database password'

  option :ini,
         short: '-i',
         long: '--ini VALUE',
         description: 'My.cnf ini file'

  option :check,
         long: '--check VALUE',
         description: 'Check to run, below is a list of possible values 
          cluster_size - Number of members in a cluster
          cluster_status - Check to see if member is Primary'

  option :warn,
         short: '-w',
         long: '--warning=VALUE',
         description: 'Warning threshold for replication lag',
         default: 900,
         # #YELLOW
         proc: lambda { |s| s.to_i }  # rubocop:disable Lambda

  option :crit,
         short: '-c',
         long: '--critical=VALUE',
         description: 'Critical threshold for replication lag',
         default: 1800,
         # #YELLOW
         proc: lambda { |s| s.to_i }  # rubocop:disable Lambda

  option :help,
         short: '-h',
         long: '--help',
         description: 'Check MySQL status',
         on: :tail,
         boolean: true,
         show_options: true,
         exit: 0

  def cluster_size(command)
    # Parsing 'show status' output
    unless command.nil?
      command.each do |row|
      if row[0] == "wsrep_cluster_size"
        cluster_size = row[1].to_i
        message = "Cluster only has #{cluster_size} members"
        if cluster_size <= config[:crit]
          critical message
        end
      end
      end
    end
  end
  
  def cluster_status(command)
    # Parsing 'show status' output
    unless command.nil?
      command.each do |row|
      if row[0] == "wsrep_cluster_status"
        cluster_status = row[1]
        message = "Cluster host is not Primary"
        if cluster_status != "Primary"
          critical message
        end
      end
      end
    end
  end 

  def run
    if config[:ini]
      ini = IniFile.load(config[:ini])
      section = ini['client']
      db_user = section['user']
      db_pass = section['password']
    else
      db_user = config[:user]
      db_pass = config[:pass]
    end
    db_host = config[:host]

    if [db_host, db_user, db_pass].any?(&:nil?)
      unknown 'Must specify host, user, password'
    end
  
    begin
      db = Mysql.new(db_host, db_user, db_pass, nil, config[:port], config[:socket])
      results = db.query 'show status'

    case config[:check]
      when "cluster_size"
        cluster_size(results)
      when "cluster_status"
        cluster_status(results)
      else 
        unknown 'You must specify check'
    end
 
    rescue Mysql::Error => e
      errstr = "Error code: #{e.errno} Error message: #{e.error}"
      critical "#{errstr} SQLSTATE: #{e.sqlstate}" if e.respond_to?('sqlstate')

    rescue => e
      critical e

    ensure
      db.close if db
    end
   ok
  end
end
