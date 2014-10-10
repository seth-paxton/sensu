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

config_path = '/etc/sensu/conf.d'
config_name = 'client.json'

parser = argparse.ArgumentParser(description='Sensu Client JSON generator')
parser.add_argument('subscriptions', help='Add subscriptions \
    (e.g. sensu_json.py sub1 sub2 sub3)', nargs='+')

args = parser.parse_args()

client_json = json.dumps({'client':{'name': socket.gethostname(), 'address': \
    socket.gethostbyname(socket.gethostname()), 'subscriptions': \
    # Argparse converts 'nargs=+' to list. Needed list items as strings. 
    [arguments for arguments in args.subscriptions]}}, \
    sort_keys=False, indent=2, separators=(',', ':'))

with open(os.path.join(config_path, config_name), 'w') as config:
  config.write(client_json)

