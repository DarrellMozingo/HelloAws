param(
  [Parameter(Mandatory=1)]
  [string]$aws_deploy_key,

  [Parameter(Mandatory=1)]
  [string]$aws_deploy_secret,

  [Parameter(Mandatory=1)]
  [string]$aws_region,

  [Parameter(Mandatory=1)]
  [string]$aws_env,

  [Parameter(Mandatory=1)]
  [string]$app_ver,

  [Parameter(Mandatory=1)]
  [string]$aws_account_number
)

$scriptPath = $(Split-Path -parent $MyInvocation.MyCommand.path)

Import-Module (join-path $scriptPath psake.psm1)
Invoke-psake (join-path $scriptPath deploy.ps1)

if ($psake.build_success -eq $false) { exit 1 } else { exit 0 }
