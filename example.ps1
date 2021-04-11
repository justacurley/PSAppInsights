function Test-Telemetry {
    $ErrorActionPreference = 'Stop'
    #Create telemetry variables for this function
    $PSStack = Get-PSCallStack | Select-Object Command, Location
    #Name of function currently running in this scope, used for Request name
    $F = $PSStack[0].Command  
    #Get the Telemetry Client hashtable. It's not using a global: in your script if it's default, right? 
    $T = $PSDefaultParameterValues.GetEnumerator().Where( { $_.Name -match "\:TClient" }).Value
    #Remove a request with this commands name, useful if you are looping the function. 
    if ($T.Requests.ContainsKey($F)) {
        flush
        $T.Requests.Remove($F)
    }
    #Create a new telemetry request, request is stored in Telemetry Client hashtable . Requests . $F
    ntt -message "Creating Request $F"
    $RT = ntr -Name $F
    $ReqSuccess = $true

    'https://www.google.com','https://github.com','https://kldfsajklfadjklasjklasfk.com' | % {
        try {
            ntt -message "Creating new dependency for $($_)"
            #Create a new telemetry dependency, dependency only exists in this variable
            $DT = ntd -Command 'Invoke-RestMethod' -Type 'GET' -Target $_ -ParentName $F
            $Result = Invoke-RestMethod -Method GET -URI $_ 
            #Update the dependency object with success values
            utd -DT $DT
        }
        catch {
            #send the caught exception 
            ntx -Exception $_.Exception
            #Update the dependency object with fail values
            utd -DT $DT -Catch
            #telemetryRequest is unsuccessful
            $ReqSuccess = $false
        }
        finally {
            ntt -message "Disposing dependency for $($_)"
            #Stop and Dispose() the telemetry dependency
            stod -DT $DT
            rv DT
        }
    }
    ntt -message "Disposing Request $F"
    #Update the request with success of fail values, and Stop and Dispose() the telemetry request    
    stor -RT $RT -Success $ReqSuccess
    #Push all telemetry data to app insights. This will happen every ten seconds by default
    flush
}
ipmo $PSScriptRoot -force -verbose
#Create a new telemetry operation. This operation will contain all of our telemetry requests, traces, exceptions, events, and dependencies
$Telemetry = New-TelemetryOperation -operationName "Test-Parameters"
#Set the value of the TClient parameter for our Telemetry functions so we don't have to provide it every time
$PSDefaultParameterValues.Add("*Telemetry*:TClient",$Telemetry)
Test-Telemetry

