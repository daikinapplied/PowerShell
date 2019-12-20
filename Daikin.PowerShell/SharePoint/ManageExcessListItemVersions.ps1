function Delete-ExcessListItemVersions{
	################################################################
	#.Synopsis
	#  Enurmerates all list items in a given list, deleting any versions over the threshold set by the MaxVersions parameter. 
	#.DESCRIPTION
	# Use this function to delete all the excess versions for items in a given list that have more than a set number of versions (set by the -MaxVersions parameter). The cmdlet will return a collection of items that contain the weburl, list title, item title, author, version author, version number and version comment of each version deleted.
	#.LINK
	# http://matthewyarlett.blogspot.co.uk
	#.LINK
	# Get-ExcessListItemVersions
	#.Parameter SiteUrl
	#  The full url to the site that hosts the list
	#.Parameter ListTitle	
	#  The list title of the list that will be enumerated
	#.Parameter MaxVersions
	#  The maximum number of versions allowed per list item
	#.Parameter ParentProgressBarId
	#  The ID of the parent progress bar (used by Write-Progress)  	
	#.Parameter DeleteMinorVersions
	#  Use this switch to delete minor versions.
	#.Parameter Recurse
	#  Recurse through all sub-webs of the SiteUrl.
	#.OUTPUTS
	#  A collection of version items that have been deleted. The collection contains a custom object for each deleted version, containing the weburl, listtitle, itemtitle, original item author, version author, version, and version comment.
	#.EXAMPLE 
	#  Delete-ExcessListItemVersions -SiteUrl http://corporate/marketing -ListTitle Pages -MaxVersions 5
	#  Enumerate all of the publishing pages in the Pages library of the Marketing site. Delete all major versions of a page in excess of 5 versions.
	#.EXAMPLE 
	#  Delete-ExcessListItemVersions -SiteUrl http://corporate/marketing -ListTitle Pages -MaxVersions 5 -DeleteMinorVersions
	#  Enumerate all of the publishing pages in the Pages library of the Marketing site. Delete all major versions of a page in excess of 5 versions, including minor versions.
	#.EXAMPLE 
	#  Delete-ExcessListItemVersions -SiteUrl http://corporate -ListTitle Pages -MaxVersions 5 -DeleteMinorVersions -Recurse
	#  Enumerate all of the publishing pages in the Pages library of the Corporate site, and all sub-webs of corporate. Delete all major versions of a page in excess of 5 versions, including minor versions.
	################################################################
	
[CmdletBinding()]
	Param(	 
			[parameter(Mandatory=$true)][string]$SiteUrl, 
			[parameter(Mandatory=$true)][string]$ListTitle,		   
			[parameter(Mandatory=$true)][int]$MaxVersions,
			[parameter(Mandatory=$false)][int]$ParentProgressBarId,
			[parameter(Mandatory=$false)][switch]$DeleteMinorVersions,
			[parameter(Mandatory=$false)][switch]$Recurse
		)
	
	if($Recurse){
		Write-Progress -Id 1 -Activity "Recursively deleting old list item versions from the web, $SiteUrl, and all sub webs." -PercentComplete (1) -Status "Recursively enumerating the webs to process.";
		$websToSearch = @();
		$websToSearch = Get-Webs $SiteUrl;
		$progressActions = 1;
		$totalWebCount = 1;
		if($websToSearch.GetType().ToString() -ne "System.String")	{
			$progressActions = $websToSearch.Count;
			$totalWebCount = $websToSearch.Count;
		}
		$currentProgress=1;		
		$currentweb =1;
		foreach($weburl in $websToSearch)
		{	
			Write-Progress -Id 1 -Activity "Recursively deleting old list item versions from the web, $SiteUrl, and all sub webs." -PercentComplete ($currentProgress/$progressActions * 100) -Status "Checking web $currentweb of $totalWebCount ($weburl) ";
			if($DeleteMinorVersions)
			{
				Delete-ExcessListItemVersions -SiteUrl $weburl -ListTitle $ListTitle -MaxVersions $MaxVersions -ParentProgressBarId 1 -DeleteMinorVersions;
			}
			else
			{
				Delete-ExcessListItemVersions -SiteUrl $weburl -ListTitle $ListTitle -MaxVersions $MaxVersions -ParentProgressBarId 1;
			}		
			$currentProgress++;
			$currentweb++;
		}
		Write-Progress -Id 1 -Activity "Recursively deleting old list item versions from the web, $SiteUrl, and all sub webs." -PercentComplete (100) -Status "Finished!";		
		return;
	}	
	
	$itemversionobj = New-Object psobject
	$itemversionobj | Add-Member -MemberType NoteProperty -Name "WebUrl" -value ""
	$itemversionobj | Add-Member -MemberType NoteProperty -Name "ListTitle" -value ""
	$itemversionobj | Add-Member -MemberType NoteProperty -Name "ItemTitle" -value ""
	$itemversionobj | Add-Member -MemberType NoteProperty -Name "Author" -value ""
	$itemversionobj | Add-Member -MemberType NoteProperty -Name "VersionAuthor" -value ""
	$itemversionobj | Add-Member -MemberType NoteProperty -Name "VersionLabel" -value ""
	$itemversionobj | Add-Member -MemberType NoteProperty -Name "VersionComment" -value ""
	$versionList = $null;
	$versionList = @();	
	
	$outerProgressBarId = 1;
	$innerProgressBarId = 2;
	if($ParentProgressBarId -ne $null)
	{
		$outerProgressBarId = $ParentProgressBarId + 1;
		$innerProgressBarId = $outerProgressBarId + 1;
	}
	else
	{
		$ParentProgressBarId = 0;
	}
	$numberOfActions = 4;
	Write-Progress -Id $outerProgressBarId -ParentId $ParentProgressBarId -Activity "Processing items in $SiteUrl" -PercentComplete (1/$numberOfActions *100) -Status "Looking for the $SiteUrl web.";
	$w = get-spweb $siteUrl
	try
	{
		Write-Progress -Id $outerProgressBarId -ParentId $ParentProgressBarId -Activity "Processing items in $SiteUrl" -PercentComplete (2/$numberOfActions *100) -Status "Getting the list.";
		$l = $w.Lists.TryGetList($ListTitle);
		if($l -eq $null)
		{
			Write-Progress -Id $outerProgressBarId -ParentId $ParentProgressBarId -Activity "Processing items in $SiteUrl" -PercentComplete (4/$numberOfActions *100) -Status "List, $ListTitle, not found in the  current web, $SiteUrl";
			return;
		}
		$listType = $l.GetType().Name;
		$items = $l.Items;
		$count = $items.Count;
		$currentItem =1;
		Write-Progress -Id $outerProgressBarId -ParentId $ParentProgressBarId -Activity "Processing items in $SiteUrl" -PercentComplete (3/$numberOfActions *100) -Status "Found the '$ListTitle' List. Checking $count items.";
		$mltf = $l.Fields["Check In Comment"];
		foreach($item in $items)
		{
			$itemTitle = $item.Title;
			if($listType -eq "SPDocumentLibrary")
			{
				if($itemTitle -eq ""){$itemTitle = $item["Name"];}
			}
			$itemAuthor	= ($item.Fields["Created By"]).GetFieldValueAsText($item["Created By"]);
			Write-Progress -Id $innerProgressBarId -ParentId $outerProgressBarId -Activity "Enumerating List Items" -PercentComplete ($currentItem/$count*100) -Status "Checking item $currentItem of $count ($itemTitle)";
			$versionsDeleted = 0;
			if($item.Versions.Count -gt $MaxVersions){
				$vtr = $item.Versions.Count; 
				while($vtr -gt $MaxVersions){			
					$vtr--;
					[Microsoft.SharePoint.SPListItemVersion]$iv = $item.Versions[$vtr];
					$versionNumber = $iv.VersionLabel;
					if($iv.IsCurrentVersion){
						Write-Host "[$itemTitle] Can't delete the current version of an item." -Foregroundcolor Red;
						continue;
					}
					if(!$iv.VersionLabel.EndsWith(".0") -and !$DeleteMinorVersions)
					{
						Write-Host "[$itemTitle] To delete minor versions, use the -DeleteMinorVersions switch." -Foregroundcolor Yellow;
						continue;
					}
					$versionAuthor = $iv.CreatedBy.User.DisplayName;
					$comment="";
					if($mltf -ne $null)
					{
						if($iv.IsCurrentVersion)
						{$comment = "Comment: "+($mltf.GetFieldValueAsText($item.Versions.GetVersionFromID($iv.VersionId)["Check In Comment"])).Replace("`r`n"," ").Replace("`n"," ");}
						else
						{$comment = "Comment: "+($mltf.GetFieldValueAsText($item.File.Versions.GetVersionFromID($iv.VersionId).CheckInComment)).Replace("`r`n"," ").Replace("`n"," ");}
					}
					$nvi = $itemversionobj | Select-Object *; $nvi.WebUrl=$SiteUrl;$nvi.ListTitle=$ListTitle;$nvi.ItemTitle=$itemTitle;$nvi.VersionLabel=$versionNumber;$nvi.VersionComment=$comment;$nvi.Author=$itemAuthor;$nvi.VersionAuthor=$versionAuthor;
					$versionList += $nvi;
					$iv.Delete();
					$versionsDeleted++;
					Write-Host "[$itemTitle]  Deleted version $versionNumber";				
				}
			}
			if($versionsDeleted -gt 0)
			{
				Write-Progress -Id $innerProgressBarId -ParentId $outerProgressBarId -Activity "Enumerating List Items" -PercentComplete ($currentItem/$count*100) -Status "Deleted $versionsDeleted versions from the list item '$itemTitle'";
			}
			$currentItem++;		
		}
	}
	finally
	{
		$w.Dispose();
	}
	Write-Progress -Id $outerProgressBarId -ParentId $ParentProgressBarId -Activity "Processing items in $SiteUrl" -PercentComplete (4/$numberOfActions *100) -Status "Successfully finished enumerating items in the $ListTitle list.";	
	return $versionList;
}

function Get-ExcessListItemVersions{
	################################################################
	#.Synopsis
	#  Enurmerates the list items in the given list, from the given web (and optional all sub-webs), listing all the list items with versions over the threshold set by the MaxVersions parameter. 
	#.DESCRIPTION
	# Use this function to produce a report of all the excess versions of a items in a given list that have more than a set number of versions (set by the -MaxVersions parameter). The cmdlet will return a collection of items that contain the weburl, list title, item title, item id, author, version author, version number and version comment.
	#.LINK
	# http://matthewyarlett.blogspot.co.uk
	#.LINK
	# Get-ExcessListItemVersions
	#.Parameter SiteUrl
	#  The full url to the root web that hosts the list. The web defined by the SiteUrl parameter will be parsed.
	#.Parameter ListTitle	
	#  The list title of the list that will be enumerated. The web defined by RootUrl (and all sub-webs) will be checked for this list, and all items within the list while have their versions checked.
	#.Parameter MaxVersions
	#  The maximum number of versions allowed per list item 
	#.Parameter ParentProgressBarId
	#  The ID of the parent progress bar (used by Write-Progress)
	#.Parameter Recurse
	#  Recurse through all sub-webs of the SiteUrl.
	#.OUTPUTS
	#  A collection of version items that have been found with versions that exceed the threshold. The collection contains a custom object for each version, containing the weburl, listtitle, itemtitle, original item author, version author, version, and version comment.
	#.EXAMPLE 
	#  Get-ExcessListItemVersions -SiteUrl http://corporate/marketing -ListTitle Pages -MaxVersions 5
	#  Enumerate all of the publishing pages in the Pages library (if found) of the marketing web. List all versions of a page in excess of 5 versions.
	#.EXAMPLE 
	#  Get-ExcessListItemVersions -SiteUrl http://corporate -ListTitle Pages -MaxVersions 5 -Recurse
	#  Enumerate all of the publishing pages in the Pages library (if found) of the corporate web, and all sub-webs of corporate. List all versions of a page in excess of 5 versions.	
	################################################################
		
	[CmdletBinding()]
		Param(	 
				[parameter(Mandatory=$true)][string]$SiteUrl, 
				[parameter(Mandatory=$true)][string]$ListTitle,		   
				[parameter(Mandatory=$true)][int]$MaxVersions,
				[parameter(Mandatory=$false)][int]$ParentProgressBarId,
				[parameter(Mandatory=$false)][switch]$Recurse
			)
	
	if($Recurse){
		Write-Progress -Id 1 -Activity "Recursively checking the web, $SiteUrl, and all sub webs." -PercentComplete (1) -Status "Recursively enumerating the webs to process.";
		$websToSearch = @();
		$websToSearch = Get-Webs $SiteUrl;
		$progressActions = 1;
		$totalWebCount = 1;
		if($websToSearch.GetType().ToString() -ne "System.String")	{
			$progressActions = $websToSearch.Count;
			$totalWebCount = $websToSearch.Count;
		}
		$currentProgress=1;		
		$currentweb =1;
		foreach($weburl in $websToSearch)
		{	
			Write-Host "Searching web: $weburl $Current Item: $currentProgress Number of Actions: $progressActions";
			Write-Progress -Id 1 -Activity "Recursively checking the web, $SiteUrl, and all sub webs." -PercentComplete ($currentProgress/$progressActions * 100) -Status "Checking web $currentweb of $totalWebCount ($weburl) ";
			Get-ExcessListItemVersions -SiteUrl $weburl -ListTitle $ListTitle -MaxVersions $MaxVersions -ParentProgressBarId 1;
			$currentProgress++;
			$currentweb++;
		}
		Write-Progress -Id 1 -Activity "Recursively checking the web, $SiteUrl, and all sub webs." -PercentComplete (100) -Status "Finished!";
		return;
	}	
	
	$itemversionobj = New-Object psobject
	$itemversionobj | Add-Member -MemberType NoteProperty -Name "WebUrl" -value ""
	$itemversionobj | Add-Member -MemberType NoteProperty -Name "ListTitle" -value ""
	$itemversionobj | Add-Member -MemberType NoteProperty -Name "ItemTitle" -value ""
	$itemversionobj | Add-Member -MemberType NoteProperty -Name "ItemId" -value ""
	$itemversionobj | Add-Member -MemberType NoteProperty -Name "Author" -value ""
	$itemversionobj | Add-Member -MemberType NoteProperty -Name "VersionAuthor" -value ""
	$itemversionobj | Add-Member -MemberType NoteProperty -Name "VersionLabel" -value ""
	$itemversionobj | Add-Member -MemberType NoteProperty -Name "VersionComment" -value ""
	$versionList = $null;
	$versionList = @();
	$outerProgressBarId = 1;
	$innerProgressBarId = 2;
	if($ParentProgressBarId -ne $null)
	{
		$outerProgressBarId = $ParentProgressBarId + 1;
		$innerProgressBarId = $outerProgressBarId + 1;
	}
	else
	{
		$ParentProgressBarId = 0;
	}
	$numberOfActions = 4;
	Write-Progress -Id $outerProgressBarId -ParentId $ParentProgressBarId -Activity "Processing items in $SiteUrl" -PercentComplete (1/$numberOfActions *100) -Status "Looking for the $SiteUrl web.";
	$w = get-spweb $siteUrl
	try
	{
		Write-Progress -Id $outerProgressBarId -ParentId $ParentProgressBarId -Activity "Processing items in $SiteUrl" -PercentComplete (2/$numberOfActions *100) -Status "Getting the list.";
		$l = $w.Lists.TryGetList($ListTitle);
		if($l -eq $null)
		{
			Write-Progress -Id $outerProgressBarId -ParentId $ParentProgressBarId -Activity "Processing items in $SiteUrl" -PercentComplete (4/$numberOfActions *100) -Status "List, $ListTitle, not found in the  current web, $SiteUrl";
			return;
		}
		$listType = $l.GetType().Name;
		$items = $l.Items;
		$count = $items.Count;
		$currentItem =1;
		Write-Progress -Id $outerProgressBarId -ParentId $ParentProgressBarId -Activity "Processing items in $SiteUrl" -PercentComplete (3/$numberOfActions *100) -Status "Found the '$ListTitle' List. Checking $count items.";
		$mltf = $l.Fields["Check In Comment"];
		foreach($item in $items)
		{
			$itemTitle = $item.Title;
			if($listType -eq "SPDocumentLibrary")
			{
				if($itemTitle -eq ""){$itemTitle = $item["Name"];}
			}
			$itemAuthor	= ($item.Fields["Created By"]).GetFieldValueAsText($item["Created By"]);
			$itemId = $item.ID;			
			Write-Progress -Id $innerProgressBarId -ParentId $outerProgressBarId -Activity "Enumerating List Items" -PercentComplete ($currentItem/$count*100) -Status "Checking item $currentItem of $count ($itemTitle)";
			$excessVersions = $false;
			$versionsDeleted = 0;
			if($item.Versions.Count -gt $MaxVersions){			
				$vtr = $item.Versions.Count; 
				$versionsDeleted = $vtr - $MaxVersions;
				$excessVersions = $true;
				Write-Host "[$SiteUrl] $itemTitle has $vtr versions.";
				while($vtr -gt $MaxVersions){	
					$vtr--;	
					$comment = "<no comment>";
					[Microsoft.SharePoint.SPListItemVersion]$iv = $item.Versions[$vtr];
					$versionLabel = $iv.VersionLabel;
					$versionAuthor = $iv.CreatedBy.User.DisplayName;
					$comment = "";
					if($mltf -ne $null)
					{
						if($iv.IsCurrentVersion)
						{$comment = "Comment: "+($mltf.GetFieldValueAsText($item.Versions.GetVersionFromID($iv.VersionId)["Check In Comment"])).Replace("`r`n"," ").Replace("`n"," ");}
						else
						{$comment = "Comment: "+($mltf.GetFieldValueAsText($item.File.Versions.GetVersionFromID($iv.VersionId).CheckInComment)).Replace("`r`n"," ").Replace("`n"," ");}
					}
					Write-Host "$itemTitle (version $versionLabel) [Comment: $comment]";
					$nvi = $itemversionobj | Select-Object *; $nvi.WebUrl=$SiteUrl;$nvi.ListTitle=$ListTitle;$nvi.ItemTitle=$itemTitle;$nvi.VersionLabel=$versionLabel;$nvi.VersionComment=$comment;$nvi.Author=$itemAuthor;$nvi.VersionAuthor=$versionAuthor;$nvi.ItemId = $itemId;
					$versionList += $nvi;
				}
			}
			if($excessVersions)
			{
				Write-Progress -Id $innerProgressBarId -ParentId $outerProgressBarId -Activity "Enumerating List Items" -PercentComplete ($currentItem/$count*100) -Status "Found $versionsDeleted excess versions from the list item '$itemTitle'";
			}
			$currentItem++;	
		}
	}
	finally
	{
		$w.Dispose();
	}
	Write-Progress -Id $outerProgressBarId -ParentId $ParentProgressBarId -Activity "Processing items in $SiteUrl" -PercentComplete (4/$numberOfActions *100) -Status "Successfully finished enumerating items in the $ListTitle list.";
	return $versionList;
}

function Get-Webs{
	################################################################
	#.Synopsis
	#  Returns the parent web URL and all of it's child web URL's, by recursing through all child webs. 
	#.Parameter WebUrl
	#  The full url to the parent web.	
	#.EXAMPLE 
	#  Get-Webs -WebUrl http://corporate
	#  Returns a list containing the URL of the parent, http://corporate, and all of its child webs.
	################################################################
	[CmdletBinding()]
	Param(	 
			[parameter(Mandatory=$true)][string]$WebUrl
		)
	$w = Get-SPWeb $WebUrl;
	try
	{
		$webCollection = @();
		$webCollection += $w.Url;
		if($w.Webs.Count -gt 0)
		{
			foreach($web in $w.Webs)
			{
				$webCollection += Get-Webs -WebUrl $web.Url;
			}
		}
	}
	finally
	{
		$w.Dispose();
	}
	return $webCollection;
}

Delete-ExcessListItemVersions -SiteUrl http://plyshar04bld01v:27009 -ListTitle Pages -MaxVersions 4 -DeleteMinorVersions -Recurse



