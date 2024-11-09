# Node power shell :


## in case other process are opened at 3000:

run this script from teh bash:

```
netstat -ano | Select-String ":3000" | ForEach-Object {
    if ($_ -match "\s+(\d+)$") {
        $procId = $matches[1]
        Try {
            Stop-Process -Id $procId -Force -ErrorAction Stop
        }
        Catch {
            Write-Output "Could not stop process ID ${procId}: $($_)"
        }
    }
}
```

