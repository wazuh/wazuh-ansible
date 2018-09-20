#------------------------- Gather parameters --------------------------#

param (
    [switch]$Elevated,
    [switch]$help
    )

#------------------------- Gather parameters --------------------------#

# ------------------------- Common functions ------------------------- #

# Restart agent service
function restartAgent {
  $service="OssecSvc"
  $status= (Get-Service $service).status

  if($status -eq "Running"){
    Restart-Service $service -Force
  }
  elseif($status -eq "Stopped"){
    Start-Service $service 
  }
}

# Get agent version

function getVersion
{
    $version = ""
    $version_path = "$($path)\VERSION"
    if (Test-Path $version_path) {
       $version_path = "$($path)\VERSION"
    } else {
       $version_path = "$($path)\VERSION.txt"
    }

    foreach($line in Get-Content "$($version_path)") {
       if ($line -like '*v2.*'){
       $version = "v2"
       }
       if ($line -like '*v3.*'){
          if ($line -like '*v3.0.*'){
              $version = "v3.0"
          } else{
              $version = "v3"
          }
       }
    }

    if ($wazuh_version -eq ""){
      "The agent version could not be obtained."
      Exit
    } else{
    return $version
    }
}

# Agent configuration
function confAgent
{

    "Updating local_internal_options.conf file..."

    $local_conf_path = "$($path)\local_internal_options.conf"
    $local_conf_path
    if (Test-Path $local_conf_path) {
         "local_internal_options.conf already exists. Proceeding with the changes. "
    } else{
         "Creating local_internal_options.conf"
         New-Item "$($path)\local_internal_options.conf" -ItemType file
         Add-Content "$($path)\local_internal_options.conf" -value "# local_internal_options.conf`r`n
#`r`n
# This file should be handled with care. It contains`r`n
# run time modifications that can affect the use`r`n
# of OSSEC. Only change it if you know what you`r`n
# are doing. Look first at ossec.conf`r`n
# for most of the things you want to change.`r`n
#`r`n
# This file will not be overwritten during upgrades.`r`n"
    }
         

    if ($wazuh_version -eq "v3") {
      $contain_output = Select-String -Path "$($path)\local_internal_options.conf" -pattern wazuh_command.remote_commands

      if ($contain_output -ne $null) {
        (Get-Content "$($path)\local_internal_options.conf") -replace('wazuh_command.remote_commands.*', 'wazuh_command.remote_commands=1') | Set-Content "$($path)\local_internal_options.conf"
      } else {
        Add-Content "$($path)\local_internal_options.conf" -value "# Wazuh Command Module - If it should accept remote commands from the manager`r`nwazuh_command.remote_commands=1`r`n"
      }
    }

    $contain_output = Select-String -Path "$($path)\local_internal_options.conf" -pattern 'logcollector.remote_commands'

    if ($contain_output -ne $null) {
      (Get-Content "$($path)\local_internal_options.conf") -replace('logcollector.remote_commands.*', 'logcollector.remote_commands=1') | Set-Content "$($path)\local_internal_options.conf"
    } else {
      Add-Content "$($path)\local_internal_options.conf" -value "# Logcollector - If it should accept remote commands from the manager`r`nlogcollector.remote_commands=1`r`n"
    }
}

# Usage function
function Usage
{
    "
       /\__/\
      /      \    WAZUH agent - Windows deploy
      \ \  / /    Site: http://www.wazuh.com
       \ VV /
        \__/
    USE: ./configure_commands_wazuh_agent.ps1 [options]
    -help: usage information.
    Examples:
        ./configure_commands_wazuh_agent.ps1
    "
}

# ------------------------- Common functions ------------------------- #

#------------------------- Analyze parameters -------------------------#

if(($help.isPresent)) {
    Usage
    Exit
}

#------------------------- Analyze parameters -------------------------#

#------------------------- Main workflow --------------------------#

# Opening powershell as Administrator
if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
       Write-Host "This script requires Administrator privileges"
       Exit
}


$path = "C:\Program Files (x86)\ossec-agent\"
if (Test-Path $path) {
    $path = "C:\Program Files (x86)\ossec-agent\"
} else {
    $path = "C:\Program Files\ossec-agent\"
}

# Get agent version
$wazuh_version = getVersion
"Agent version: $wazuh_version"
# Configure agent
confAgent

# Restart agent
restartAgent

#------------------------- Main workflow --------------------------#