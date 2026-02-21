BeforeAll {
Write-TestInProgress
}

Describe "Test-BlockHighRiskUser" -Tag "CISA", "ConditionalAccess", "Done" {
  Context "There Shall be a Conditional Access Policy Blocking High Risk Users - MS.AAD.2.1" {
    It "Validates at least 1 Conditional Access Policy Blocks High Risk Users" {
      $result = Test-BlockHighRiskUser
      $result | Should -Be "Pass" -Because "High Risk Users Shall be blocked"
    }
  }
}
