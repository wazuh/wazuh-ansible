#ansible-ossec-server Release

Below an overview of all changes in the releases.

Version (Release date)

0.2.0   (2017-02-14)

  * Added molecule testing
  * do not look for specific key ID. It appears that OSSEC released a new… #3 (By pull request: recunius (Thanks!))
  * Updates #4 (By pull request: recunius (Thanks!))
  * allow providing own local_rules.xml template with var ossec_server_… #5  (By pull request: recunius (Thanks!))
  * Update CIS filename to CentOS & Redhat 7 #6 (By pull request: jlruizmlg (Thanks!))
  * add ossec authd as service #7 (By pull request: jlruizmlg (Thanks!))
  * Fix the permissions in the wazuh-authd in upstart system. #8  (By pull request: jlruizmlg (Thanks!))
  * Remove ssl files and add task to generate them + Fix script init task #10 (By pull request: aarnaud (Thanks!))

0.1.0   (2015-11-16)

  * Fixes for CentOS/EL7 #1 (By pull request: andskli (Thanks!))
  * Updates to support Ubuntu and also adds more configuration options #2 (By pull request: recunius (Thanks!))
  * Added kitchen test and serverspec tests

0.0.2   (2014-12-11)

  * Added possibilty to use other mail settings
  * Reworked module for better setup. Updated readme

0.0.1   (2014-12-04)

  * Initial creation
