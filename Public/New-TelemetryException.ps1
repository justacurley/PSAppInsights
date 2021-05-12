function New-TelemetryException {
    <#
    .SYNOPSIS
        Sends a Telemetry Exception to the Telemetry Client
    #>
    param (
        [System.Exception]$Exception,
        [parameter(Mandatory, HelpMessage = "TelemetryClient object created from New-TelemetryClient")]
        [hashtable]
        $TClient
    )
    $TClient.TelemetryClient.TrackException($Exception)
}
New-Alias ntx New-TelemetryException