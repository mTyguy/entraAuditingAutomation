BeforeAll {
Write-TestInProgress
}

Describe "Test-GraphExplorerAssignment" -Tag "Custom", "Entra", "Applications" {
  Context "Graph Explorer Access" {
    It "Validates that Assignment is required for MS Graph Explorer - Custom.Entra.Apps.1.02" {
      $result = Test-GraphExplorerAssignment
      $result | Should -Be "Pass" -Because "Graph Explorer Access Should be Restricted"
    }
  }
}
