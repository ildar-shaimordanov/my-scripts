# Copy to clipboard

Cygwin

```shell
$ zcat example-270x400k.txt.gz | ( time ../clp -v )
+ eval 'cat - > /dev/clipboard'
++ cat -

real    0m5.541s
user    0m3.812s
sys     0m1.311s
```

BusyBox

```cmd
>busybox sh -c "zcat example-270x400k.txt.gz | ( time ../clp -v )"
+ eval putclip
+ putclip
+ posh '$b = @(); $i = [Console]::OpenStandardInput();' 'do { $b += @{ c = 0; d = [byte[]]::new(1048576) } }' 'while ( $b[-1].c = $i.Read($b[-1].d, 0, $b[-1].d.count) )' '$a = $b | ForEach-Object { $_.d[0..($_.c - 1)] };' '[System.Text.Encoding]::UTF8.GetString($a) | Set-Clipboard'
+ powershell -NoLogo -NoProfile -ExecutionPolicy Bypass -Command '$b = @(); $i = [Console]::OpenStandardInput(); do { $b += @{ c = 0; d = [byte[]]::new(1048576) } } while ( $b[-1].c = $i.Read($b[-1].d, 0, $b[-1].d.count) ) $a = $b | ForEach-Object { $_.d[0..($_.c - 1)] }; [System.Text.Encoding]::UTF8.GetString($a) | Set-Clipboard'
real    0m 4.74s
user    0m 0.01s
sys     0m 0.00s
```

# Copy from clipboard

Cygwin

```shell
$ time ../clp -v >/dev/null
+ eval 'cat - < /dev/clipboard'
++ cat -

real    0m0.382s
user    0m0.000s
sys     0m0.327s
```

BusyBox

```cmd
>busybox sh -c "time ../clp -v >/dev/null"
+ eval getclip
+ getclip
+ posh 'Get-Clipboard -Raw | Write-Host -NoNewLine'
+ powershell -NoLogo -NoProfile -ExecutionPolicy Bypass -Command 'Get-Clipboard -Raw | Write-Host -NoNewLine'
real    0m 0.89s
user    0m 0.01s
sys     0m 0.01s
```
