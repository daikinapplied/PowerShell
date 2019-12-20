Param(
  [string] $webSite,
  [string] $ListName,
  [string] $FieldName
  )

Function AddSnapIn()
{
 #handles exceptions caused by trying to add a snapin
	Trap [Exception]
	{
	  continue; 
	}

 #Check that the required snapins are available , use a comma delimited list.
 #example
 # ("Microsoft.SharePoint.PowerShell", "Microsoft.Office.Excel")
	$RequiredSnapIns = ("Microsoft.SharePoint.PowerShell");
	ForEach ($SnapIn in $RequiredSnapIns)
	{
		if ( (Get-PSSnapin -Name $SnapIn -ErrorAction SilentlyContinue) -eq $null ) 
		{ 
		 Add-PsSnapin $SnapIn
		} 
  else 
  {
  }
	}
 [System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SharePoint");
}

AddSnapIn;

#Delete column on a specified list in all sites of a site collection
$site = Get-SPSite $webSite
$site | Get-SPWeb -Limit all | ForEach-Object {
#Specify list which contains the column
$list = $_.Lists[$ListName]
#Specify column to be deleted
$field = $list.Fields[$FieldName]
#Allow column to be deleted
$field.AllowDeletion = $true
#Delete the column 
$field.Delete()
#Update the list
$list.Update()
}
$site.Dispose()
