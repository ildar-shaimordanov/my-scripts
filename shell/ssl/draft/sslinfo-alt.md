# using sslage

```shell
$ sslage -v goo.gle
# Running: /usr/bin/openssl
depth=2 C = US, O = Internet Security Research Group, CN = ISRG Root X1
verify return:1
depth=1 C = US, O = Let's Encrypt, CN = R3
verify return:1
depth=0 CN = goo.gle
verify return:1
DONE
Since: May  2 23:12:41 2024 GMT
Until: Jul 31 23:12:40 2024 GMT
Days: 89
Left: 88
```

# Using keytool

```shell
$ keytool -printcert -sslserver goo.gle | sed -n '/Certificate #0/,/^$/p'
Certificate #0
====================================
Owner: CN=goo.gle
Issuer: CN=R3, O=Let's Encrypt, C=US
Serial number: 32e49fbf3c6786ea25f379ed5b127e641f5
Valid from: Fri May 03 02:12:41 MSK 2024 until: Thu Aug 01 02:12:40 MSK 2024
Certificate fingerprints:
         SHA1: 2C:E1:02:91:A2:FB:DD:6B:B2:D6:A5:04:E4:5E:C8:B7:1E:5C:B5:0C
         SHA256: E3:29:5C:1D:00:2F:E0:26:03:DF:FB:F9:49:5E:D4:30:34:B8:AB:4B:D0:21:87:C6:52:B6:0A:90:2B:4A:05:50
Signature algorithm name: SHA256withRSA
Subject Public Key Algorithm: 2048-bit RSA key
Version: 3
```

# Using powershell

For some addresses it gives something weird

```shell
powershell -ep bypass -f sslinfo-alt.ps1 goo.gle 443
Subject      : CN=bit.ly, O="Bitly, Inc.", L=New York, S=New York, C=US, SERIALNUMBER=4627013, OID.2.5.4.15=Private Org
               anization, OID.1.3.6.1.4.1.311.60.2.1.2=Delaware, OID.1.3.6.1.4.1.311.60.2.1.3=US
Issuer       : CN=DigiCert EV RSA CA G2, O=DigiCert Inc, C=US
Thumbprint   : A29E97EAE45106C67BBF11557767F58FE57AF70A
FriendlyName :
NotBefore    : 12.05.2023 03:00:00
NotAfter     : 16.05.2024 02:59:59
Extensions   : {System.Security.Cryptography.Oid, System.Security.Cryptography.Oid, System.Security.Cryptography.Oid, S
               ystem.Security.Cryptography.Oid...}
```

Based on:

* https://serverfault.com/a/820698
* https://gist.github.com/jstangroome/5945820
* https://www.powershellgallery.com/packages/TAK/1.1.0.16/Content/tak.Test-TLSConnection.ps1
* https://www.powershellgallery.com/packages/Remoting/0.2.1.4/Content/functions%5CGet-RemoteCert.ps1
