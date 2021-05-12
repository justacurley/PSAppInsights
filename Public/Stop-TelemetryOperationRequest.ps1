Function Stop-TelemetryOperationRequest {
    <#
    .SYNOPSIS        
        #Stop and dispose of a Telemetry Request
    .DESCRIPTION        
    #>
    param(
        [parameter(Mandatory, HelpMessage = "Request object to stop")]
        [Object]
        $RT,
        [parameter(Mandatory, HelpMessage = "Was the request successful")]
        [bool]$Success,
        [parameter(HelpMessage = "Result Code of request. Defaults to 200/404 if not provided")]
        [int]$Code,
        [parameter(Mandatory, HelpMessage = "TelemetryClient object created from New-TelemetryClient")]
        [hashtable]
        $TClient
    )
    $RT.Telemetry.Success = $Success
    if (!$Code) {
        If ($Success) {$Code=200}
        else {$Code=404}
    }
    $RT.Telemetry.ResponseCode=$Code
    $TClient.TelemetryItem.StopOperationRT($RT)
    $TClient.Requests.Remove($RT.Telemetry.Name)
}
New-Alias stor Stop-TelemetryOperationRequest