///|
test "parse::note" {
  let parser = Parser::new()
  let src =
    #|%gt /4 e0 e3 b3 /8 x b1e3- b3e5- b1e3- b3e5- b1e3 e12 b15 b13 g14
  parser.init(src)
  try parser.parse() |> println catch {
    ExpectTokens(beg, end, tokens) =>
      println("ExpectTokens from \{beg} to \{end}: \{tokens}")
  }
  println(parser.lexer.cur.off)
}
