import os

import testinfra.utils.ansible_runner

testinfra_hosts = testinfra.utils.ansible_runner.AnsibleRunner(
    os.environ['MOLECULE_INVENTORY_FILE']).get_hosts('all')


def test_logstash_is_installed(host):
    """Test if logstash is installed with correct version."""
    logstash = host.package("logstash")
    assert logstash.is_installed

    distribution = host.system_info.distribution.lower()
    if distribution == 'ubuntu':
        assert logstash.version.startswith('1:6.7.1')
    else:
        assert logstash.version.startswith('6.7.1')


def test_logstash_is_running(host):
    """Test if the services are enabled and running."""
    logstash = host.service("logstash")
    assert logstash.is_enabled
    assert logstash.is_running


def test_find_correct_logentry(host):
    """See if logstash is started and is connected to Elasticsearch."""
    logfile = host.file("/var/log/logstash/logstash-plain.log")
    assert logfile.contains("Successfully started Logstash API endpoint")
    assert logfile.contains("Restored connection to ES instance")
