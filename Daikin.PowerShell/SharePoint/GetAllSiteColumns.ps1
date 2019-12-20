Add-PsSnapin Microsoft.SharePoint.PowerShell
## SharePoint DLL++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++Start
[void][System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SharePoint") 

# Give Your Site Collection URL
param
    (
        [string] $webSite  = $(throw "Please Enter the full url of your SharePoint Site!")
	)



# Code to Get the current working directory and generate the file Name with Current Date and Time + SiteColumnDetails.CSV
function Get-ScriptDirectory
{
    $Invocation = (Get-Variable MyInvocation -Scope 1).Value
    Split-Path $Invocation.MyCommand.Path
} 
$localFolderObject = Get-ScriptDirectory
$localFolder = $localFolderObject.ToString() + "\"
#Get current working directory
$today = Get-Date
$fileName = $localFolder + $today.Day.ToString() + "-" + $today.month.ToString() + "-" + $today.year.ToString() + "--SiteColumnDetails.csv"


#Writing the CSV Column Header  - Tab Separated
 "Column Title `t Site Column ID `t InternalName `t StaticName `t MaxLength `t Description `t Group `t TypeShortDescription " | out-file $fileName


#Operation+++++++++++++++++++++++++++++++++++++++++++++++++++Start
$site   =    new-object Microsoft.SharePoint.SPSite($webSite)
$web    = $site.rootweb.Fields
echo "Generating File..."
ForEach ($id in $web)
{

"$($id.Title) `t $($id.Id) `t $($id.InternalName) `t $($id.StaticName) `t $($id.MaxLength)/$($id.MaxLength) `t $($id.Description) `t $($id.Group) `t $($id.TypeShortDescription) " | Out-File $fileName -Append

}
$site.Dispose()

#Operation+++++++++++++++++++++++++++++++++++++++++++++++++++Start
echo "CSV file generated successfully, please check the below given path"
echo "File created at : + $fileName "