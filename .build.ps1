#Requires -Modules InvokeBuild
Param (
    [String]
    $BuildOutput = "$PSScriptRoot\BuildOutput",

    [String[]]
    $GalleryRepository, #used in ResolveDependencies, has default

    [Uri]
    $GalleryProxy, #used in ResolveDependencies, $null if not specified

    [Switch]
    $ForceEnvironmentVariables = [switch]$true
)

Process {
    if ((Get-PSCallStack)[1].InvocationInfo.MyCommand.Name -ne 'Invoke-Build.ps1') {
        Write-Verbose "Returning control to Invoke-Build"
        Invoke-Build
        return
    }

    Resolve-Dependency

    Get-ChildItem -Path "$PSScriptRoot/.build/" -Recurse -Include *.ps1 -Verbose |
        Foreach-Object {
            "Importing file $($_.BaseName)" | Write-Verbose
            . $_.FullName 
        }
    

    task . DscClean, test #,Invoke-DscBuild

    task DscClean {
        Get-ChildItem -Path "$PSScriptRoot\DscBuildOutput\" -Recurse | Remove-Item -force -Recurse -Exclude README.md
    }

    task test {}
}





begin {
    function Resolve-Dependency {

        if (!(Get-Module -Listavailable PSDepend)) {
            Write-verbose "BootStrapping PSDepend"
            "Parameter $BuildOutput"| Write-verbose
            $InstallPSDependParams = @{
                Name = 'PSDepend'
                AllowClobber = $true
                Confirm = $false
                Force = $true
            }
            if ($GalleryRepository) { $InstallPSDependParams.Add('Repository',$GalleryRepository) }
            if ($GalleryProxy)      { $InstallPSDependParams.Add('Proxy',$GalleryProxy) }
            if ($GalleryCredential) { $InstallPSDependParams.Add('ProxyCredential',$GalleryCredential) }
            Install-Module @InstallPSDependParams
        }

        $PSDependParams = @{
            Force = $true
            Path = "$PSScriptRoot\Dependencies.psd1"
        }

        if ($DependencyTarget) {
            $PSDependParams.Add('Target',$DependencyTarget)
        }
        Invoke-PSDepend @PSDependParams
        Write-Verbose "Project Bootstrapped, returning to Invoke-Build"
    }
}

