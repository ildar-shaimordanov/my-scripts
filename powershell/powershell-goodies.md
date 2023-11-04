minimal requirement to enable powershell execution

```cmd
powershell -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "code"
powershell -NoLogo -NoProfile -ExecutionPolicy Bypass -File filename
```

proxy settings

```powershell
$url  = ...;
$file = ...;

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12;
$w = New-Object System.Net.WebClient;
$w.Proxy.Credentials = [System.Net.CredentialCache]::DefaultNetworkCredentials;
$w.DownloadFile($url, $file)
```

convert string to byte array

```powershell
$bytes = [System.Text.Encoding]::UTF8.GetBytes($string) 
```

convert byte array to string

```powershell
$string = [System.Text.Encoding]::UTF8.GetString($bytes) 
```

base64 encoding

```powershell
$base64 = [System.Convert]::ToBase64String($bytes)
```

base64 decoding

```powershell
$bytes = [System.Convert]::FromBase64String($base64)
```

stdin to stdout

```powershell
$i = [Console]::OpenStandardInput();
$o = [Console]::OpenStandardOutput();
$i.CopyTo($o);
$i.Close();
$o.Close();
```
