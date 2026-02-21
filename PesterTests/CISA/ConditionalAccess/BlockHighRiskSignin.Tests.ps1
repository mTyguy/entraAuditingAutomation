BeforeAll {
Write-TestInProgress
}

Describe "Test-BlockHighRiskSignin" -Tag "CISA", "ConditionalAccess", "Done" {
  Context "There Shall be a Conditional Access Policy Blocking High Risk Signin Events - MS.AAD.2.3" {
    It "Validates at least 1 Conditional Access Policy Blocks High Risk Signin Events" {
      $result = Test-BlockHighRiskSignin
      $result | Should -Be "Pass" -Because "High Risk Signins Shall be Blocked"
    }
  }
}
