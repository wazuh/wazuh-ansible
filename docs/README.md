# Introduction

[![Slack](https://img.shields.io/badge/slack-join-blue.svg)](https://wazuh.com/community/join-us-on-slack/)
[![Email](https://img.shields.io/badge/email-join-blue.svg)](https://groups.google.com/forum/#!forum/wazuh)
[![Documentation](https://img.shields.io/badge/docs-view-green.svg)](https://documentation.wazuh.com)
[![Documentation](https://img.shields.io/badge/web-view-green.svg)](https://wazuh.com)

# Wazuh Ansible Documentation

Here is the technical documentation for deploying Wazuh using the Ansible method. The documentation is structured into the following key guides:

- **Development Guide**: Step-by-step instructions to set up the development environment and deploy Wazuh effectively using Ansible.
- **Reference Manual**: In-depth details on the Wazuh Ansible deployment process, including prerequisites, configuration options, compatibility guidelines, and usage instructions.

## Docs requirements

To work with this documentation, you need **mdBook** installed. For installation instructions, refer to the [mdBook documentation](https://rust-lang.github.io/mdBook/).

## Usage

- To build the documentation, run:

  ```bash
  ./build.sh
  ```

  The output will be generated in the `book` directory.

- To serve the documentation locally for preview, run:

  ```bash
  ./server.sh
  ```

  The documentation will be available at [http://127.0.0.1:3000](http://127.0.0.1:3000).
