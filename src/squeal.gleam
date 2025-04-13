import argv
import filepath
import gleam/io
import gleam/list
import gleam/result
import gleam/string
import glint
import simplifile
import squeal/sql_formatter.{FormatOptions}

@internal
pub fn main() {
  glint.new()
  |> glint.pretty_help(glint.default_pretty_help())
  |> glint.add([], execute())
  |> glint.run(argv.load().arguments)
}

fn nil_error(result) {
  result.replace_error(result, Nil)
}

const default = sql_formatter.default_options

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
    |> nil_error()
    |> result.then(sql_formatter.casing_from_string)
  let assert Ok(identifiercase) =
    identifiercase(flags)
    |> nil_error()
    |> result.then(sql_formatter.casing_from_string)
  let assert Ok(datatypecase) =
    datatypecase(flags)
    |> nil_error()
    |> result.then(sql_formatter.casing_from_string)
  let assert Ok(functioncase) =
    functioncase(flags)
    |> nil_error()
    |> result.then(sql_formatter.casing_from_string)
  let assert Ok(indentstyle) =
    indentstyle(flags)
    |> nil_error()
    |> result.then(sql_formatter.indent_style_from_string)
  let assert Ok(logicalopnewline) = logicalopnewline(flags)
  let assert Ok(expressionwidth) = expressionwidth(flags)
  let assert Ok(linesbetween) = linesbetween(flags)
  let assert Ok(denseoperators) = denseoperators(flags)
  let assert Ok(newlinesemi) = newlinesemi(flags)
  let assert Ok(dialect) =
    dialect(flags)
    |> nil_error()
    |> result.then(sql_formatter.dialect_from_string)

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
    case sql_formatter.format(content, options) {
      Ok(formatted) -> simplifile.write(file, formatted)
      Error(message) -> panic as message
    }
  })

  Nil
}

fn get_sql_files(dir: String, files: List(String)) -> List(String) {
  let assert Ok(contents) = simplifile.read_directory(dir)
  contents
  |> list.map(fn(path) {
    let full_path = filepath.join(dir, path)
    let file_type = case simplifile.file_info(full_path) {
      Ok(info) -> info |> simplifile.file_info_type()
      Error(_) -> {
        io.println_error("Couldn't get file-type of '" <> full_path <> "'.")
        simplifile.Other
      }
    }

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
