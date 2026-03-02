BeforeAll {
Write-TestInProgress
}

Describe "Test-PrivRolesActivationAlert" -Tag "CISA", "Entra", "Done" {
  Context "Activation of Highly Privileged Roles via PIM Shall trigger an Alert - MS.AAD.7.7" {
    It "Validates Activation of Highly Privileged Roles will trigger an Alert" {
      $result = Test-PrivRolesActivationAlert
      $result | Should -Be "Pass" -Because "Activation of Highly Privileged Roles via PIM Shall trigger an Alert"
    }
  }
}
