function New-RuleMetaData {
  [Cmdletbinding()]
  Param(
    [string]$RuleDescription,
    [string]$Result,
    [string]$Resolution,
    [string]$Controls,
    [string]$Citations,
    [string]$Framework
  )

  $htmlRuleMetaData = [PSCustomObject] [ordered] @{
    'Rule Description' = $RuleDescription
    Result             = $Result
    Resolution         = $Resolution
    Controls           = $Controls
    Citations          = $Citations
    Framework          = $Framework
  }

  return $htmlRuleMetaData

}
