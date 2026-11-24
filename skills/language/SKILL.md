---
name: language
description: The rules for writing correct Sheerpower 4GL (sp4gl) code -- .spsrc programs and .spinc include files. Load this BEFORE writing, changing, reviewing or debugging any Sheerpower code, or answering a question about Sheerpower syntax. Sheerpower has rules of its own, and many habits from Python, C and JavaScript do not compile in it.
---

# Sheerpower: the language rules

Sheerpower 4GL is a compiled language for business programs on Windows and Linux.  `sp4gl` (`sp4gl.exe` on
Windows) compiles and runs a `.spsrc` program; `.spinc` files are pulled in with `%include`.  A compile takes
milliseconds, so compile after every change and let the compiler's messages guide the fix.

When you are unsure of a statement or function, do not guess from another language: look it up with the
**sheerpower:help** skill (a catalog of every name, with examples that were run on the engine), or write a
five-line probe program and run it.

## 1. Compile and run

- **Compile without running** -- on Windows, from PowerShell: `cmd /c "sp4gl prog.spsrc /validate 2>&1"`; from
  the Bash tool: `cmd //c "sp4gl prog.spsrc /validate 2>&1"` (Git Bash turns a plain `/c` or `/validate` into a
  file path).  On Linux: `sp4gl prog.spsrc /validate 2>&1`.  Exit code 0 = clean, 1 = errors.
- **Read the messages**: `$error |file |line |column | message`, usually followed by
  `$info | Help>> ...` or `Fix>> ...` saying exactly what to write instead.  Fix the first error first.
- **Run a program without a window, capturing what it prints**: on Windows
  `cmd /c "sp4gl prog.spsrc /headless < input.txt 2>&1"` (`< nul` when it reads nothing); on Linux
  `sp4gl prog.spsrc /headless < input.txt 2>&1` (`< /dev/null`).  Exit code 0 = it ended normally, `abort n`
  gives n, an uncaught exception gives 1 and writes `prog_error_<timestamp>.txt` beside the program (read it:
  it names the statement and the variables).
- **Always give `/validate` or `/headless` in a tool call.**  On Windows, go through cmd: sp4gl started directly
  from PowerShell or bash hands the program to a window and returns at once, printing nothing, and without either
  switch it opens a window on the user's screen.  On Linux, sp4gl runs in the shell directly; without either
  switch, and with no terminal, it prints nothing.
- **Never put a program in a temporary folder** -- `%TEMP%` on Windows; `/tmp`, `/var/tmp` or `$TMPDIR` on
  Linux: sp4gl refuses to run it there (on Windows a security dialog that looks like a hang; on Linux the line
  "Cannot run Sheerpower from a TEMPORARY folder", with exit code 0).  Use a folder in the project.
- With this plugin, every Edit or Write of a .spsrc or .spinc file is compiled for you and the errors
  come back as hook feedback: fix them before doing anything else.

## 2. Program shape

```sheerpower
! report.spsrc -- totals three readings (a one-line comment says what the program does)
option abort
total = 0
for reading_no = 1 to 3
  total += reading_no * 10
next reading_no
show_total with label$ 'Total', amount total
print 'done'

routine show_total with label$, amount
  print label$; ': '; amount
end routine
```
```output
Total:  60 
done
```

- `option abort` as the first statement: without it an uncaught exception drops into the interactive
  console and a headless run HANGS waiting for input.
- The main code comes first and ends at the first `routine`; routines follow, callers before callees.
- Comments: `!` or `//` to the end of the line, and `/* ... */` inside a line or over several lines.  No line numbers, no `main()`, no `end` needed.
- `\` joins two statements on one line (`first = 1 \ second = 2`); a colon does not.
- A statement continues onto the next line after a trailing comma -- except `print`, which continues with
  a trailing `&` (in a print, `,` and `;` already mean something).  Nothing may follow that `&`, not even a
  comment: it breaks the continuation.
- `do ... end do` (no LOOP line) runs its block ONCE; a `repeat do` inside runs it again -- a block with a retry.
- `%include '@utils.spinc'` merges a file into the program (`@` = the program's own folder); it shares the
  program's names, so a widely shared include should keep its routines in a `module`.

## 3. Names and types: the suffix is the type

| Name | Type |
|---|---|
| `total`, `price`, `rate#` | REAL -- exact decimal: 16 places after the point, 0.1 + 0.2 = 0.3 exactly |
| `name$` | string |
| `done?` | boolean (true / false, held as 1 / 0) |
| `count%` | 32-bit integer -- only for passing to routines written in another language (DLL calls) |

- Use bare REAL names for every number in an application, counts and money included.  `%` integers
  overflow (and raise) past 2,147,483,647; REAL holds 16 decimal places and up to 54 integer digits.
- `x`, `x$`, `x%`, `x?` are four different variables.  No declaration is needed: assigning creates the
  variable.  A name used but never assigned anywhere is a COMPILE error (typos are caught).
- `declare` is only for a bare name that needs another type (`declare string city`); never write
  `declare string name$` -- the suffix already says it.
- Custom types: `type real money`, then `declare money price, tax` (both money).  Values of two custom
  types cannot be added, subtracted, joined or compared (`price + width` is a compile error when `width`
  is FEET); a plain number goes with any, and `price * 3` is still money.  In a routine header the type
  comes first: `routine add_tax with money price, ...`.
- Descriptive snake_case names (`invoice_total`, not `t`); digit groups with underscores: `1_000_000`.
- Constants: `const max_rows = 500`, `const app_name$ = 'Ledger'`.  Lists of named values:
  `enum colour: red, green, blue` then `colour->green` (= 2).
- Strings use single or double quotes; there are NO backslash escapes: `chr$(10)` is a line feed,
  `chr$(9)` a tab; a quote inside is doubled (`'it''s'`) or uses the other quote (`"it's"`).

## 4. The habits that do not compile (or do not do what you expect)

| Do not write | Write |
|---|---|
| `x--` | `x -= 1` -- there is no `--`; `x += 2`, `x *= 1.5`, `x ^= 2`, `name$ += 'text'` and `x++` work, each as a statement of its own |
| `y = x++`, `a(i++)` | `x++` (or `x += 1`) on its own line, then use `x` |
| `cond ? a : b` | the IF expression: `fee = if member? then 0 else 5` -- ELSE is required, `elseif` chains, only the chosen value is worked out; a routine call or an array expression in THEN / ELSE is refused -- put it in a variable first |
| `if pos(text$, 'c') then`, `if match(list$, x$) and ready? then` | `if pos(text$, 'c') > 0 then` -- `pos()`, `match()` and `pattern()` return a position or an element number, not true / false: used bare in a test, any answer above 1 raises "Logical values must be either 0 (false) or 1 (true)" |
| `if a == b` | `if a = b then` -- one `=` assigns and compares; not-equal is `<>` (`!=` also works, `<>` is the house form) |
| `else if` | `elseif` (one word) |
| `if count then`, `if not name$ then` | `if count <> 0 then`, `if name$ = '' then` -- no implicit truthiness |
| `if divisor <> 0 and total / divisor > 2` (the left side guarding the right) | `and` / `or` work out BOTH sides, always: that still divides by zero, and a routine call or `findrow()` on the right still runs (`findrow()` moves the current row).  Guard with an IF of its own -- `if divisor <> 0 then` / `if total / divisor > 2 then ...` -- or choose with the IF expression, which works out only the chosen value.  On plain numbers `and` / `or` work bit by bit: `2 and 1` is 0 |
| `if x then print 'y'` + `end if` | a one-line IF takes no `end if`; a block IF puts its statements on the lines after `then` |
| `while c ... wend`, `while (c) {}` | `do while c ... loop`; also `do until c ... loop`, `do ... loop until c` |
| `for i = 1 to n ... next` | `next i` -- NEXT names its loop variable |
| `continue` / `break` in a loop | `iterate for` / `exit for` in a FOR; `iterate do` / `exit do` in a DO (`iterate do` repeats from the bottom, running the LOOP line's test; `repeat do` repeats from the top; `repeat for` runs the same FOR pass again) |
| `break outer` (a labelled loop), or a flag an inner loop sets to leave the outer one | name the outer loop: `exit for r` (a FOR by its counter, a FOR EACH by its cluster: `iterate for orders`); a DO is named by `do named scan` ... `loop scan`, then `exit do scan` -- `iterate` and `repeat` take a name too |
| `a \ b` or `a // b` for integer division, `a % b` | `int(a / b)`, `mod(a, b)` -- `\` joins two statements and `//` starts a comment, so `a // b` is silently just `a` |
| `pow(x, 2)`, `Math.sqrt(x)` | `x ^ 2` (`x ** 2` is the same power); `sqrt(x)` is the square ROOT (`sqr(x)` is its older name) |
| `call my_routine`, `my_routine()` | `my_routine` -- a routine is called by its name alone |
| `routine factorial`, then `factorial(n)` | `routine factorial_of` -- EVERY routine name contains an underscore; a name without one is read as an ARRAY ("Arrays require declaration before use") |
| `is_even n`, `check_it text$, returning ok?` | `is_even with number n, returning even even?` -- WITH, then each parameter's name and its value; or the function form `is_even?(n)` inside an expression |
| a plain `routine` that calls itself | `recursive routine factorial_of with n, returning result` -- only a RECURSIVE ROUTINE may call itself, and routines that call each other must all be recursive (otherwise a compile error: "A routine that calls itself must be a RECURSIVE ROUTINE"); each call gets its own fresh variables, and the caller's come back when it returns; a TAIL call (the last step calls itself and hands its answers straight back: `sum_to with n n - 1, acc acc + n, returning total total`) has no depth limit, other self-calls nest up to 100,000 routine calls and then raise the catchable MANYGOSUBS (one more raises MANYGOSUBS), a self-call that is the routine's last act has no limit; a loop is still plainer when it does the job |
| `print 'n = ' + n` | `print 'n = '; n` or `'n = ' + str$(n)` -- `+` joins strings only |
| `dim x as integer` | `dim x(10)` -- the suffix gives the type; arrays are 1-origin, an element is `x(i)` (`x[i]` works too) |
| `s$(2:4)`, `x(2:4)` for a piece | `s$[2:4]`, `x[2:4]` -- square brackets index and slice; parentheses call and index but never slice (a compile error says so) |
| `x = {1, 2, 3}`, `x = (1, 2, 3)`, `x = array(1, 2, 3)` | `x = [1, 2, 3]` -- square brackets where a value starts are an array; a new name becomes one with no `dim` |
| `person.name` for a record | `person->name$` (a cluster's field) |
| `select case` with no `case else` | always write `case else` -- no match and no CASE ELSE raises |
| `case x > 5` | `case is > 5`, `case 1 to 10`, `case 'a', 'b'`; or `select case true` with `case x > 5` |
| `try / catch / finally` | `when exception in ... use ... end when` (section 9) |
| `1,000` in code | `1_000` |

## 5. Routines

```sheerpower
option abort
price = 80
add_tax with amount price, rate 0.25, returning total total_price
print 'statement form:'; total_price
print 'function form:'; add_tax(amount = 20, rate = 0.5)
print 'default rate:'; add_tax(100)

routine add_tax with amount, rate = 0.1, returning total
  total = amount + amount * rate
end routine
```
```output
statement form: 100 
function form: 30 
default rate: 110 
```

- Header: `routine name with p1, p2$, returning r` -- a COMMA separates the `with` list from `returning`,
  in the header and at the call.
- Every routine name contains an underscore (`factorial_of`, not `factorial`).
- Statement-form call: WITH, then each parameter's NAME and then the value: `add_tax with amount price, rate
  0.25, returning total total_price` (`with amount = price` also works for with-parameters; a returning
  binding is `returning total my_var`, never `=`).  Omit the value only when the caller's variable has the
  parameter's own name.
- A routine with exactly ONE returning parameter is also a function: `add_tax(amount = 20, rate = 0.5)`;
  the first argument may be positional (`add_tax(100)`), the rest are named.  A `$` routine name returns
  a string: `routine full_name$ with first$, last$, returning name$`, called as `full_name$(...)`.  With no `with`
  parameters, or a default for every one, the call is empty parentheses: `say_hello$()`, `is_ready?()`,
  `add_fee()` -- a parameter with no default must still be given, and `()` after a variable is refused.
- `with` parameters are read-only.  Defaults: `rate = 0.1`, evaluated per call; omitting a parameter with
  no default is a compile error.  Up to 16 with + 16 returning parameters.
- Arrays pass by reference with `(*)`: `routine total_of with values(*), returning total`, called
  `total_of with values scores, returning total sum_all` -- nothing is copied.  Under `with` the array is read-only
  like any `with` parameter: an element store, an append, `fill`, `redim` or `values = ...` in the routine is a
  compile error ("Routine WITH parameters cannot be modified").  To change or grow the caller's array, pass it
  under `returning`: `routine push_it, returning values(*)`, called `push_it returning values pile` -- the routine
  works on the caller's array itself.  Clusters pass by reference by name.
- `exit routine` returns early.  A plain routine shares the program's variables; `routine name: private
  a$, b` keeps a few of its own; `private routine` or a `module ... end module` block isolates them all.
- Inside a `private routine` the program's own variables, constants and clusters are written `main$name`
  (`main$tax_rate`, `main$orders->total`); a bare name is the routine's own, so a module constant read bare is a
  compile error: "Unassigned variable: SHOW_SETTINGS$TAX_RATE".
- House style (suggested): a header comment above each routine -- a border line, the name spaced out, then
  Brief description / Expected on entry / Locals used / Results on exit.

## 6. Text

- `len(s$)`, `ucase$`, `lcase$`, `trim$` (strips everything <= space), `mid$(s$, start, length)`, slices
  `s$[2:4]` (both ends inclusive, 1-origin; `s$[*-2:*]` the last three, `s$[*:1:-1]` reversed),
  `pos(s$, find$)` (0 = not found), `contains(s$, find$)` (case-BLIND unless `exact: true`),
  `startswith`, `endswith`, `element$(list$, n)` (nth comma piece, trimmed), `split(line$, ',')` (into
  a string array: a new name becomes one by the assignment, `words$ = split(line$, ',')`, no `dim` needed), `join$(array, ', ')`, `str$(n)` (no padding), `val(s$)`, `repeat$(s$, n)`,
  `lpad$(s$, w)` / `rpad$(s$, w)`, `change$` (characters), `replace$(s$, 'old=new')` (its find side is a
  pattern).
- Formatting: `f$('[[name$]] owes [[amount]]')` evaluates each `[[expr]]` at run time (built-ins are fine
  in a slot, but not a call of your own routine: put its result in a variable first); `sprintf$('%.2m', 1234.5)` =
  `1,234.50` (`%m` comma-groups, `%10.2m` right-justifies in 10), `sprintf$('%-12s|', s$)`,
  `sprintf$('% %p', count, 'item')` pluralizes, `%t@yyyy-@mm2-@dd2` dates.
- `print a; b` puts a number in a sign slot with a space after it; `print a, b` jumps to the next zone
  (zones are 20 columns wide).  `print item$; tab(20); price` moves to column 20 (1 is the first column)
  before `price`; if the output is already past column 20, it moves to the next line, then to column 20.
  For exact spacing build the text with `str$`, `f$` or `sprintf$`.

```sheerpower
option abort
name$ = 'Ann'
balance = 1234.5
print 'tight: ['; str$(balance); ']  semicolon: ['; balance; ']'
print f$('[[name$]] owes [[sprintf$("%.2m", balance)]]')
print sprintf$('%-6s|%10.2m|', name$, balance)
words$ = split('red, green ,blue', ',')
print size(words$); '['; trim$(words$(2)); ']'
print element$('red, green ,blue', 2); ' '; contains('Hello World', 'WORLD')
```
```output
tight: [1234.5]  semicolon: [ 1234.5 ]
Ann owes 1,234.50
Ann   |  1,234.50|
 3 [green]
green  1 
```

- `%text` ... `%end text` holds a block of text verbatim (HTML, SQL): `page$ = %text`, the lines, then
  `%end text` on a line of its own.  Nothing inside is worked out -- a `[[ ]]` slot stays as written.
- A VIEW reads a piece of a string without copying it: `view token$ into data$, piece ',', match idx` makes
  `token$` the idx-th comma piece.  Once the view is used, `_integer` is -1 when there is no such piece -- end the
  loop on that, not on an empty piece (an empty piece still counts):

```sheerpower
option abort
data$ = 'red,green,blue,yellow'
for idx = 1
  view token$ into data$, piece ',', match idx
  _ = len(token$)                   // using the view resolves it and sets _integer
  if _integer = -1 then exit for    // -1: no such piece
  print idx; ': '; token$
next idx
```
```output
 1 : red
 2 : green
 3 : blue
 4 : yellow
```

## 7. Numbers and dates

- REAL is exact decimal: `0.1 + 0.2 = 0.3` is true; `/` rounds at the 16th place (`1 / 3 * 3` is
  0.9999999999999999; `divr(1, 3)` is an exact fraction when you need one).
- `int(x)` drops the fraction, `round(x, 2)` rounds half-up (2.5 -> 3), `mod(a, b)`, `abs`, `sqrt`,
  `max(a, b)`, `min(a, b)`, `rnd(n)` (1 to n).
- Dates: `date$` is today as YYYYMMDD; `days('2026-03-01')` a day number (ISO text accepted), so a span is
  `days(b$) - days(a$)`; `date$(day_number)` back to YYYYMMDD; `day$(day_number)` the weekday name;
  `fulltime$` now; `sprintf$('%t@ts')` an ISO time stamp.

## 8. Arrays and clusters

- `dim scores(10)` (1 to 10), `dim grid(3, 4)`, `dim names$(*)` expandable: `names$(*) = 'Ann'` appends;
  `size(names$)` counts; `fill scores with 7, 8, 9`; `print scores` prints the whole array.
- A name not used yet that is given a WHOLE ARRAY becomes an expandable array by that assignment, no `dim`
  needed: `evens = seq(2, 10, 2)`, `doubled = evens * 2`, `words$ = split(line$)`, `kept = scores`.  A name
  that already holds one value cannot take an array (a compile error naming its first use), and under
  `option require declare` the `dim` is still required.  Write the subscript when you mean one element:
  `best = scores` on a new name copies the whole array.
- Square brackets write an array out where a value starts: `scores = [88, 92, 75]`, `rates = [2 of base, base * 2]`
  -- the items are any expressions, worked out once, left to right; `n of value` repeats one (worked out for each element, as in `fill`); an array name or call as an item is
  joined in (`[names$, 'Zoe']`, `[0, seq(3), 99]`).  It goes anywhere an array goes: `stats$mean([88, 92, 75])`,
  `isin(codes, [3, 5, 7])`, `reshape([1, 2, 3, 4, 5, 6], 2, 3)` for a table (a list is one dimension).  One kind in
  a list -- the first item decides; `[5]` is one item, `[]` is refused (an empty array is `dim name(*)`), and so is a list inside a list -- `[[1, 2], [3, 4]]` is not a table: `stack([1, 2], [3, 4])` or `reshape()` makes one.  `fill`
  writes into an array that already exists.
- Folds: `reduce(scores, +)` (one value from a list, a row each from a grid), `scan(scores, +)` (the running
  totals); the operator is bare and may follow any array expression: `scan(seq(10), *)` is 1, 2, 6 ... 3628800.
- Whole-array work: `stats$mean(scores)`, `stats$sum`, `stats$max`, `stats$min`, `stats$median`,
  `stats$stddev`; `sort(scores)`, `filter(scores, scores > 50)`, `scores * 2`.  `stats$mean` of an EMPTY
  array raises -- check `size()` first.
- Building and picking: `seq(n)` is 1 to n and `seq(lo, hi [, step])` counts with exact steps (`seq(10, 1, -1)`
  counts down); `x[2:4]` is a slice; `unique(x)` keeps the first of each value; `isin(x, set)` is a 1 / 0 mask;
  `where(mask, a, b)` chooses element by element:

```sheerpower
option abort
print seq(5)
print seq(0, 1, 0.25)
prices = [12, 5, 12, 30, 5, 7]
print prices[2:4]
print unique(prices)
print sort(prices)
print filter(prices, isin(prices, seq(10)))
print where(prices > 10, prices, 0)
```
```output
1  2  3  4  5
   0  0.25   0.5  0.75     1
 5  12  30
12   5  30   7
 5   5   7  12  12  30
5  5  7
12   0  12  30   0   0
```
- A CLUSTER is a table of records in memory -- prefer it to parallel arrays:

```sheerpower
option abort
cluster sales: region$, amount
add cluster sales
  sales->region$ = 'East'
  sales->amount = 100
end add
add cluster sales
  sales->region$ = 'West'
  sales->amount = 250
end add
add cluster sales
  sales->region$ = 'East'
  sales->amount = 40
end add
cluster totals: region$, amount
collect cluster sales
  sort by sales->region$
end collect
for each sales
  row = findrow(totals->region$, sales->region$)
  if row = 0 then
    add cluster totals
      totals->region$ = sales->region$
    end add
  end if
  totals->amount += sales->amount
next sales
collect cluster totals
end collect
for each totals
  print totals->region$; totals->amount
next totals
```
```output
East 140 
West 250 
```

- Fields are `cluster->field`; `add cluster name` ... `end add` adds a row, one field per line inside it.  Inside a
  `collect cluster`, `for each` or `add cluster` block, `->field` with no cluster name is that block's cluster's field.
- `collect cluster name` (with optional `include cond`, `exclude cond`, `sort by expr`,
  `sort descending by expr`) must come before `for each name ... next name`; `_extracted` is the number
  collected, `size(name)` every row.  Per-row work can go inside the collect block itself.
- `findrow(c->field$, value$)` finds a row in O(1) (case-blind; 0 = not found, and a miss leaves no
  current row); `findvalue(c->key$, k$, c->wanted, default)` reads one field of the match in one call.
- `collect cluster words: unique words->word$` gives one row per distinct value, with the group's count
  in `_extracted` inside the block -- GROUP BY + COUNT in one statement.
- Loading data: `cluster input name '@data.csv', headers 1: sales` -- `name` is a KEYWORD (as in
  `open file ch: name ...`), not a place for the cluster's name; the cluster comes after the colon.  The
  file's columns fill the fields in order; TSV: `, field chr$(9)`; JSON too.  `cluster output name
  '@out.csv': sales` writes it back.

```sheerpower
option abort
open file csv_ch: name '@sample_sales.csv', access output
print #csv_ch: 'region,amount'
print #csv_ch: 'East,100'
print #csv_ch: 'West,250.5'
close #csv_ch
cluster sales: region$, amount
cluster input name '@sample_sales.csv', headers 1: sales
collect cluster sales
end collect
for each sales
  print sales->region$; ' '; sprintf$('%.2m', sales->amount)
next sales
```
```output
East 100.00
West 250.50
```
- Two `for each` loops cannot nest directly; call a routine from the outer loop and put the inner
  `for each` (over ANOTHER cluster) inside it.

## 9. Exceptions

```sheerpower
option abort
dim divisors(3)
fill divisors with 4, 0, 5
for index_no = 1 to 3
  when exception in
    print 100 / divisors(index_no)
  use
    print 'cannot divide: '; extext$
  end when
next index_no
```
```output
 25 
cannot divide: Division by zero
 20 
```

- `extype` is the number, `extext$` the message, `_string$` the detail; `exceptiontype('divby0')` names a
  type (a wrong name is a compile error); `cause exception exceptiontype('badformat')` raises one.
- Inside `use`: `retry` re-runs the failing statement, `continue` goes on after it.  Keep `use` blocks
  to assignments and prints: an exception INSIDE a use block ends the program.  A loop jump (`exit do`,
  `exit for`, `iterate for` ...) may leave a use block; it ends the exception being handled.

## 10. Files and input

```sheerpower
option abort
open file out_ch: name '@notes.txt', access output
for line_no = 1 to 3
  print #out_ch: 'line '; str$(line_no)
next line_no
close #out_ch
lines_read = 0
last_line$ = ''
open file in_ch: name '@notes.txt'
do
  line input #in_ch, eof at_end?: text$
  if at_end? then exit do
  lines_read = lines_read + 1
  last_line$ = text$
loop
close #in_ch
print lines_read; last_line$
```
```output
 3 line 3
```

- `open file ch: name '...', access output | input | update | append` (input is the default); `#ch` in
  print / line input / close, but not in open.  `@` = the program's folder.
- Reading a person's answer: use `line input 'Your name': name$` -- it takes the whole line as typed, commas
  and all, and leaves the program in control of what to do with it.  For a number, read the text and convert
  it: `line input 'How old are you': answer$` then `age = val(answer$)`.  Plain `input` is rarely the right
  choice: it splits the answer at commas (one variable given `Lee, Ann` raises "Too many input items").
  Under `/headless` the answers come from stdin, one line each, and the output shows each prompt with `? `
  and the answer echoed (`Your name? Ann`).
- `fileinfo$('@data.txt', 'contents')` reads a whole file; `findfile$('*.csv')` finds files (it hands the path back in lower case); `copy file`,
  `move file`, `rename file`, `kill` work on files.
- JSON: `jsonutil$(json$, '/city')`, `jsonutil$(json$, '/temps/0')` (JSON Pointer, 0-origin arrays);
  `json$(cluster)` writes a cluster as JSON.
- `pass 'command'` runs an operating-system command (`pass 'dir > listing.txt'` to keep what it prints -- its
  output does not come back to the program); `_integer` then holds its exit status.
- Some statements hand back a second result in `_integer`, `_real` or `_string$`: `pass` (the exit status), a
  VIEW past the last piece (`_integer` = -1), a URL open the server refused (the HTTP status in `_integer`, its
  reply in `_string$`), an exception (`_string$` the detail).  Read them in the very next statement.

## 11. Database tables

A table keeps its rows on disk.  Its statements read much like the cluster ones, but a field is
`table(field)` -- parentheses, not `->`:

```sheerpower
option abort
open table cust: name 'sheerpower:samples\customer'
extract table cust
  include cust(state) = 'CA'
  sort by cust(name)
end extract
print 'customers in CA: '; str$(_extracted)
for each cust
  print cust(custnbr); '  '; cust(name)
next cust
set table cust, field custnbr: key '11111'
if _extracted = 0 then
  print 'no customer 11111'
else
  print 'customer 11111 is '; cust(name)
end if
close table cust
```
```output
customers in CA: 5
11111  ALLEN
21670  Anywhere Travel Service
20348  MicroNet Solutions
10546  PacWest Corp.
21138  Peabody Plumbing
customer 11111 is ALLEN
```


- `open table cust: name 'path'` opens it READ ONLY (`sheerpower:` is the Sheerpower folder, `@` the program's);
  add `, access update` to change it.  `close table cust` when done.
- `extract table t ... end extract` picks the rows (`include`, `exclude`) and orders them (`sort by`);
  `for each t ... next t` walks them; `_extracted` counts them.
- `set table t, field key_field: key value$` makes one row current; `_extracted` is 0 when there is none.
- A text field is stored padded with blanks and read back WITHOUT the trailing ones: no `trim$()` is needed to
  print or compare it.  A field whose definition has a print mask prints through it (`    250.00`).
- Adding and changing rows, in a table opened with `access update`:

```sheerpower
option abort
open table cust: name '@customer', access update
add table cust
  cust(custnbr) = '90001'
  cust(name) = 'Ann Lee'
end add
set table cust, field custnbr: key '90001'
cust(balance) = cust(balance) + 25      // one statement that reads and writes the row: safe without a lock
lock table cust                         // keep the row locked across several statements
new_balance = cust(balance) * 2
cust(balance) = new_balance
unlock table cust
close table cust
```

- Assigning a field writes it to the current row.  A single statement that reads and writes the row
  (`t(f) = t(f) * 1.1`, `+=`, `++`) is safe alone: Sheerpower locks the row first and reads it again if another
  user changed it.  To hold a row across several statements, `lock table t` ... `unlock table t`.
- Keys, partial keys, ranges and table facts: **sheerpower:help** (`set table`, `extract table`, `ask table`).

## 12. The web and e-mail

- A URL is a file: `open file ch: name 'https://...'` performs a GET and the reply reads with `line input #ch`
  like any file; `jsonutil$()` picks values out of JSON.  A POST: `open file ch: name 'http-post://' +
  quote$(url$), data body$, headers hdrs$` (header lines one per line; `verb 'PUT'` changes the method);
  `ask #ch: status code` gives the HTTP status.
- A reply of 400 or more RAISES: catch it, and in the `use` block `_integer` is the status and `_string$` the
  server's reply.  For a service called many times, `set session 'api': base url$, headers h$`, then
  `open file ch: name '/v1/items', session 'api'`.

```sheerpower
option abort
api_url$ = 'https://api.example.com/v1/items/42'
when exception in
  open file api_ch: name api_url$
  reply$ = ''
  do
    line input #api_ch, eof done?: line$
    if done? then exit do
    reply$ = reply$ + line$
  loop
  close #api_ch
  print 'name: '; jsonutil$(reply$, '/name')
use
  print 'the service answered'; _integer; ': '; _string$
end when
```

- A web handler, run by SPINS (Sheerpower's web server), reads each request from a `cgi://` channel, and what it
  prints to that channel is the reply.  Follow this pattern -- never another language's web framework:

```sheerpower
option abort
open file cgi_ch: name 'cgi://WORD'      // SPINS hands it each request for /scripts/spiis.dll/word/...
do
  line input #cgi_ch: method$            // the next request -- '' when none is waiting yet
  if method$ = '' then repeat do
  word$ = getsymbol$('word')             // a value from the request
  if word$ = '' then
    print #cgi_ch: 'error,missing word'
    repeat do
  end if
  print #cgi_ch: 'success,'; ucase$(word$)
loop
```

- For an HTML reply, write the page as a `[[%spscript]]` template (**sheerpower:help** `[[%spscript]]`).
- E-mail is a file too: `open file mail_ch: name 'mailto://' + to$ + '?subject=' + subject$ + '&mailfrom=' +
  from$, access output`, print the body to it, `close #mail_ch`; the server, port, user name and password are
  more `&name=value` parameters (**sheerpower:help** `open file mailto://`).

## 13. Before you hand a program over

- It compiles clean (`/validate`), starts with `option abort`, and has run headless on real input with the
  output checked.
- No `%` integers outside DLL calls, no magic numbers (name them with `const`), descriptive names,
  `case else` in every `select case`.
- Guards first: a routine checks what must hold at its top and leaves with `exit routine`, so the main path is not
  buried in nested IFs.
- No exception handler whose only action is to print and stop.  A failure that is handed back carries a named code
  (a `const`, or `exceptiontype()`) and a message with its context -- and no secret goes into a log line.
- Data from outside (a file, a web reply, a table) is turned into the program's own cluster and field names in one
  routine; business decisions live in routines of their own, apart from the file, database and e-mail actions.
- One change does one thing: anything else noticed is left as a `%todo` line (`%todo check the discount
  boundary`) -- the compiler lists it on every build, as an `$error` line, and the build stays clean.
- ID and key fields (customer numbers, product codes, account ids) are text, never numbers: nothing does arithmetic
  on them, and text keeps their leading zeros.
- For anything not covered here, use **sheerpower:help** before writing from memory.
