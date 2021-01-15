# Change Log
All notable changes to this project will be documented in this file.

## [v4.0.4]

### Added

- Update to [Wazuh v4.0.4](https://github.com/wazuh/wazuh/blob/v4.0.4/CHANGELOG.md#v404)

- Support for new Wazuh API config options.

- Add localfile labels to agent ossec.conf template ([@dragospe](https://github.com/dragospe)) [PR#521](https://github.com/wazuh/wazuh-ansible/pull/521)

### Changed

- Please notice that default Kibana user in role defaults changed from `kibanaserver` to `admin`. See listed PRs below for details.

### Fixed

- `create_user.py` generates invalid passwords ([@singuliere](https://github.com/singuliere)) [PR#519](https://github.com/wazuh/wazuh-ansible/pull/519)
- Fix invalid Jinja2 syntax in centralized configuration template ([@kravietz](https://github.com/kravietz)) [PR#528](https://github.com/wazuh/wazuh-ansible/pull/528)
- Replace default user for `opendistro-kibana` role ([@zenidd](https://github.com/zenidd)) [PR#529](https://github.com/wazuh/wazuh-ansible/pull/529)
- Remove legacy declarations of `od_node_name` in `opendistro-elasticsearch` ([@neonmei](https://github.com/neonmei), [@dragospe](https://github.com/dragospe))  [PR#530](https://github.com/wazuh/wazuh-ansible/pull/530)
- Add missing variable `elasticsearch_node_master` in `opendistro-elasticsearch` ([@neonmei](https://github.com/neonmei)) [PR#534](https://github.com/wazuh/wazuh-ansible/pull/534)
- Add missing variable `elasticsearch_network_host` in `opendistro-elasticsearch` ([@neonmei](https://github.com/neonmei)) [PR#540](https://github.com/wazuh/wazuh-ansible/pull/540)


## [v4.0.3]

### Added

- Update to Wazuh v4.0.3

### Fixed

- Fix wrong `delegate_to` in task added by PR#488, hotfixed in `v4.0.2` in [PR#511](https://github.com/wazuh/wazuh-ansible/pull/511)

## [v4.0.2]

### Added

- Update to Wazuh v4.0.2

### Changed

- New role variables have been introduced (e.g: `wazuh_agent_api_validate`), see documentation or PRs listed here for details.
- Some variables have been deprecated (e.g: `wazuh_agent_nat`) in favour of other ones, see documentation or PRs listed here for details.

### Fixed

- Fix agent enrollment default value. Fix authd registration. [PR#505](https://github.com/wazuh/wazuh-ansible/issues/505)
- Remove async clause causing agent install timeout on resource-constrained Centos installations [PR#507](https://github.com/wazuh/wazuh-ansible/issues/507)
- Fix REST registration method for agents [PR#509](https://github.com/wazuh/wazuh-ansible/issues/509)
- `authd_pass` and `api_pass` [precedence](https://docs.ansible.com/ansible/latest/user_guide/playbooks_variables.html#variable-precedence-where-should-i-put-a-variable) too high, lower to role defaults [PR#488](https://github.com/wazuh/wazuh-ansible/issues/488)

## [v4.0.1]

### Added

- Update to Wazuh v4.0.1
- Allow installing fixed Filebeat-oss version ([@Zenidd](https://github.com/Zenidd)) [PR#486](https://github.com/wazuh/wazuh-ansible/pull/486)
- Feature adapt molecule tests ([@neonmei](https://github.com/neonmei)) [PR#477](https://github.com/wazuh/wazuh-ansible/pull/477)

### Fixed

- Roles/elastic-stack: update jvm.options template per upstream updates ([@neonmei](https://github.com/neonmei)) [PR#501](https://github.com/wazuh/wazuh-ansible/pull/501)
- Improve linting history ([@neonmei](https://github.com/neonmei))
  - Fix lint opendistro kibana [PR#497](https://github.com/wazuh/wazuh-ansible/pull/497)
  - Feature lint roles configurations [PR#496](https://github.com/wazuh/wazuh-ansible/pull/496)
  - Feature lint role wazuh agent [PR#495](https://github.com/wazuh/wazuh-ansible/pull/495)
  - Feature lint role filebeat oss [PR#494](https://github.com/wazuh/wazuh-ansible/pull/494)
  - Lint role wazuh-manager [PR#493](https://github.com/wazuh/wazuh-ansible/pull/493)
  - Feature lint role elasticsearch [PR#492](https://github.com/wazuh/wazuh-ansible/pull/492)
  - Feature lint role opendistro-elasticsearch [PR#491](https://github.com/wazuh/wazuh-ansible/pull/491)
  - Feature lint remove unused variables [PR#487](https://github.com/wazuh/wazuh-ansible/pull/487)
  - Feature agent default vars depth reduction [PR#485](https://github.com/wazuh/wazuh-ansible/pull/485)
- Remove unnecesary nodejs dependency ([@neonmei](https://github.com/neonmei)) [PR#482](https://github.com/wazuh/wazuh-ansible/pull/482)
- Feature manager configuration unnest ([@neonmei](https://github.com/neonmei)) [PR#481](https://github.com/wazuh/wazuh-ansible/pull/481)
- Elastic API check fix ([@Zenidd](https://github.com/Zenidd)) [PR#480](https://github.com/wazuh/wazuh-ansible/pull/480)
- Improve handling of run_once at opendistro-elasticsearch role ([@neonmei](https://github.com/neonmei)) [PR#478](https://github.com/wazuh/wazuh-ansible/pull/478)


## [v4.0.0]

### Added

- Update to Wazuh v4.0.0
- New example playbooks on README ([@Zenidd](https://github.com/Zenidd)) [PR#468](https://github.com/wazuh/wazuh-ansible/pull/468)

### Fixed

- Ensure recursive /usr/share/kibana permissions before installing WUI ([@Zenidd](https://github.com/Zenidd)) [PR#471](https://github.com/wazuh/wazuh-ansible/pull/471)
- Remove vuls integration ([@manuasir](https://github.com/manuasir)) [PR#469](https://github.com/wazuh/wazuh-ansible/pull/469)


## [v3.13.2]

### Added

- Update to Wazuh v3.13.2
- Add kibana extra ssl option ([@xr09](https://github.com/xr09)) [PR#451](https://github.com/wazuh/wazuh-ansible/pull/451)
- Force basic auth ([@xr09](https://github.com/xr09)) [PR#456](https://github.com/wazuh/wazuh-ansible/pull/456)

### Fixed

- Fix check_mode condition ([@manuasir](https://github.com/manuasir)) [PR#452](https://github.com/wazuh/wazuh-ansible/pull/452)
- Fixes for opendistro role ([@xr09](https://github.com/xr09)) [PR#453](https://github.com/wazuh/wazuh-ansible/pull/453)

## [v3.13.1_7.8.0]

### Added

- Update to Wazuh v3.13.1
- Add support to configure path.repo option in ES. Required for backups/snapshots ([@pescobar](https://github.com/pescobar)) [PR#433](https://github.com/wazuh/wazuh-ansible/pull/433)

### Changed

- Update Opendistro tasks ([@jm404](https://github.com/jm404)) [PR#443](https://github.com/wazuh/wazuh-ansible/pull/443)
- Provide ansible.cfg with merge hash_behaviour ([@xr09](https://github.com/xr09)) [PR#440](https://github.com/wazuh/wazuh-ansible/pull/440)

### Fixed

- Fixes for wazuh-agent registration ([@pchristos](https://github.com/pchristos)) [PR#406](https://github.com/wazuh/wazuh-ansible/pull/406)
- Fixes for OpenDistro deployments ([@xr09](https://github.com/xr09)) [PR#445](https://github.com/wazuh/wazuh-ansible/pull/445)

## [v3.13.0_7.7.1]

### Added

- Update to Wazuh v3.13.0
- Open Distro-Kibana and Filebeat-oss roles ([@manuasir](https://github.com/manuasir)) [PR#424](https://github.com/wazuh/wazuh-ansible/pull/424)

### Changed

- Fetch ES template from wazuh/wazuh repository ([@Zenidd](https://github.com/Zenidd)) [PR#435](https://github.com/wazuh/wazuh-ansible/pull/435)

### Fixed

- Use local path while generating xpack certificates ([@xr09](https://github.com/xr09)) [PR#432](https://github.com/wazuh/wazuh-ansible/pull/432)

## [v3.12.3_7.6.2]

### Added

- Update to Wazuh v3.12.2
- AWS S3 block to template ([@limitup](https://github.com/limitup)) [PR#404](https://github.com/wazuh/wazuh-ansible/pull/413)

### Changed

- Update Kibana optimize task parameters and command ([@jm404](https://github.com/jm404)) [PR#404](https://github.com/wazuh/wazuh-ansible/pull/412)
- Update Kibana optimize folder and owner ([@jm404](https://github.com/jm404)) [PR#404](https://github.com/wazuh/wazuh-ansible/pull/410)

## [v3.12.2_7.6.2]

### Added

- Update to Wazuh v3.12.2

### Fixed
- Adjusting Kibana plugin optimization max memory ([@Zenidd](https://github.com/Zenidd)) [PR#404](https://github.com/wazuh/wazuh-ansible/pull/404)
- Removed python-cryptography library tasks ([@Zenidd](https://github.com/Zenidd)) [PR#401](https://github.com/wazuh/wazuh-ansible/pull/401)
- Removed duplicated task block ([@manuasir](https://github.com/manuasir)) [PR#400](https://github.com/wazuh/wazuh-ansible/pull/400)

## [v3.12.0_7.6.1]

### Added

- Update to Wazuh v3.12.0
- Added registration address variable to wazuh-agent playbook ([@Zenidd](https://github.com/Zenidd)) [PR#392](https://github.com/wazuh/wazuh-ansible/pull/392)

### Changed

- Bump NodeJS version to 10.x ([@manuasir](https://github.com/manuasir)) [PR#386](https://github.com/wazuh/wazuh-ansible/pull/386)
- Add flag to enable/disable Windows MD5 check ([@jm404](https://github.com/jm404)) [PR#383](https://github.com/wazuh/wazuh-ansible/pull/383)
- Rule paths are now relative to playbooks. ([@Zenidd ](https://github.com/Zenidd)) [PR#393](https://github.com/wazuh/wazuh-ansible/pull/393)
- Add the option to create agent groups and add an agent to 1 or more group. ([@rshad](https://github.com/rshad)) [PR#361](https://github.com/wazuh/wazuh-ansible/pull/361)


### Fixed

- Removed bad formed XML comments. ([@manuasir](https://github.com/manuasir)) [PR#391](https://github.com/wazuh/wazuh-ansible/pull/391)
- NodeJS node_options variable and Kibana plugin optimization fix. ([@Zenidd](https://github.com/Zenidd)) [PR#385](https://github.com/wazuh/wazuh-ansible/pull/385)
- Restrictive permissions for certificate files. ([@Zenidd](https://github.com/Zenidd)) [PR#382](https://github.com/wazuh/wazuh-ansible/pull/382)

## [v3.11.4_7.6.1]

### Added

- Update to Wazuh v3.11.4
- Support for RHEL/CentOS 8 ([@jm404](https://github.com/jm404)) [PR#377](https://github.com/wazuh/wazuh-ansible/pull/377)

### Changed

- Disabled shared configuration by default ([@jm404](https://github.com/jm404)) [PR#369](https://github.com/wazuh/wazuh-ansible/pull/369)
- Add chdir argument to Wazuh Kibana Plugin installation tasks ([@jm404](https://github.com/jm404)) [PR#375](https://github.com/wazuh/wazuh-ansible/pull/375)
- Adjustments for systems without (direct) internet connection ([@joschneid](https://github.com/joschneid)) [PR#348](https://github.com/wazuh/wazuh-ansible/pull/348)

### Fixed

- Avoid to install Wazuh API in worker nodes ([@manuasir](https://github.com/manuasir)) [PR#371](https://github.com/wazuh/wazuh-ansible/pull/371)
- Conditionals of custom Wazuh packages installation tasks ([@rshad](https://github.com/rshad)) [PR#372](https://github.com/wazuh/wazuh-ansible/pull/372)
- Fix Ansible elastic_stack-distributed template ([@francobep](https://github.com/francobep)) [PR#352](https://github.com/wazuh/wazuh-ansible/pull/352)
- Fix manager API verification ([@Zenidd](https://github.com/Zenidd)) [PR#360](https://github.com/wazuh/wazuh-ansible/pull/360)

## [v3.11.3_7.5.2]

### Added

- Update to Wazuh v3.11.3

### Fixed

- Fix Wazuh Agent configuration file for RHEL 8 ([@xr09](https://github.com/xr09)) [PR#354](https://github.com/wazuh/wazuh-ansible/pull/354)
- Fix default port used in Wazuh Agent playbook ([@jm404](https://github.com/jm404)) [PR#347](https://github.com/wazuh/wazuh-ansible/pull/347)

## [v3.11.2_7.5.1]

### Added

- Update to Wazuh v3.11.2

### Changed

- Update templates for Python 3 compatibility ([@xr09](https://github.com/xr09)) [PR#344](https://github.com/wazuh/wazuh-ansible/pull/344)

## [v3.11.1_7.5.1]

### Added

- Update to Wazuh v3.11.1


## [v3.11.0_7.5.1]

### Added

- Update to Wazuh v3.11.0

- Implemented changes to configure Wazuh API using the `wazuh.yml` file ([@xr09](https://github.com/xr09)) [PR#342](https://github.com/wazuh/wazuh-ansible/pull/342)

- Wazuh Agent registration task now explicitly notify restart ([@jm404](https://github.com/jm404)) [PR#302](https://github.com/wazuh/wazuh-ansible/pull/302)

- Support both IP and DNS when creating elastic cluster ([@xr09](https://github.com/xr09)) [PR#252](https://github.com/wazuh/wazuh-ansible/pull/252)

- Added config tag to the Wazuh Agent's enable task ([@xr09](https://github.com/xr09)) [PR#261](https://github.com/wazuh/wazuh-ansible/pull/261)

- Implement task to configure Elasticsearch user on every cluster node ([@xr09](https://github.com/xr09)) [PR#270](https://github.com/wazuh/wazuh-ansible/pull/270)

- Added SCA to Wazuh Agent and Manager installation ([@jm404](https://github.com/jm404)) [PR#260](https://github.com/wazuh/wazuh-ansible/pull/260)

- Added support for environments with low disk space ([@xr09](https://github.com/xr09)) [PR#281](https://github.com/wazuh/wazuh-ansible/pull/281)

- Add parameters to configure an Elasticsearch coordinating node ([@jm404](https://github.com/jm404)) [PR#292](https://github.com/wazuh/wazuh-ansible/pull/292)


### Changed

- Updated Filebeat and Elasticsearch templates ([@manuasir](https://github.com/manuasir)) [PR#285](https://github.com/wazuh/wazuh-ansible/pull/285)

- Make ossec.conf file more readable by removing trailing whitespaces ([@jm404](https://github.com/jm404)) [PR#286](https://github.com/wazuh/wazuh-ansible/pull/286)

- Wazuh repositories can now be configured to different sources URLs ([@jm404](https://github.com/jm404)) [PR#288](https://github.com/wazuh/wazuh-ansible/pull/288)

- Wazuh App URL is now flexible ([@jm404](https://github.com/jm404)) [PR#304](https://github.com/wazuh/wazuh-ansible/pull/304)

- Agent installation task now does not hardcodes the "-1" sufix ([@jm404](https://github.com/jm404)) [PR#310](https://github.com/wazuh/wazuh-ansible/pull/310)

- Enhanced task importation in Wazuh Manager role and removed deprecated warnings ([@xr09](https://github.com/xr09)) [PR#320](https://github.com/wazuh/wazuh-ansible/pull/320)

- Wazuh API installation task have been upgraded ([@rshad](https://github.com/rshad)) [PR#330](https://github.com/wazuh/wazuh-ansible/pull/330)

- It's now possible to install Wazuh Manager and Agent from sources ([@jm404](https://github.com/jm404)) [PR#329](https://github.com/wazuh/wazuh-ansible/pull/329)


### Fixed

- Ansible upgrade from 6.x to 7.x ([@jm404](https://github.com/jm404)) [PR#252](https://github.com/wazuh/wazuh-ansible/pull/251)

- Wazuh Agent registration using agent name has been fixed ([@jm404](https://github.com/jm404)) [PR#298](https://github.com/wazuh/wazuh-ansible/pull/298)
- Fix Wazuh repository and installation conditionals ([@jm404](https://github.com/jm404)) [PR#299](https://github.com/wazuh/wazuh-ansible/pull/299)

- Fixed Wazuh Agent registration using an Agent's name ([@jm404](https://github.com/jm404)) [PR#334](https://github.com/wazuh/wazuh-ansible/pull/334)


## [v3.11.0_7.3.2]

### Added

- Update to Wazuh v3.11.0

### Changed

- Moved molecule folder to Wazuh QA Repository [manuasir](https://github.com/manuasir) [#120ed16](https://github.com/wazuh/wazuh-ansible/commit/120ed163b6f131315848938beca65c1f1cad7f1b)

- Refactored XPack Security configuration tasks [@jm404](https://github.com/jm404) [#246](https://github.com/wazuh/wazuh-ansible/pull/246)

### Fixed

- Fixed ES bootstrap password configuration [@jm404](https://github.com/jm404) [#b8803de](https://github.com/wazuh/wazuh-ansible/commit/b8803de85fb71edf090b0c076d4fe3684cd7cb36)

## [v3.10.0_7.3.2]

### Added

- Update to Wazuh v3.10.0

### Changed

- Updated Kibana [@jm404](https://github.com/jm404) [#237](https://github.com/wazuh/wazuh-ansible/pull/237)
- Updated agent.conf template [@moodymob](https://github.com/moodymob) [#222](https://github.com/wazuh/wazuh-ansible/pull/222)
- Improved molecule tests [@rshad](https://github.com/rshad) [#223](https://github.com/wazuh/wazuh-ansible/pull/223/files)
- Moved "run_cluster_mode.sh" script to molecule folder [@jm404](https://github.com/jm404) [#a9d2c52](https://github.com/wazuh/wazuh-ansible/commit/a9d2c5201047c273c2c4fead5a54e576111da455)

### Fixed

- Fixed typo in the `agent.conf` template [@joey1a2b3c](https://github.com/joey1a2b3c) [#227](https://github.com/wazuh/wazuh-ansible/pull/227)
- Updated conditionals in tasks to fix Amazon Linux installation [@jm404](https://github.com/jm404) [#229](https://github.com/wazuh/wazuh-ansible/pull/229)
- Fixed Kibana installation in Amazon Linux [@jm404](https://github.com/jm404) [#232](https://github.com/wazuh/wazuh-ansible/pull/232)
- Fixed Windows Agent installation and configuration [@jm404](https://github.com/jm404) [#234](https://github.com/wazuh/wazuh-ansible/pull/234)

### Fixed

- Removed registry key check on Wazuh Agent installation in windows [@jm404](https://github.com/jm404) [#265](https://github.com/wazuh/wazuh-ansible/pull/265)

## [v3.9.5_7.2.1]

### Added

- Update to Wazuh v3.9.5
- Update to Elastic Stack to v7.2.1

## [v3.9.4_7.2.0]

### Added

- Support for registring agents behind NAT [@jheikki100](https://github.com/jheikki100) [#208](https://github.com/wazuh/wazuh-ansible/pull/208)

### Changed

- Default protocol to TCP [@ionphractal](https://github.com/ionphractal) [#204](https://github.com/wazuh/wazuh-ansible/pull/204).

### Fixed

- Fixed network.host is not localhost [@rshad](https://github.com/rshad) [#204](https://github.com/wazuh/wazuh-ansible/pull/212).

## [v3.9.3_7.2.0]

### Added
- Update to Wazuh v3.9.3 ([rshad](https://github.com/rshad) [PR#206](https://github.com/wazuh/wazuh-ansible/pull/206#))
- Added Versioning Control for Wazuh stack's components installation, so now it's possible to specify which package to install for wazuh-manager, wazuh-agent, Filebeat, Elasticsearch and Kibana. ([rshad](https://github.com/rshad) [PR#206](https://github.com/wazuh/wazuh-ansible/pull/206#))
- Fixes for Molecule testing issues. Issues such as Ansible-Lint and None-Idempotent tasks. ([rshad](https://github.com/rshad) [PR#206](https://github.com/wazuh/wazuh-ansible/pull/206#))
- Fixes for Wazuh components installations' related issues. Such issues were related to determined OS distributions such as `Ubuntu Trusty` and `CetOS 6`. ([rshad](https://github.com/rshad) [PR#206](https://github.com/wazuh/wazuh-ansible/pull/206#))
-  Created Ansible playbook and role in order to automate the uninstallation of already installed Wazuh components. ([rshad](https://github.com/rshad) [PR#206](https://github.com/wazuh/wazuh-ansible/pull/206#))


## [v3.9.2_7.1.1]

### Added

- Update to Wazuh v3.9.2
- Support for Elastic 7
- Ability to deploy an Elasticsearch cluster [#6b95e3](https://github.com/wazuh/wazuh-ansible/commit/6b95e304b6ac4dfec08df5cd0fe29be9cc7dc22c)

## [v3.9.2_6.8.0]

### Added

- Update to Wazuh v3.9.2

## [v3.9.1]

### Added

- Update to Wazuh v3.9.1
- Support for ELK v6.8.0

## [v3.9.0]

### Added

- Update to Wazuh Wazuh v3.9.0 ([manuasir](https://github.com/manuasir) [#177](https://github.com/wazuh/wazuh-ansible/pull/177)).
- Support for Elasticsearch v6.7.1 ([LuisGi91](https://github.com/LuisGi91) [#168](https://github.com/wazuh/wazuh-ansible/pull/168)).
- Added Molecule testing suit ([JJediny](https://github.com/JJediny) [#151](https://github.com/wazuh/wazuh-ansible/pull/151)).
- Added Molecule tests for Wazuh Manager ([dj-wasabi](https://github.com/dj-wasabi) [#169](https://github.com/wazuh/wazuh-ansible/pull/169)).
- Added Molecule tests for Wazuh Agent ([dj-wasabi](https://github.com/dj-wasabi) [#174](https://github.com/wazuh/wazuh-ansible/pull/174)).

### Changed

- Updated network commands ([kravietz](https://github.com/kravietz) [#159](https://github.com/wazuh/wazuh-ansible/pull/159)).
- Enable active response section ([kravietz](https://github.com/kravietz) [#155](https://github.com/wazuh/wazuh-ansible/pull/155)).

### Fixed

- Fix default active response ([LuisGi93](https://github.com/LuisGi93) [#164](https://github.com/wazuh/wazuh-ansible/pull/164)).
- Changing from Oracle Java to OpenJDK ([LuisGi93](https://github.com/LuisGi93) [#173](https://github.com/wazuh/wazuh-ansible/pull/173)).
- Adding alias to agent config file template ([LuisGi93](https://github.com/LuisGi93) [#163](https://github.com/wazuh/wazuh-ansible/pull/163)).

## [v3.8.2]

### Changed

- Update to Wazuh version v3.8.2. ([#150](https://github.com/wazuh/wazuh-ansible/pull/150))

## [v3.8.1]

### Changed
- Update to Wazuh version v3.8.1. ([#148](https://github.com/wazuh/wazuh-ansible/pull/148))


## [v3.8.0]

### Added

- Added custom name for single agent registration ([#117](https://github.com/wazuh/wazuh-ansible/pull/117))
- Adapt ossec.conf file for windows agents ([#118](https://github.com/wazuh/wazuh-ansible/pull/118))
- Added labels to ossec.conf ([#135](https://github.com/wazuh/wazuh-ansible/pull/135))

### Changed

- Changed Windows installation directory ([#116](https://github.com/wazuh/wazuh-ansible/pull/116))
- move redundant tags to the outer block ([#133](https://github.com/wazuh/wazuh-ansible/pull/133))
- Adapt new version (3.8.0-6.5.4) ([#144](https://github.com/wazuh/wazuh-ansible/pull/144))

### Fixed

- Fixed a couple linting issues with yamllint and ansible-review ([#111](https://github.com/wazuh/wazuh-ansible/pull/111))
- Fixes typos: The word credentials doesn't have two consecutive e's ([#130](https://github.com/wazuh/wazuh-ansible/pull/130))
- Fixed multiple remote connection ([#120](https://github.com/wazuh/wazuh-ansible/pull/120))
- Fixed null value for wazuh_manager_fqdn ([#132](https://github.com/wazuh/wazuh-ansible/pull/132))
- Erasing extra spaces in playbooks ([#131](https://github.com/wazuh/wazuh-ansible/pull/131))
- Fixed oracle java cookies ([#143](https://github.com/wazuh/wazuh-ansible/pull/143))

### Removed

- delete useless files from wazuh-manager role ([#137](https://github.com/wazuh/wazuh-ansible/pull/137))

## [v3.7.2]

### Changed

- Adapt configuration to current release ([#106](https://github.com/wazuh/wazuh-ansible/pull/106))

## [v3.7.1]

### Added

 - include template local_internal_options.conf. ([#87](https://github.com/wazuh/wazuh-ansible/pull/87))
 - Add multiple Elasticsearch IPs for Logstash reports. ([#92](https://github.com/wazuh/wazuh-ansible/pull/92))

### Changed

 - Changed windows agent version. ([#89](https://github.com/wazuh/wazuh-ansible/pull/89))
 - Updating to Elastic Stack to 6.5.3 and Wazuh 3.7.1. ([#108](https://github.com/wazuh/wazuh-ansible/pull/108))

### Fixed

- Solve the conflict betwwen tha agent configuration and the shared master configuration. Also include monitoring for `/var/log/auth.log`. ([#90](https://github.com/wazuh/wazuh-ansible/pull/90))
- Moved custom_ruleset files. ([#98](https://github.com/wazuh/wazuh-ansible/pull/98))
- Add authlog fix to localfile. ([#99](https://github.com/wazuh/wazuh-ansible/pull/99))
- Exceptions reload systemd. ([#114](https://github.com/wazuh/wazuh-ansible/pull/114))

### Removed

- clean old code for windows agent. ([#86](https://github.com/wazuh/wazuh-ansible/pull/86))

## v3.7.0-3701

### Added

- Amazon Linux deployments are now supported ([#71](https://github.com/wazuh/wazuh-ansible/pull/71)) and for the old repository structure ([#67](https://github.com/wazuh/wazuh-ansible/pull/67))
- Added the option to add rule files and decoders directly over the local rule and decoder directories in /var/ossec/etc ([#81](https://github.com/wazuh/wazuh-ansible/pull/81)).
- Added the necessary variables to configure a new configuration template for the Wazuh API ([#80](https://github.com/wazuh/wazuh-ansible/pull/80)).
- Added the option to verify the shared configuration for agents set in the manager ([#76](https://github.com/wazuh/wazuh-ansible/pull/76)).
- Added the option to configure the active response ([#75](https://github.com/wazuh/wazuh-ansible/pull/75)).

### Changed

- Repository restructure.
- Extended conditions to register a Wazuh agent. Now will register the agent in cases where there is no client.keys or the file exists but this empty ([#79](https://github.com/wazuh/wazuh-ansible/pull/79)).
- Grouping of tasks in a block under the same condition to improve the efficiency of the code ([#74](https://github.com/wazuh/wazuh-ansible/pull/74)).
- Improved efficiency of the Java repository ([#73](https://github.com/wazuh/wazuh-ansible/pull/73)).

### Fixed

- Fix oracle java cookie ([#71](https://github.com/wazuh/wazuh-ansible/pull/71)).
- include the logall_json label in ossec.conf template. This was causing an error when recreating the cdb_lists ([#84](https://github.com/wazuh/wazuh-ansible/pull/84)).

## v3.6.0

Ansible starting point.

Roles:
 - Elastic Stack:
   - ansible-elasticsearch: This role is prepared to install elasticsearch on the host that runs it.
   - ansible-kibana: Using this role we will install Kibana on the host that runs it.
 - Wazuh:
   - ansible-filebeat: This role is prepared to install filebeat on the host that runs it.
   - ansible-wazuh-manager: With this role we will install Wazuh manager and Wazuh API on the host that runs it.
   - ansible-wazuh-agent: Using this role we will install Wazuh agent on the host that runs it and is able to register it.
