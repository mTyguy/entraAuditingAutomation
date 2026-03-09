BeforeAll {
Write-TestInProgress
}

Describe "Test-GlobalAdminsCount" -Tag "CISA", "Entra" {
  Context "There Shall be between 2 and 8 Global Administrators MS.AAD.7.1" {
    It "Validates the number of assigned Global Administrators" {
      $result = Test-GlobalAdminsCount
      $result | Should -BeGreaterOrEqual "2" -Because "Shall be more than or equal to 2"
      $result | Should -BeLessOrEqual "8" -Because "Shall be less than or equal to 8"
    }
  }
}
