 #Helps to resolve error:  Missing server side dependencies. 
 #Error like:   [MissingFeature] Database [$contentDatabase] has reference(s) to a missing feature: Name = [UI Feature], Id = [2bbd41f4-fefa-4d63-a256-23d70f094503], 
 #At the end of this document are two examples.  Get the feature ID's and conentdb from above
 
 Param(
  [string] $contentDatabase
  )
  
Import-Module WebAdministration

function Remove-SPFeatureFromContentDB($FeatureId)
{
	
    $db = Get-SPDatabase | where { $_.Name -eq $contentDatabase }
	
	write-host $contentDatabase
	
    [bool]$report = $false
    #if ($ReportOnly) { $report = $true }
    
    $db.Sites | ForEach-Object {
        
        Remove-SPFeature -obj $_ -objName "site collection" -featId $FeatureId -report $report
                
        $_ | Get-SPWeb -Limit all | ForEach-Object {
            
            Remove-SPFeature -obj $_ -objName "site" -featId $FeatureId -report $report
        }
    }
}

function Remove-SPFeature($obj, $objName, $featId, [bool]$report)
{
    $feature = $obj.Features[$featId]
    
    if ($feature -ne $null) {
        if ($report) {
            write-host "Feature found in" $objName ":" $obj.Url -foregroundcolor Red
        }
        else
        {
            try {
                $obj.Features.Remove($feature.DefinitionId, $true)
                write-host "Feature successfully removed from" $objName ":" $obj.Url -foregroundcolor Red
            }
            catch {
                write-host "There has been an error trying to remove the feature:" $_
            }
        }
    }
    else {
        #write-host "Feature ID specified does not exist in" $objName ":" $obj.Url
    }
}

#Remove-SPFeatureFromContentDB -FeatureId "45172fa8-3b10-4057-b574-0e8104cebb62"
#Remove-SPFeatureFromContentDB -FeatureId "2bbd41f4-fefa-4d63-a256-23d70f094503"

















