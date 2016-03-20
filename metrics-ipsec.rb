#!/usr/bin/env ruby
#
#  ipsec-metrics
#
# DESCRIPTION:
# Pulls values from strongswan and posts to Graphite
#
# OUTPUT:
#   plain text
#
# PLATFORMS:
#   Linux
#
# DEPENDENCIES:
#   gem: sensu-plugin
#
# Author:
#
# Seth Paxton - Layered Communications
#


require 'sensu-plugin/metric/cli'
require 'socket'

class StronSwanMetric < Sensu::Plugin::Metric::CLI::Graphite
  option :scheme,
         description: 'Metric naming scheme, text to prepend to .$parent.$child',
         long: '--scheme SCHEME',
         default: "#{Socket.gethostname}.ipsec."

  option :path,
         description: 'Path to ipsec binary',
         long: '--path $IPSEC',
         default: "/usr/sbin/ipsec"


  def run

    timestamp = Time.now.to_i
    command = `sudo #{config[:path]} statusall`.split("\n")
    command.each do |lines|
      if lines.include? "bytes"
        tunnel_name = lines.split("{")[0]
        bytes_i = lines[/(\d+)\sbytes_i/,1]
        bytes_o = lines[/(\d+)\sbytes_o/,1]
        output [config[:scheme], tunnel_name, '.bytes_in'].join(), bytes_i, timestamp
        output [config[:scheme], tunnel_name, '.bytes_out'].join(), bytes_o, timestamp
      end
    end
  ok    
  end
end
