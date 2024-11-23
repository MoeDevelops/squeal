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

@external(javascript, "../squeal_ffi.mjs", "format")
pub fn format(sql: String, options: FormatOptions) -> Result(String, String)
