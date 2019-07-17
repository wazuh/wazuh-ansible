import os

import testinfra.utils.ansible_runner

testinfra_hosts = testinfra.utils.ansible_runner.AnsibleRunner(
    os.environ['MOLECULE_INVENTORY_FILE']).get_hosts('all')


def test_filebeat_is_installed(host):
    """Test if the elasticsearch package is installed."""
    filebeat = host.package("filebeat")
    assert filebeat.is_installed
    assert filebeat.version.startswith('7.1.1')
