Function New-TelemetryDependency {
    <#
    .SYNOPSIS
        Adds a Telemtry Dependency operation to a Telemetry Client
    .DESCRIPTION        
    #>
    param(
        [parameter(Mandatory, HelpMessage = "The command being run (e.g. Invoke-RestMethod)")]
        [string]
        $Command,
        [parameter(HelpMessage = "The full command being run")]
        [string]
        $Data,
        [parameter(Mandatory, HelpMessage = "Dependency Type (e.g. API, SQL)")]
        [string]
        $Type,
        [parameter(Mandatory, HelpMessage = "The parameter of the command being run (e.g. URI for API call)")]
        $Target,
        [parameter(Mandatory, HelpMessage = "The name of this dependencies parent Request")]
        $ParentName,
        [parameter(Mandatory, HelpMessage = "TelemetryClient object created from New-TelemetryClient")]
        [hashtable]
        $TClient
        )
    $ParentID = $TClient.Requests.$ParentName.Telemetry.Id
    $DT = ($TClient.TelemetryItem.StartOperationDT($Command, $TClient.OpId, $ParentID))
    $DT.Telemetry.Context.Operation.Id = $TClient.OpId
    $DT.Telemetry.Type = $Type
    $DT.Telemetry.Target = $Target
    $DT.Telemetry.Data = $Data
    $DT
}
New-Alias ntd New-TelemetryDependency