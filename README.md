sensu_jsongen
======================

This script auto generates Sensu client JSON. I use this with Saltstack when deploying new Sensu clients.

### Usage

#### Local
```
./sensu_jsongen.py sub1 sub2 sub3
```

Generates the following:


    {
       "client":{
         "subscriptions":[
           "sub1",
           "sub2",
           "sub3"
         ],
       "name":"hostname.example.com",
       "address":"192.168.1.100"
      }
    }


**Note**: The hostname and IP address is automatically added. 
#### Salt
Run the following Salt command to generate the new client file. This can be used to generate client files across hundreds of servers. 

```
salt 'hostname.example.com' cmd.script salt://sensu/sensu_jsongen.py args="sub1 sub2"
```

check-netstat-tcp
======================
Slightly modified version of the code below. I removed the thresholds feature so that I could just check that a connection was established.  
[check-netstat-tcp.rb](https://github.com/sensu/sensu-community-plugins/blob/master/plugins/network/check-netstat-tcp.rb)

softlayer_api
======================
This is a handler that will connect to the SoftLayer API and change Global IP routing automatically. 

### Handler Definition


    {                                                        
     "handlers": {                                           
       "slgbiproute": {                                      
         "type": "pipe",                                     
         "command": "/etc/sensu/handlers/softlayer_api.rb"   
        }                                                    
      }                                                      
    }      
           

### JSON Settings

* Create API user on SoftLayer Portal. 
* Generate API Key
* Get Object ID using something similar to the ```get_object_id.py 192.168.1.2```
* Add API, object_id, username, and IP to ```softlayer.json``` configuration file
  * object_id is the actual Global IP
  * route_to is the IP you want to route the Global IP to. 

#### softlayer.json configuration file

     {                                                                                       
       "softlayer": {                                                                        
       "route_to": "192.168.1.2",                                                         
       "object_id": "12345",                                                               
       "username": "softlayeruser",                                             
       "api_key": "1234567890"       
      }                                                                                     
    }   
