BeforeAll {
Write-TestInProgress
}

Describe "Test-MFAAllUsersAllApps" -Tag "CISA", "Entra" {
  Context "MFA Shall be Enabled For All Users & All Apps - MS.AAD.3.2" {
    It "Validates MFA is enabled for all Users targeting all Apps" {
      $result = Test-MFAAllUsersAllApps
      $result | Should -Be "Pass" -Because "MFA Shall be Enabled for all Users targeting All Apps"
    }
  }
}
