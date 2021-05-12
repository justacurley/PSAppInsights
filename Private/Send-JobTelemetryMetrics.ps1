Function Send-JobTelemetryMetrics {
    param(
        [parameter(Mandatory, HelpMessage = "TelemetryClient object created from New-TelemetryClient")]
        [hashtable]
        $TClient,
        $job 
        )
    #If the RSJob has an error, call .TrackException
    if ($job.HasErrors) {    
        if ($job.Error) {
            $job.Error | Foreach-Object {
                ntx -TClient $TClient $_.Exception
            }
        }
    } 
    #If Job has SessionCount or LoadIndexesCPU metric data, send it off to AI            
    elseif ($job.Output) {  
        try {
            if (($job.Output.OverburdenedBy.Count -ge 1) -and ($Null -ne $job.Output.OverburdenedBy))   {
                $job.Output.OverburdenedBy | % {        
                    $res = $TClient.TMetric.OverburdenedBy.TrackValue($_.OverburdenedBy, $_.DSG)
                }
            }
            if (($job.Output.SessionCount.Count -ge 1) -and ($Null -ne $job.Output.SessionCount)) {
                $job.Output.SessionCount | % {
                    $res = $TClient.TMetric.SessionCount.TrackValue($_.SCT, $_.DSG, $_.SRV)
                }
            }                 
            if (($job.Output.LoadIndexesCPU.Count -ge 1) -and ($Null -ne $job.Output.LoadIndexesCPU)) {
                $job.Output.LoadIndexesCPU | % {
                    $res = $TClient.TMetric.LoadIndexesCPU.TrackValue($_.CPU, $_.DSG, $_.SRV)
                }
            }
            if (($job.Output.MinutesToRegister.Count -ge 1) -and ($Null -ne $job.Output.MinutesToRegister)) {
                $job.Output.MinutesToRegister | % {
                    $res = $TClient.TMetric.MinutesToRegister.TrackValue($_.MIN, $_.DSG, $_.SRV)
                }
            }
            if (($job.Output.MinutesToUnRegister.Count -ge 1) -and ($Null -ne $job.Output.MinutesToUnRegister)) {
                $job.Output.MinutesToUnRegister | % {
                    $res = $TClient.TMetric.MinutesToUnRegister.TrackValue($_.MIN, $_.DSG, $_.SRV)
                }
            }
            if (($job.Output.HoursDeallocated.Count -ge 1) -and ($Null -ne $job.Output.HoursDeallocated)) {
                $job.Output.HoursDeallocated | % {
                    $res = $TClient.TMetric.HoursDeallocated.TrackValue($_.HRS, $_.DSG, $_.SRV)
                }
            }
            if (($job.Output.HoursRunning.Count -ge 1) -and ($Null -ne $job.Output.HoursRunning)) {
                $job.Output.HoursRunning | % {
                    $res = $TClient.TMetric.HoursRunning.TrackValue($_.HRS, $_.DSG, $_.SRV)
                }
            }
        }
        catch {
            ntx -TClient $TClient $_.Exception
        }
    }           
}