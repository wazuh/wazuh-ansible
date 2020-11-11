#!/usr/bin/python3

import os
import pytest
import testinfra.utils.ansible_runner
import json

hosts_filter = 'managers'
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
    manager = host.package("wazuh-manager")
    assert manager.is_installed
    assert manager.version.startswith(get_wazuh_version())


def test_wazuh_services_are_running(host):
    """Test the services are enabled and running.
    """
    manager = host.service("wazuh-manager")
    assert manager.is_running


def test_filebeat_is_installed(host):
    """Test the elasticsearch package is installed."""
    filebeat = host.package("filebeat")

    assert filebeat.is_installed
    assert filebeat.version.startswith('7.9')


def test_filebeat_is_running(host):
    """Test the filebeat service is running."""
    filebeat = host.service("filebeat")
    assert filebeat.is_running


@pytest.mark.parametrize("wazuh_file, wazuh_owner, wazuh_group, wazuh_mode", [
    ("/var/ossec/etc/sslmanager.cert", "root", "root", 0o640),
    ("/var/ossec/etc/sslmanager.key", "root", "root", 0o640),
    ("/var/ossec/etc/rules/local_rules.xml", "ossec", "ossec", 0o640),
    ("/var/ossec/etc/lists/audit-keys", "ossec", "ossec", 0o660),
])
def test_wazuh_files(host, wazuh_file, wazuh_owner, wazuh_group, wazuh_mode):
    """Test Wazuh related files exist and have proper owners and mode."""
    wazuh_file_host = host.file(wazuh_file)
    assert wazuh_file_host.user == wazuh_owner
    assert wazuh_file_host.group == wazuh_group
    # FIXME: Disabled because permissions are not ok on wazuh-packages for wazuh-manager  4.0.0
    # 4.0.0: https://github.com/wazuh/wazuh-packages/blob/master/debs/SPECS/4.0.0/wazuh-manager/debian/postinst#L97
    # 4.0.1: https://github.com/wazuh/wazuh-packages/blob/master/debs/SPECS/4.0.1/wazuh-manager/debian/postinst#L97
    if get_wazuh_version() != "4.0.0":
        assert wazuh_file_host.mode == wazuh_mode


def test_wazuh_manager_ports(host):
    """Test if Wazuh service ports are open."""
    hostname = host.check_output('hostname -s')
    address = host.interface("eth0").addresses[0]

    # CentOS is a manager, Debian a Worker
    assert host.socket(f"tcp://{address}:1515").is_listening
    assert host.socket(f"tcp://{address}:1514").is_listening

    if hostname in get_wazuh_masters():
        assert host.socket(f"tcp://{address}:1516").is_listening


def test_wazuh_api_ports(host):
    """Test if wazuh-api port is up and running."""
    address = host.interface("eth0").addresses[0]
    assert host.socket(f"tcp://{address}:55000").is_listening


def test_wazuh_agents_registered(host):
    """Test if cluster has all agents running."""
    hostname = host.check_output('hostname -s')

    if hostname in get_wazuh_masters():
        cmd = host.check_output("/var/ossec/bin/agent_control -l -j")
        json_data = json.loads(cmd)

        # TODO: should also check "status" == "Active"
        agents_returned = [agent['name']
                           for agent in json_data['data'] if agent['name']]
        agents_expected = get_wazuh_agents() + [hostname]

        # sort is stable
        agents_returned.sort()
        agents_expected.sort()

        assert agents_returned == agents_expected

def test_wazuh_cluster_nodes(host):
    """Test if cluster has all managers running."""
    hostname = host.check_output('hostname -s')

    if hostname in get_wazuh_masters():
        cluster_output = host.check_output(
            "/var/ossec/bin/cluster_control -l | awk '{ print $1 }' | grep wazuh-")
        cluster_returned = cluster_output.splitlines()
        cluster_expected = get_wazuh_workers() + get_wazuh_masters()

        cluster_returned.sort()
        cluster_expected.sort()

        assert cluster_returned == cluster_expected

# maybe test api?
# curl -k -u wazuh:wazuh 'https://127.0.0.1:55000/security/user/authenticate'

