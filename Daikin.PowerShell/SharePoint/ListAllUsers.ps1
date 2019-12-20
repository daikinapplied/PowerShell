 Param(
  [string] $webSite
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
cls;

ShowAllUsers;

Function ShowAllUsersInAllGroups()
{

    $site = Get-SPSite $webSite

    $groups = $site.RootWeb.sitegroups

    foreach ($grp in $groups) {"Group: " + $grp.name; foreach ($user in $grp.users) {"User: " + $user.name + "  ID: " + $user.ID + "  Email: " + $user.UserLogin} }

    $site.Dispose()
}

Function ShowAllUsers()
{

    $site = Get-SPSite $webSite

    $users = $site.RootWeb.SiteUsers

    foreach ($user in $users) 
    {$user.name + "^" + $user.ID + "^" + $user.Email + "^" + $user.UserLogin} 

    $site.Dispose()
}