function Stop-TelemetryOperation {
    <#
    .SYNOPSIS
        Doesn't actually Dispose of the Operation. Only removes the variable and clears PSDefaultParameterValues
    .DESCRIPTION        
    #>
    if ( Get-Variable -Scope Global -Name T -ErrorAction Ignore) { 
        Remove-Variable -Scope Global -Name T 
    }
    $T=$Global:PSDefaultParameterValues.GetEnumerator().Where( { $_.Name -match "\:TClient" })
    if ($T) {        
        $Global:PSDefaultParameterValues.Remove("*Telemetry*:TClient")
    }
}
New-Alias sto Stop-TelemetryOperation 