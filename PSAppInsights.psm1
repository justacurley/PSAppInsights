function New-TelemetryItem {
    #Expose methods to Start new telemetry Request and Dependency operations
    param(
        [parameter(Mandatory, HelpMessage = "TelemetryClient object created from New-TelemetryClient")]
        [Microsoft.ApplicationInsights.TelemetryClient]
        $TClient,
        [parameter(HelpMessage = "Full paths to Microsoft.ApplicationInsights.dll and System.Diagnostics.DiagnosticSource.dll, if not using dlls in this module.")]
        [string[]]
        $dllPath
    )
    $Source = @"
    using Microsoft.ApplicationInsights;
    using Microsoft.ApplicationInsights.DataContracts;
    using Microsoft.ApplicationInsights.Extensibility;
    using Microsoft.ApplicationInsights.Metrics;
    using Microsoft.ApplicationInsights.Metrics.Extensibility;
    using System.Collections.Generic;
    using System.Linq;



    namespace PSTelemetryHelper
    {
        public class TelemetryHelper
        {
            public TelemetryClient TeleClient { get; private set; }
            public TelemetryHelper(System.Object client)
            {
                TeleClient = (TelemetryClient)client;
            }
            public IOperationHolder<RequestTelemetry> StartOperationRT(string operationName, string operationId, string parentOperationId)
            {
                return TeleClient.StartOperation<RequestTelemetry>(operationName, operationId, parentOperationId);
            }



            public IOperationHolder<DependencyTelemetry> StartOperationDT(string operationName, string operationId, string parentOperationId)
            {
                return TeleClient.StartOperation<DependencyTelemetry>(operationName, operationId, parentOperationId);
            }



            public void StopOperationRT(IOperationHolder<RequestTelemetry> operation)
            {
                TeleClient.StopOperation<RequestTelemetry>(operation);
                operation.Dispose();
            }



            public void StopOperationDT(IOperationHolder<DependencyTelemetry> operation)
            {
                TeleClient.StopOperation<DependencyTelemetry>(operation);
                operation.Dispose();
            }



            //public MetricConfiguration GetMetricConfiguration(int seriesCountLimit = 10000, IEnumerable<int> valuesPerDimensionLimit = null, bool useIntegersOnly = true)
            //{
            //    if (valuesPerDimensionLimit == null)
            //    {
            //        valuesPerDimensionLimit = new List<int>()
            //        {
            //            1000
            //        };
            //    }
            //    IMetricSeriesConfiguration seriesConfig = new MetricSeriesConfigurationForMeasurement(useIntegersOnly);
            //    return new MetricConfiguration(seriesCountLimit, valuesPerDimensionLimit, seriesConfig);
            //}



            public MetricConfiguration GetMetricConfiguration(int seriesCountLimit = 10000, int valuesPerDimensionLimit = 1000, bool useIntegersOnly = true)
            {
                IMetricSeriesConfiguration seriesConfig = new MetricSeriesConfigurationForMeasurement(useIntegersOnly);
                return new MetricConfiguration(seriesCountLimit, valuesPerDimensionLimit, seriesConfig);
            }
            public Metric GetMetric(string metricId, MetricConfiguration metricConfig = null, string dimension1Name = null, string dimension2Name = null, string dimension3Name = null, string dimension4Name = null)
            {
                if (dimension1Name == null)
                {
                    if (metricConfig == null)
                    {
                        return TeleClient.GetMetric(metricId);
                    }
                    else
                    {
                        return TeleClient.GetMetric(metricId, metricConfig);
                    }
                }
                else if (dimension2Name == null)
                {
                    if (metricConfig == null)
                    {
                        return TeleClient.GetMetric(metricId, dimension1Name);
                    }
                    else
                    {
                        return TeleClient.GetMetric(metricId, dimension1Name, metricConfig);
                    }
                }
                else if (dimension3Name == null)
                {
                    if (metricConfig == null)
                    {
                        return TeleClient.GetMetric(metricId, dimension1Name, dimension2Name);
                    }
                    else
                    {
                        return TeleClient.GetMetric(metricId, dimension1Name, dimension2Name, metricConfig);
                    }
                }
                else if (dimension4Name == null)
                {
                    if (metricConfig == null)
                    {
                        return TeleClient.GetMetric(metricId, dimension1Name, dimension2Name, dimension3Name);
                    }
                    else
                    {
                        return TeleClient.GetMetric(metricId, dimension1Name, dimension2Name, dimension3Name, metricConfig);
                    }
                }
                else
                {
                    if (metricConfig == null)
                    {
                        return TeleClient.GetMetric(metricId, dimension1Name, dimension2Name, dimension3Name, dimension4Name);
                    }
                    else
                    {
                        return TeleClient.GetMetric(metricId, dimension1Name, dimension2Name, dimension3Name, dimension4Name, metricConfig);
                    }
                }
            }
        }
    }
"@
    if ($dllPath) {
        Add-Type -TypeDefinition $Source -IgnoreWarnings -ReferencedAssemblies $dllPath
    }
    else {
        Add-Type -TypeDefinition $Source -IgnoreWarnings -ReferencedAssemblies 'Microsoft.ApplicationInsights', 'System.Diagnostics.DiagnosticSource', 'System.Runtime'
    }

    return [PSTelemetryHelper.TelemetryHelper]::new($TClient)
}
New-Alias nti New-TelemetryItem
function New-TelemetryClient {
    param (
        [parameter(Mandatory, HelpMessage = "Name of the operation, the parent of all subsequent telemetry operations.")]
        [string]
        $operationName,
        [parameter(Mandatory, HelpMessage = "Application Insights Instrumentation Key.")]
        [string]
        $AppInsightsKey,
        [parameter(HelpMessage = "Interval (in seconds) that this telemetry client will send data to App Insights. Default 10.")]
        [int]
        $SendingInterval = 10,
        [parameter(HelpMessage = "Full path to Microsoft.ApplicationInsights.dll, if not using dll in this module.")]
        [string]
        $dllPath
    )
    $aik = $appinsightskey
    $oID = (new-guid).guid.split('-')[-1]
    $sID = (new-guid).guid.split('-')[-1]
    if ($dllPath) {
        [reflection.assembly]::LoadFrom($dllPath) | out-null
    }
    #Create TelemetryClient configuration
    [Microsoft.ApplicationInsights.Extensibility.TelemetryConfiguration]::Active.InstrumentationKey = $aik
    [Microsoft.ApplicationInsights.Extensibility.TelemetryConfiguration]::Active.DisableTelemetry = $false
    [Microsoft.ApplicationInsights.Extensibility.TelemetryConfiguration]::Active.TelemetryChannel.SendingInterval = New-TimeSpan -Seconds $SendingInterval
    $config = [Microsoft.ApplicationInsights.Extensibility.TelemetryConfiguration]::Active
    $OpInit = [Microsoft.ApplicationInsights.Extensibility.OperationCorrelationTelemetryInitializer]::new()
    $config.TelemetryInitializers.Add($OpInit)
    $config.TelemetryInitializers | Where-Object { $_ -is 'Microsoft.ApplicationInsights.Extensibility.ITelemetryModule' } | % { $_.Initialise($config) }
    #Create TelemetryClient object
    $client = [Microsoft.ApplicationInsights.TelemetryClient]::new($config)
    $client.InstrumentationKey = $aik
    $client.Context.Session.Id = $sID
    $client.Context.Operation.Id = $oID
    $client.Context.Operation.Name = $operationName
    $client.Context.Device.Id = $env:COMPUTERNAME
    $client.Context.User.Id = $env:USERNAME
    return $client
}
New-Alias ntc New-TelemetryClient
function New-TelemetryOperation {
    #Create a new Telemetry Operation. The hashtable returned will be used for all further telemetry actions.
    param(
        [parameter(Mandatory, HelpMessage = "Name for the Operation")]
        [string]$OperationName,
        [parameter(HelpMessage = "Array of Names for metrics to track")]
        [string[]]$Metrics
    )
    $TClient = New-TelemetryClient -operationName $OperationName -AppInsightsKey $PSAppInsights_conf.AppInsightsKey
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
            $TMetric = $GlobalVar.TelemetryItem.GetMetric($MetricDefinition[0], $GlobalVar.TMetricConfig, $MetricDefinition[1], $MetricDefinition[2])
            $GlobalVar.TMetric.Add($MetricDefinition[0], $TMetric)
        }
    }
    $global:PSDefaultParameterValues["*Telemetry*:TClient"] = $GlobalVar
    return $GlobalVar
}
New-Alias nto New-TelemetryOperation
function New-TelemetryRequest {
    #Create a new Request to track. These sit below the parent Operation.
    param(
        [parameter(Mandatory, HelpMessage = "TelemetryClient object created from New-TelemetryClient")]
        [hashtable]
        $TClient,
        [parameter(Mandatory, HelpMessage = "Name of Request. This could be the name of the Function that will have Dependencies in it")]
        [string]
        $Name,
        [parameter(HelpMessage = "Name of the parent request, defaults to Operation ID")]
        [string]
        $ParentName
    )
    #Get
    $ParentID = $null
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
Function Stop-TelemetryOperationRequest {
    #Stop and dispose of a request
    param(
        [parameter(Mandatory, HelpMessage = "TelemetryClient object created from New-TelemetryClient")]
        [hashtable]
        $TClient,
        [parameter(Mandatory, HelpMessage = "Request object to stop")]
        [Object]
        $RT,
        [parameter(Mandatory, HelpMessage = "Was the request successful")]
        [bool]$Success,
        [parameter(HelpMessage = "Result Code of request. Defaults to 200/404 if not provided")]
        [int]$Code
    )
    $RT.Telemetry.Success = $Success
    if (!$Code) {
        If ($Success) { $Code = 200 }
        else { $Code = 404 }
    }
    $RT.Telemetry.ResponseCode = $Code
    $TClient.TelemetryItem.StopOperationRT($RT)
    # $TClient.Requests.Remove($RT.Telemetry.Name)
}
New-Alias stor Stop-TelemetryOperationRequest
Function New-TelemetryDependency {
    #Create a new Dependency to track
    param(
        [parameter(Mandatory, HelpMessage = "TelemetryClient object created from New-TelemetryClient")]
        [hashtable]
        $TClient,
        [parameter(Mandatory, HelpMessage = "The command being run (e.g. Invoke-RestMethod)")]
        [string]
        $Command,
        [parameter(Mandatory, HelpMessage = "Dependency Type (e.g. API, SQL)")]
        [string]
        $Type,
        [parameter(Mandatory, HelpMessage = "The parameter of the command being run (e.g. URI for API call)")]
        $Target,
        [parameter(Mandatory, HelpMessage = "The name of this dependencies parent Request")]
        $ParentName
    )
    $ParentID = $TClient.Requests.$ParentName.Telemetry.Id
    $DT = ($TClient.TelemetryItem.StartOperationDT($Command, $TClient.OpId, $ParentID))
    $DT.Telemetry.Context.Operation.Id = $TClient.OpId
    $DT.Telemetry.Type = $Type
    $DT.Telemetry.Target = $Target
    $DT
}
New-Alias ntd New-TelemetryDependency
function Update-TelemetryDependency {
    #Set properties of Dependency in Try or Catch block
    param(
        [parameter(Mandatory, HelpMessage = "Dependency object to set")]
        [Object]
        $DT,
        [parameter(HelpMessage = "Dependency failure settings. If not provided, dependency success settings are applied.")]
        [switch]
        $Catch,
        [parameter(HelpMessage = "Result Code of request. Defaults to 200/404 if not provided")]
        [int]$Code
    )
    if ($Catch) {
        if (!$Code) { $Code = 404 }
        $DT.Telemetry.ResultCode = $Code
        $DT.Telemetry.Success = $false
    }
    else {
        if (!$Code) { $Code = 200 }
        $DT.Telemetry.ResultCode = $Code
        $DT.Telemetry.Success = $true
    }
}
New-Alias utd Update-TelemetryDependency
Function Stop-TelemetryOperationDependency {
    #Stop and dispose of a dependency
    param(
        [parameter(Mandatory, HelpMessage = "TelemetryClient object created from New-TelemetryClient")]
        [hashtable]
        $TClient,
        [parameter(Mandatory, HelpMessage = "Dependency object to stop")]
        [Object]
        $DT
    )
    $TClient.TelemetryItem.StopOperationDT($DT)
}
New-Alias stod Stop-TelemetryOperationDependency
function New-TelemetryEvent {
    #Track an Event
    param (
        [parameter(Mandatory, HelpMessage = "TelemetryClient object created from New-TelemetryClient")]
        [hashtable]
        $TClient,
        [parameter(Mandatory, HelpMessage = "Message for Event")]
        [string]
        $message,
        [parameter(HelpMessage = "Property hashtable of [string],[string] key,value pairs")]
        [hashtable]
        $phash,
        [parameter(HelpMessage = "Property hashtable of [string],[double] key,value pairs")]
        [hashtable]
        $mhash

    )
    $dictProperties = New-Object 'system.collections.generic.dictionary[[string],[string]]'
    $dubProperties = New-Object 'system.collections.generic.dictionary[[string],[double]]'
    if ($phash) {
        foreach ($h in $PHash.GetEnumerator() ) {
            $dictProperties.Add($h.Name, $h.Value)
        }
    }
    else {
        $dictProperties = $null
    }
    if ($mhash) {
        foreach ($h in $MHash.GetEnumerator() ) {
            $dubProperties.Add($h.Name, $h.Value)
        }
    }
    else {
        $dubProperties = $null
    }
    $TClient.TelemetryClient.TrackEvent($message, $dictProperties, $dubProperties)
}
New-Alias nte New-TelemetryEvent
function New-TelemetryTrace {
    #Track Tracelogs. Use this to create a breadcrumb trail inbetween request and dependency calls
    param (
        [parameter(Mandatory, HelpMessage = "TelemetryClient object created from New-TelemetryClient")]
        [hashtable]
        $TClient,
        [parameter(Mandatory, HelpMessage = "Message for Trace")]
        [string]
        $message,
        [parameter(HelpMessage = "Severity level for Trace")]
        [validateSet('Critical', 'Warning', 'Information', 'Verbose', 'Warning', $null, '')]
        [string]
        $Severity

    )
    if (!$Severity) {
        $Severity = 'Information'
    }
    $TClient.TelemetryClient.TrackTrace($Message, $Severity)
}
New-Alias ntt New-TelemetryTrace
function New-TelemetryException {
    #Track Exceptions. There are more properties you can track aside from a system.exception
    #https://docs.microsoft.com/en-us/dotnet/api/hashtable.trackexception?view=azure-dotnet
    param (
        [parameter(Mandatory, HelpMessage = "TelemetryClient object created from New-TelemetryClient")]
        [hashtable]
        $TClient,
        [System.Exception]$Exception
    )
    $TClient.TelemetryClient.TrackException($Exception)
}
New-Alias ntx New-TelemetryException
Function Send-TelemetryData {
    #Flush telemetry client, forcing data to Application Insights.
    #Useful if you need to exit a scope before running all code.
    param(
        [parameter(Mandatory, HelpMessage = "TelemetryClient object created from New-TelemetryClient")]
        [hashtable]
        $TClient
    )
    $TClient.TelemetryClient.Flush()
}
New-Alias flush Send-TelemetryData
function newdict ($Hash) {
    $dictProperties = New-Object 'system.collections.generic.dictionary[[string],[string]]'
    foreach ($h in $Hash.GetEnumerator() ) {
        $dictProperties.Add($h.Name, $h.Value)
    }
    $dictProperties
}
Function Send-JobTelemetryMetrics {
    param(
        [parameter(Mandatory, HelpMessage = "TelemetryClient object created from New-TelemetryClient")]
        [hashtable]
        $TClient,
        $job,
        $MetricHash)
    #If the RSJob has an error, call .TrackException
    if ($job.HasErrors) {
        if ($job.Error) {
            ntx $_.Error
        }
    }
    #If Job has SessionCount or LoadIndexesCPU metric data, send it off to AI
    elseif ($job.Output) {
        if (($job.Output.SessionCount.Count -ge 1) -and ($Null -ne $job.Output.SessionCount)) {
            # Write-host -foregroundcolor cyan "$($job.Output.SessionCount.DSG)"
            $job.Output.SessionCount | % {
                $res = $MetricHash.TMetric.SessionCount.TrackValue($_.SCT, $_.DSG, $_.SRV)
            }
        }
        if (($job.Output.LoadIndexesCPU.Count -ge 1) -and ($Null -ne $job.Output.LoadIndexesCPU)) {
            $job.Output.LoadIndexesCPU | % {
                $res = $MetricHash.TMetric.LoadIndexesCPU.TrackValue($_.CPU, $_.DSG, $_.SRV)
            }
        }
    }
}

$PSAppInsights_conf = Import-PowerShellDataFile -Path $PSScriptRoot\conf.psd1
Export-ModuleMember -Variable PSAppInsights_confj -Alias *