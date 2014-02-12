TestFixture "FormatCommandName" {
	TestSetup {
		$Parent = Split-Path (Split-Path $PSCommandPath -Parent)
		Import-Module (Join-Path $Parent "PrettyPrint\PrettyPrint.ps1") -Force
	}

	TestCase "ShouldFormatCommandName" {
		$ExpandedAst = Expand-Alias -Ast ({get-childitem}.Ast.ToString())

		$ExpandedAst | Should be "{Get-ChildItem}"
	}
}