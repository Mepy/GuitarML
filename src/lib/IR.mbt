///|
fn Duration::to_size(self : Duration) -> UInt {
  match self {
    H1 => 192
    H2 => 96
    H4 => 48
    H8 => 24
    H16 => 12
    H32 => 6
    D1 => 288 // 附点 = *3/2, 192*3/2 = 288
    D2 => 144
    D4 => 72
    D8 => 36
    D16 => 18
    D32 => 9
    T1 => 128 // 三连音 = *2/3, 192*2/3 = 128
    T2 => 64
    T4 => 32
    T8 => 16
    T16 => 8
    T32 => 4
  }
}

///|
fn Duration::to_trim_size(self : Duration) -> UInt {
  match self {
    H1 => 32
    H2 => 16
    H4 => 8
    H8 => 4
    H16 => 2
    H32 => 1
    D1 => 32
    D2 => 16
    D4 => 8
    D8 => 4
    D16 => 2
    D32 => 1
    T1 => 32
    T2 => 16
    T4 => 8
    T8 => 4
    T16 => 2
    T32 => 1
  }
}

///|
fn Sig::to_size(self : Sig) -> UInt {
  let { top, bot } = self
  top * bot.to_size()
}

///|
pub struct IRLine {
  x1 : UInt
  x2 : UInt
  y : UInt
} derive(Show)

///|
pub struct IRNote {
  x : UInt
  y : UInt
  fret : UInt
} derive(Show)

///|
pub enum IRSlur {
  Slide(x1~ : UInt, y1~ : UInt, x2~ : UInt, y2~ : UInt)
} derive(Show)

///|
pub struct IRBarline {
  x : UInt
  y1 : UInt
  y2 : UInt
} derive(Show)

///|
pub struct IRTAB {
  x : UInt
  yT : UInt
  yA : UInt
  yB : UInt
} derive(Show)

///|
pub struct IRDura {
  x1 : UInt
  x2 : UInt
  y : UInt
} derive(Show)

///|
pub struct IRStem {
  x : UInt
  y1 : UInt
  y2 : UInt
} derive(Show)

///|
pub struct IRPhrase {
  lines : Array[Array[IRLine]] // lines[Guitar'string-1][index]
  notes : Array[Array[IRNote]] // notes[Guitar'string-1][index]
  slurs : Array[Array[IRSlur]] // slurs[Guitar'string-1][index]
  stems : Array[IRStem] // stems[index]
  duras : Array[IRDura] // duras[index]
  barlines : Array[IRBarline] // barlines[index]
  tab : IRTAB
} derive(Show)

///|
pub struct Beam {
  chords : Array[Chord]
} derive(Show)

///|
pub fn Beam::new() -> Self {
  { chords: Array::new() }
}

///|
fn compute_beams(
  chords : Array[Chord],
  dur : Duration,
  base_offset? : UInt = 0,
) -> Array[Beam] {
  let beams = Array::new()
  let mut beam = Beam::new()
  let mut offset_counter : UInt = base_offset
  let dur_size = dur.to_size()
  for i in 0..<chords.length() {
    let chord = chords[i]
    offset_counter += chord.duration.to_size()
    beam.chords.push(chord)
    if offset_counter >= dur_size {
      offset_counter %= dur_size
      beams.push(beam)
      beam = Beam::new()
    }
  }
  if 0 != beam.chords.length() {
    beams.push(beam)
  }
  beams
}

///|
fn compute_offsets(chords : Array[Chord]) -> (Array[UInt], UInt) {
  let offsets : Array[UInt] = Array::new(capacity=chords.length())
  let mut min_size : UInt = Duration::D1.to_size()
  let mut total_size : UInt = 0
  for chord in chords {
    let delta = chord.duration.to_size()
    if delta < min_size {
      min_size = delta
    }
    offsets.push(total_size)
    total_size += delta
  }
  (offsets, total_size)
}

///|
pub fn Phrase::to_IR(self : Phrase, sig : Sig) -> IRPhrase {
  // basic settings, todo : we may use pprint lib to rewrite these stuffs? with softbreak and hardbreak, sth

  let x_beg : UInt = 40
  let x_TAB : UInt = 60
  let x_base : UInt = 120
  let x_H4 : UInt = 160 // width of H4 note
  let x_char : UInt = 6 // minus x_char when fret >= 10
  let y_base : UInt = 20
  let y_char : UInt = 6
  let y_sep : UInt = 20
  let s_H4 = Duration::H4.to_size()
  let { chords, slurs, .. } = self
  // collect offset of each chord and total, prepare for the relative position of each chord
  let (offsets, total_size) = compute_offsets(chords)
  let width = total_size * x_H4 / s_H4
  let x_end : UInt = x_base + width
  let sig_size = sig.to_size()
  // println("offsets \{offsets}, deltas \{deltas}, sig_size \{sig_size}")
  let ir : IRPhrase = {
    lines: [[], [], [], [], [], []],
    notes: [[], [], [], [], [], []],
    slurs: [[], [], [], [], [], []],
    barlines: [],
    stems: [],
    duras: [],
    tab: {
      x: x_TAB,
      yT: y_base + y_sep * 2,
      yA: y_base + y_sep * 4,
      yB: y_base + y_sep * 6,
    },
  }
  let x_begs : Array[UInt] = Array::make(6, x_beg)
  // write chords
  for i in 0..<chords.length() {
    let offset = offsets[i]
    let x = x_base + offset * x_H4 / s_H4
    let { notes, .. } = chords[i]
    let slur = slurs[i]
    let mut s_max : UInt = 1
    // write each note in the chord
    for note in notes {
      let { string, fret } = note
      let s = string.reinterpret_as_int() - 1
      let y = y_base + string * y_sep
      if string > s_max {
        s_max = string
      }
      if fret >= 10 {
        ir.lines[s].push({ x1: x_begs[s], x2: x - x_char, y })
        ir.notes[s].push({ x: x - x_char, y: y + y_char, fret })
        x_begs[s] = x + x_char * 3
      } else {
        ir.lines[s].push({ x1: x_begs[s], x2: x - x_char, y })
        ir.notes[s].push({ x, y: y + y_char, fret })
        x_begs[s] = x + x_char * 3
      }
    }
    // write each slur
    match slur {
      Slide =>
        if i == offsets.length() - 1 ||
          chords[i].notes.length() == 0 ||
          chords[i + 1].notes.length() == 0 {
          println(
            "please consider add one more note at the end of line \{i}\n\{chords[i].notes}\n\{chords[i+1].notes}",
          )
          let y = y_base + y_char + s_max * y_sep
          let x1 = x + x_char * 3
          let x2 = x + x_H4 / s_H4 - x_char * 2
          ir.slurs[s_max.reinterpret_as_int() - 1].push(
            Slide(x1~, y1=y, x2~, y2=y),
          )
        } else {
          let fret1 = chords[i].notes[0].fret
          let fret2 = chords[i + 1].notes[0].fret
          let y = y_base + y_char + s_max * y_sep
          let x1 = x + x_char * (if fret1 >= 10 { 4 } else { 3 })
          let x2 = x_base +
            offsets[i + 1] * x_H4 / s_H4 -
            x_char * (if fret1 >= 10 { 1 } else { 2 })
          let (y1, y2) = if fret1 < fret2 {
            (y, y - y_sep / 2)
          } else {
            (y - y_sep / 2, y)
          }
          ir.slurs[s_max.reinterpret_as_int() - 1].push(
            Slide(x1~, y1~, x2~, y2~),
          )
        }
      _ => ()
    }
  }

  // write duration 
  let beams = compute_beams(self.chords, Duration::H4)
  let mut i_base = 0
  for beam in beams {
    for j in 0..<beam.chords.length() {
      let chord = beam.chords[j]
      let offset = offsets[i_base]
      let delta = chord.duration.to_size()
      let x1 = x_base + x_char + offset * x_H4 / s_H4
      let x2 = x1 + delta * x_H4 / s_H4 // * 90 / 100
      let y1 = y_base + y_sep * 13 / 2 // under line 6
      let y2 = y_base + y_sep * 17 / 2 // under line 6
      if 0 != chord.notes.length() {
        ir.stems.push(IRStem::{ x: x1, y1, y2 })
      } else {
        ir.stems.push(IRStem::{ x: x1, y1: (y1 + y2) / 2, y2 })
      }
      if j != beam.chords.length() - 1 {
        for
          i in 0..<(Duration::H8.to_trim_size() / chord.duration.to_trim_size()).reinterpret_as_int() {
          ir.duras.push(IRDura::{
            x1,
            x2,
            y: y2 - i.reinterpret_as_uint() * y_sep / 2,
          })
        }
      }
      i_base += 1
    }
  }
  // write 6 lines ——
  for s in 0..=5 {
    ir.lines[s].push({
      x1: x_begs[s],
      x2: x_end,
      y: y_base + (s.reinterpret_as_uint() + 1) * y_sep,
    })
  }
  // write barlines  | 
  for x = (0 : UInt); x <= total_size; x = x + sig_size {
    ir.barlines.push({
      x: (x_TAB + x_base) / 2 + x * x_H4 / s_H4,
      y1: y_base + y_sep,
      y2: y_base + y_sep * 6,
    })
  }
  ir
}

///|
pub fn IRPhrase::to_svg(self : IRPhrase) -> String {
  let mut output : String = ""
  output += "<svg xmlns=\"http://www.w3.org/2000/svg\" viewBox=\"0 0 1080 360\" fill=\"none\" width=\"210mm\" height=\"80mm\">\n"
  let { lines, notes, slurs, stems, duras, barlines, tab } = self
  output += "\t<g stroke=\"#000\" stroke-width=\"2\">\n"
  output += "\t<!-- lines of Tablature -->\n"
  for s in 0..=5 {
    let lines = lines[s]
    for line in lines {
      let { x1, x2, y } = line
      output += "\t\t<line x1=\"\{x1}\" y1=\"\{y}\" x2=\"\{x2}\" y2=\"\{y}\"/>\n"
    }
  }
  output += "\n"
  output += "\t<!-- barlines on Tablature -->\n"
  for barline in barlines {
    let { x, y1, y2 } = barline
    output += "\t\t<line x1=\"\{x}\" y1=\"\{y1}\" x2=\"\{x}\" y2=\"\{y2}\"/>\n"
  }
  output += "\t</g>\n"
  output += "\t<g font-family=\"Arial\" font-size=\"28\" font-weight=\"bold\" fill=\"#000\">\n"
  output += "\t<!-- TAB -->\n"
  {
    let { x, yT, yA, yB } = tab
    output += "\t\t<text x=\"\{x}\" y=\"\{yT}\">T</text>\n"
    output += "\t\t<text x=\"\{x}\" y=\"\{yA}\">A</text>\n"
    output += "\t\t<text x=\"\{x}\" y=\"\{yB}\">B</text>\n"
  }
  output += "\t</g>\n"

  // duras
  output += "\t<g stroke=\"#000\" stroke-width=\"2\">\n"
  output += "\t<!-- duras -->\n"
  for dura in duras {
    let { x1, x2, y } = dura
    output += "\t\t<line x1=\"\{x1}\" y1=\"\{y}\" x2=\"\{x2}\" y2=\"\{y}\"/>\n"
  }
  output += "\t<!-- stems -->\n"
  for stem in stems {
    let { x, y1, y2 } = stem
    output += "\t\t<line x1=\"\{x}\" y1=\"\{y1}\" x2=\"\{x}\" y2=\"\{y2}\"/>\n"
  }
  output += "\t</g>\n"

  // notes
  output += "\t<g font-family=\"Arial\" font-size=\"20\" font-weight=\"bold\" fill=\"#000\">\n"
  output += "\t<!-- notes on Tablature -->\n"
  for s in 0..=5 {
    let notes = notes[s]
    for note in notes {
      let { x, y, fret } = note
      output += "\t\t<text x=\"\{x}\" y=\"\{y}\">\{fret}</text>\n"
    }
  }
  output += "\t</g>\n"
  output += "\t<g stroke=\"#000\" stroke-width=\"2\">\n"
  output += "\t<!-- slurs on Tablature -->\n"
  for s in 0..=5 {
    let slurs = slurs[s]
    for slur in slurs {
      match slur {
        Slide(x1~, y1~, x2~, y2~) =>
          output += "\t\t<line x1=\"\{x1}\" y1=\"\{y1}\" x2=\"\{x2}\" y2=\"\{y2}\" />\n"
      }
    }
  }
  output += "\t</g>\n"
  output += "</svg>\n"
  output
}

///|
test "IRPhrase::to_IR/semmatsu" {
  let phrase = Phrase::{
    chords: [
      { duration: H4, notes: [{ string: 1, fret: 0 }] },
      { duration: H4, notes: [{ string: 1, fret: 3 }] },
      { duration: H4, notes: [{ string: 2, fret: 3 }] },
      { duration: H8, notes: [] },
      { duration: H8, notes: [{ string: 2, fret: 1 }, { string: 1, fret: 3 }] },
      { duration: H8, notes: [{ string: 2, fret: 3 }, { string: 1, fret: 5 }] },
      { duration: H8, notes: [{ string: 2, fret: 1 }, { string: 1, fret: 3 }] },
      { duration: H8, notes: [{ string: 2, fret: 3 }, { string: 1, fret: 5 }] },
      { duration: H8, notes: [{ string: 2, fret: 1 }, { string: 1, fret: 3 }] },
      { duration: H8, notes: [{ string: 1, fret: 12 }] },
      { duration: H8, notes: [{ string: 2, fret: 15 }] },
      { duration: H8, notes: [{ string: 2, fret: 13 }] },
      { duration: H8, notes: [{ string: 3, fret: 14 }] },
    ],
    slurs: [
      Normal,
      Normal,
      Normal,
      Normal,
      Slide,
      Slide,
      Slide,
      Slide,
      Normal,
      Normal,
      Normal,
      Normal,
      Normal,
    ],
    lyric: "",
  }
  // println(phrase.to_IR({ top: 4, bot: H4 }).to_svg())
}
