#!/usr/bin/env ruby                                                                                                             
#                                                                                                                               
# Seth Paxton - Layered Communications (9/2014)                                                                                 
#                                                                                                                               
# This handler changes global IP routing on the SoftLayer API. The global IPs                                                   
# issued by SoftLayer will not move between machines unless a routing change is performed.                                      
# this handler automates the change through their API.                                                                          
#                                                                                                                               
# There are 4 requied fields that need to be added to softlayer.json in the conf.d directory:                                   
#                                                                                                                               
# username   :  api username                                                                                                    
# api_key    :  api key                                                                                                         
# route_to   :  IP address of the host you want to route the global to.                                                         
# object_id  :  object_id is a field unique to SoftLayer. This field represents the object you want to change, in this case     
#                 the global IP. I was able to derive the object_id using their Python API. I havn't found a good way to do it  
#                 in Ruby (yet). The documentation on their Ruby API is not very good.                                          
#                                                                                                                               
                                                                                                                                
require 'rubygems' if RUBY_VERSION < '1.9.0'                                                                                    
require 'softlayer_api'                                                                                                         
require 'sensu-handler'                                                                                                         
                                                                                                                                
class SoftLayerApi < Sensu::Handler                                                                                             
                                                                                                                                
  def handle                                                                                                                    
    global_ip_service = SoftLayer::Service.new("SoftLayer_Network_Subnet_IpAddress_Global",                                     
      :username => settings['softlayer']['username'],                                                                           
      :api_key => settings['softlayer']['api_key'])                                                                             
                                                                                                                                
    route_ip = settings['softlayer']['route_to']                                                                                
    object_id = settings['softlayer']['object_id']                                                                              
                                                                                                                                
    set_global = global_ip_service.object_with_id(object_id).route(route_ip)                                                    
 end                                                                                                                            
                                                                                                                                
 end                                                                                                                            
