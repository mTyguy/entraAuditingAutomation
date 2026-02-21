BeforeAll {
Write-TestInProgress
}

Describe "Test-BlockDeviceCodeFlow" -Tag "CISA", "ConditionalAccess", "Done" {
  Context "There Should be a Conditional Access Policy Blocking Device Code Flow Authentication - MS.AAD.3.9" {
    It "Validates at least 1 Conditional Access Policy Blocks Device Code Flow" {
      $result = Test-BlockDeviceCodeFlow
      $result | Should -Be "Pass" -Because "Device Code Flow Should be blocked"
    }
  }
}
