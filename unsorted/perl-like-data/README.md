# Perl-like data

Perl has a builtin feature allowing to store data blocks within a script. They are marked with the `__DATA__` and `__END__` tokens indicating the logical end of script before the actual end of file. The text following the tokens is ignored by the interpreter but get be read via the special file handler `DATA`. More details available at [perldoc/perldata](https://perldoc.perl.org/perldata#Special-Literals) and [Inline::Files](https://metacpan.org/pod/Inline::Files).

There are two implementations in Batch focusing on different aspects:

* simplicity over safety
* safety over simplicity

## Simplicity over safety

Simple usage has higher priority. Data blocks defined almost the same way as in Perl:

```
<beginning of string> __<digits, latin letters, underscore>__ <end of string>
```

But the code is not safe -- to prevent the further execution of scripts, `goto :EOF` or `exit /b` commands are required. For example:

```
call :extract_data DATA
...
goto :EOF

__DATA__
...
```

The full example is here: [](01-unsafe.bat)

## Safety over simplicity

Data blocks are defined stricter:

```
<beginning of string> goto <space> :EOF <space> & <space> :<digits, latin letters, underscore> <end of string>
```

Example:
```
call :extract_data DATA
...
goto :EOF & DATA
...
```

The full example is here: [](02-safe.bat)
