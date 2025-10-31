///|
pub enum TOKEN {
  LAURUS_ERROR
  LAURUS_EOF
  LAURUS_SPACE
  Rest
  String1
  String2
  String3
  String4
  String5
  String6
  Fret
  H1
  H2
  H4
  H8
  H16
  H32
  D1
  D2
  D4
  D8
  D16
  D32
  T1
  T2
  T4
  T8
  T16
  T32
  Slide
  Space
  Line
  Percent
  Guitar
  Lyrics
} derive(Show)

///|
suberror LexerError {
  ExpectTokens(Location, Location, Array[TOKEN])
}

///|
pub struct Location {
  mut row : Int
  mut col : Int
  mut off : Int
} derive(Show)

///|
impl Default for Location with default() {
  Location::{ row: 1, col: 0, off: 0 }
}

///|
fn Location::clone(self : Self) -> Self {
  let { row, col, off } = self
  { row, col, off }
}

///|
pub struct Lexeme {
  mut token : TOKEN
  mut beg : Location
  mut end : Location
} derive(Show)

///|
fn Lexeme::new(beg? : Location = Location::default()) -> Self {
  { token: LAURUS_ERROR, beg, end: Location::default() }
}

///|
fn Lexeme::init(self : Self) -> Unit {
  self.token = LAURUS_ERROR
  self.beg = Location::default()
}

///|
struct Lexer {
  mut src : String
  mut cur : Location
  mut lexeme : Lexeme
} derive(Show)

///|
pub fn Lexer::new(src? : String = "") -> Self {
  { src, cur: Location::default(), lexeme: Lexeme::new() }
}

///|
pub fn Lexer::init(
  self : Self,
  src : String,
  cur? : Location = Location::default(),
) -> Unit {
  self.src = src
  self.cur = cur
  self.lexeme.init()
}

///|
#inline
pub fn Lexer::cur_loc(self : Self) -> Location {
  self.cur.clone()
}

///|
pub fn Lexer::get(self : Self, lexeme : Lexeme) -> String {
  let beg = lexeme.beg
  let end = lexeme.end
  self.src.unsafe_substring(start=beg.off, end=end.off)
}

///|
fn Lexer::next(self : Self) -> Int {
  let cur_off = self.cur.off
  guard cur_off < self.src.length() else { -1 }
  match self.src[cur_off] {
    0xD800..=0xDBFF as lead => {
      let tail = self.src[cur_off + 1]
      self.cur.off += 2
      self.cur.col += 1
      (((lead & 0x3FF) << 10) | (tail & 0x3FF)) + 0x10000
    }
    0xA as c => {
      self.cur.off += 1
      self.cur.row += 1
      self.cur.col = 0
      c
    }
    _ as c => {
      self.cur.off += 1
      self.cur.col += 1
      c
    }
  }
}

///|
pub fn Lexer::skip_space(self : Self) -> Lexeme raise LexerError {
  loop 0 {
    0 => {
      self.lexeme.end = self.cur.clone()
      self.lexeme.token = LAURUS_SPACE
      break
    }
    _ => break
  }
  if self.lexeme.token is LAURUS_ERROR {
    raise ExpectTokens(self.lexeme.beg.clone(), self.cur.clone(), [LAURUS_SPACE])
  }
  let lexeme = self.lexeme
  self.cur = lexeme.end.clone()
  self.lexeme = Lexeme::new(beg=lexeme.end.clone())
  lexeme
}

///|
pub fn Lexer::scan0(self : Self) -> Lexeme raise LexerError {
  // [Percent]
  self.skip_space() |> ignore
  loop 0 {
    0 =>
      continue match self.next() {
          '%' => 1
          _ => break
        }
    1 => {
      self.lexeme.end = self.cur.clone()
      self.lexeme.token = Percent
      break
    }
    _ => break
  }
  if self.lexeme.token is LAURUS_ERROR {
    raise ExpectTokens(self.lexeme.beg.clone(), self.cur.clone(), [Percent])
  }
  let lexeme = self.lexeme
  self.cur = lexeme.end.clone()
  self.lexeme = Lexeme::new(beg=lexeme.end.clone())
  lexeme
}

///|
pub fn Lexer::scan1(self : Self) -> Lexeme raise LexerError {
  // [Guitar]
  self.skip_space() |> ignore
  loop 0 {
    0 =>
      continue match self.next() {
          'g' => 1
          _ => break
        }
    1 =>
      continue match self.next() {
          't' => 2
          _ => break
        }
    2 => {
      self.lexeme.end = self.cur.clone()
      self.lexeme.token = Guitar
      break
    }
    _ => break
  }
  if self.lexeme.token is LAURUS_ERROR {
    raise ExpectTokens(self.lexeme.beg.clone(), self.cur.clone(), [Guitar])
  }
  let lexeme = self.lexeme
  self.cur = lexeme.end.clone()
  self.lexeme = Lexeme::new(beg=lexeme.end.clone())
  lexeme
}

///|
pub fn Lexer::scan2(self : Self) -> Lexeme raise LexerError {
  // [Rest, String1, String2, String3, String4, String5, String6, H1, H2, H4, H8, H16, H32, D1, D2, D4, D8, D16, D32, T1, T2, T4, T8, T16, T32]
  self.skip_space() |> ignore
  loop 0 {
    0 =>
      continue match self.next() {
          '/' => 1
          'A' => 2
          'B' => 3
          'D' => 4
          'E' => 5
          'G' => 6
          'X' => 7
          'a' => 2
          'b' => 3
          'd' => 4
          'e' => 8
          'g' => 6
          'x' => 7
          _ => break
        }
    1 =>
      continue match self.next() {
          '1' => 9
          '2' => 10
          '3' => 11
          '4' => 12
          '8' => 13
          _ => break
        }
    2 => {
      self.lexeme.end = self.cur.clone()
      self.lexeme.token = String5
      break
    }
    3 => {
      self.lexeme.end = self.cur.clone()
      self.lexeme.token = String2
      break
    }
    4 => {
      self.lexeme.end = self.cur.clone()
      self.lexeme.token = String4
      break
    }
    5 => {
      self.lexeme.end = self.cur.clone()
      self.lexeme.token = String6
      break
    }
    6 => {
      self.lexeme.end = self.cur.clone()
      self.lexeme.token = String3
      break
    }
    7 => {
      self.lexeme.end = self.cur.clone()
      self.lexeme.token = Rest
      break
    }
    8 => {
      self.lexeme.end = self.cur.clone()
      self.lexeme.token = String1
      break
    }
    9 => {
      self.lexeme.end = self.cur.clone()
      self.lexeme.token = H1
      continue match self.next() {
          '.' => 27
          '/' => 28
          '6' => 29
          _ => break
        }
    }
    10 => {
      self.lexeme.end = self.cur.clone()
      self.lexeme.token = H2
      continue match self.next() {
          '.' => 24
          '/' => 25
          _ => break
        }
    }
    11 =>
      continue match self.next() {
          '2' => 20
          _ => break
        }
    12 => {
      self.lexeme.end = self.cur.clone()
      self.lexeme.token = H4
      continue match self.next() {
          '.' => 17
          '/' => 18
          _ => break
        }
    }
    13 => {
      self.lexeme.end = self.cur.clone()
      self.lexeme.token = H8
      continue match self.next() {
          '.' => 14
          '/' => 15
          _ => break
        }
    }
    14 => {
      self.lexeme.end = self.cur.clone()
      self.lexeme.token = D8
      break
    }
    15 =>
      continue match self.next() {
          '3' => 16
          _ => break
        }
    16 => {
      self.lexeme.end = self.cur.clone()
      self.lexeme.token = T8
      break
    }
    17 => {
      self.lexeme.end = self.cur.clone()
      self.lexeme.token = D4
      break
    }
    18 =>
      continue match self.next() {
          '3' => 19
          _ => break
        }
    19 => {
      self.lexeme.end = self.cur.clone()
      self.lexeme.token = T4
      break
    }
    20 => {
      self.lexeme.end = self.cur.clone()
      self.lexeme.token = H32
      continue match self.next() {
          '.' => 21
          '/' => 22
          _ => break
        }
    }
    21 => {
      self.lexeme.end = self.cur.clone()
      self.lexeme.token = D32
      break
    }
    22 =>
      continue match self.next() {
          '3' => 23
          _ => break
        }
    23 => {
      self.lexeme.end = self.cur.clone()
      self.lexeme.token = T32
      break
    }
    24 => {
      self.lexeme.end = self.cur.clone()
      self.lexeme.token = D2
      break
    }
    25 =>
      continue match self.next() {
          '3' => 26
          _ => break
        }
    26 => {
      self.lexeme.end = self.cur.clone()
      self.lexeme.token = T2
      break
    }
    27 => {
      self.lexeme.end = self.cur.clone()
      self.lexeme.token = D1
      break
    }
    28 =>
      continue match self.next() {
          '3' => 33
          _ => break
        }
    29 => {
      self.lexeme.end = self.cur.clone()
      self.lexeme.token = H16
      continue match self.next() {
          '.' => 30
          '/' => 31
          _ => break
        }
    }
    30 => {
      self.lexeme.end = self.cur.clone()
      self.lexeme.token = D16
      break
    }
    31 =>
      continue match self.next() {
          '3' => 32
          _ => break
        }
    32 => {
      self.lexeme.end = self.cur.clone()
      self.lexeme.token = T16
      break
    }
    33 => {
      self.lexeme.end = self.cur.clone()
      self.lexeme.token = T1
      break
    }
    _ => break
  }
  if self.lexeme.token is LAURUS_ERROR {
    raise ExpectTokens(self.lexeme.beg.clone(), self.cur.clone(), [
      Rest,
      String1,
      String2,
      String3,
      String4,
      String5,
      String6,
      H1,
      H2,
      H4,
      H8,
      H16,
      H32,
      D1,
      D2,
      D4,
      D8,
      D16,
      D32,
      T1,
      T2,
      T4,
      T8,
      T16,
      T32,
    ])
  }
  let lexeme = self.lexeme
  self.cur = lexeme.end.clone()
  self.lexeme = Lexeme::new(beg=lexeme.end.clone())
  lexeme
}

///|
pub fn Lexer::scan3(self : Self) -> Lexeme raise LexerError {
  // [LAURUS_EOF, Space]
  self.skip_space() |> ignore
  loop 0 {
    0 => {
      self.lexeme.end = self.cur.clone()
      self.lexeme.token = LAURUS_EOF
      continue match self.next() {
          ' ' => 1
          _ => break
        }
    }
    1 => {
      self.lexeme.end = self.cur.clone()
      self.lexeme.token = Space
      continue match self.next() {
          ' ' => 1
          _ => break
        }
    }
    _ => break
  }
  if self.lexeme.token is LAURUS_ERROR {
    raise ExpectTokens(self.lexeme.beg.clone(), self.cur.clone(), [
      LAURUS_EOF,
      Space,
    ])
  }
  let lexeme = self.lexeme
  self.cur = lexeme.end.clone()
  self.lexeme = Lexeme::new(beg=lexeme.end.clone())
  lexeme
}

///|
pub fn Lexer::scan4(self : Self) -> Lexeme raise LexerError {
  // [Fret]
  self.skip_space() |> ignore
  loop 0 {
    0 =>
      continue match self.next() {
          '0' => 1
          '1' => 2
          '2' => 2
          '3'..='9' => 1
          _ => break
        }
    1 => {
      self.lexeme.end = self.cur.clone()
      self.lexeme.token = Fret
      break
    }
    2 => {
      self.lexeme.end = self.cur.clone()
      self.lexeme.token = Fret
      continue match self.next() {
          '0' => 1
          '1' => 2
          '2' => 2
          '3'..='9' => 1
          _ => break
        }
    }
    _ => break
  }
  if self.lexeme.token is LAURUS_ERROR {
    raise ExpectTokens(self.lexeme.beg.clone(), self.cur.clone(), [Fret])
  }
  let lexeme = self.lexeme
  self.cur = lexeme.end.clone()
  self.lexeme = Lexeme::new(beg=lexeme.end.clone())
  lexeme
}

///|
pub fn Lexer::scan5(self : Self) -> Lexeme raise LexerError {
  // [LAURUS_EOF, String1, String2, String3, String4, String5, String6, Slide, Space]
  self.skip_space() |> ignore
  loop 0 {
    0 => {
      self.lexeme.end = self.cur.clone()
      self.lexeme.token = LAURUS_EOF
      continue match self.next() {
          ' ' => 1
          '-' => 2
          'A' => 3
          'B' => 4
          'D' => 5
          'E' => 6
          'G' => 7
          'a' => 3
          'b' => 4
          'd' => 5
          'e' => 8
          'g' => 7
          _ => break
        }
    }
    1 => {
      self.lexeme.end = self.cur.clone()
      self.lexeme.token = Space
      continue match self.next() {
          ' ' => 1
          _ => break
        }
    }
    2 => {
      self.lexeme.end = self.cur.clone()
      self.lexeme.token = Slide
      break
    }
    3 => {
      self.lexeme.end = self.cur.clone()
      self.lexeme.token = String5
      break
    }
    4 => {
      self.lexeme.end = self.cur.clone()
      self.lexeme.token = String2
      break
    }
    5 => {
      self.lexeme.end = self.cur.clone()
      self.lexeme.token = String4
      break
    }
    6 => {
      self.lexeme.end = self.cur.clone()
      self.lexeme.token = String6
      break
    }
    7 => {
      self.lexeme.end = self.cur.clone()
      self.lexeme.token = String3
      break
    }
    8 => {
      self.lexeme.end = self.cur.clone()
      self.lexeme.token = String1
      break
    }
    _ => break
  }
  if self.lexeme.token is LAURUS_ERROR {
    raise ExpectTokens(self.lexeme.beg.clone(), self.cur.clone(), [
      LAURUS_EOF,
      String1,
      String2,
      String3,
      String4,
      String5,
      String6,
      Slide,
      Space,
    ])
  }
  let lexeme = self.lexeme
  self.cur = lexeme.end.clone()
  self.lexeme = Lexeme::new(beg=lexeme.end.clone())
  lexeme
}
