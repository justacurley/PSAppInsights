function New-TelemetryOperation {
    <#
    .SYNOPSIS
        #Create a new Telemetry Operation. The hashtable returned will be used for all further telemetry actions. 
    .DESCRIPTION        
        #Optionally provide a Telemetry Metric configuration. 
    #>
    param(
        [parameter(Mandatory, HelpMessage = "Name for the Operation")]
        [string]$OperationName,

        [parameter(HelpMessage = "Array of Names for metrics to track")]
        [string[]]$Metrics,

        [parameter(HelpMessage = "Do not set this telemetry operation as a default parameter value")]
        [switch]$NoPSDefaultParameterValues,

        [parameter(Mandatory, HelpMessage = "TelemetryClient object created from New-TelemetryClient")]
        [string]$AppInsightsKey
    )
    $TClient = New-TelemetryClient -operationName $OperationName -AppInsightsKey $AppInsightsKey
    $TItem = New-TelemetryItem -TClient $TClient
    $GlobalVar = @{
        TelemetryClient = $TClient
        OpID            = $TClient.Context.Operation.Id
        TelemetryItem   = $TItem 
        Requests        = @{ }
    }
    if ($Metrics) {
        $GlobalVar.Add('TMetric', @{ })
        $GLobalVar.Add('TMetricConfig', $TItem.GetMetricConfiguration())        
        Foreach ($Metric in $Metrics) {
            $MetricDefinition = $Metric -Split ','
            if ($MetricDefinition.Count -eq 3) {
                $TMetric = $GlobalVar.TelemetryItem.GetMetric($MetricDefinition[0], $GlobalVar.TMetricConfig, $MetricDefinition[1], $MetricDefinition[2])
            }
            elseif ($MetricDefinition.Count -eq 2) {
                $TMetric = $GlobalVar.TelemetryItem.GetMetric($MetricDefinition[0], $GlobalVar.TMetricConfig, $MetricDefinition[1])
            }
            $GlobalVar.TMetric.Add($MetricDefinition[0], $TMetric)
        }
    }   
    if (!$NoPSDefaultParameterValues) {
        $global:PSDefaultParameterValues["*Telemetry*:TClient"] = $GlobalVar
    }
    return $GlobalVar
}
New-Alias nto New-TelemetryOperation