import birdie
import gleeunit
import gleeunit/should
import squeal.{FormatOptions}

pub fn main() {
  gleeunit.main()
}

pub fn default_format_test() {
  squeal.format("selECT name, AGE FRom usErs", squeal.default_options)
  |> should.be_ok()
  |> birdie.snap("default format test")
}

pub fn format_params_success_test() {
  squeal.format(
    "selECT name, AGE FRom usErs where name = $1",
    FormatOptions(..squeal.default_options, dialect: squeal.Postgresql),
  )
  |> should.be_ok()
  |> birdie.snap("params success")
}

pub fn format_params_no_postgres_fail_test() {
  // The '$1' parameter syntax needs to use the postgres dialect
  squeal.format(
    "selECT name, AGE FRom usErs where name = $1",
    squeal.default_options,
  )
  |> should.be_error()
}

pub fn format_lower_test() {
  squeal.format(
    "SELECT
  NAME,
  AGE
FROM
  USERS",
    FormatOptions(
      ..squeal.default_options,
      identifier_case: squeal.Lowercase,
      keyword_case: squeal.Lowercase,
    ),
  )
  |> should.be_ok()
  |> birdie.snap("format lower")
}
