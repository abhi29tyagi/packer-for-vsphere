# packer-for-vsphere

This project creates golden images (or image templates) using standard ISO via _packer_, which later can be used to create VM(s) on demand.
It uses subiquity (https://github.com/canonical/subiquity) the ubuntu autoinstaller available from ubuntu-18.04 onwards, along with cloud-init (https://help.ubuntu.com/community/CloudInit)


## To generate a hashed password for identity in user-data
Using mkpasswd
On Ubuntu you need to install whois package to get mkpasswd utility.

```sh
apt-get install whois
mkpasswd -m sha-512 --rounds=4096
```

If PASSWORD is missing then it is asked interactively.

Example:
```sh
Password:
$6$KU2P9m78xF3n$noEN/CV.0R4qMLdDh/TloUplmJ0DLnqi6/cP7hHgfwUu.D0hMaD2sAfxDT3eHP5BQ3HdgDkKuIk8zBh0mDLzO1
```


## Running packer build with hcl
#### Ubuntu 20.04

```sh
 packer build -on-error=ask -var-file vsphere.pkrvars.hcl -var-file 100GB-vm.pkrvars.hcl -var-file  ubuntu-20.04.pkrvars.hcl ubuntu-20.04.pkr.hcl
```
*Note: Use '-force', if you want to overwrite an existing template with same name in vcenter.*

