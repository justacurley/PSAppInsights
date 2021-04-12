filter Convert-VersionToComparableText { '{0:0000}{1:0000}{2:0000}' -f $_.Major, $_.Minor, $_.Build }
$script:Root = Split-Path $PSScriptRoot -Parent
$script:Config = Import-PowershellDataFile -Path $PSScriptRoot\conf.psd1
task TestDLL {
    $dll = $Config.dll
    $dll.keys | % {
        $CurrentDLL = $dll.$_
        if (!(Test-Path $CurrentDLL.Path)) {
            throw "$_ [$($CurrentDLL.Version)] missing from project."
        }
        else {
            $CurrentDLLVersion = [version]($CurrentDLL.Version) | Convert-VersionToComparableText
            $Version =[version](Get-Item $CurrentDLL.Path).VersionInfo.FileVersion | Convert-VersionToComparableText
            if ($Version -ne $CurrentDLLVersion) {
                throw "$CurrentDLLName version mismatch. Version required:[$($CurrentDLL.Version)]. "
            }
        }
    }
}

task AddDefaultParameters {

}