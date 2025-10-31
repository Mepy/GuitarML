///|
fn parse(src : String) -> @lib.Phrase {
  let { chords, slurs, .. } = @parser.parse(src)
  @lib.Phrase::{ chords, slurs, lyric: "" }
}

///|
fn main {

}
