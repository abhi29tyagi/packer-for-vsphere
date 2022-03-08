##################################################################################
# VARIABLES
##################################################################################

# Credentials

vcenter_username                = "USER"
vcenter_password                = "PASS"

# vSphere Objects

vcenter_insecure_connection     = true

# Replace <IP> with your vcenter_server IP.
vcenter_server                  = "<IP>"
# Replace datacenter with your targetted datacenter in vsphere.
vcenter_datacenter              = "datacenter"
# This is the cluster name (or a folder to group your all resources including VMs) 
vcenter_cluster                 = "cluster-1"
# Replace <HOSTNAME> with hostname of your vcenter_host.
vcenter_host                    = "<HOSTNAME>"
# Replace <DATASTORE> with coressponding datastore.
vcenter_datastore               = "<DATASTORE>"
vcenter_network                 = "VM Network"
# This is the targetted or containing folder for your vm template
vcenter_folder                  = "cluster-1"
