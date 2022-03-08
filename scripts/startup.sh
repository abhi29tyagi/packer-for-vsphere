#!/usr/bin/bash

#packer command to create a new vm template
packer build ${3} -on-error=ask -var-file vsphere.pkrvars.hcl -var-file ${2}GB-vm.pkrvars.hcl -var-file ${1}.pkrvars.hcl ${1}.pkr.hcl
