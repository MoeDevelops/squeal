import birdie
import gleeunit
import gleeunit/should
import squeal/sql_formatter.{FormatOptions}

pub fn main() {
  gleeunit.main()
}

pub fn default_format_test() {
  sql_formatter.format(
    "selECT name, AGE FRom usErs",
    sql_formatter.default_options,
  )
  |> should.be_ok()
  |> birdie.snap("default format test")
}

pub fn format_params_success_test() {
  sql_formatter.format(
    "selECT name, AGE FRom usErs where name = $1",
    FormatOptions(
      ..sql_formatter.default_options,
      dialect: sql_formatter.Postgresql,
    ),
  )
  |> should.be_ok()
  |> birdie.snap("params success")
}

pub fn format_params_no_postgres_fail_test() {
  // The '$1' parameter syntax needs to use the postgres dialect
  sql_formatter.format(
    "selECT name, AGE FRom usErs where name = $1",
    sql_formatter.default_options,
  )
  |> should.be_error()
}

pub fn format_lower_test() {
  sql_formatter.format(
    "SELECT
  NAME,
  AGE
FROM
  USERS",
    FormatOptions(
      ..sql_formatter.default_options,
      identifier_case: sql_formatter.Lowercase,
      keyword_case: sql_formatter.Lowercase,
    ),
  )
  |> should.be_ok()
  |> birdie.snap("format lower")
}
