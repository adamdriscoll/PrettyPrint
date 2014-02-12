Get-Process -Name 'Test'

Get-ChildItem

function TestFunc()
{
Get-Process
[System.IO.File]::Create("Test")
	$ScriptBlock = { 
		Get-ChildItem | Remove-Item

		Get-Process | Stop-Process
	}
}
