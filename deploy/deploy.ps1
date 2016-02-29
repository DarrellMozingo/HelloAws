task default -depends deploy

task deploy {
#  echo "Getting AWS BeanStalk properties..."
  import-module awspowershell
  set-awscredentials -accesskey $aws_deploy_key -secretkey $aws_deploy_secret
#  $outputs = (get-cfnstack -stackname $target_beanstalk_stack -region $aws_region).Outputs
#  $app_ref = ($outputs | where { $_.OutputKey -eq "ApplicationRef" }).OutputValue
#  $env_ref = ($outputs | where { $_.OutputKey -eq "EnvironmentRef" }).OutputValue
  $app_ref = "My First Elastic Beanstalk Application"
  $env_ref = "Default-Environment"
  echo "Template = ElasticBeanstalk" > config_for_aws_deploy_command
  echo "Deploying to BeanStalk application '$app_ref', environment '$env_ref'"

#  pushd

#  echo "Swapping web.config..."
#  cd .\aws-package\Content\*\BuildAgent\work\*\src\*\obj\Debug\Package\PackageTmp
#  mv Web.$aws_env.$aws_region.config Web.config

#  popd

#  echo "Bundling msdeploy package with new config..."
  # Can't use a normal zip util, need to use msdeploy, otherwise it blows up on the other end trying to unpackage.
  # Couldn't get sub quotes passed correctly from powershell to msdeploy. '--%' is new in PS 3.0 to stop parsing PS code, and expands normal %% variables, but not context specific ones like %cd%.
  #   So put everything in variables for PS to expand variables first (including $pwd), then use --% to fork out to cmd.exe and pass everything else normally to msdeploy.
  #   Super convoluted but only way it seems to work properly.

#  $stop_parsing = "--%"
#  $msdeploy_args = "-verb:sync `
#    -source:archiveDir=$pwd\aws-package `
#    -dest:package=aws-package.zip `
#    -declareParam:name=`"IIS Web Application Name`",defaultValue=`"Default Web Site`",tags=IisApp `
#    -declareParam:name=`"IIS Web Application Name`",type=ProviderPath,scope=IisApp,match=^.*PackageTmp$ `
#    -declareParam:name=`"IIS Web Application Name`",type=ProviderPath,scope=setAcl,match=^.*PackageTmp$"

#  exec { &"C:\Program Files\IIS\Microsoft Web Deploy V3\msdeploy.exe" $stop_parsing $msdeploy_args }

  exec { &"C:\Program Files (x86)\AWS Tools\Deployment Tool\awsdeploy.exe" `
    /r /w `
    /DAWSAccessKey=$aws_deploy_key `
    /DAWSSecretKey=$aws_deploy_secret `
    /DRegion=$aws_region `
    /DUploadBucket=elasticbeanstalk-$aws_region-$aws_account_number `
    /DApplication.Name="$app_ref" `
    /DEnvironment.Name="$env_ref" `
    /DApplication.Version=$app_ver `
    /DDeploymentPackage=aws-package.zip `
    config_for_aws_deploy_command }

  $versionsToKeep = 5
  echo "Removing all but the last $versionsToKeep application versions"
  Get-EbApplicationVersion -applicationName $app_ref -region $aws_region `
    | sort dateUpdated `
    | select -skip $versionsToKeep `
    | Remove-EbApplicationVersion -region $aws_region -deleteSourceBundle $true -force
}
