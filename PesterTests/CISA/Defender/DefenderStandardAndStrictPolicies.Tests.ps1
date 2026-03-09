BeforeAll {
Write-TestInProgress
}

Describe "Test-DefenderStandardAndStrictPolicies" -Tag "CISA", "Defender" {
  Context "Standard and Strict O365 Security Policies Shall be Enabled - MS.Defender.1.1" {
    It "Validates Standard and Strict policies are enabled" {
      $result = Test-DefenderStandardAndStrictPolicies
      $result | Should -Be "Pass" -Because "Standard and Strict O365 Security Policies Shall be Enabled"
    }
  }
}
