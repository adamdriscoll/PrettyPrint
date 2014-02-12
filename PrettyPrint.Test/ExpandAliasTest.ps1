TestFixture "ExpandAlias" {
	TestSetup {
		$Parent = Split-Path (Split-Path $PSCommandPath -Parent)
		Import-Module (Join-Path $Parent "PrettyPrint\PrettyPrint.ps1") -Force
	}

	TestCase "ShouldExpandAlias" {
		$ExpandedAst = Expand-Alias -Ast ({dir}.Ast.ToString())

		$ExpandedAst | Should be "{Get-ChildItem}"
	}

	TestCase "ShouldExpandMultipleAliases" {
		$ExpandedAst = Expand-Alias -Ast ({dir | del}.Ast.ToString())

		$ExpandedAst | Should be "{Get-ChildItem | Remove-Item}"
	}
}