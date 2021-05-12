function New-TelemetryTrace {
    <#
    .SYNOPSIS
        Creates a new Telemetry Trace operation in the Telemetry Client
    .DESCRIPTION   
        Optionally provide a hashtable of Properties [string]-[string] as CustomProperties     
    #>
    param (
        [parameter(Mandatory,HelpMessage="Message for Trace")]
        [string]
        $message,
        [parameter(HelpMessage="Severity level for Trace")]
        [validateSet('Critical','Warning','Information','Verbose','Warning',$null,'')]
        [string]
        $Severity,
        [parameter(HelpMessage="Property hashtable of [string],[string] key,value pairs")]
        [hashtable]
        $PropHash,
        [parameter(Mandatory, HelpMessage = "TelemetryClient object created from New-TelemetryClient")]
        [hashtable]
        $TClient
         
    )
    if (!$Severity) {
        $Severity = 'Information'
    }
    if ($PropHash) {
        $dictProperties = customMeasurements -PropHash $PropHash
    }

    $TClient.TelemetryClient.TrackTrace($Message,$Severity,$dictProperties)      
}
New-Alias ntt New-TelemetryTrace