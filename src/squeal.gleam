import argv
import filepath
import gleam/list
import gleam/result
import gleam/string
import glint
import simplifile

pub fn main() {
  glint.new()
  |> glint.pretty_help(glint.default_pretty_help())
  |> glint.add([], execute())
  |> glint.run(argv.load().arguments)
}

pub type FormatOptions {
  FormatOptions(
    tab_width: Int,
    use_tabs: Bool,
    keyword_case: Casing,
    identifier_case: Casing,
    data_type_case: Casing,
    function_case: Casing,
    indent_style: IndentStyle,
    logical_operator_new_line_before: Bool,
    expression_width: Int,
    lines_between_queries: Int,
    dense_operators: Bool,
    newline_before_semicolon: Bool,
    dialect: Dialect,
  )
}

pub const default_options = FormatOptions(
  tab_width: 2,
  use_tabs: False,
  keyword_case: Uppercase,
  identifier_case: Uppercase,
  data_type_case: Uppercase,
  function_case: Uppercase,
  indent_style: Standard,
  logical_operator_new_line_before: True,
  expression_width: 50,
  lines_between_queries: 1,
  dense_operators: False,
  newline_before_semicolon: False,
  dialect: Sql,
)

const default = default_options

pub type Casing {
  Preserve
  Uppercase
  Lowercase
}

pub fn casing_from_string(string: String) -> Result(Casing, Nil) {
  case string {
    "preserve" -> Ok(Preserve)
    "upper" -> Ok(Uppercase)
    "lower" -> Ok(Lowercase)
    _ -> Error(Nil)
  }
}

pub fn casing_to_string(casing: Casing) -> String {
  case casing {
    Preserve -> "preserve"
    Uppercase -> "upper"
    Lowercase -> "lower"
  }
}

pub type IndentStyle {
  Standard
  TabularLeft
  TabularRight
}

pub fn indent_style_from_string(string: String) -> Result(IndentStyle, Nil) {
  case string {
    "standard" -> Ok(Standard)
    "tableft" -> Ok(TabularLeft)
    "tabright" -> Ok(TabularRight)
    _ -> Error(Nil)
  }
}

pub fn indent_style_to_string(style: IndentStyle) -> String {
  case style {
    Standard -> "standard"
    TabularLeft -> "tableft"
    TabularRight -> "tabright"
  }
}

pub type Dialect {
  Sql
  Postgresql
  Sqlite
  MySql
  MariaSql
}

pub fn dialect_from_string(string: String) -> Result(Dialect, Nil) {
  case string {
    "sql" -> Ok(Sql)
    "postgresql" -> Ok(Postgresql)
    "postgres" -> Ok(Postgresql)
    "sqlite" -> Ok(Sqlite)
    "mysql" -> Ok(MySql)
    "mariasql" -> Ok(MariaSql)
    _ -> Error(Nil)
  }
}

pub fn dialect_to_string(dialect: Dialect) -> String {
  case dialect {
    Sql -> "sql"
    Postgresql -> "postgresql"
    Sqlite -> "sqlite"
    MySql -> "mysql"
    MariaSql -> "mariasql"
  }
}

@external(javascript, "./squeal_ffi.mjs", "format")
pub fn format(sql: String, options: FormatOptions) -> String

// CLI

fn execute() -> glint.Command(Nil) {
  use width <- glint.flag(width_flag())
  use tabs <- glint.flag(tabs_flag())
  use keywordcase <- glint.flag(keywordcase_flag())
  use identifiercase <- glint.flag(identifiercase_flag())
  use datatypecase <- glint.flag(datatypecase_flag())
  use functioncase <- glint.flag(functioncase_flag())
  use indentstyle <- glint.flag(indentstyle_flag())
  use logicalopnewline <- glint.flag(logicalopnewline_flag())
  use expressionwidth <- glint.flag(expressionwidth_flag())
  use linesbetween <- glint.flag(linesbetween_flag())
  use denseoperators <- glint.flag(denseoperators_flag())
  use newlinesemi <- glint.flag(newlinesemi_flag())
  use dialect <- glint.flag(dialect_flag())
  use _, _, flags <- glint.command()

  let assert Ok(width) = width(flags)
  let assert Ok(tabs) = tabs(flags)
  let assert Ok(keywordcase) =
    keywordcase(flags)
    |> result.nil_error()
    |> result.then(casing_from_string)
  let assert Ok(identifiercase) =
    identifiercase(flags)
    |> result.nil_error()
    |> result.then(casing_from_string)
  let assert Ok(datatypecase) =
    datatypecase(flags)
    |> result.nil_error()
    |> result.then(casing_from_string)
  let assert Ok(functioncase) =
    functioncase(flags)
    |> result.nil_error()
    |> result.then(casing_from_string)
  let assert Ok(indentstyle) =
    indentstyle(flags)
    |> result.nil_error()
    |> result.then(indent_style_from_string)
  let assert Ok(logicalopnewline) = logicalopnewline(flags)
  let assert Ok(expressionwidth) = expressionwidth(flags)
  let assert Ok(linesbetween) = linesbetween(flags)
  let assert Ok(denseoperators) = denseoperators(flags)
  let assert Ok(newlinesemi) = newlinesemi(flags)
  let assert Ok(dialect) =
    dialect(flags)
    |> result.nil_error()
    |> result.then(dialect_from_string)

  let options =
    FormatOptions(
      tab_width: width,
      use_tabs: tabs,
      keyword_case: keywordcase,
      identifier_case: identifiercase,
      data_type_case: datatypecase,
      function_case: functioncase,
      indent_style: indentstyle,
      logical_operator_new_line_before: logicalopnewline,
      expression_width: expressionwidth,
      lines_between_queries: linesbetween,
      dense_operators: denseoperators,
      newline_before_semicolon: newlinesemi,
      dialect: dialect,
    )

  let assert Ok(dir) = simplifile.current_directory()
  get_sql_files(dir, [])
  |> list.map(fn(file) {
    let assert Ok(content) = simplifile.read(file)
    let formatted = format(content, options)
    simplifile.write(file, formatted)
  })

  Nil
}

fn get_sql_files(dir: String, files: List(String)) -> List(String) {
  let assert Ok(contents) = simplifile.read_directory(dir)
  contents
  |> list.map(fn(path) {
    case simplifile.file_info(path) {
      Ok(info) -> Ok(#(path, info |> simplifile.file_info_type()))
      _ -> Error(Nil)
    }
  })
  |> result.values()
  |> list.map(fn(file) {
    let #(path, file_type) = file
    let full_path = filepath.join(dir, path)
    case file_type, path |> string.ends_with(".sql") {
      simplifile.File, True -> Ok([full_path, ..files])
      simplifile.Directory, _ -> Ok(get_sql_files(full_path, files))
      _, _ -> Error(Nil)
    }
  })
  |> result.values()
  |> list.flatten()
}

fn width_flag() {
  glint.int_flag("width")
  |> glint.flag_default(default.tab_width)
}

fn tabs_flag() {
  glint.bool_flag("tabs")
  |> glint.flag_default(default.use_tabs)
}

fn keywordcase_flag() {
  glint.string_flag("keywordcase")
  |> glint.flag_default("upper")
}

fn identifiercase_flag() {
  glint.string_flag("identifiercase")
  |> glint.flag_default("upper")
}

fn datatypecase_flag() {
  glint.string_flag("datatypecase")
  |> glint.flag_default("upper")
}

fn functioncase_flag() {
  glint.string_flag("functioncase")
  |> glint.flag_default("upper")
}

fn indentstyle_flag() {
  glint.string_flag("indentstyle")
  |> glint.flag_default("standard")
}

fn logicalopnewline_flag() {
  glint.bool_flag("logicalopnewline")
  |> glint.flag_default(True)
}

fn expressionwidth_flag() {
  glint.int_flag("expressionwidth")
  |> glint.flag_default(default.expression_width)
}

fn linesbetween_flag() {
  glint.int_flag("linesbetween")
  |> glint.flag_default(default.lines_between_queries)
}

fn denseoperators_flag() {
  glint.bool_flag("denseoperators")
  |> glint.flag_default(default.dense_operators)
}

fn newlinesemi_flag() {
  glint.bool_flag("newlinesemi")
  |> glint.flag_default(default.newline_before_semicolon)
}

fn dialect_flag() {
  glint.string_flag("dialect")
  |> glint.flag_default("sql")
}
