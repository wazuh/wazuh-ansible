#!/usr/bin/python3

import os
import pytest
import testinfra.utils.ansible_runner
import json

hosts_filter = 'agents'
testinfra_hosts = testinfra.utils.ansible_runner.AnsibleRunner(
    os.environ['MOLECULE_INVENTORY_FILE']).get_hosts(hosts_filter)


def get_wazuh_version():
    """This return the version of Wazuh."""
    return "4.0.0"


def get_wazuh_masters():
    """This returns Wazuh managers."""
    mgr_list = ['wazuh-mgr01']
    return mgr_list


def get_wazuh_workers():
    """This returns Wazuh workers."""
    mgr_list = ['wazuh-mgr02']
    return mgr_list


def get_wazuh_agents():
    """This returns Wazuh agents."""
    agent_list = ['wazuh-agent01', 'wazuh-agent02']
    return agent_list


def test_wazuh_packages_are_installed(host):
    """Test the main packages are installed."""
    agent = host.package("wazuh-agent")
    assert agent.is_installed
    assert agent.version.startswith(get_wazuh_version())


def test_wazuh_services_are_running(host):
    """Test the services are enabled and running."""
    agent = host.service("wazuh-agent")
    assert agent.is_running
