# 🗣️ Squeal

[![Package Version](https://img.shields.io/hexpm/v/squeal)](https://hex.pm/packages/squeal)
[![Hex Docs](https://img.shields.io/badge/hex-docs-ffaff3)](https://hexdocs.pm/squeal/)

## Gleam SQL-Formatter using the js package [sql-formatter](https://github.com/sql-formatter-org/sql-formatter)

Squeal formats all `*.sql` files in your current directory and subdirectories

```sh
gleam add --dev squeal@1
gleam run -m squeal
gleam run -m squeal -- --width=4 --identifiercase=lower
```

## Flags

```
--datatypecase=preserve|upper|lower
--denseoperators=<BOOL>
--dialect=sql|postgres|sqlite|mysql|mariasql
--expressionwidth=<INT>
--functioncase=preserve|upper|lower
--identifiercase=preserve|upper|lower
--indentstyle=standard|tableft|tabright
--keywordcase=preserve|upper|lower
--linesbetween=<INT>
--logicalopnewline=<BOOL>
--newlinesemi=<BOOL>
--tabs=<BOOL>
--width=<INT>
```

## Example

SQL-File:
```sql
select * FROM users
```
Command:
```sh
gleam run -m squeal -- --width=4 --identifiercase=lower
```
SQL-File:
```sql
SELECT
    *
FROM
    users
```
Command:
```sh
gleam run -m squeal -- --width=2 --identifiercase=lower --keywordcase=lower
```
SQL-File:
```sql
select
  *
from
  users
```
