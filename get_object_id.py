import SoftLayer

sl_api_key = '1234567890'
sl_api_user = 'softlayeruser'
global_ip = '192.168.1.2'

# Setup SL API Connection
client = SoftLayer.Client(username=sl_api_user, api_key=sl_api_key)
network = SoftLayer.managers.network.NetworkManager(client)

# Returns list of IDs used to make routing changes
global_ip_id = network.resolve_global_ip_ids(global_ip)
print global_ip_id
