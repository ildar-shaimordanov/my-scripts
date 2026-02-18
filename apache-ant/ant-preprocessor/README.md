# Conditional directives

Primitive preprocessor for Apache Ant implementing conditional directives
to create different versions of one product.

## SYNTAX

```
%%IF symbol
%%ENDIF symbol
```

## DESCRIPTION

The main purpose of the conditional directives is to take the control
over building the different versions of the product or tool for different
systems and environments. Using of the conditional directives allows to
keep different versions of some code together, within a single file.

The `%%IF` directive will include some code till the corresponding
`%%ENDIF` directive, if the `symbol` is defined. The symbol can be
defined in `build.xml`, other build and property files or provided via
the command line.

The `symbol` can match either string exactly or regexp (regexp matching).
The matching is controlled by the optional attribute `match-mode` to the
macro `conditional-directive-apply` that accepts one of `string` (the
default value) or `regexp`.

Nested directives are allowed.

Sometimes unbalanced directives could not be detected.

Intersections between directives are not controlled. If some directives
spread and have the common intersecting parts of code, this can lead to
unexpected results or raise a build failure.

What will happen depends on how they are intersect and which directives
are processed.

In rare cases of conflicts of the conditional directives names
with contents of your files you can redefine them by assigning new
names for the opening and closing conditional directives setting
them within `build.xml`, `build.properties` or any other way valid
for Apache Ant. There is the only main rule: you should do this
before including this file to your project. By default, if the file
`build-conditional-directive.properties` exists in the project's base
directory, it is read and applied immediately by this scenario. So you
don't need to load it explicitly.


## EXAMPLES

Example are available by the link https://github.com/ildar-shaimordanov/ant-preprocessor.


## TODO

Try to implement (if it is possible) the conditional directive `%%UNLESS`
which is opposite to `%%IF`:

```
%%UNLESS symbol
%%ENDIF symbol
```

## SEE ALSO

 * https://javacc.org/
 * https://github.com/raydac/java-comment-preprocessor
 * https://github.com/abego/jpp
 * https://sourceforge.net/projects/epptask/
 * https://sourceforge.net/projects/prebop/


## REFERENCES

 * Include a File If a Condition Is Met Inside Apache Ant fileset
   https://stackoverflow.com/q/25733759/3627676
 * ant replaceregexp, matching with variable/property
   https://stackoverflow.com/q/24135428/3627676
 * ANT Conditions task with regex match in a file
   https://stackoverflow.com/q/29953595/3627676
