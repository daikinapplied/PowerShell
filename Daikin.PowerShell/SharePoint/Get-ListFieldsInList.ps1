## $webSite is the SharePoint site
## $ListName is the ListName we want to delete items from
Param(
  [string] $webSite,
  [string] $ListName
  )

$web = Get-SPWeb $webSite
$list = $web.Lists[$ListName]
$list.fields | select Title, InternalName, Hidden, CanBeDeleted | sort title | ft -AutoSize