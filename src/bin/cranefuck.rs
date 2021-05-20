use clap::{App, SubCommand, Arg, crate_name, crate_version, crate_description};
use std::ffi::OsStr;
use std::error::Error;
use std::fs::File;
use std::io::{Read, Write, stdin, stdout};
use cranefuck::{parse, Interpreter, CraneFuckError};
use std::time::SystemTime;
use codespan_reporting::term::termcolor::{StandardStream, Color, ColorChoice, WriteColor, ColorSpec};

fn main() -> Result<(), Box<dyn Error>> {
    let matches = create_clap_app().get_matches();

    match matches.subcommand() {
        ("run", Some(arg_matches)) => {
            run_file(
                arg_matches.is_present("VERBOSE"),
                arg_matches.value_of_os("FILE").unwrap(),
            )
        }
        _ => {
            eprintln!("{}", matches.usage());
            Ok(())
        }
    }
}

fn create_clap_app() -> App<'static, 'static> {
    App::new(crate_name!())
        .version(crate_version!())
        .about(crate_description!())
        .subcommand(SubCommand::with_name("run")
            .about("Run application")
            .arg(Arg::with_name("FILE")
                .required(true)
                .help("Brainfuck source file"))
            .arg(Arg::with_name("VERBOSE")
                .short("v")
                .long("verbose"))
        )
}

fn run_file(verbose: bool, path: &OsStr) -> Result<(), Box<dyn Error>> {
    let mut file = File::open(path)?;

    let mut source = "".to_owned();

    file.read_to_string(&mut source)?;

    let mut ts = SystemTime::now();

    let program = match parse(&source) {
        Ok(program) => program,
        Err(err) => {
            return err.pretty_print(&source, Some(&path.to_string_lossy()));
        }
    };

    if verbose {
        let mut writer = StandardStream::stderr(ColorChoice::Auto);
        writer.set_color(ColorSpec::new().set_fg(Some(Color::Yellow)))?;
        writeln!(writer, "Parsed program with {} instructions and {} loops in {}ms",
                 program.op_count,
                 program.loop_count,
                 ts.elapsed()?.as_micros() as f32 / 1000.0
        )?;
        writer.reset()?;
        ts = SystemTime::now();
    }

    let mut interpreter = Interpreter::new(stdin(), stdout());

    interpreter.execute(&program)?;

    if verbose {
        let mut writer = StandardStream::stderr(ColorChoice::Auto);
        writer.set_color(ColorSpec::new().set_fg(Some(Color::Yellow)))?;
        writeln!(writer, "Executed program in {}ms",
                 ts.elapsed()?.as_micros() as f32 / 1000.0
        )?;
        writer.reset()?;
    }

    Ok(())
}
