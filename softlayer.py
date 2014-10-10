#!/usr/bin/env python
#
# Get objectID from a Global IP Address in SoftLayer. Pass the 
# Global Ip as an argument to the script
#
# Seth Paxton - Layered Communications
#
# Usage: ./get_object_id.py 192.168.1.2

import SoftLayer
import argparse

sl_api_key = '1234567890'
sl_api_user = 'softlayeruser'

# Setup SL API Connection
client = SoftLayer.Client(username=sl_api_user, api_key=sl_api_key)
network = SoftLayer.managers.network.NetworkManager(client)

# Command-Line Args
parser = argparse.ArgumentParser(description='Change SoftLayer Global\
                IP Routing')

parser.add_argument('global_ip', help='Floating Global IP From SL')
parser.add_argument('routed_ip', help='IP that will route Global IP')

args = parser.parse_args()

# Returns list of IDs used to make routing changes
global_ip_id = network.resolve_global_ip_ids(args.global_ip)

# Makes the routing change via API call
# network.assign_global_ip(global_ip_id[0], args.routed_ip)

print global_ip_id
