///|
using @parser {type Note, type Duration, type Chord, type Slur}

// ///| 
// pub struct Note {
//   string : UInt
//   fret : UInt
// } derive(Show)

// ///|
// pub enum Duration {
//   H1 // 𝅝
//   H2 // 𝅗𝅥
//   H4 // ♩
//   H8 // ♪
//   H16 // 𝅘𝅥𝅯
//   H32 // 𝅘𝅥𝅰
//   D1 // 𝅝.
//   D2 // 𝅗𝅥.
//   D4 // ♩.
//   D8 // ♪.
//   D16 // 𝅘𝅥𝅯.
//   D32 // 𝅘𝅥𝅰.
//   T1 // one of 𝅝𝅝𝅝3
//   T2 // one of 𝅗𝅥𝅗𝅥𝅗𝅥3
//   T4 // one of ♩♩♩3
//   T8 // one of ♪♪♪3
//   T16 // one of 𝅘𝅥𝅯𝅘𝅥𝅯𝅘𝅥𝅯3
//   T32 // one of 𝅘𝅥𝅰𝅘𝅥𝅰𝅘𝅥𝅰3
// } derive(Show)

// ///|
// pub struct Chord {
//   duration : Duration
//   notes : Array[Note] // [] -> rest note ; [n] -> single note n ; [...] -> chord
//   // ensures notes are sorted under the descending order of strings
// } derive(Show)

// ///|
// pub enum Slur {
//   Normal // 什么也没有
//   Slide // 滑弦
//   Hammer // 击弦
//   Pull // 勾弦
//   Bend1 // 推弦半音
//   Bend2 // 推弦全音
//   Bend1R // 推弦半音复位
//   Bend2R // 推弦全音复位
//   Vibrato // 揉弦
// } derive(Show)

///|
/// 一行乐句, chords.length = slurs.length + 1 = lyric.length
pub(all) struct Phrase {
  chords : Array[Chord]
  slurs : Array[Slur]
  lyric : String
} derive(Show)

///|
/// 乐段
pub struct Section {
  name : String
  phrases : Array[Phrase]
} derive(Show)

///|
/// 调性主音
pub enum Key {
  C
  Db
  D
  Eb
  E
  F
  Gb
  G
  Ab
  A
  Bb
  B
} derive(Show)

///|
/// 调式
pub enum Mode {
  Major
  Minor
  Ionian // = Major
  Dorian
  Phrygian
  Lydian
  Mixolydian
  Aeolian // Minor
  Locrian
} derive(Show)

///|
/// 节拍
pub(all) struct Sig {
  top : UInt
  bot : Duration
} derive(Show)

///|
pub struct Track {
  title : String
  author : String
  key : Key
  mode : Mode
  sig : Sig
  bpm : UInt
  sections : Array[Section]
} derive(Show)
