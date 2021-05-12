function New-TelemetryRequest {
    <#
    .SYNOPSIS
        Adds a Telemtry Request operation to a Telemetry Client
    .DESCRIPTION 
        This will search for another request in the call stack. If another request exists, this request will be made the child of it.  
        #TODO Add properties parameter - optionally provide $PSBoundParameters of the function that calls this
    #>
    param(
        [parameter(Mandatory, HelpMessage = "Name of Request. This could be the name of the Function that will have Dependencies in it")]
        [string]
        $Name,
        [parameter(HelpMessage = "Name of the parent request, defaults to Operation ID")]
        [string]
        $ParentName,
        [parameter(Mandatory, HelpMessage = "TelemetryClient object created from New-TelemetryClient")]
        [hashtable]
        $TClient
    )
    $ParentID = $Tclient.OpID 
    if (!$ParentName) {
        foreach ($Command in (Get-PSCallStack)) {
            if ($TClient.Requests.Keys -Contains $Command.Command) {
                $ParentName = $Command.Command
                $ParentId=$TClient.Requests.$ParentName.Telemetry.Id
                break
            }
        }        
    }
    else {
        $ParentID = $TClient.Requests.$ParentName.Telemetry.Id
    }
    #Add the request to $TClient.Requests hashtable
    $TClient.Requests.Add($name, $TClient.TelemetryItem.StartOperationRT($Name, $TClient.OpId, $ParentID))
    #Set parent context to the operation ID
    $TClient.Requests.$name.telemetry.context.operation.id = $TClient.OpId
    $TClient.Requests.$name
}
New-Alias ntr New-TelemetryRequest