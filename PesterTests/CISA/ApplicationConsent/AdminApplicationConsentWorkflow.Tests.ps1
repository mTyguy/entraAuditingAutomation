BeforeAll {
Write-TestInProgress
}

Describe "Test-AdminApplicationConsentWorkflow" -Tag "CISA", "Entra", "Done" {
  Context "Admin Application Consent Workflow" {
    It "Validates that Admin Applications workflow is configured - MS.AAD.5.3" {
      $result = Test-AdminApplicationConsentWorkflow
      $result | Should -Be "Pass" -Because "Admin Application Consent Workflow Shall be configured"
    }
  }
}
