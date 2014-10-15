#!/usr/bin/env python
#
# Generate sensu client file. This is mainly used with Salt to generate the
# file when deploying a new Sensu agent. This can also be used to remotely
# modify the client subscriptions.
#
# Seth Paxton - Layered Communications

import json
import socket
import argparse
import os.path
import sys

config_path = '/etc/sensu/conf.d'
config_name = 'client.json'

parser = argparse.ArgumentParser(description='Sensu Client JSON generator')
parser.add_argument('--subscriptions', help='Set Subscriptions \
    (e.g. sensu_json.py sub1 sub2 sub3)', nargs='+')
parser.add_argument('--append', help='Append Subscription \
    (e.g. sensu_json.py --append sub4)', nargs='+') 

# Print the help menu if no arguments are supplied
if len(sys.argv) <= 1:
    parser.print_usage() 
    sys.exit(1) 
else: 
    args = parser.parse_args() 

# This retrieves the current list of subscriptions and appends new ones 
if args.append:
    with open(os.path.join(config_path, config_name), 'r') as config:
        load_client_json = json.load(config)
        get_client_subs = load_client_json['client']['subscriptions']
        subscriptions = get_client_subs + args.append

if args.subscriptions:
    subscriptions = args.subscriptions

# Generate the client.json file
client_json = json.dumps({'client':{'name': socket.gethostname(), 'address': \
    socket.gethostbyname(socket.gethostname()), 'subscriptions': \
    # Argparse converts 'nargs=+' to list. Needed list items as strings. 
    [arguments for arguments in subscriptions]}}, \
    sort_keys=False, indent=2, separators=(',', ':'))
    
with open(os.path.join(config_path, config_name), 'w') as config:
  config.write(client_json)
