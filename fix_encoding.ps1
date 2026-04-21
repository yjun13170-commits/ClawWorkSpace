$path = 'C:\Users\hci\.openclaw\workspace\need_help.ps1'
$content = [IO.File]::ReadAllText($path)
[IO.File]::WriteAllText($path, $content, [System.Text.Encoding]::UTF8)
Write-Host "Encoding fixed"
