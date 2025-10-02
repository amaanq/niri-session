use std::io::{self, Write as _};

use anstyle::{AnsiColor, Color, Style};
use log::{Level, LevelFilter, Log, Metadata, Record};

pub fn paint(color: Option<impl Into<Color>>, text: &str) -> String {
   let style = Style::new().fg_color(color.map(Into::into));
   format!("{style}{text}{style:#}")
}

struct Logger;

impl Log for Logger {
   fn enabled(&self, _: &Metadata) -> bool {
      true
   }

   fn log(&self, record: &Record) {
      match record.level() {
         Level::Error => eprintln!(
            "{} {}",
            paint(Some(AnsiColor::Red), "Error:"),
            record.args()
         ),
         Level::Warn => eprintln!(
            "{} {}",
            paint(Some(AnsiColor::Yellow), "Warning:"),
            record.args()
         ),
         Level::Info => eprintln!(
            "{} {}",
            paint(Some(AnsiColor::Green), "Info:"),
            record.args()
         ),
         Level::Debug => eprintln!(
            "{} {}",
            paint(Some(AnsiColor::Blue), "Debug:"),
            record.args()
         ),
         Level::Trace => eprintln!(
            "[{}] {}",
            record.module_path().unwrap_or_default(),
            record.args()
         ),
      }
   }

   fn flush(&self) {
      let mut stderr = io::stderr().lock();
      let _ = stderr.flush();
   }
}

pub fn init() {
   log::set_boxed_logger(Box::new(Logger {})).unwrap();
   log::set_max_level(LevelFilter::Info);
}

pub fn enable_debug() {
   log::set_max_level(LevelFilter::Debug);
}
