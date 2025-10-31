///|
let parser : Parser = Parser::new()

///|
pub fn parse(src : String) -> GtBuilder {
  let parser = Parser::new()
  parser.init(src)
  parser.parse() catch {
    ExpectTokens(beg, end, tokens) => {
      println("ExpectTokens from \{beg} to \{end}: \{tokens}")
      panic()
    }
  }
}
