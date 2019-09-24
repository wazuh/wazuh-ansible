import os

import testinfra.utils.ansible_runner

testinfra_hosts = testinfra.utils.ansible_runner.AnsibleRunner(
    os.environ['MOLECULE_INVENTORY_FILE']).get_hosts('all')


def test_port_kibana_is_open(host):
    """Test if the port 5601 is open and listening to connections."""
    host.socket("tcp://0.0.0.0:5601").is_listening


def test_find_correct_elasticsearch_version(host):
    """Test if we find the kibana/elasticsearch version in package.json"""
    kibana = host.file("/usr/share/kibana/plugins/wazuh/package.json")
    assert kibana.contains("7.3.2")


def test_wazuh_plugin_installed(host):
    """Make sure there is a plugin wazuh directory."""
    kibana = host.file("/usr/share/kibana/plugins/wazuh/")

    assert kibana.is_directory
