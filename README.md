sensu-client-generator
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
