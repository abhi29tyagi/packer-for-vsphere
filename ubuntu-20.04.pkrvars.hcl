##################################################################################
# VARIABLES
##################################################################################

# ISO Objects
iso_path                    = "[Datastore] /packer_cache/ubuntu-20.04.3-live-server-amd64.iso"
iso_file                    = "ubuntu-20.04.3-live-server-amd64.iso"
iso_checksum                = "f8e3086f3cea0fb3fefb29937ab5ed9d19e767079633960ccb50e76153effc98"
iso_checksum_type           = "sha256"
iso_url                     = "https://releases.ubuntu.com/20.04.3/ubuntu-20.04.3-live-server-amd64.iso"

# Scripts
shell_scripts               = ["./scripts/setup_ubuntu2004.sh"]