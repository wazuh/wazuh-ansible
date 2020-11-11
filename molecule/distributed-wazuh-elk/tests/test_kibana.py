#!/usr/bin/python3

import os
import pytest
import testinfra.utils.ansible_runner
import json

hosts_filter = 'kibana'
testinfra_hosts = testinfra.utils.ansible_runner.AnsibleRunner(
    os.environ['MOLECULE_INVENTORY_FILE']).get_hosts(hosts_filter)


def get_stack_version():
    """This function returns the version of ELK/ODFE Stack."""
    return "7.9.1"


def get_kibana_port():
    """This function returns listening port for Kibana."""
    return 5601


def get_kibanas():
    """This returns Kibana hostnames."""
    mgr_list = ['wazuh-kib01']
    return mgr_list


def test_kibana_packages_are_installed(host):
    """Test the main packages are installed."""
    kibana = host.package("kibana")
    assert kibana.is_installed
    assert kibana.version.startswith(get_stack_version())


def test_kibana_services_are_running(host):
    """Test the services are enabled and running."""
    kibana = host.service("kibana")
    assert kibana.is_running


def test_kibana_ports(host):
    """Test if Kibana service ports are open."""
    address = host.interface("eth0").addresses[0]
    port = get_kibana_port()
    assert host.socket(f"tcp://{address}:{port}").is_listening

# maybe?
# app/status
# http://172.17.0.8:5601/hosts/apis
# http://172.17.0.8:5601/api/saved_objects/_find?fields=title&per_page=10000&type=index-pattern
