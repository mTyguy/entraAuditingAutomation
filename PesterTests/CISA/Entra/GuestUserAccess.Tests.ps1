BeforeAll {
Write-TestInProgress
}

Describe "Test-GuestUserAccess" -Tag "CISA", "Entra" {
  Context "Guest users should have limited access to directory objects - MS.AAD.8.1" {
    It "Validates Guest Access Settings" {
      $result = Test-GuestUserAccess
      $result | Should -Be "Pass" -Because "Guest users should have limited access to directory objects"
    }
  }
}
