///|
pub struct Span {
  beg : Location
  end : Location
  children : FixedArray[Span]
} derive(Show)

///|
#inline
fn Span::leaf(beg : Location, end : Location) -> Span {
  { beg, end, children: FixedArray::default() }
}

///|
fn Span::tree(children : FixedArray[Span]) -> Span {
  let len = children.length()
  // guard len != 0
  let beg = children[0].beg
  let end = children[len - 1].end
  { beg, end, children }
}

///|
struct Parser {
  lexer : Lexer
  state_stack : Array[Int]
  span_stack : Array[Span]
  node_stack : Array[Node]
} derive(Show)

///|
pub fn Parser::new(src? : String = "") -> Self {
  {
    lexer: Lexer::new(src~),
    state_stack: Array::new(),
    span_stack: Array::new(),
    node_stack: Array::new(),
  }
}

///|
pub fn Parser::init(
  self : Self,
  src : String,
  cur? : Location = Location::default(),
) -> Unit {
  self.lexer.init(src, cur~)
  self.state_stack.clear()
  self.node_stack.clear()
}

///|
#inline
fn Parser::shift_span(self : Self, lexeme : Lexeme) -> Unit {
  // no need to clone lexeme.beg/end because it is to be consumed.
  self.span_stack.push(Span::leaf(lexeme.beg, lexeme.end))
}

///|
#inline
fn Parser::enter_state(self : Self, state_i : Int) -> Unit {
  self.state_stack.push(state_i)
}

///|
enum Node {
  GtBuilder(GtBuilder)
  Slur(Slur)
  Array_LB_Note_RB_(Array[Note])
  Note(Note)
  UInt(UInt)
  Duration(Duration)
} derive(Show)

///|
pub fn Parser::parse(self : Self) -> GtBuilder raise LexerError {
  let mut lexeme = self.lexer.scan0()
  loop 0 {
    0 => {
      self.enter_state(0)
      continue match lexeme.token {
          Percent => { // shift
            // ignore the old lexeme
            self.shift_span(lexeme)
            lexeme = self.lexer.scan1()
            2
          }
          _ => break
        }
    }
    1 => {
      self.enter_state(1)
      continue match lexeme.token {
          Space => { // shift
            // ignore the old lexeme
            self.shift_span(lexeme)
            lexeme = self.lexer.scan2()
            4
          }
          LAURUS_EOF => { // reduce
            let span = self.span_stack[self.span_stack.length() - 1:].iter()
              |> FixedArray::from_iter
              |> Span::tree
            self.state_stack.unsafe_pop() |> ignore
            self.span_stack.unsafe_pop() |> ignore
            self.span_stack.push(span)
            guard self.node_stack.unsafe_pop() is Node::GtBuilder(x0)
            let node = x0 |> Node::GtBuilder
            self.node_stack.push(node)
            break
          }
          _ => break
        }
    }
    2 => {
      self.enter_state(2)
      continue match lexeme.token {
          Guitar => { // shift
            // ignore the old lexeme
            self.shift_span(lexeme)
            lexeme = self.lexer.scan3()
            3
          }
          _ => break
        }
    }
    3 => {
      self.enter_state(3)
      continue match lexeme.token {
          LAURUS_EOF | Space => { // reduce
            let span = self.span_stack[self.span_stack.length() - 2:].iter()
              |> FixedArray::from_iter
              |> Span::tree
            self.state_stack.unsafe_pop() |> ignore
            self.span_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.span_stack.unsafe_pop() |> ignore
            self.span_stack.push(span)
            // ignore Node [x1 : Guitar]
            // ignore Node [x0 : Percent]
            let node = GtBuilder::new() |> Node::GtBuilder
            self.node_stack.push(node)
            1
          }
          _ => break
        }
    }
    4 => {
      self.enter_state(4)
      continue match lexeme.token {
          Rest => { // shift
            // ignore the old lexeme
            self.shift_span(lexeme)
            lexeme = self.lexer.scan3()
            7
          }
          String1 => { // shift
            let node = self.lexer.get(lexeme) |> UInt::string1 |> Node::UInt
            self.node_stack.push(node)
            self.shift_span(lexeme)
            lexeme = self.lexer.scan4()
            10
          }
          String2 => { // shift
            let node = self.lexer.get(lexeme) |> UInt::string2 |> Node::UInt
            self.node_stack.push(node)
            self.shift_span(lexeme)
            lexeme = self.lexer.scan4()
            11
          }
          String3 => { // shift
            let node = self.lexer.get(lexeme) |> UInt::string3 |> Node::UInt
            self.node_stack.push(node)
            self.shift_span(lexeme)
            lexeme = self.lexer.scan4()
            12
          }
          String4 => { // shift
            let node = self.lexer.get(lexeme) |> UInt::string4 |> Node::UInt
            self.node_stack.push(node)
            self.shift_span(lexeme)
            lexeme = self.lexer.scan4()
            13
          }
          String5 => { // shift
            let node = self.lexer.get(lexeme) |> UInt::string5 |> Node::UInt
            self.node_stack.push(node)
            self.shift_span(lexeme)
            lexeme = self.lexer.scan4()
            14
          }
          String6 => { // shift
            let node = self.lexer.get(lexeme) |> UInt::string6 |> Node::UInt
            self.node_stack.push(node)
            self.shift_span(lexeme)
            lexeme = self.lexer.scan4()
            15
          }
          H1 => { // shift
            // ignore the old lexeme
            self.shift_span(lexeme)
            lexeme = self.lexer.scan3()
            16
          }
          H2 => { // shift
            // ignore the old lexeme
            self.shift_span(lexeme)
            lexeme = self.lexer.scan3()
            17
          }
          H4 => { // shift
            // ignore the old lexeme
            self.shift_span(lexeme)
            lexeme = self.lexer.scan3()
            18
          }
          H8 => { // shift
            // ignore the old lexeme
            self.shift_span(lexeme)
            lexeme = self.lexer.scan3()
            19
          }
          H16 => { // shift
            // ignore the old lexeme
            self.shift_span(lexeme)
            lexeme = self.lexer.scan3()
            20
          }
          H32 => { // shift
            // ignore the old lexeme
            self.shift_span(lexeme)
            lexeme = self.lexer.scan3()
            21
          }
          D1 => { // shift
            // ignore the old lexeme
            self.shift_span(lexeme)
            lexeme = self.lexer.scan3()
            22
          }
          D2 => { // shift
            // ignore the old lexeme
            self.shift_span(lexeme)
            lexeme = self.lexer.scan3()
            23
          }
          D4 => { // shift
            // ignore the old lexeme
            self.shift_span(lexeme)
            lexeme = self.lexer.scan3()
            24
          }
          D8 => { // shift
            // ignore the old lexeme
            self.shift_span(lexeme)
            lexeme = self.lexer.scan3()
            25
          }
          D16 => { // shift
            // ignore the old lexeme
            self.shift_span(lexeme)
            lexeme = self.lexer.scan3()
            26
          }
          D32 => { // shift
            // ignore the old lexeme
            self.shift_span(lexeme)
            lexeme = self.lexer.scan3()
            27
          }
          T1 => { // shift
            // ignore the old lexeme
            self.shift_span(lexeme)
            lexeme = self.lexer.scan3()
            28
          }
          T2 => { // shift
            // ignore the old lexeme
            self.shift_span(lexeme)
            lexeme = self.lexer.scan3()
            29
          }
          T4 => { // shift
            // ignore the old lexeme
            self.shift_span(lexeme)
            lexeme = self.lexer.scan3()
            30
          }
          T8 => { // shift
            // ignore the old lexeme
            self.shift_span(lexeme)
            lexeme = self.lexer.scan3()
            31
          }
          T16 => { // shift
            // ignore the old lexeme
            self.shift_span(lexeme)
            lexeme = self.lexer.scan3()
            32
          }
          T32 => { // shift
            // ignore the old lexeme
            self.shift_span(lexeme)
            lexeme = self.lexer.scan3()
            33
          }
          _ => break
        }
    }
    5 => {
      self.enter_state(5)
      continue match lexeme.token {
          LAURUS_EOF | Space => { // reduce
            let span = self.span_stack[self.span_stack.length() - 3:].iter()
              |> FixedArray::from_iter
              |> Span::tree
            self.state_stack.unsafe_pop() |> ignore
            self.span_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.span_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.span_stack.unsafe_pop() |> ignore
            self.span_stack.push(span)
            guard self.node_stack.unsafe_pop() is Node::Duration(x2)
            // ignore Node [x1 : Space]
            guard self.node_stack.unsafe_pop() is Node::GtBuilder(x0)
            let node = GtBuilder::set_dur(x0, x2) |> Node::GtBuilder
            self.node_stack.push(node)
            1
          }
          _ => break
        }
    }
    6 => {
      self.enter_state(6)
      continue match lexeme.token {
          String1 => { // shift
            let node = self.lexer.get(lexeme) |> UInt::string1 |> Node::UInt
            self.node_stack.push(node)
            self.shift_span(lexeme)
            lexeme = self.lexer.scan4()
            10
          }
          String2 => { // shift
            let node = self.lexer.get(lexeme) |> UInt::string2 |> Node::UInt
            self.node_stack.push(node)
            self.shift_span(lexeme)
            lexeme = self.lexer.scan4()
            11
          }
          String3 => { // shift
            let node = self.lexer.get(lexeme) |> UInt::string3 |> Node::UInt
            self.node_stack.push(node)
            self.shift_span(lexeme)
            lexeme = self.lexer.scan4()
            12
          }
          String4 => { // shift
            let node = self.lexer.get(lexeme) |> UInt::string4 |> Node::UInt
            self.node_stack.push(node)
            self.shift_span(lexeme)
            lexeme = self.lexer.scan4()
            13
          }
          String5 => { // shift
            let node = self.lexer.get(lexeme) |> UInt::string5 |> Node::UInt
            self.node_stack.push(node)
            self.shift_span(lexeme)
            lexeme = self.lexer.scan4()
            14
          }
          String6 => { // shift
            let node = self.lexer.get(lexeme) |> UInt::string6 |> Node::UInt
            self.node_stack.push(node)
            self.shift_span(lexeme)
            lexeme = self.lexer.scan4()
            15
          }
          Slide => { // shift
            // ignore the old lexeme
            self.shift_span(lexeme)
            lexeme = self.lexer.scan3()
            37
          }
          Space | LAURUS_EOF => { // reduce
            let loc = self.lexer.cur_loc()
            let span = Span::leaf(loc, loc)
            self.span_stack.push(span)
            let node = Slur::Normal |> Node::Slur
            self.node_stack.push(node)
            35
          }
          _ => break
        }
    }
    7 => {
      self.enter_state(7)
      continue match lexeme.token {
          LAURUS_EOF | Space => { // reduce
            let span = self.span_stack[self.span_stack.length() - 3:].iter()
              |> FixedArray::from_iter
              |> Span::tree
            self.state_stack.unsafe_pop() |> ignore
            self.span_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.span_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.span_stack.unsafe_pop() |> ignore
            self.span_stack.push(span)
            // ignore Node [x2 : Rest]
            // ignore Node [x1 : Space]
            guard self.node_stack.unsafe_pop() is Node::GtBuilder(x0)
            let node = GtBuilder::add_rest(x0) |> Node::GtBuilder
            self.node_stack.push(node)
            1
          }
          _ => break
        }
    }
    8 => {
      self.enter_state(8)
      continue match lexeme.token {
          Slide
          | Space
          | String1
          | String2
          | String3
          | String4
          | String5
          | String6
          | LAURUS_EOF => { // reduce
            let span = self.span_stack[self.span_stack.length() - 1:].iter()
              |> FixedArray::from_iter
              |> Span::tree
            self.state_stack.unsafe_pop() |> ignore
            self.span_stack.unsafe_pop() |> ignore
            self.span_stack.push(span)
            guard self.node_stack.unsafe_pop() is Node::Note(x0)
            let node = Array::singleton(x0) |> Node::Array_LB_Note_RB_
            self.node_stack.push(node)
            6
          }
          _ => break
        }
    }
    9 => {
      self.enter_state(9)
      continue match lexeme.token {
          Fret => { // shift
            let node = self.lexer.get(lexeme) |> UInt::from_str |> Node::UInt
            self.node_stack.push(node)
            self.shift_span(lexeme)
            lexeme = self.lexer.scan5()
            34
          }
          _ => break
        }
    }
    10 => {
      self.enter_state(10)
      continue match lexeme.token {
          Fret => { // reduce
            let span = self.span_stack[self.span_stack.length() - 1:].iter()
              |> FixedArray::from_iter
              |> Span::tree
            self.state_stack.unsafe_pop() |> ignore
            self.span_stack.unsafe_pop() |> ignore
            self.span_stack.push(span)
            guard self.node_stack.unsafe_pop() is Node::UInt(x0)
            let node = x0 |> Node::UInt
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              4 | 6 => 9
              _ => break
            }
          }
          _ => break
        }
    }
    11 => {
      self.enter_state(11)
      continue match lexeme.token {
          Fret => { // reduce
            let span = self.span_stack[self.span_stack.length() - 1:].iter()
              |> FixedArray::from_iter
              |> Span::tree
            self.state_stack.unsafe_pop() |> ignore
            self.span_stack.unsafe_pop() |> ignore
            self.span_stack.push(span)
            guard self.node_stack.unsafe_pop() is Node::UInt(x0)
            let node = x0 |> Node::UInt
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              4 | 6 => 9
              _ => break
            }
          }
          _ => break
        }
    }
    12 => {
      self.enter_state(12)
      continue match lexeme.token {
          Fret => { // reduce
            let span = self.span_stack[self.span_stack.length() - 1:].iter()
              |> FixedArray::from_iter
              |> Span::tree
            self.state_stack.unsafe_pop() |> ignore
            self.span_stack.unsafe_pop() |> ignore
            self.span_stack.push(span)
            guard self.node_stack.unsafe_pop() is Node::UInt(x0)
            let node = x0 |> Node::UInt
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              4 | 6 => 9
              _ => break
            }
          }
          _ => break
        }
    }
    13 => {
      self.enter_state(13)
      continue match lexeme.token {
          Fret => { // reduce
            let span = self.span_stack[self.span_stack.length() - 1:].iter()
              |> FixedArray::from_iter
              |> Span::tree
            self.state_stack.unsafe_pop() |> ignore
            self.span_stack.unsafe_pop() |> ignore
            self.span_stack.push(span)
            guard self.node_stack.unsafe_pop() is Node::UInt(x0)
            let node = x0 |> Node::UInt
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              4 | 6 => 9
              _ => break
            }
          }
          _ => break
        }
    }
    14 => {
      self.enter_state(14)
      continue match lexeme.token {
          Fret => { // reduce
            let span = self.span_stack[self.span_stack.length() - 1:].iter()
              |> FixedArray::from_iter
              |> Span::tree
            self.state_stack.unsafe_pop() |> ignore
            self.span_stack.unsafe_pop() |> ignore
            self.span_stack.push(span)
            guard self.node_stack.unsafe_pop() is Node::UInt(x0)
            let node = x0 |> Node::UInt
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              4 | 6 => 9
              _ => break
            }
          }
          _ => break
        }
    }
    15 => {
      self.enter_state(15)
      continue match lexeme.token {
          Fret => { // reduce
            let span = self.span_stack[self.span_stack.length() - 1:].iter()
              |> FixedArray::from_iter
              |> Span::tree
            self.state_stack.unsafe_pop() |> ignore
            self.span_stack.unsafe_pop() |> ignore
            self.span_stack.push(span)
            guard self.node_stack.unsafe_pop() is Node::UInt(x0)
            let node = x0 |> Node::UInt
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              4 | 6 => 9
              _ => break
            }
          }
          _ => break
        }
    }
    16 => {
      self.enter_state(16)
      continue match lexeme.token {
          Space | LAURUS_EOF => { // reduce
            let span = self.span_stack[self.span_stack.length() - 1:].iter()
              |> FixedArray::from_iter
              |> Span::tree
            self.state_stack.unsafe_pop() |> ignore
            self.span_stack.unsafe_pop() |> ignore
            self.span_stack.push(span)
            // ignore Node [x0 : H1]
            let node = Duration::H1 |> Node::Duration
            self.node_stack.push(node)
            5
          }
          _ => break
        }
    }
    17 => {
      self.enter_state(17)
      continue match lexeme.token {
          Space | LAURUS_EOF => { // reduce
            let span = self.span_stack[self.span_stack.length() - 1:].iter()
              |> FixedArray::from_iter
              |> Span::tree
            self.state_stack.unsafe_pop() |> ignore
            self.span_stack.unsafe_pop() |> ignore
            self.span_stack.push(span)
            // ignore Node [x0 : H2]
            let node = Duration::H2 |> Node::Duration
            self.node_stack.push(node)
            5
          }
          _ => break
        }
    }
    18 => {
      self.enter_state(18)
      continue match lexeme.token {
          Space | LAURUS_EOF => { // reduce
            let span = self.span_stack[self.span_stack.length() - 1:].iter()
              |> FixedArray::from_iter
              |> Span::tree
            self.state_stack.unsafe_pop() |> ignore
            self.span_stack.unsafe_pop() |> ignore
            self.span_stack.push(span)
            // ignore Node [x0 : H4]
            let node = Duration::H4 |> Node::Duration
            self.node_stack.push(node)
            5
          }
          _ => break
        }
    }
    19 => {
      self.enter_state(19)
      continue match lexeme.token {
          Space | LAURUS_EOF => { // reduce
            let span = self.span_stack[self.span_stack.length() - 1:].iter()
              |> FixedArray::from_iter
              |> Span::tree
            self.state_stack.unsafe_pop() |> ignore
            self.span_stack.unsafe_pop() |> ignore
            self.span_stack.push(span)
            // ignore Node [x0 : H8]
            let node = Duration::H8 |> Node::Duration
            self.node_stack.push(node)
            5
          }
          _ => break
        }
    }
    20 => {
      self.enter_state(20)
      continue match lexeme.token {
          Space | LAURUS_EOF => { // reduce
            let span = self.span_stack[self.span_stack.length() - 1:].iter()
              |> FixedArray::from_iter
              |> Span::tree
            self.state_stack.unsafe_pop() |> ignore
            self.span_stack.unsafe_pop() |> ignore
            self.span_stack.push(span)
            // ignore Node [x0 : H16]
            let node = Duration::H16 |> Node::Duration
            self.node_stack.push(node)
            5
          }
          _ => break
        }
    }
    21 => {
      self.enter_state(21)
      continue match lexeme.token {
          Space | LAURUS_EOF => { // reduce
            let span = self.span_stack[self.span_stack.length() - 1:].iter()
              |> FixedArray::from_iter
              |> Span::tree
            self.state_stack.unsafe_pop() |> ignore
            self.span_stack.unsafe_pop() |> ignore
            self.span_stack.push(span)
            // ignore Node [x0 : H32]
            let node = Duration::H32 |> Node::Duration
            self.node_stack.push(node)
            5
          }
          _ => break
        }
    }
    22 => {
      self.enter_state(22)
      continue match lexeme.token {
          Space | LAURUS_EOF => { // reduce
            let span = self.span_stack[self.span_stack.length() - 1:].iter()
              |> FixedArray::from_iter
              |> Span::tree
            self.state_stack.unsafe_pop() |> ignore
            self.span_stack.unsafe_pop() |> ignore
            self.span_stack.push(span)
            // ignore Node [x0 : D1]
            let node = Duration::D1 |> Node::Duration
            self.node_stack.push(node)
            5
          }
          _ => break
        }
    }
    23 => {
      self.enter_state(23)
      continue match lexeme.token {
          Space | LAURUS_EOF => { // reduce
            let span = self.span_stack[self.span_stack.length() - 1:].iter()
              |> FixedArray::from_iter
              |> Span::tree
            self.state_stack.unsafe_pop() |> ignore
            self.span_stack.unsafe_pop() |> ignore
            self.span_stack.push(span)
            // ignore Node [x0 : D2]
            let node = Duration::D2 |> Node::Duration
            self.node_stack.push(node)
            5
          }
          _ => break
        }
    }
    24 => {
      self.enter_state(24)
      continue match lexeme.token {
          Space | LAURUS_EOF => { // reduce
            let span = self.span_stack[self.span_stack.length() - 1:].iter()
              |> FixedArray::from_iter
              |> Span::tree
            self.state_stack.unsafe_pop() |> ignore
            self.span_stack.unsafe_pop() |> ignore
            self.span_stack.push(span)
            // ignore Node [x0 : D4]
            let node = Duration::D4 |> Node::Duration
            self.node_stack.push(node)
            5
          }
          _ => break
        }
    }
    25 => {
      self.enter_state(25)
      continue match lexeme.token {
          Space | LAURUS_EOF => { // reduce
            let span = self.span_stack[self.span_stack.length() - 1:].iter()
              |> FixedArray::from_iter
              |> Span::tree
            self.state_stack.unsafe_pop() |> ignore
            self.span_stack.unsafe_pop() |> ignore
            self.span_stack.push(span)
            // ignore Node [x0 : D8]
            let node = Duration::D8 |> Node::Duration
            self.node_stack.push(node)
            5
          }
          _ => break
        }
    }
    26 => {
      self.enter_state(26)
      continue match lexeme.token {
          Space | LAURUS_EOF => { // reduce
            let span = self.span_stack[self.span_stack.length() - 1:].iter()
              |> FixedArray::from_iter
              |> Span::tree
            self.state_stack.unsafe_pop() |> ignore
            self.span_stack.unsafe_pop() |> ignore
            self.span_stack.push(span)
            // ignore Node [x0 : D16]
            let node = Duration::D16 |> Node::Duration
            self.node_stack.push(node)
            5
          }
          _ => break
        }
    }
    27 => {
      self.enter_state(27)
      continue match lexeme.token {
          Space | LAURUS_EOF => { // reduce
            let span = self.span_stack[self.span_stack.length() - 1:].iter()
              |> FixedArray::from_iter
              |> Span::tree
            self.state_stack.unsafe_pop() |> ignore
            self.span_stack.unsafe_pop() |> ignore
            self.span_stack.push(span)
            // ignore Node [x0 : D32]
            let node = Duration::D32 |> Node::Duration
            self.node_stack.push(node)
            5
          }
          _ => break
        }
    }
    28 => {
      self.enter_state(28)
      continue match lexeme.token {
          Space | LAURUS_EOF => { // reduce
            let span = self.span_stack[self.span_stack.length() - 1:].iter()
              |> FixedArray::from_iter
              |> Span::tree
            self.state_stack.unsafe_pop() |> ignore
            self.span_stack.unsafe_pop() |> ignore
            self.span_stack.push(span)
            // ignore Node [x0 : T1]
            let node = Duration::T1 |> Node::Duration
            self.node_stack.push(node)
            5
          }
          _ => break
        }
    }
    29 => {
      self.enter_state(29)
      continue match lexeme.token {
          Space | LAURUS_EOF => { // reduce
            let span = self.span_stack[self.span_stack.length() - 1:].iter()
              |> FixedArray::from_iter
              |> Span::tree
            self.state_stack.unsafe_pop() |> ignore
            self.span_stack.unsafe_pop() |> ignore
            self.span_stack.push(span)
            // ignore Node [x0 : T2]
            let node = Duration::T2 |> Node::Duration
            self.node_stack.push(node)
            5
          }
          _ => break
        }
    }
    30 => {
      self.enter_state(30)
      continue match lexeme.token {
          Space | LAURUS_EOF => { // reduce
            let span = self.span_stack[self.span_stack.length() - 1:].iter()
              |> FixedArray::from_iter
              |> Span::tree
            self.state_stack.unsafe_pop() |> ignore
            self.span_stack.unsafe_pop() |> ignore
            self.span_stack.push(span)
            // ignore Node [x0 : T4]
            let node = Duration::T4 |> Node::Duration
            self.node_stack.push(node)
            5
          }
          _ => break
        }
    }
    31 => {
      self.enter_state(31)
      continue match lexeme.token {
          Space | LAURUS_EOF => { // reduce
            let span = self.span_stack[self.span_stack.length() - 1:].iter()
              |> FixedArray::from_iter
              |> Span::tree
            self.state_stack.unsafe_pop() |> ignore
            self.span_stack.unsafe_pop() |> ignore
            self.span_stack.push(span)
            // ignore Node [x0 : T8]
            let node = Duration::T8 |> Node::Duration
            self.node_stack.push(node)
            5
          }
          _ => break
        }
    }
    32 => {
      self.enter_state(32)
      continue match lexeme.token {
          Space | LAURUS_EOF => { // reduce
            let span = self.span_stack[self.span_stack.length() - 1:].iter()
              |> FixedArray::from_iter
              |> Span::tree
            self.state_stack.unsafe_pop() |> ignore
            self.span_stack.unsafe_pop() |> ignore
            self.span_stack.push(span)
            // ignore Node [x0 : T16]
            let node = Duration::T16 |> Node::Duration
            self.node_stack.push(node)
            5
          }
          _ => break
        }
    }
    33 => {
      self.enter_state(33)
      continue match lexeme.token {
          Space | LAURUS_EOF => { // reduce
            let span = self.span_stack[self.span_stack.length() - 1:].iter()
              |> FixedArray::from_iter
              |> Span::tree
            self.state_stack.unsafe_pop() |> ignore
            self.span_stack.unsafe_pop() |> ignore
            self.span_stack.push(span)
            // ignore Node [x0 : T32]
            let node = Duration::T32 |> Node::Duration
            self.node_stack.push(node)
            5
          }
          _ => break
        }
    }
    34 => {
      self.enter_state(34)
      continue match lexeme.token {
          String6
          | String5
          | String4
          | String3
          | String2
          | String1
          | Space
          | Slide
          | LAURUS_EOF => { // reduce
            let span = self.span_stack[self.span_stack.length() - 2:].iter()
              |> FixedArray::from_iter
              |> Span::tree
            self.state_stack.unsafe_pop() |> ignore
            self.span_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.span_stack.unsafe_pop() |> ignore
            self.span_stack.push(span)
            guard self.node_stack.unsafe_pop() is Node::UInt(x1)
            guard self.node_stack.unsafe_pop() is Node::UInt(x0)
            let node = Note::{ string: x0, fret: x1 } |> Node::Note
            self.node_stack.push(node)
            let former = self.state_stack[self.state_stack.length() - 1]
            match former {
              4 => 8
              6 => 36
              _ => break
            }
          }
          _ => break
        }
    }
    35 => {
      self.enter_state(35)
      continue match lexeme.token {
          LAURUS_EOF | Space => { // reduce
            let span = self.span_stack[self.span_stack.length() - 4:].iter()
              |> FixedArray::from_iter
              |> Span::tree
            self.state_stack.unsafe_pop() |> ignore
            self.span_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.span_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.span_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.span_stack.unsafe_pop() |> ignore
            self.span_stack.push(span)
            guard self.node_stack.unsafe_pop() is Node::Slur(x3)
            guard self.node_stack.unsafe_pop() is Node::Array_LB_Note_RB_(x2)
            // ignore Node [x1 : Space]
            guard self.node_stack.unsafe_pop() is Node::GtBuilder(x0)
            let node = GtBuilder::add_chord(x0, x2, x3) |> Node::GtBuilder
            self.node_stack.push(node)
            1
          }
          _ => break
        }
    }
    36 => {
      self.enter_state(36)
      continue match lexeme.token {
          Slide
          | Space
          | String1
          | String2
          | String3
          | String4
          | String5
          | String6
          | LAURUS_EOF => { // reduce
            let span = self.span_stack[self.span_stack.length() - 2:].iter()
              |> FixedArray::from_iter
              |> Span::tree
            self.state_stack.unsafe_pop() |> ignore
            self.span_stack.unsafe_pop() |> ignore
            self.state_stack.unsafe_pop() |> ignore
            self.span_stack.unsafe_pop() |> ignore
            self.span_stack.push(span)
            guard self.node_stack.unsafe_pop() is Node::Note(x1)
            guard self.node_stack.unsafe_pop() is Node::Array_LB_Note_RB_(x0)
            let node = Array::snoc(x0, x1) |> Node::Array_LB_Note_RB_
            self.node_stack.push(node)
            6
          }
          _ => break
        }
    }
    37 => {
      self.enter_state(37)
      continue match lexeme.token {
          Space | LAURUS_EOF => { // reduce
            let span = self.span_stack[self.span_stack.length() - 1:].iter()
              |> FixedArray::from_iter
              |> Span::tree
            self.state_stack.unsafe_pop() |> ignore
            self.span_stack.unsafe_pop() |> ignore
            self.span_stack.push(span)
            // ignore Node [x0 : Slide]
            let node = Slur::Slide |> Node::Slur
            self.node_stack.push(node)
            35
          }
          _ => break
        }
    }
    _ => break
  }
  guard self.node_stack[0] is GtBuilder(node)
  node
}
