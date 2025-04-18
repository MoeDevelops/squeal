import {
  casing_to_string,
  indent_style_to_string,
  dialect_to_string,
} from "./squeal/sql_formatter.mjs";
import { format as jsformat } from "./sql-formatter.mjs";
import { Ok, Error } from "./gleam.mjs";

export function format(sql, options) {
  try {
    return new Ok(
      jsformat(sql, {
        tabWidth: options.tab_width,
        useTabs: options.use_tabs,
        keywordCase: casing_to_string(options.keyword_case),
        identifierCase: casing_to_string(options.identifier_case),
        dataTypeCase: casing_to_string(options.data_type_case),
        functionCase: casing_to_string(options.function_case),
        indentStyle: indent_style_to_string(options.indent_style),
        logicalOperatorNewline: options.logical_operator_new_line
          ? "before"
          : "after",
        expressionWidth: options.expression_width,
        linesBetweenQueries: options.lines_between_queries,
        denseOperators: options.dense_operators,
        newlineBeforeSemicolon: options.newline_before_semicolon,
        language: dialect_to_string(options.dialect),
      }),
    );
  } catch (ex) {
    return new Error(ex);
  }
}
