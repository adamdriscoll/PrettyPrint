TestFixture "FullScriptTest" {
	TestSetup {
		$Parent = Split-Path (Split-Path $PSCommandPath -Parent)
		Import-Module (Join-Path $Parent "PrettyPrint\PrettyPrint.ps1") -Force
	}

	TestCase "ShouldReformatEntireScript" {
		$Pretty = [IO.File]::ReadAllText((Join-Path (Split-Path $PSCommandPath -Parent) "Pretty.ps1"))
		$Ugly = Join-Path  (Split-Path $PSCommandPath -Parent) "Ugly.ps1"

		Format-Script -Path $Ugly | Should be $Pretty
	}
}