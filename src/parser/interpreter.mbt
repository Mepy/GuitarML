///|
#inline
fn UInt::string1(_ : String) -> UInt {
  1
}

///|
#inline
fn UInt::string2(_ : String) -> UInt {
  2
}

///|
#inline
fn UInt::string3(_ : String) -> UInt {
  3
}

///|
#inline
fn UInt::string4(_ : String) -> UInt {
  4
}

///|
#inline
fn UInt::string5(_ : String) -> UInt {
  5
}

///|
#inline
fn UInt::string6(_ : String) -> UInt {
  6
}

///|
#inline
fn UInt::from_str(str : String) -> UInt {
  let mut result : UInt = 0
  for c in str {
    let digit : UInt = match c {
      '0' => 0
      '1' => 1
      '2' => 2
      '3' => 3
      '4' => 4
      '5' => 5
      '6' => 6
      '7' => 7
      '8' => 8
      '9' => 9
      _ => 0
    }
    result = result * 10 + digit
  }
  result
}

///|
#inline
fn[T] Array::empty() -> Array[T] {
  Array::new()
}

///|
#inline
fn[T] Array::singleton(x : T) -> Array[T] {
  [x]
}

///|
#inline
fn[T] Array::snoc(array : Array[T], x : T) -> Array[T] {
  array.push(x)
  array
}
