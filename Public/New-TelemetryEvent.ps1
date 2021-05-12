function New-TelemetryEvent {
    <#
    .SYNOPSIS
        Adds a Telemetry Event to a Telemetry Client
    .DESCRIPTION        
        Optionally provide a hashtable of Properties [string]-[string] as CustomProperties and/or a hashtable of Metrics [string]-[double] as a Custom Metric
    #>
    param (
        [parameter(Mandatory, HelpMessage = "Message for Event")]
        [string]
        $message,
        [parameter(HelpMessage = "Property hashtable of [string],[string] key,value pairs")]
        [hashtable]
        $PropHash,
        [parameter(HelpMessage = "Property hashtable of [string],[double] key,value pairs")]
        [hashtable]
        $MetHash,
        [parameter(Mandatory, HelpMessage = "TelemetryClient object created from New-TelemetryClient")]
        [hashtable]
        $TClient
         
    )
    if ($PropHash) {
        $dictProperties = customMeasurements -PropHash $PropHash
    }
    if ($MetHash) {
        $dubProperties = customMeasurements -MetHash $MetHash
    }    
    $TClient.TelemetryClient.TrackEvent($message, $dictProperties, $dubProperties)   
}
New-Alias nte New-TelemetryEvent