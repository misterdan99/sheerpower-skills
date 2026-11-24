# Sheerpower task index: what I want to do -> the names that do it

Every name is a catalog name (catalog_index.md has its form, meaning and an example; traps.md what to
avoid).  Built from the tutorial.


## Program shape

- **start a program so a failure ends it instead of hanging** -- `option abort`, `program`, `end`, `abort`
- **end a program with an exit code** -- `abort`, `stop`, `end`
- **split a program across files** -- `%include`, `%include once:`, `%include conditional:`, `/merge`
- **name a constant / a list of named values** -- `const`, `enum`, `enum (explicit values)`, `enumname$()`, `enumvalue()`
- **make a value read-only after loading it** -- `declare freezable`, `freeze`, `unfreeze`, `permafreeze`
- **write a comment, or two statements on one line** -- `!`, `//`, `\ (statement separator)`

## Variables and types

- **declare a variable's type / a custom type** -- `declare`, `declare (custom type)`, `type`, `type format`, `declare dynamic`
- **find out what a variable holds** -- `typeof$()`, `dtype()`, `nameof$()`
- **convert between text and numbers** -- `val()`, `str$()`, `sprintf$()`, `format$()`
- **work with exact fractions, complex numbers, NaN** -- `divr()`, `fraction$()`, `numerator()`, `denominator()`, `decimal()`, `complex()`, `real()`, `imag()`, `isnan()`, `isfinite()`, `_nan`, `_inf`
- **know whether the engine rounded a value** -- `isrounded()`, `typeof$()`
- **check that two numbers agree to the cent, to n decimal places or to n significant digits; stop when a value settles** -- `near()`, `round()`
- **add to a variable, or change it by an amount** -- `+=`, `-=`, `*=`, `/=`, `^=`, `++`

## Decisions and loops

- **choose between cases** -- `if`, `elseif`, `select case`, `case is`, `case to`, `case (multiple values)`, `case else`, `select case true`
- **choose a value by a condition** -- `if expression`, `where()`
- **loop a fixed number of times** -- `for`, `for step`, `next`, `exit for`, `iterate for`, `repeat for`
- **loop until something happens** -- `do`, `do while`, `loop until`, `loop while`, `exit do`, `iterate do`, `repeat do`
- **leave, skip or repeat an OUTER loop from an inner one** -- `exit for`, `iterate for`, `repeat for`, `do named`, `exit do`, `iterate do`, `repeat do`
- **run a block once with a way to retry it** -- `do ... end do`, `repeat do`
- **leave a routine early / only continue if a condition holds** -- `exit routine`, `guard`

## Routines

- **write and call a routine** -- `routine`, `routine with`, `routine with returning`, `routine call`, `end routine`
- **call a routine as a function / in a pipeline** -- `routine call (function form)`, `|> (pipe into routine)`, `routine name$`
- **give a parameter a default value** -- `routine (default parameter values)`
- **pass an array or a cluster to a routine** -- `routine (array parameters)`, `routine returning array`, `routine cluster parameter`, `routine call with cluster`
- **apply a routine to every element of an array** -- `routine map`
- **keep a routine's variables to itself** -- `private routine`, `scoped routine`, `local routine`, `private`, `module`
- **run a routine only once / suspend and resume it** -- `routine once`, `yield`, `continue routine`
- **write a routine that calls itself** -- `recursive routine`, `unoptimized`

## Text

- **cut, find and compare text** -- `mid$()`, `pos()`, `contains()`, `startswith()`, `endswith()`, `between$()`, `left$()`, `right$()`, `match()`, `matchword()`, `compare()`
- **change text** -- `replace$()`, `change$()`, `trim$()`, `ltrim$()`, `rtrim$()`, `edit$()`, `ucase$()`, `lcase$()`, `reduce$()`, `unique$()`, `substring assignment`
- **split text into pieces / join pieces** -- `split()`, `join$()`, `element$()`, `elements()`, `piece$()`, `pieces()`, `getword$()`, `parse$()`
- **build text from values** -- `f$()`, `sprintf$()`, `str$()`, `lpad$()`, `rpad$()`, `cpad$()`, `repeat$()`, `space$()`, `quote$()`
- **write a multi-line text literal** -- `%text`, `%text trim`, `%end text`
- **look at a piece of a string without copying it** -- `view`, `view mid`, `view between`, `view piece`
- **regular expressions and patterns** -- `regexsearch()`, `regexreplace$()`, `pattern()`
- **encode, hash, make ids** -- `base64encode$()`, `base64decode$()`, `urlencode$()`, `urldecode$()`, `htmlencode$()`, `htmldecode$()`, `sha256$()`, `hash$()`, `uuid$()`, `_gid$`, `rndbytes$()`

## Numbers, dates and time

- **round and clip** -- `round()`, `truncate()`, `int()`, `floor()`, `ceil()`, `clamp()`, `min()`, `max()`, `mod()`, `div0()`
- **random numbers, repeatable** -- `rnd()`, `set seed`, `randomize`
- **today, now, and date arithmetic** -- `date$()`, `days()`, `seconds()`, `fulltime$()`, `time$()`, `time()`, `day$()`
- **time a piece of code** -- `start timer`, `_elapsed`
- **distance between two places** -- `geodistance()`

## Arrays

- **make an array that grows** -- `dim (*)`, `array append (*)`, `x(*) = v`, `size()`
- **load, slice, mask and gather** -- `fill`, `fill (list)`, `seq()`, `array assignment (array expression)`, `array assignment (masked store)`, `array assignment (slice store)`, `filter()`, `where()`
- **sort, deduplicate, test membership** -- `sort()`, `sortindex()`, `unique()`, `isin()`, `dim sorted`
- **reduce an array to one value** -- `stats$sum()`, `stats$mean()`, `stats$max()`, `stats$min()`, `stats$median()`, `reduce()`, `dot()`, `norm()`
- **matrices and equations** -- `matmul()`, `transpose()`, `solve()`, `determinant()`, `lstsq()`, `reshape()`, `outer()`, `stack()`
- **optimize under constraints** -- `maximize (block)`, `minimize (block)`, `maximize()`, `minimize()`, `diophantine()`
- **print an array** -- `print (array)`, `print array`, `print array: csv`

## Clusters (in-memory records and tables)

- **declare a record / a table in memory** -- `cluster`, `cluster (initial values)`, `cluster using`
- **add, change and remove rows** -- `add cluster`, `set cluster: row`, `delete from cluster`, `reset cluster`, `reset cluster all`, `copy cluster`
- **find a row or read one value by key** -- `findrow()`, `findrowby()`, `findvalue()`, `findvalue$()`, `findvalueby()`, `set cluster->field: create`, `set cluster->field: exact`
- **filter, sort and walk rows** -- `collect cluster`, `include`, `exclude`, `sort by`, `sort descending by`, `sort nocase by`, `for each`, `_extracted`, `_pointer`
- **group and count** -- `collect cluster: unique`, `collect cluster: groupmin`, `collect cluster: groupmax`
- **statistics over a field** -- `stats$*()`, `stats$sum()`, `stats$mean()`, `stats$stddev()`, `stats$percentile()`, `stats$pcorr()`
- **load and save CSV, TSV, JSON** -- `cluster input`, `cluster input (json)`, `cluster input invalid`, `cluster input columns`, `cluster output`, `print cluster all`, `json$()`, `jsonutil$()`

## Files and the web

- **read and write a text file** -- `open file`, `open file access input`, `open file access output`, `open file access append`, `line input #`, `print #`, `close`, `close all`
- **read a whole file, find files, get file facts** -- `fileinfo$()`, `findfile$()`, `filespec$()`
- **copy, move, rename, delete files** -- `copy file`, `move file`, `rename file`, `kill`
- **fetch a URL / call a REST API** -- `open file (url)`, `open file http-post://`, `open file http-post:// data`, `open file http-post:// headers`, `open file http-post:// verb`, `open file timeout`, `jsonutil$()`
- **send mail, talk over TCP / UDP** -- `open file mailto://`, `open file tcp://`, `open file udp://`
- **build a web handler** -- `open file cgi://`, `getsymbol$()`, `[[%spscript]]`, `[[expression]]`, `htmlencode$()`
- **an in-memory file** -- `open file data://`, `ask # data`

## Database tables

- **open a table and read by key** -- `open table`, `set table (key)`, `set table (partial key)`, `table(field)`, `_extracted`, `ask table: count`
- **read many rows** -- `extract table`, `extract table (key range)`, `extract table (partial key)`, `include`, `exclude`, `sort by`, `for each`, `exit extract`
- **add or change a row safely** -- `add table`, `add table: conditional`, `lock table`, `unlock table: commit`
- **table and field facts** -- `ask table`, `ask table: fields`, `ask table, field: name`, `ask table, field: datatype`

## Talking to a person (console)

- **ask for a value, a line, a key** -- `input`, `line input`, `key input`, `input prompt`, `input default`, `input valid`, `input length`, `input timeout`, `input eof`
- **what the person typed instead of an answer** -- `_exit`, `_back`, `_help`, `_terminator$`
- **a menu** -- `line input menu`, `line input menu item value`, `line input menu submenu`, `line input menu %title`, `line input menu %multi`, `line input menu %menubar`
- **a fill-in field, a form, a dialog** -- `input screen`, `line input dialogbox`, `line input dialogbox file picker`
- **messages, pauses, screen** -- `message`, `message error`, `message delay`, `delay`, `clear`, `clear area`, `print at`
- **format what is printed** -- `print`, `print using`, `sprintf$()`, `tab()`

## Errors

- **catch an exception and decide** -- `when exception in`, `use`, `end when`, `retry`, `continue`, `extype`, `extext$`, `exlabel$`, `_string$`, `exceptiontype()`, `exceptionname$()`
- **raise an exception** -- `cause exception`, `assert`
- **a handler shared by several blocks** -- `when exception use`, `handler`

## Testing and debugging

- **check a program without running it / run it unattended** -- `run 'name'`, `option test on`, `%test`, `assert`
- **see what a program is doing** -- `debug on`, `trace on`, `trace routine: on`, `stats on`, `list stats`, `debug show`, `debug all`, `show all`, `_debug`
- **compile-time switches and code generation** -- `%defined`, `%++`, `%--`, `macro`, `@macro_name`, `blueprint`, `%generate`, `%debug`, `%todo`

## The operating system and other programs

- **run a command or open a URL** -- `pass`, `pass nowait`, `pass url`, `ask system, pass`
- **settings that outlive the program** -- `set system, logical`, `ask system, logical`, `set system, symbol`, `ask system, symbol`, `set system, global`, `ask system, global increment`
- **call a DLL / evaluate text as code** -- `library`, `call`, `eval()`, `execute`
- **charts** -- `start chart`, `add chart`, `set chart`, `end chart`
- **ask an AI** -- `aichat$()`
