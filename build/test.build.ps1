filter Convert-VersionToComparableText { '{0:0000}{1:0000}{2:0000}' -f $_.Major, $_.Minor, $_.Build }
$script:Root = Split-Path $PSScriptRoot -Parent
$script:Config = Import-PowershellDataFile -Path $PSScriptRoot\config.psd1
task TestDLL {
    $DLLRoot = Join-Path $root 'lib'
    if (!(Test-Path $DLLRoot)) {
        New-Item -ItemType Directory -Path $DLLRoot
    }
    $dll.keys | % {
        $CurrentDLLName = $_
        $CurrentDLLVersionPath = (Join-Path $DLLRoot $_)
        if (!(Test-Path $CurrentDLLVersionPath)) {
            throw "$CurrentDLLName[$($dll[$CurrentDLLName])] missing from project."
        }
        else {
            $CurrentDLLVersion = [version]($dll.$CurrentDLLName) | Convert-VersionToComparableText       
            $Version =[version](Get-Item $CurrentDLLVersionPath).VersionInfo.FileVersion | Convert-VersionToComparableText
            if ($Version -ne $CurrentDLLVersion) {
                throw "$CurrentDLLName[$CurrentDLLVersion)] version mismatch. Version required:[$($dll[$CurrentDLLName])]. "
            }
        }
    }
}

task AddDefaultParameters {

}