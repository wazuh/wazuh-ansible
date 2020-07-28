import os
import pytest
import testinfra.utils.ansible_runner

testinfra_hosts = testinfra.utils.ansible_runner.AnsibleRunner(
    os.environ['MOLECULE_INVENTORY_FILE']).get_hosts('all')

def get_wazuh_version():
    """This return the version of Wazuh."""
    return "3.13.1"

def test_wazuh_packages_are_installed(host):
    """Test if the main packages are installed."""
    manager = host.package("wazuh-manager")
    api = host.package("wazuh-api")
    assert manager.is_installed
    assert manager.version.startswith(get_wazuh_version())
    assert api.is_installed
    assert api.version.startswith(get_wazuh_version())

def test_wazuh_services_are_running(host):
    """Test if the services are enabled and running.

    When assert commands are commented, this means that the service command has
    a wrong exit code: https://github.com/wazuh/wazuh-ansible/issues/107
    """
    manager = host.service("wazuh-manager")
    api = host.service("wazuh-api")
    # assert manager.is_running
    assert manager.is_enabled
    # assert api.is_running
    assert api.is_enabled

@pytest.mark.parametrize("wazuh_file, wazuh_owner, wazuh_group, wazuh_mode", [
    ("/var/ossec/etc/sslmanager.cert", "root", "root", 0o640),
    ("/var/ossec/etc/sslmanager.key", "root", "root", 0o640),
    ("/var/ossec/etc/rules/local_rules.xml", "ossec", "root", 0o640),
    ("/var/ossec/etc/lists/audit-keys", "ossec", "root", 0o640),
])

def test_wazuh_files(host, wazuh_file, wazuh_owner, wazuh_group, wazuh_mode):
    """Test if Wazuh related files exist and have proper owners and mode."""
    wazuh_file_host = host.file(wazuh_file)
    assert wazuh_file_host.user == wazuh_owner
    assert wazuh_file_host.group == wazuh_group
    assert wazuh_file_host.mode == wazuh_mode

def test_open_ports(host):
    """Test if the main port is open and the agent-auth is not open."""
    assert host.socket("tcp://1515").is_listening
    assert host.socket("tcp://1514").is_listening

def test_filebeat_is_installed(host):
    """Test if the elasticsearch package is installed."""
    filebeat = host.package("filebeat")
    assert filebeat.is_installed
    assert filebeat.version.startswith('7.8.0')
