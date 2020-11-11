#!/usr/bin/python3

import os
import pytest
import testinfra.utils.ansible_runner
import json
import requests

hosts_filter = 'elastic'
testinfra_hosts = testinfra.utils.ansible_runner.AnsibleRunner(
    os.environ['MOLECULE_INVENTORY_FILE']).get_hosts(hosts_filter)


def get_stack_version():
    """This function returns the version of ELK/ODFE Stack."""
    return "7.9.1"


def get_elasticsearch_rest_port():
    """This function returns listening port for Elasticsearch REST API."""
    return 9200


def get_elasticsearch_cluster_port():
    """This function returns listening port for Elasticsearch cluster communication."""
    return 9300


def get_elasticsearch_nodes():
    """This returns Elasticsearch hostnames."""
    mgr_list = ['wazuh-es01', 'wazuh-es02']
    return mgr_list


def test_elasticsearch_packages_are_installed(host):
    """Test the main packages are installed."""
    elasticsearch = host.package("elasticsearch")
    assert elasticsearch.is_installed
    assert elasticsearch.version.startswith(get_stack_version())


def test_elasticsearch_services_are_running(host):
    """Test the services are enabled and running."""
    elasticsearch = host.service("elasticsearch")
    assert elasticsearch.is_running


def test_elasticsearch_rest_ports(host):
    """Test if Elasticsearch REST ports are open."""
    address = host.interface("eth0").addresses[0]
    port = get_elasticsearch_rest_port()
    assert host.socket(f"tcp://{address}:{port}").is_listening


def test_elasticsearch_cluster_ports(host):
    """Test if Elasticsearch cluster ports are open."""
    address = host.interface("eth0").addresses[0]
    port = get_elasticsearch_cluster_port()
    assert host.socket(f"tcp://{address}:{port}").is_listening


def test_elasticsearch_cluster_nodes(host):
    """Test if Elasticsearch cluster nodes are registered."""
    address = host.interface("eth0").addresses[0]
    port = get_elasticsearch_rest_port()

    node_request = requests.get(f"http://{address}:{port}/_cat/nodes")
    node_result = node_request.text.splitlines()

    returned_nodes = [line.split(' ')[9] for line in node_result]
    expected_nodes = get_elasticsearch_nodes()

    expected_nodes.sort()
    returned_nodes.sort()

    assert returned_nodes == expected_nodes


def test_elasticsearch_cluster_health(host):
    """Test if Elasticsearch cluster ports are open."""
    address = host.interface("eth0").addresses[0]
    port = get_elasticsearch_rest_port()

    health_request = requests.get(
        f"http://{address}:{port}/_cluster/health?pretty")
    health_result = health_request.json()

    assert health_result['status'] == 'green'


def test_elasticsearch_template_wazuh(host):
    """Test if Wazuh template exists."""
    address = host.interface("eth0").addresses[0]
    port = get_elasticsearch_rest_port()

    template_request = requests.get(f"http://{address}:{port}/_template/wazuh")
    assert template_request.status_code == 200
