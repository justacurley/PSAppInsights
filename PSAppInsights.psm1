<#
    The module manifest (.psd1) defines this file as the entry point or root of the module.
    Ensure that all of the module functionality is loaded directly from this file.
#>

#load required assemblies, and export their paths
$Telemetry_dllPath = @(
    "$PSScriptRoot\Resources\Microsoft.ApplicationInsights.dll",
    "$PSScriptRoot\Resources\System.Diagnostics.DiagnosticSource.dll"
)
$Telemetry_dllPath | Foreach-Object {Add-Type -Path $_ -ErrorAction Stop}     
$PublicPath = Join-Path $PSScriptRoot "Public"
$PrivatePath = Join-Path $PSScriptRoot "Private"
# load functions
foreach ($functionFile in (Get-ChildItem -Path "$PublicPath\*.ps1"))
{    
    . $functionFile
}
foreach ($functionFile in (Get-ChildItem -Path "$PrivatePath\*.ps1"))
{
    . $functionFile
}
Export-ModuleMember -Variable Telemetry_dllPath
Export-ModuleMember -Alias @(
    # 'itd',
    'ntc',
    'ntd',
    'nte',
    'ntx',
    'nti',
    'nto',
    'ntr',
    'ntt',
    'flush',
    'sts',
    'stod',
    'stor',
    'utd'
)