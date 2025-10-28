//// A collection of special keys for use with the 
//// [`action.enter_keys`](https://hexdocs.pm/butterbee/action.html#enter_keys/2) function.
////
//// NOTE: This module has been slopped together from a claude prompt.
//// If a key doesn't work, it's probably a hallucination.
//// Please [open an issue](https://codeberg.org/gelei/butterbee/issues/new) if you find one.

pub type MouseButton {
  LeftClick
  RightClick
}

@internal
pub fn mouse_button_to_int(click: MouseButton) -> Int {
  case click {
    LeftClick -> 0
    RightClick -> 1
  }
}

/// NOTE: Don't use this key for entering a new line into text fields using the `node.set_value` 
/// function. Use `\n` instead.
pub const enter: String = "\u{E007}"

pub const tab: String = "\u{E004}"

pub const escape: String = "\u{E00C}"

pub const space: String = "\u{E00D}"

pub const backspace: String = "\u{E003}"

pub const delete: String = "\u{E017}"

pub const arrow_up: String = "\u{E013}"

pub const arrow_down: String = "\u{E015}"

pub const arrow_left: String = "\u{E012}"

pub const arrow_right: String = "\u{E014}"

pub const home: String = "\u{E011}"

pub const end: String = "\u{E010}"

pub const page_up: String = "\u{E00E}"

pub const page_down: String = "\u{E00F}"

pub const f1: String = "\u{E031}"

pub const f2: String = "\u{E032}"

pub const f3: String = "\u{E033}"

pub const f4: String = "\u{E034}"

pub const f5: String = "\u{E035}"

pub const f6: String = "\u{E036}"

pub const f7: String = "\u{E037}"

pub const f8: String = "\u{E038}"

pub const f9: String = "\u{E039}"

pub const f10: String = "\u{E03A}"

pub const f11: String = "\u{E03B}"

pub const f12: String = "\u{E03C}"

pub const shift: String = "\u{E008}"

pub const control: String = "\u{E009}"

pub const alt: String = "\u{E00A}"

pub const super: String = "\u{E03D}"

pub const insert: String = "\u{E016}"

pub const numpad_0: String = "\u{E01A}"

pub const numpad_1: String = "\u{E01B}"

pub const numpad_2: String = "\u{E01C}"

pub const numpad_3: String = "\u{E01D}"

pub const numpad_4: String = "\u{E01E}"

pub const numpad_5: String = "\u{E01F}"

pub const numpad_6: String = "\u{E020}"

pub const numpad_7: String = "\u{E021}"

pub const numpad_8: String = "\u{E022}"

pub const numpad_9: String = "\u{E023}"

pub const numpad_decimal: String = "\u{E024}"

pub const numpad_divide: String = "\u{E025}"

pub const numpad_multiply: String = "\u{E026}"

pub const numpad_subtract: String = "\u{E027}"

pub const numpad_add: String = "\u{E028}"

pub const numpad_enter: String = "\u{E007}"
