BeforeAll {
Write-TestInProgress
}

Describe "Test-BlockLegacyAuthN" -Tag "CISA", "Entra" {
  Context "There Should be a Conditional Access Policy Blocking Legacy Authentication - MS.AAD.1.1" {
    It "Validates at least 1 Conditional Access Policy Blocking Legacy Authentication" {
      $result = Test-BlockLegacyAuthN
      $result | Should -Be "Pass" -Because "Legacy Authentication Shall be Blocked"
    }
  }
}
