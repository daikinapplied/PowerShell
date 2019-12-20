## $webSite is the SharePoint site
## $ListName is the ListName we want to delete items from
## Use emptyBin.ps1 to permanently remove these from the recycling bin
Param(
  [string] $webSite,
  [string] $ListName
  )

$Web = Get-SPWeb -identity $webSite
$List = $Web.Lists[$ListName]

foreach ($Item in $List.Items)
{
    $List.GetItemById($Item.Id).delete()
}

foreach ($Item in $List.Folders)
{
    $List.GetItemById($Item.Id).delete()

}
