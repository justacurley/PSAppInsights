Function Stop-TelemetryOperationDependency {
    <#
    .SYNOPSIS
        #Stop and dispose of a Telemetry Dependency        
    .DESCRIPTION        
    #>
    param(
        [parameter(Mandatory, HelpMessage = "Dependency object to stop")]
        [Object]
        $DT,
        [parameter(Mandatory, HelpMessage = "TelemetryClient object created from New-TelemetryClient")]
        [hashtable]
        $TClient
    )
    $TClient.TelemetryItem.StopOperationDT($DT)
}
New-Alias stod Stop-TelemetryOperationDependency