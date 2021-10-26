This document is based on this discussion on the StackOverflow [What is the ProgId or CLSID for IE9's Javascript engine (code-named "Chakra")](https://stackoverflow.com/q/7167690/3627676).

I can't answer if it works or not because I couldn't apply those recommendations due to restrictions set on my PC. Nevertheless, I keep it here to have it at hand.

Setup Chakra as JScript9:

```
Windows Registry Editor Version 5.00

[HKEY_LOCAL_MACHINE\SOFTWARE\Classes\CLSID\{16d51579-a30b-4c8b-a276-0ff4dc41e755}\ProgID]
@="JScript9"

[HKEY_LOCAL_MACHINE\SOFTWARE\Classes\Wow6432Node\CLSID\{16d51579-a30b-4c8b-a276-0ff4dc41e755}\ProgID]
@="JScript9"

[HKEY_LOCAL_MACHINE\SOFTWARE\Classes\JScript9]
@="JScript Language"

[HKEY_LOCAL_MACHINE\SOFTWARE\Classes\JScript9\CLSID]
@="{16d51579-a30b-4c8b-a276-0ff4dc41e755}"

[HKEY_LOCAL_MACHINE\SOFTWARE\Classes\JScript9\OLEScript]
```

Revert to the original settings:

```
Windows Registry Editor Version 5.00

[HKEY_LOCAL_MACHINE\SOFTWARE\Classes\CLSID\{16d51579-a30b-4c8b-a276-0ff4dc41e755}\ProgID]
@="JScript"

[HKEY_LOCAL_MACHINE\SOFTWARE\Classes\Wow6432Node\CLSID\{16d51579-a30b-4c8b-a276-0ff4dc41e755}\ProgID]
@="JScript"

[-HKEY_LOCAL_MACHINE\SOFTWARE\Classes\JScript9]
```
