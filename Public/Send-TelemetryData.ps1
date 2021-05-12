Function Send-TelemetryData {
    <#
    .SYNOPSIS
        #Flush telemetry client, forcing data to Application Insights.
    .DESCRIPTION        
        #Useful if you need to exit a scope before running all code.
    #>
    param(
        [parameter(Mandatory, HelpMessage = "TelemetryClient object created from New-TelemetryClient")]
        [hashtable]
        $TClient
    )
    $TClient.TelemetryClient.Flush()
}
New-Alias flush Send-TelemetryData