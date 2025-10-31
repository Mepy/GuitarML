///|
pub(all) struct GtBuilder {
  mut cur_dur : Duration
  mut chords : Array[Chord]
  mut slurs : Array[Slur]
} derive(Show)

///|
pub(all) struct Chord {
  duration : Duration
  notes : Array[Note] // [] -> rest note ; [n] -> single note n ; [...] -> chord
  // ensures notes are sorted under the descending order of strings
} derive(Show)

///|
/// 一行乐句, chords.length = slurs.length + 1 = lyric.length
pub(all) struct Phrase {
  chords : Array[Chord]
  slurs : Array[Slur]
  lyric : String
} derive(Show)

///|
fn GtBuilder::new() -> Self {
  { cur_dur: Duration::H4, chords: [], slurs: [] }
}

///|
fn GtBuilder::set_dur(self : Self, duration : Duration) -> Self {
  // println("set_dur: \{duration}")
  self.cur_dur = duration
  self
}

///|
fn GtBuilder::add_chord(self : Self, notes : Array[Note], slur : Slur) -> Self {
  // println("add_chord: \{notes}, slur: \{slur}")
  let chord = { duration: self.cur_dur, notes }
  self.slurs.push(slur)
  self.chords.push(chord)
  self
}

///|
fn GtBuilder::add_rest(self : Self) -> Self {
  let chord = { duration: self.cur_dur, notes: [] }
  self.slurs.push(Slur::Normal)
  self.chords.push(chord)
  self
}

///|
fn GtBuilder::build(self : Self) -> Phrase {
  Phrase::{ chords: self.chords, slurs: self.slurs, lyric: "" }
}
