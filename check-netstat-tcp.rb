#!/usr/bin/env ruby
#
# Check for TCP socket state
# ===
#
# Modified by: Seth Paxton
#
# Example
# -------
#
# $ ./check-netstat-tcp.rb --states ESTABLISHED,CLOSE_WAIT -p 22
# CheckNetstatTCP: Warn:ESTABLISHED=18 OK:CLOSE_WAIT=0
#
# Acknowledgements
# ----------------
# - Slightly modified version of the code below. I removed the thresholds feature so that I could just check that a conneciton was established.  
#  https://github.com/sensu/sensu-community-plugins/blob/master/plugins/network/check-netstat-tcp.rb
#
# Released under the same terms as Sensu (the MIT license); see LICENSE
# for details.
#
# rubocop:disable FavorUnlessOverNegatedIf

require 'rubygems' if RUBY_VERSION < '1.9.0'
require 'sensu-plugin/check/cli'
require 'socket'

TCP_STATES = {
  '00' => 'UNKNOWN',  # Bad state ... Impossible to achieve ...
  'FF' => 'UNKNOWN',  # Bad state ... Impossible to achieve ...
  '01' => 'ESTABLISHED',
  '02' => 'SYN_SENT',
  '03' => 'SYN_RECV',
  '04' => 'FIN_WAIT1',
  '05' => 'FIN_WAIT2',
  '06' => 'TIME_WAIT',
  '07' => 'CLOSE',
  '08' => 'CLOSE_WAIT',
  '09' => 'LAST_ACK',
  '0A' => 'LISTEN',
  '0B' => 'CLOSING'
}

class CheckNetstatTCP < Sensu::Plugin::Check::CLI

  option :states,
    :description => "Comma delimited list of states to check",
    :short => "-s STATES",
    :long => "--states STATES",
    :default => ["ESTABLISHED"],
    :proc => proc {|a| a.split(',') }

  option :port,
    :description => "Port you wish to check values on (default: all)",
    :short => "-p PORT",
    :long => "--port PORT",
    :proc => proc {|a| a.to_i }

  def netstat(protocols = ['tcp'])
    state_counts = Hash.new(0)
    TCP_STATES.each_pair { |hex, name| state_counts[name] = 0 }

    protocols.each do |protocol|
      File.open('/proc/net/' + protocol).each do |line|
        line.strip!
        if m = line.match(/^\s*\d+:\s+(.{8}|.{32}):(.{4})\s+(.{8}|.{32}):(.{4})\s+(.{2})/) # rubocop:disable AssignmentInCondition
          connection_state = m[5]
          connection_port = m[2].to_i(16)
          connection_state = TCP_STATES[connection_state]
          next unless config[:states].include?(connection_state)
          if config[:port] && config[:port] == connection_port
            state_counts[connection_state] += 1
          elsif !config[:port]
            state_counts[connection_state] += 1
          end
        end
      end
    end
    state_counts
  end

  def run
    state_counts = netstat(['tcp', 'tcp6'])
    is_critical = false
    message = ""

    config[:states].each_index do |i|
      if state_counts[config[:states][i]] <= 0
        is_critical = true
        message += " CRITICAL:#{config[:states][i]}=#{state_counts[config[:states][i]]}"
      else
        message += " OK:#{config[:states][i]}=#{state_counts[config[:states][i]]}"
      end
    end

    critical message if is_critical
    ok message

  end

end

