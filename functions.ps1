function Get-SolutionProjects {
	#Add-Type -Path (${env:ProgramFiles(x86)} + '\Reference Assemblies\Microsoft\MSBuild\v14.0\Microsoft.Build.dll')
	Add-Type -Path (${env:ProgramFiles(x86)} + '\Microsoft Visual Studio\2017\Enterprise\MSBuild\15.0\Bin\Microsoft.Build.dll')

	$solutionFile = (Get-ChildItem('*.sln')).FullName | Select -First 1
	$solution = [Microsoft.Build.Construction.SolutionFile] $solutionFile

	return $solution.ProjectsInOrder |
			Where-Object {$_.ProjectType -eq 'KnownToBeMSBuildFormat'} |
			ForEach-Object {
				$isWebProject = (Select-String -Pattern "<UseIISExpress>.+</UseIISExpress>" -Path $_.AbsolutePath) -ne $null
				@{
					Path = $_.AbsolutePath;
					Name = $_.ProjectName;
					Directory = "$(Split-Path -Path $_.AbsolutePath -Resolve)";
					IsWebProject = $isWebProject
				}
			}
}

function Get-PackagePath($packageId, $projectPath) {
	if (!(Test-Path "$projectPath\packages.config")) {
		throw "Package.config doesn't exist in $projectPath"
	}
	else {
		[xml]$packageXml = Get-Content "$projectPath\packages.config"
		$package = $packageXml.Packages.Package | Where {$_.id -eq $packageId}
		if (!$package) {
			return $null
		}
	}
	
	Write-Host "$($package.id) - $($package.version)"

	return "packages\$($package.id).$($package.version)"
}

function Get-Version($projectPath) {
	$line = Get-Content "$projectPath\properties\AssemblyInfo.cs" | Where { $_.Contains("AssemblyVersion") }
	if (!$line) {
		throw "AssbmelyInfo not available."
	}

	$version=$line.Split('"')[1]

	$isLocalBuild = [String]::IsNullOrEmpty($env:BUILD_SERVER)

	if ($isLocalBuild) {		
		$buildDate = $(Get-Date).ToString("MMddyyyy")
		$buildTime = $(Get-Date).ToString("HHmmss")
		#$version="$($version.Replace("*",0))_$($buildDate)_$($buildTime)"
		$preRelease = $(Get-Date).ToString("MMddyyyy")
		$version="$($version.Replace("*",0))-pre$preRelease"
	}
	else {
		$version = $version.Replace("*", $env:BUILD_NUMBER)
	}

	return $version

}