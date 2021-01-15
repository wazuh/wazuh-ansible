import os
import pytest
import testinfra.utils.ansible_runner

testinfra_hosts = testinfra.utils.ansible_runner.AnsibleRunner(
    os.environ['MOLECULE_INVENTORY_FILE']).get_hosts('all')


def get_wazuh_version():
    """This return the version of Wazuh."""
    return "4.0.4"


def test_wazuh_packages_are_installed(host):
    """Test the main packages are installed."""
    manager = host.package("wazuh-manager")
    assert manager.is_installed
    assert manager.version.startswith(get_wazuh_version())


def test_wazuh_services_are_running(host):
    """Test the services are enabled and running.

    When assert commands are commented, this means that the service command has
    a wrong exit code: https://github.com/wazuh/wazuh-ansible/issues/107
    """
    # This currently doesn't work with out current Docker base images
    # manager = host.service("wazuh-manager")
    # api = host.service("wazuh-api")
    # assert manager.is_running
    # assert api.is_running
    output = host.check_output(
        'ps aux | grep ossec | tr -s " " | cut -d" " -f11'
        )
    assert 'ossec-authd' in output
    assert 'wazuh-modulesd' in output
    assert 'wazuh-db' in output
    assert 'ossec-execd' in output
    assert 'ossec-monitord' in output
    assert 'ossec-remoted' in output
    assert 'ossec-logcollector' in output
    assert 'ossec-analysisd' in output
    assert 'ossec-syscheckd' in output


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
    assert wazuh_file_host.mode == wazuh_mode


def test_filebeat_is_installed(host):
    """Test the elasticsearch package is installed."""
    filebeat = host.package("filebeat")
    assert filebeat.is_installed
    assert filebeat.version.startswith('7.9.3')
