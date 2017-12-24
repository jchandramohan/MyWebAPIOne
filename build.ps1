cls

$nugetPath = "$env:LOCALAPPDATA\NuGet\NuGet.exe"
if (!(Get-Command NuGet -ErrorAction SilentlyContinue) -and !(Test-Path $nugetPath))
{
	Write-Host "Downloading NuGet.exe..."
	$downloadUrl = "https://dist.nuget.org/win-x86-commandline/latest/nuget.exe"
	(New-Object System.Net.WebClient).DownloadFile($downloadUrl, $nugetPath)
}

if (Test-Path $nugetPath)
{
	Set-Alias NuGet (Resolve-Path $nugetPath)
}

Write-Host "Restoring Nuget..."
NuGet restore

. '.\functions.ps1'

$invokeBuild = (Get-ChildItem('.\packages\Invoke-Build*\tools\Invoke-Build.ps1')).FullName | Sort-Object $_ | Select -Last 1

& $InvokeBuild $args task.ps1 
