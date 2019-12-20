[void][System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SharePoint")
[void][System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SharePoint.Publishing")
 
 Param(
  [string] $webSite
  )
  
function ListWebParts($web) {
 if ([Microsoft.SharePoint.Publishing.PublishingWeb]::IsPublishingWeb($web))
 {
   write-host $web
   $webPublish = [Microsoft.SharePoint.Publishing.PublishingWeb]::GetPublishingWeb($web)
   $pages = $webPublish.GetPublishingPages()
 
   foreach($page in $pages)
   {
     $manager = $web.GetLimitedWebPartManager($page.Url, [System.Web.UI.WebControls.WebParts.PersonalizationScope]::Shared)
     $webCollection = $manager.WebParts
     if($webCollection.Count -ne 0)
     {
       for($i =0;$i -lt $webCollection.Count; $i++)	
       {
         write-host $web.url  $page.url  $webCollection[$i].GetType().Name  $webCollection[$i].Title
       }
     }
   }
 }
}
 
function LoadSPSite()
{
  $site = New-Object Microsoft.SharePoint.SPSite($webSite)

  foreach($web in $site.allwebs)
  {
     echo $web.Title
     if($web.Title -eq "English")
     {
       ListWebParts($web)
     }
  }
  $site.Dispose()
}
 

Write-Debug "Page URL;Web Part Type;Web Part Title"
LoadSPSite
