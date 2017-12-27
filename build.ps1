cls

$nugetPath = "$env:LOCALAPPDATA\NuGet\NuGet.exe"
$policy = Get-ExecutionPolicy
Write-Host "Current execution policy: " $policy
Set-ExecutionPolicy RemoteSigned
$policy = Get-ExecutionPolicy
Write-Host "New execution policy: " $policy

if (!(Get-Command NuGet -ErrorAction SilentlyContinue) -and !(Test-Path $nugetPath))
{
	Write-Host "Downloading NuGet.exe..."
	$downloadUrl = "https://dist.nuget.org/win-x86-commandline/latest/nuget.exe"
	#(New-Object System.Net.WebClient).DownloadFile($downloadUrl, $nugetPath)
	$web = New-Object System.Net.WebClient

	<#
	$web = New-Object System.Net.WebClient
	$credentials = [System.Text.Encoding]::ASCII.GetBytes("user:pwd")
	$credentialsB64S = [System.Convert]::ToBase64String($credentials)
	$web.Headers[[System.Net.HttpRequestHeader]::Authorization] = "Basic" + $credentialsB64S
	#>
	if ($web -ne $null)	{
		Write-Host "Web client is valid. Trying to download..."
		$web.DownloadFile($downloadUrl, $nugetPath)
	}
	else {
		Write-Host "Web client cannot be initialized."
	}
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
