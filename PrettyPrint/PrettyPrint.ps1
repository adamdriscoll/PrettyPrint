function ParseAst($contents)
{
	$tokens = @()
    $errors = @()
    [System.Management.Automation.Language.Parser]::ParseInput($contents, [ref] $tokens, [ref] $errors)
}

function Expand-Alias
{
	param($AstString)

	$ast = ParseAst($AstString)

    $commands = $ast.FindAll({$args[0] -is [System.Management.Automation.Language.CommandAst]}, $true)

	$reprocess = $false
	$NewAstString = $AstString
    foreach ($command in $commands)
    {
		$alias = Get-Alias -Name $command.GetCommandName() -ErrorAction SilentlyContinue

        if ($alias -ne $null)
        {
            $astString = $ast.ToString()

            $commandElement = $command.CommandElements[0]

            $NewAstString = $NewAstString.Remove($commandElement.Extent.StartOffset, $commandElement.Extent.EndOffset - $commandElement.Extent.StartOffset)
            $NewAstString = $NewAstString.Insert($commandElement.Extent.StartOffset, $alias.Definition)

            $reprocess = $true
            break
        }
    }

    if ($reprocess) { $AstString = Expand-Alias $NewAstString }

	$AstString
}

function Format-CommandName {
	param($AstString)

	$ast = ParseAst($AstString)

    $commands = $ast.FindAll({$args[0] -is [System.Management.Automation.Language.CommandAst]}, $true)

	$reprocess = $false
	$NewAstString = $AstString
    foreach ($command in $commands)
    {
		$commandInfo = Get-Command -Name $command.GetCommandName() -ErrorAction SilentlyContinue

        if ($commandInfo -ne $null -and $commandInfo.Name -cne $command.GetCommandName())
        {
            $astString = $ast.ToString()

            $commandElement = $command.CommandElements[0]

            $NewAstString = $NewAstString.Remove($commandElement.Extent.StartOffset, $commandElement.Extent.EndOffset - $commandElement.Extent.StartOffset)
            $NewAstString = $NewAstString.Insert($commandElement.Extent.StartOffset, $commandInfo.Name)

            $reprocess = $true
            break
        }
    }

    if ($reprocess) { $AstString = Format-CommandName $NewAstString }

	$AstString
}

function Format-TypeName {
	param($AstString)

	$ast = ParseAst($AstString)

    $types = $ast.FindAll({$args[0] -is [System.Management.Automation.Language.TypeExpressionAst] -or $args[0] -is [System.Management.Automation.Language.TypeConstraintAst]}, $true)

	$reprocess = $false
	$NewAstString = $AstString
    foreach ($type in $types)
    {
		$typeName = $type.TypeName.Name
        $extent = $type.TypeName.Extent
		$FullTypeName = Invoke-Expression "$type.FullName"

        if ($FullTypeName -ne $null -and $typeName -cne $fullTypeName)
        {
            $astString = $ast.ToString()

			$NewAstString = $NewAstString.Remove($extent.StartOffset, $extent.EndOffset - $extent.StartOffset)
            $NewAstString = $NewAstString.Insert($extent.StartOffset, $fullTypeName)

            $reprocess = $true
            break
        }
    }

    if ($reprocess) { $AstString = Format-TypeName $NewAstString }

	$AstString
}

function Indent {
	param($AstString)

	$ast = ParseAst($AstString)

    $types = $ast.FindAll({$args[0] -is [System.Management.Automation.Language.ScriptBlockAst]}, $false)

	$reprocess = $false
	$NewAstString = $AstString
    foreach ($type in $types)
    {
		$typeName = $type.TypeName.Name
        $extent = $type.TypeName.Extent
		$FullTypeName = Invoke-Expression "$type.FullName"

        if ($FullTypeName -ne $null -and $typeName -cne $fullTypeName)
        {
            $astString = $ast.ToString()

			$NewAstString = $NewAstString.Remove($extent.StartOffset, $extent.EndOffset - $extent.StartOffset)
            $NewAstString = $NewAstString.Insert($extent.StartOffset, $fullTypeName)

            $reprocess = $true
            break
        }
    }

    if ($reprocess) { $AstString = Format-TypeName $NewAstString }

	$AstString
}

function Format-Script {
	param($Path, [Switch]$AsString)

	$Contents = [IO.File]::ReadAllText($Path)

	$Contents = Expand-Alias -AstString $Contents 
	$Contents = Format-CommandName -AstString $Contents
	Format-TypeName -AstString $Contents
}