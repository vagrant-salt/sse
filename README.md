# sse

# Environment

This [vagrant](https://www.vagrantup.com/) environment configures a Salt enterprise installation with all services installed on 3 VMs: raas head (VM1), postgresql database & redis (VM2) and salt-master (VM3)

# Requirements

1. Vagrant
2. Virtualbox
3. A computer with Virtualization (VTx) enabled in BIOS

# Usage

Deploy the Salt enterprise environment by running:
    vagrant up

Sign In into Salt enterprise console using `root` username and the `salt` password at:

> https://localhost
