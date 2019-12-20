    param
    (
        [string] $webSite  = $(throw "Please Enter the full url of your SharePoint Site!")
	)

$sitecollectionUrl = $webSite
 

$siteCollection = New-Object Microsoft.SharePoint.SPSite($sitecollectionUrl)

 
write-host("Items to be deleted : " +$siteCollection.RecycleBin.Count.toString())

 
$now = Get-Date

 
write-host("Deleting started at " +$now.toString())

 
$siteCollection.RecycleBin.DeleteAll();

 
$now = Get-Date

 
write-host("Deleting completed at " +$now.toString())

 
$siteCollection.Dispose(); 
 
