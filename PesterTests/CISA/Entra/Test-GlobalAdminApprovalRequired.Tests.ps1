BeforeAll {
Write-TestInProgress
}

Describe "Test-GlobalAdminApprovalRequired" -Tag "CISA", "Entra", "Done" {
  Context "Activation of Global Administrator Rule via PIM Shall require Approval - MS.AAD.7.6" {
    It "Validates Activation of Global Admin role requires Approval" {
      $result = Test-GlobalAdminApprovalRequired
      $result | Should -Be "Pass" -Because "Activation of Global Administrator Rule via PIM Shall require Approval"
    }
  }
}
