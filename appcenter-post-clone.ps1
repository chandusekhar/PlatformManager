function Generate-VersionNumber() {
    $end = Get-Date
    $start = Get-Date "5/17/2017"

    $today = Get-Date
    $today = $today.ToShortDateString()
    $today = Get-Date $today

    $revisionNumber = New-TimeSpan -Start $start -End $end
    $minutes = New-TimeSpan -Start $today -End $end
	
	$buildNumber =  ("{0:00}" -f ([math]::Round($end.Month))) + ("{0:00}" -f ([math]::Round($end.Day)))
	$revisionNumber = ("{0:00}" -f [math]::Round($minutes.Hours)) + ("{0:00}" -f ([math]::Round($minutes.Minutes)))

	return "$buildNumber.$revisionNumber"

}

$scriptPath = (Split-Path $MyInvocation.MyCommand.Path);

"Copy Environment Specific Icons"
$env:APPCENTER_BRANCH
Copy-Item -Path ".\BuildAssets\UWP\$env:APPCENTER_BRANCH\*"  -Destination ".\src\LagoVista.PlatformManager.UWP\Assets" -Force

$versionFile = "$scriptPath\version.txt"

[string] $versionContent = Get-Content $versionFile;
$revisionNumber = Generate-VersionNumber
$versionNumber = "$versionContent.$revisionNumber"
"Done setting version: $versionNumber"

$appmanifestFile = "$scriptPaths\src\LagoVista.PlatformManager.UWP\Package.appxmanifest"
[xml] $content = Get-Content  $appmanifestFile
$content.Package.Identity.Name
$content.Package.Identity.Name = $env:UWPAPPIDENTITY
$content.Package.Identity.Version = $versionNumber
$content.save($appmanifestFile)

$storeAssociationFile = "$scriptPath\src\LagoVista.PlatformManager.UWP\Package.StoreAssociation.xml"
[xml] $storeContent = (Get-Content  $storeAssociationFile) 
$storeContent.StoreAssociation.ProductReservedInfo.MainPackageIdentityName
$storeContent.StoreAssociation.ProductReservedInfo.MainPackageIdentityName = $env:UWPAPPIDENTITY
$storeContent.save($storeAssociationFile)

$uwpAppFileContent = "$scriptPath\src\LagoVista.PlatformManager.UWP\App.xaml.cs"
[string] $uwpAppFileContent = (Get-Content $assemblyInfoFile) -join "`r`n"
$regEx = "MOBILE_CENTER_KEY = \""[0-9a-f\-]+\"";"
$uwpAppFileContent -replace $regEx, "MOBILE_CENTER_KEY = ""$env:APPCENTERID""";

$assemblyInfoFile = "$scriptPath\src\LagoVista.PlatformManager.UWP\AssemblyInfo.cs"
[string] $assemblyInfoContent = (Get-Content $assemblyInfoFile) -join "`r`n"
$regEx = "assembly: AssemblyVersion\(\""[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+\""\)"
$assemblyInfoContent = $assemblyInfoContent -replace $regEx,  "assembly: AssemblyVersion(""$versionNumber"")"
$regEx = "assembly: AssemblyFileVersion\(\""[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+\""\)"
$assemblyInfoContent = $assemblyInfoContent -replace $regEx,  "assembly: AssemblyFileVersion(""$versionNumber"")"
$assemblyInfoContent | Set-Content  $assemblyInfoFile 