Param(
  [string] $webSite,
  [string] $ListName
  )
  
$list = $webSite.Lists[$ListName]

"List is :" + $list.Title + " with item count " + $list.ItemCount


foreach ($item in $list.Items)
{
  #Update choice field with Active
  $item["Product Status"] = “Active”;
  
  $item.Update();
}