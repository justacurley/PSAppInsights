function Test-Telemetry {
    [CmdletBinding()]
    param (
        [parameter(mandatory)]
        [string]
        $uri
    )
    begin {
        $ErrorActionPreference = 'Stop'
        ###Telemetry###
        $F = $MyInvocation.MyCommand.Name
        $TimeStamp = Get-Date -f MMddhhmm
        $PSDefaultParameterValues = $Global:PSDefaultParameterValues
            if (-not $PSDefaultParameterValues['*Telemetry*:TClient'] -or $PSDefaultParameterValues['*Telemetry*:TClient'].TelemetryItem.TeleClient.Context.Operation.Name -ne "Test-Telemetry_$TimeStamp") {            
                $AppInsightsKey = '69fd389e-416e-47c3-b511-f83d22ab18ae'
                $Telemetry = nto -operationName "Test-Telemetry_$TimeStamp" -AppInsightsKey $AppInsightsKey
                ntt "Started new operation"
                #Set the value of the TClient parameter for our Telemetry functions so we don't have to provide it every time
                $PSDefaultParameterValues=@{"*Telemetry*:TClient"=$Telemetry}
            }
        #Create a new telemetry request, request is stored in Telemetry Client hashtable . Requests . $F
        $RT = New-TelemetryRequest -Name $F -CustomProperties $PSBoundParameters
        $RS = $true
        ###Telemetry###
        #Telemetry trace 
    }
    process {        
        try {
            New-TelemetryTrace -message "Creating new dependency for $uri"
            #Create a new telemetry dependency, dependency only exists in this variable
            {Invoke-WebRequest -Method Get -Uri $uri -UseBasicParsing -DisableKeepAlive} | Invoke-TelemetryDependency -Type 'GET' -Target $URI
        }
        catch {
            #send the caught exception 
            New-TelemetryException -Exception $_.Exception
            #telemetryRequest is unsuccessful
            $RS = $false
        }        
    }
    end {
        New-TelemetryTrace -message "Disposing Request $F"
        #Update the request with success of fail values, and Stop and Dispose() the telemetry request    
        Stop-TelemetryOperationRequest -RT $RT -Success $RS
        #Push all telemetry data to app insights. This will happen every ten seconds by default
        Send-TelemetryData
    }
}
ipmo 'C:\Users\acurley\source\PSAppInsights' -force -verbose
#Create a new telemetry operation. This operation will contain all of our telemetry requests, traces, exceptions, events, and dependencies
$AppInsightsKey = '69fd389e-416e-47c3-b511-f83d22ab18ae'
$TimeStamp = Get-Date -f MMddhhmm
$Telemetry = nto -operationName "Test-Telemetry_$TimeStamp" -AppInsightsKey $AppInsightsKey
#Set the value of the TClient parameter for our Telemetry functions so we don't have to provide it every time
$PSDefaultParameterValues=@{"*Telemetry*:TClient"=$Telemetry}
Test-Telemetry -uri 'https://google.com'
Test-Telemetry -uri 'https://github.com'
Test-Telemetry -uri 'https://klasqioiowmioifjweifojiowfn.com'
Stop-TelemetryOperation
