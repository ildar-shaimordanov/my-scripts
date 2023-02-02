<!-- toc-begin -->
# Table of Content
* [NAME](#name)
* [SYNOPSIS](#synopsis)
* [DESCRIPTION](#description)
  * [Capturing the certificate dates](#capturing-the-certificate-dates)
  * [Calculate the certificate age using `awk` or pure shell](#calculate-the-certificate-age-using-awk-or-pure-shell)
* [SEE ALSO](#see-also)
* [LICENSE](#license)
<!-- toc-end -->


# NAME

`sslage` - validate the domain certificate

# SYNOPSIS

    sslage [-v] HOST[:PORT]

# DESCRIPTION

* Displays the time period when the certificate is valid
* Estimates the total number of days when the certificate is valid
* Estimates the number of days left until the certificate expires


## Capturing the certificate dates

`openssl` is the standard tool for testing certificates. That's the
simplest way to find out the certificate time period.

There is the alternative way to recognize the SSL certificate
details. Calling `curl` verbosely allows us to capture the full
information about handshake and extract some details about the
certificate. If something goes wrong we show it immediately. Also
using the `-v` option we will be able to show the certificate details.


## Calculate the certificate age using `awk` or pure shell

The certificate age is estimated as the number of the whole days. So,
if today is the last day of the certificate validity, it's assumed
that the certificate is expired already. I tried to implement the
script POSIX-compliant as much as possible.

Initially it's been the shell script with `awk` inline script having
almost 50% of the script size. Later I improved it and added the
function validating the certificate age implemented in pure shell. I
decided to leave the previous `awk`-based implementation. Just for fan.


# SEE ALSO

* https://github.com/shakibamoshiri/curly
Their "check SSL date" does almost the same thing the current project
implements.

# LICENSE

Copyright 2023 Ildar Shaimordanov

    MIT License

