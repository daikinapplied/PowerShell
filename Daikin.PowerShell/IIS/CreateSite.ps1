#   .\CreateSite.ps1 -webApp 1 -AppName FakeSite -hostHeader mike.daikinapplied.com -UserName ami_nt\bishopms -Password xxxx  -useHttps 1

##This script will create a file directory, a .net core app pool, and a web site(http or https).
##If UserName is not included, then the appPool will run as ApplicationPoolIdentity.
##If a hostHeader is included, than port 80 will include that.
Param(
  [bool] $webSite = $true,
  [string] $AppName,
  [string] $hostHeader = "",
  [string] $UserName = "",
  [string] $Password = "",
  [bool] $useHttps = $false
)
#Setting below to "" = "No Managed code" - This is necessary for .net core apps!
$appPoolIisNetVersion = "No Managed code"
$fileLocation = "D:\"

#Make the application file directory
if($webSite) {
	$fileLocation = $fileLocation + "Websites\" + $AppName
	MKDIR $fileLocation
}
else {
	$fileLocation = $fileLocation + "Services\" + $AppName
	MKDIR $fileLocation
}

#Create App Pool
$appPool = New-WebAppPool -Name $AppName
$appPool.managedRuntimeVersion = $appPoolIisNetVersion

if($UserName -ne "") {
	$appPool.processmodel.identityType = 3
	$appPool.processModel.userName = $UserName
	$appPool.processModel.password = $Password
}
$appPool | Set-Item

#Create WebSite
$website = New-Website -Name $AppName -PhysicalPath $fileLocation -ApplicationPool ($appPool.Name) -HostHeader $hostHeader

#Add website settings
#$IISSite = "IIS:\Sites\$AppName"
#Set-ItemProperty $IISSite -name  Bindings -value @{protocol="https";bindingInformation="*:443:$HostName"}
if($useHttps) {
	New-WebBinding -Name $AppName -IP "*" -Port 443 -Protocol https
}


