function New-TelemetryItem {
    <#
        .SYNOPSIS
        #Expose methods to Start new telemetry Request and Dependency operations
    #>
    param(
        [parameter(Mandatory, HelpMessage = "TelemetryClient object created from New-TelemetryClient")]
        [Object]
        $TClient
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
    
     
    
            public MetricConfiguration GetMetricConfiguration(int seriesCountLimit = 10000, int valuesPerDimensionLimit = 1000, bool useIntegersOnly = false)
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
    $Type = Add-Type -TypeDefinition $Source -IgnoreWarnings -ReferencedAssemblies $Telemetry_dllPath -PassThru
        
    return [PSTelemetryHelper.TelemetryHelper]::new($TClient)
}
New-Alias nti New-TelemetryItem