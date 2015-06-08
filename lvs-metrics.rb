#! /usr/bin/env ruby #  encoding: UTF-8
#
#  lvs-metrics 
#
# DESCRIPTION:
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
# NOTES:
# Used to collect metrics from LVS. It collects both real and virtual server metrics. 
 

require 'sensu-plugin/metric/cli'
require 'socket'

class Lvs < Sensu::Plugin::Metric::CLI::Graphite
  option :scheme,
         description: 'Metric naming scheme, text to prepend to .$parent.$child',
         long: '--scheme SCHEME',
         default: "#{Socket.gethostname}.lvs"

  option :table,
         description: 'Table to count',
         long: '--table TABLE',
         default: 'conntrack'

  def parser(command)
    results = []
    command.each do |stat|
      stat = stat.split(" ")
      vip = stat[1].gsub(".", "_")
      metrics = {
        vip => {
      	  connections: stat[2],
          InPkts: stat[3],
      	  OutPkts: stat[4],
          InBytes: stat[5],
      	  OutBytes: stat[6]
      	}
       }	  
       results << metrics
     end 
     return results
  end
 

  def run

    timestamp = Time.now.to_i   
   
    # Get VIP Metrics
    vips = parser(`ipvsadm -Ln --stats | grep -Ev '>|^IP|^Prot'`.split("\n"))
    vips.each do |hash|
      hash.each do |parent, children|
        children.each do |child, value|
      output [config[:scheme], "vip", parent, child].join('.'), value, timestamp
      end
    end      
  end 

    # Get Real Server Metrics
    real = parser(`ipvsadm -Ln --stats | grep -Ev '^UDP|^TCP|^Prot|^IP|RemoteAddress'`.split("\n"))
    real.each do |hash|
      hash.each do |parent, children|
	children.each do |child, value|
      output [config[:scheme], "real", parent, child].join('.'), value, timestamp
      end
    end 
  end
  ok
  end
end
