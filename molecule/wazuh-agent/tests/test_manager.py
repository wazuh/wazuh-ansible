import os

import testinfra.utils.ansible_runner

testinfra_hosts = testinfra.utils.ansible_runner.AnsibleRunner(
    os.environ['MOLECULE_INVENTORY_FILE']).get_hosts('manager')


def test_agents_registered_on_manager(host):
    cmd = host.run("/var/ossec/bin/manage_agents -l")
    assert 'wazuh_agent_bionic' in cmd.stdout
    assert 'wazuh_agent_xenial' in cmd.stdout
    assert 'wazuh_agent_trusty' in cmd.stdout
    assert 'wazuh_agent_centos6' in cmd.stdout
    assert 'wazuh_agent_centos7' in cmd.stdout
