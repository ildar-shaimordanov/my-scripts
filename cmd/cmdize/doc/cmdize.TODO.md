# .lua

v5.2+ only

* https://www.lua.org/manual/5.2/readme.html#changes
* https://www.lua.org/manual/5.2/manual.html#3.3.4
* https://forum.script-coding.com/viewtopic.php?pid=150252#p150252

```
::____CMD____::--[[
@echo off
lua "%~f0" %*
goto :EOF
]]
```

# .raku

* https://www.cyberforum.ru/post16775977.html
* https://perlmonks.org/index.pl?node_id=11150647

## the first attempt for Raku hybridization

```
@rem = q:to/use strict;/;
@echo off
raku -e "('no strict;' ~ (slurp shift @*ARGS)).EVAL" "%~f0" %*
goto :EOF
use strict;

say "Hello! I am Raku.";
say @*ARGS;
```

the same as above, but a bit shorter

```
@rem = q:to/use strict;/;
@echo off
raku -e "('no strict;' ~ (slurp q<%~f0>)).EVAL" %*
goto :EOF
use strict;

say "Hello! I am Raku.";
say @*ARGS;
```

## one more way to hybride Raku

In fact, everything above is a bit buggy because the command `use strict` being a heredoc marker is not executed at all. Others below are fixed and optimized versions of the above examples.

### [shift] slurp assign eval

```
@rem = q:to/=cut/;
@echo off
raku -e "my @rem = slurp shift @*ARGS; @rem.EVAL" "%~f0" %*
goto :EOF
=cut

say "Hello! I am Raku.";
say @*ARGS;
```

```
@rem = q:to/=cut/;
@echo off
raku -e "my @rem = slurp q<%~f0>; @rem.EVAL" %*
goto :EOF
=cut

say "Hello! I am Raku.";
say @*ARGS;
```

### [shift] slurp eval

```
@rem = q:to/=cut/;
@echo off
raku -e "my @rem; (slurp shift @*ARGS)).EVAL" "%~f0" %*
goto :EOF
=cut

say "Hello! I am Raku.";
say @*ARGS;
```

```
@rem = q:to/=cut/;
@echo off
raku -e "my @rem; (slurp shift q<%~f0>)).EVAL" %*
goto :EOF
=cut

say "Hello! I am Raku.";
say @*ARGS;
```

# .sql

Probably, none of SQL dialects seem able to be hybridized but they can be chimerified.

* https://forum.script-coding.com/viewtopic.php?pid=150294#p150294

```
@echo off
for /f "tokens=1 delims=:" %%n in ( 'findstr /n /r /c:"^-- SQL --" "%~f0"' ) do (
	cmd /c "for /f "usebackq skip=%%n tokens=* eol=" %%s in ( "%~f0" ) do @echo:%%s" | sqlite3 %*
	goto :EOF
)
goto :EOF
-- SQL -- [this marker means that sql statements start below]
select 1, date(), time();

-- SQL -- [nothing important; it's simply comment]
select 2, date(), time();

echo:@echo off
echo:for /f "tokens=1 delims=:" %%%%n in ( 'findstr /n /r /c:"^-- SQL --" "%%~f0"' ) do (
echo:	cmd /c "for /f "usebackq skip=%%%%n tokens=* eol=" %%%%s in ( "%%~f0" ) do @echo:%%%%s" ^| sqlite3 %%*
echo:	goto :EOF
echo:)
echo:goto :EOF
echo:-- SQL --
goto :EOF
```
