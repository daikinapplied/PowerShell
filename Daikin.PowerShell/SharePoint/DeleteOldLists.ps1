#At the bottom of this lists you will see a template for two lists we could remove.
#Create a line for each list you wish delete and run this script.
Function DeleteSPList
{
    param
    (
        [string] $webSite  = $(throw "Please Enter the full url of your SharePoint Site!"),
        [string] $ListName = $(throw "Please Enter the List Name to Delete!")
    )
	#Change the below url before running
    $WebUrl = $webSite
    #Get the Objects
    $Web = Get-SPWeb $WebUrl
    $List = $Web.lists[$ListName]
  
    if($List)
    {
        #Set Allow Delete Flag
        $list.AllowDeletion = $true
        $list.Update()
 
        #delete list from sharepoint using powershell - Send List to Recycle bin
        $list.Recycle()
         
        #TO permanently delete a list.  We will Recycle and permanently remove manually during testing.:
        #$List.Delete()
 
        Write-Host "List: $($ListName) deleted successfully from: $($WebUrl)"
    }
    else
    {
        Write-Host "List: $($ListName) doesn't exist at $($WebUrl)"
    }
    $web.Dispose()
}
#DeleteSPList  "http://SharePointSite/Site" "List1"
#DeleteSPList  "http://SharePointSite/Site" "List2"