## $webSite is the SharePoint site
## $ListName is the ListName we want to delete items from
Param(
  [string] $webSite,
  [string] $ViewNameUrl  # "/Products/DV%20%20Daikin%20Applied%20Base%20Product.aspx"  
  )
  
$SiteUrl = $webSite           
$viewurl = $webSite + $ViewNameUrl           
             
$targetUrl = Get-SPWeb -Identity $SiteUrl            
if ($targetUrl -ne $null)            
{            
    $targetFile = $targetUrl.GetFile($viewurl)
    if($targetFile.Exists)            
    {            
        Write-Host "Created By: " $targetFile.Author            
        Write-Host "Modified: " $targetFile.TimeLastModified            
        Write-Host "Modified By: " $targetFile.ModifiedBy            
        Write-Host "Created: " $targetFile.TimeCreated            
    }            
    else            
    {            
        Write-Host "File doesn't exist"            
    }            
}