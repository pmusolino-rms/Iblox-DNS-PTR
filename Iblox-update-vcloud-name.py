import sys
import socket
import ssl
import requests
import urllib3
import urllib3.contrib.pyopenssl
import logging
import json

urllib3.contrib.pyopenssl.inject_into_urllib3()
urllib3.disable_warnings()
logging.captureWarnings(True)

URL = 'https://IBLOX-MASTER/wapi/v1.7.1/'

EXTATTRIB="Customer Name"
COMMENT='Edge'

USERNAME='USERNAME'
PASS='PASS'

def requestsGetHandler(url):
	try:
		url=url+"&_return_fields=network,extattrs"
		response=requests.get(url,verify=False,auth=(USERNAME,PASS))
		return response
	except urllib3.exceptions.SSLError as e:
		print e

def requestsPutHandler(url,payload):
	try:
		response=requests.put(url,verify=False,auth=(USERNAME,PASS),data=payload)
		return response
	except urllib3.exceptions.SSLError as e:
		print e

def getNetwork(tenant,extattr,comment):
		r=requestsGetHandler(URL+"network?*Customer+Name~:="+tenant+"&comment~:="+comment)
		j=r.json()
		network=None
		if r.status_code == 200:
			network=(j[0].get(u'_ref'))
		return network

def putvCloudAttrib(ref,tenant):

	vlan=str((int(tenant)+3002))
	extattrs = {'vCloud_Network_Name':{'value':"TENANT-"+tenant}, \
		'Site':{'value':'LHR1 / KEF1'}, \
		'Country':{'value':'UK / IS'}, \
		'Customer Name':{'value':'TENANT-'+tenant}, \
		'VLAN':{'value': vlan }}
	data = '{"extattrs": ' + json.JSONEncoder().encode(extattrs) + '}'
	print data
	restUrl = URL + ref
	r=requestsPutHandler(restUrl,data)
	print str(r.status_code) + ":" + r.reason + ":" + r.text
	if r.status_code == 200:
		print "Success adding vCloud_Network_Name=TENANT-"+tenant
		return
	else:
		print "Error"
		return

def main():
	for tenant_id in range(1,123):
		netRef=getNetwork(str(tenant_id).zfill(3),EXTATTRIB,COMMENT)
		putvCloudAttrib(netRef,str(tenant_id).zfill(3))
	pass

if __name__ == "__main__":
	main()