function New-TelemetryClient {
    <#
    .SYNOPSIS
        Creates and configures an App Insights Telemetry Client.
    .DESCRIPTION        
    #>
    param (
        [string]$operationName,
        [string]$AppInsightsKey
    )
    $aik = $appinsightskey    
    $oID = (new-guid).guid.split('-')[-1]
    $sID = (new-guid).guid.split('-')[-1]

    $TelemetryConfiguration = New-Object -TypeName "Microsoft.ApplicationInsights.Extensibility.TelemetryConfiguration, Microsoft.ApplicationInsights, Version=2.14.0.17971, Culture=neutral, PublicKeyToken=31bf3856ad364e35"
    $TelemetryConfiguration.InstrumentationKey = $aik
    $TelemetryConfiguration.DisableTelemetry = $false
    $TelemetryConfiguration.TelemetryChannel.SendingInterval = New-TimeSpan -Seconds 10   
    $OpInit = New-Object -TypeName "Microsoft.ApplicationInsights.Extensibility.OperationCorrelationTelemetryInitializer, Microsoft.ApplicationInsights, Version=2.14.0.17971, Culture=neutral, PublicKeyToken=31bf3856ad364e35"
    $TelemetryConfiguration.TelemetryInitializers.Add($OpInit)
    $TelemetryConfiguration.TelemetryInitializers | Where-Object { $_ -is 'Microsoft.ApplicationInsights.Extensibility.ITelemetryModule' } | % { $_.Initialise($TelemetryConfiguration) } 
    $client = New-Object -TypeName "Microsoft.ApplicationInsights.TelemetryClient, Microsoft.ApplicationInsights, Version=2.14.0.17971, Culture=neutral, PublicKeyToken=31bf3856ad364e35" -ArgumentList $TelemetryConfiguration
    $client.InstrumentationKey = $aik
    $client.Context.Session.Id = $sID
    $client.Context.Operation.Id = $oID
    $client.Context.Operation.Name = $operationName
    $client.Context.Device.Id = $env:COMPUTERNAME 
    $client.Context.User.Id = $env:USERNAME 
    return $client
}
New-Alias ntc New-TelemetryClient