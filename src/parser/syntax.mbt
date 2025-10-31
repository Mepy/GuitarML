///|
pub(all) struct Note {
  string : UInt
  fret : UInt
} derive(Show)

///|
pub(all) enum Slur {
  Normal
  Slide
} derive(Show)

///|
pub(all) enum Duration {
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
} derive(Show)
