function Invoke-TelemetryDependency {
    <#
    .SYNOPSIS
        Receives ScritpBlock pipeline input and wraps it in telemetry dependency.
    .DESCRIPTION
        Using the AST, this will attempt to convert parameters and their supplied values from the ScriptBlock into CustomDimensions in the Telemetry Dependency. 
    #>
    [CmdletBinding()]
    param (
        [parameter(ValueFromPipeline, HelpMessage = "Scriptblock of command to be run")]
        [scriptblock]
        $InputObject,
        [parameter(HelpMessage = "Type of dependency (e.g. AzAPI, CitrixSDK)")]
        [string]
        $Type,
        [parameter(HelpMessage = "URI or Server")]
        [string]
        $Target,
        [parameter(HelpMessage = "Use this if your dependency is not running inside a function which has been decorated with telemetry code")]
        [string]
        $ParentName,
        [parameter(Mandatory, HelpMessage = "TelemetryClient object created from New-TelemetryClient")]
        [hashtable]
        $TClient
    )
    begin {
        #look up the call stack and try to find a telemetry Request in the TClient hashtable ($TClient.Requests)
        $ErrorActionPreference = 'Stop'
        $PSStack = Get-PSCallStack #| Select-Object Command, Location
        $F = $PSStack[0].Command
        $PSDefaultParameterValues = $Global:PSDefaultParameterValues
        try {
            if (!$ParentName) {
                $ParentName = $F        
                foreach ($Command in $PSStack) {
                    if ($TClient.Requests.Keys -Contains $Command.Command) {
                        $ParentName = $Command.Command                    
                        break
                    }
                }
            }
            if ($ParentName -eq $F) {
                New-TelemetryTrace -message ($PSStack | ConvertTo-Json)
                New-TelemetryTrace -Message "Invoke-TelemetryDependency could not find a parent request for $F."
            }    
        }
        catch {
            ntx $_.Exception
        }
    }    
   
    process {

        [ScriptBlock]$predicate1 = {
            param ([System.Management.Automation.Language.Ast]$Ast)
            [bool]$returnValue = $false
            if ($Ast -is [System.Management.Automation.Language.CommandAst]) {
                $returnValue = $true 
            }                
            return $returnValue
        }
        try {
            [System.Management.Automation.Language.Ast[]]$commandAst = $InputObject.Ast.FindAll($predicate1, $true)
            #Grab the first command if there are more than one (e.g. {get-thing | where-object} is two commands).
            #We only care about the first command in the pipeline, but we care about the extent of that commands parent AST object
            if ($commandAst.Count -gt 1) {
                $CommandAst = $commandAst[0]
            }
            $Command = $commandAst.CommandElements[0].Value
            $Data = $commandAst.extent.Text
            $dict = New-Object 'system.collections.generic.dictionary[[string],[string]]'
            $AstHash = @{}
            #Parse the commandAst for individual commandelements. 
            for ($i = 0; $i -lt $commandAst.CommandElements.Count; $i++) {
                $element = $commandAst.CommandElements[$i] 
                if ($AstHash.ContainsKey($element.GetHashCode())) { continue }
                else { $AstHash.Add($element.GetHashCode(), $element) }
                if ($element.Value -eq $Command) { continue }
                #Try to expand a hashtable and add each key/value pair to the dictionary
                if ($element.Splatted) {      
                    $SplatHash = $PSCmdlet.SessionState.PSVariable.GetValue($element.variablePath.UserPath)
                    # $SplatHash = Invoke-Expression -Command "`$$($element.variablePath.UserPath)"
                    if ($SplatHash) {
                        $SplatHash.GetEnumerator() | Foreach-Object {
                            $dict.Add($_.Key, $_.Value.ToString())
                        }
                    }
                    else {
                        New-TelemetryTrace -Message "Could not expand splatted variable $($element.variablePath.UserPath)"
                    }
                }
                elseif ($element.ParameterName) {
                    #switch statement with an argument
                    if ($element.ParameterName -and ($null -ne $element.Argument)) {
                        $VariableValue = $element.Argument.Extent.Text
                    } 
                    else {
                        #Assume the next element is the parameter value, add current element name and next element extent.text
                        $ParameterValue = $commandAst.CommandElements[($i + 1)]
                        #Next element is another parameter, so maybe this current parameter is a switch?
                        if ($ParameterValue -is [System.Management.Automation.Language.CommandParameterAst]) {
                            $VariableValue = $true
                        }
                        #Next element is a BareWord or Int, so no need to invoke-ex
                        elseif (($ParameterValue -is [System.Management.Automation.Language.StringConstantExpressionAst]) -or ($ParameterValue -is [System.Management.Automation.Language.ConstantExpressionAst])) {
                            $VariableValue = $ParameterValue.Extent.Text
                            $AstHash.Add($ParameterValue.GetHashCode(), $ParameterValue)
                        }
                        #Switch statement without an argument
                        elseif ($null -eq $ParameterValue) {
                            $VariableValue = $true
                        }
                        else {
                            $VariableValue = Invoke-Expression $ParameterValue.Extent.Text -ErrorAction Ignore
                            $AstHash.Add($ParameterValue.GetHashCode(), $ParameterValue)
                        }
                    }
                    if (!$VariableValue) { $VariableValue = $ParameterValue.Extent.Text }
                    $dict.Add($element.ParameterName, ($VariableValue | out-string).TrimEnd())
                }
            }            
        }
        catch {
            New-TelemetryException $_.Exception
        }
        
        #Create the dependency, add the custom properties retrieved from AST, and invoke the scriptblock
        try {
            $DT = New-TelemetryDependency -Command $command -Data $Data -Type $Type -Target $Target -ParentName $ParentName
            $dict.GetEnumerator() | Foreach-Object {                
                [void]($DT.Telemetry.Properties.TryAdd($_.Key, $_.Value))
            }
            if ($Command -ne 'Invoke-WebRequest') {
                Invoke-Command $InputObject                
                Update-TelemetryDependency $DT
            }
            else {
                [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
                $Response = Invoke-Command $InputObject 
                Update-TelemetryDependency $DT -Code $Response.StatusCode
            }
        }
        catch {
            New-TelemetryException $_.Exception
            if ($Command -ne 'Invoke-WebRequest') {          
                Update-TelemetryDependency $DT -Catch
            }
            else {
                Update-TelemetryDependency $DT -Catch -Code $_.Exception.Response.StatusCode.Value__
            }
            throw $_
        }
        finally {
            if ($Response) {
                #Return Invoke-Webrequest asif Invoke-RestMethod
                $Response.Content | ConvertFrom-Json
            }
            Stop-TelemetryOperationDependency $DT 
            Remove-Variable -Name DT
        }
    }
}
Set-Alias itd Invoke-TelemetryDependency