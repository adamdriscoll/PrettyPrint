TestFixture "FormatTypeName" {
	TestSetup {
		$Parent = Split-Path (Split-Path $PSCommandPath -Parent)
		Import-Module (Join-Path $Parent "PrettyPrint\PrettyPrint.ps1") -Force
	}

	TestCase "ShouldMakeTypeNamesCorrectCase" {
		$ExpandedAst = Format-TypeName -Ast ({[version]}.Ast.ToString())

		$ExpandedAst | Should be "{[System.Version]}"
	}
}