function Update-TelemetryDependency {
    <#
    .SYNOPSIS
        #Set properties of Dependency in Try or Catch block        
    .DESCRIPTION        
    #>
    param(
        [parameter(Mandatory, HelpMessage = "Dependency object to set")]
        [Object]
        $DT,
        [parameter(HelpMessage = "Dependency failure settings. If not provided, dependency success settings are applied.")]
        [switch]
        $Catch,
        [parameter(HelpMessage = "Result Code of request. Defaults to 200/404 if not provided")]
        [int]$Code
    )
    if ($Catch) {
        if (!$Code) { $Code = 404 }
        $DT.Telemetry.ResultCode = $Code
        $DT.Telemetry.Success = $false 
    }
    else {
        if (!$Code) { $Code = 200 }
        $DT.Telemetry.ResultCode = $Code
        $DT.Telemetry.Success = $true
    }
}
New-Alias utd Update-TelemetryDependency