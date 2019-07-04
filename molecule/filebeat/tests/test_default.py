import os

import testinfra.utils.ansible_runner

testinfra_hosts = testinfra.utils.ansible_runner.AnsibleRunner(
    os.environ['MOLECULE_INVENTORY_FILE']).get_hosts('all')


def test_logstash_is_installed(host):
    """Test if the filebeat package is installed."""
    filebeat = host.package("filebeat")
    assert filebeat.is_installed


def test_logstash_is_running(host):
    """Test if the services are enabled and running."""
    filebeat = host.service("filebeat")
    assert filebeat.is_enabled
    assert filebeat.is_running
