param(
	$outputDir = (property outputDir "builds"),
	$configuration = (property configuration "Release")
)

$absoluteOutputDir = "$((Get-Location).Path)\$outputDir"
$projects = Get-SolutionProjects

task Clean {
	if (Test-Path $absoluteOutputDir)
	{
		Write-Host "Cleaning directory $absoluteOutputDir..."
		Remove-Item "$absoluteOutputDir" -Recurse -Force -ErrorAction SilentlyContinue | Out-Null
	}

	Write-Host "Creating output directory..."
	New-Item $absoluteOutputDir -ItemType Directory | Out-Null
	
	if ($projects -eq $null)
	{
		Write-Host "Projects can't be retrieved"
		return $null
	}

	$projects |
	ForEach-Object {
			Remove-Item -Path "$($_.Directory)\bin" -Recurse -Force -ErrorAction SilentlyContinue | Out-Null
			Remove-Item -Path "$($_.Directory)\obj" -Recurse -Force -ErrorAction SilentlyContinue | Out-Null
		}
}

task Compile {
	use "15.0" MSBuild 
	$projects |
		ForEach-Object {
			if ($_.IsWebProject)
			{
				$webOutputDir = "$absoluteOutputDir\$($_.Name)"
				$outputDir = "$absoluteOutputDir\$($_.Name)\bin"

				Write-Host "Compiling $($_.Name)..."
				exec {MSBuild $($_.Path) /p:Configuration=$configuration /p:OutDir=$outputDir /p:WebProjectOutputDir=$webOutputDir /p:DebugType=None `
											/nologo /p:Platform=AnyCpu /verbosity:quiet }
			}
			else
			{
				$outputDir = "$absoluteOutputDir\$($_.Name)\bin"

				Write-Host "Compiling $($_.Name)..."
				exec {MSBuild $($_.Path) /p:Configuration=$configuration /p:OutDir=$outputDir /p:DebugType=None `
											/nologo /p:Platform=AnyCpu /verbosity:quiet }
			}
		}
}

task Test {
	$projects |
		ForEach-Object {
			$testToolPath = Get-PackagePath "xunit.runner.console" $($_.Directory)
			if ($testToolPath -eq $null) {
				Write-Host "Test tool doesn't exist"
				return
			}

			Write-Host "Running test tool on $($_.Name)..."
			$testTool = "$testToolPath\tools\net452\xunit.console.exe"

			Write-Host $testTool
			if ($testTool -ne $null) {			
				exec { & $testTool $absoluteOutputDir\$($_.Name)\bin\$($_.Name).dll `
						-xml "$absoluteOutputDir\xunit_$($_.Name).xml" `
						-html "$absoluteOutputDir\xunit_$($_.Name).html" `
						-nologo }
			}
		}
}

task Dev Clean, Compile #, Test
task CI Dev
