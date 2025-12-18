///|
test "parse_svg/semmatsu" {
  let src =
    #|%gt /4 e0 e3 b3 /8 x b1e3- b3e5- b1e3- b3e5- b1e3 e12 b15 b13 g14
  let phrase = parse(src)
  let ir = phrase.to_IR({ top: 4, bot: H4 })
  let svg = ir.to_svg()
  @fs.write_string_to_file("semmatsu.svg", svg)
}

///|
test "parse_svg/theman" {
  let src =
    #|%gt /8 E3 d0 /4. g0 /8 d0 g0 d0 /8 E2 d0 /4. g0 /8 d0 g0 d0
  let phrase = parse(src)
  let ir = phrase.to_IR({ top: 4, bot: H4 })
  let svg = ir.to_svg()
  @fs.write_string_to_file("theman.svg", svg)
}

///|
test "parse_svg/example" {
  let src =
    #|%gt /4 e0 e3 /8 e0 x e3 /4 e3 /8 e0
  let phrase = parse(src)
  let ir = phrase.to_IR({ top: 4, bot: H4 })
  let svg = ir.to_svg()
  @fs.write_string_to_file("example.svg", svg)
}
