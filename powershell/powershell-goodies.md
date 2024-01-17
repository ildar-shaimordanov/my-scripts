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
$filename = ...
$string = Get-Content $filename -Raw -Encoding utf8
$bytes = [System.Text.Encoding]::UTF8.GetBytes($string)
$base64 = [System.Convert]::ToBase64String($bytes
#, [Base64FormattingOptions]::InsertLineBreaks	# to insert a line break every 76 characters
#, [Base64FormattingOptions]::None		# to not insert line breaks
)
```

base64 decoding

```powershell
$filename = ...
$base64 = Get-Content $filename -Raw
$bytes = [System.Convert]::FromBase64String($base64)
$string = [System.Text.Encoding]::UTF8.GetString($bytes) 
```

stdin to stdout

```powershell
$i = [Console]::OpenStandardInput();
$o = [Console]::OpenStandardOutput();
$i.CopyTo($o);
$i.Close();
$o.Close();
```
