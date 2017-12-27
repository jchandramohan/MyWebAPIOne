cls

$nugetPath = "$env:LOCALAPPDATA\NuGet\NuGet.exe"
if (!(Get-Command NuGet -ErrorAction SilentlyContinue) -and !(Test-Path $nugetPath))
{
	Write-Host "Downloading NuGet.exe..."
	<#
	$downloadUrl = "https://dist.nuget.org/win-x86-commandline/latest/nuget.exe"
	(New-Object System.Net.WebClient).DownloadFile($downloadUrl, $nugetPath)
	#>

	$web = New-Object System.Net.WebClient
	$credentials = [System.Text.Encoding]::ASCII.GetBytes("admin:P@ssw0rd123")
	$credentialsB64S = [System.Convert]::ToBase64String($credentials)
	$web.Headers[[System.Net.HttpRequestHeader]::Authorization] = "Basic" + $credentialsB64S

	$web.DownloadFile($downloadUrl, $nugetPath)
}
else
{
	Write-Host "NuGet package already exists. Skipping download."
}

if (Test-Path $nugetPath)
{
	Set-Alias NuGet (Resolve-Path $nugetPath)
	Write-Host "Restoring Nuget..."
	NuGet restore
}
else
{
	Write-Host "NuGet package could not be found."
}

. '.\functions.ps1'

$invokeBuild = (Get-ChildItem('.\packages\Invoke-Build*\tools\Invoke-Build.ps1')).FullName | Sort-Object $_ | Select -Last 1

& $InvokeBuild $args task.ps1 
