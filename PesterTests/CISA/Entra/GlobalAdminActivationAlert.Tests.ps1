BeforeAll {
Write-TestInProgress
}

Describe "Test-GlobalAdminActivationAlert" -Tag "CISA", "Entra" {
  Context "Activation of Global Admin Role via PIM Shall trigger an Alert - MS.AAD.7.8" {
    It "Validates Activation of Global Admin Role will trigger an Alert" {
      $result = Test-GlobalAdminActivationAlert
      $result | Should -Be "Pass" -Because "Activation of Global Admin Role via PIM Shall trigger an Alert"
    }
  }
}
