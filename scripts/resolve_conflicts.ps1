Param(
    [string]$Root = ".",
    [string[]]$Extensions = @("*.dart","*.yaml","*.md","*.txt")
)

Get-ChildItem -Path $Root -Recurse -Include $Extensions -File | ForEach-Object {
    $path = $_.FullName
    try {
        $text = Get-Content -Raw -Encoding UTF8 -Path $path
    } catch {
        Write-Output "Skip (read error): $path"
        return
    }
    if ($text -notmatch '<<<<<<<') { return }

    $out = ''
    $pos = 0
    while ($true) {
        $m1 = $text.IndexOf('<<<<<<<', $pos)
        if ($m1 -lt 0) { $out += $text.Substring($pos); break }
        $out += $text.Substring($pos, $m1 - $pos)
        $m2 = $text.IndexOf('=======', $m1)
        $m3 = $text.IndexOf('>>>>>>>', $m2)
        if ($m2 -lt 0 -or $m3 -lt 0) { $out += $text.Substring($m1); break }
        $start = $m2 + 7
        $len = $m3 - $start
        if ($len -gt 0) { $incoming = $text.Substring($start, $len) } else { $incoming = "" }
        $out += $incoming
        $pos = $m3 + 7
    }

    if ($out -ne $text) {
        Set-Content -Path $path -Value $out -Encoding UTF8
        Write-Output "Resolved: $path"
    }
}
