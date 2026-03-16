BeforeAll {
Write-TestInProgress
}

Describe "Test-GraphCLIAssignment" -Tag "Custom", "Entra", "Applications" {
  Context "Graph Command Line Tools Access" {
    It "Validates that Assignment is required for MS Graph CLI Tools - Custom.Entra.Apps.1.01" {
      $result = Test-GraphCLIAssignment
      $result | Should -Be "Pass" -Because "Graph Command Line Tools Access Should be Restricted"
    }
  }
}
