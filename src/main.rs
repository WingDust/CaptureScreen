extern crate hotkey;

// use libloading::{Library,Symbol};

#[allow(unused_imports)]
use std::fs;
use std::path::{Path, PathBuf};
#[allow(unused_imports)]
use std::thread;
use std::{
    io::Write,
    process::{Child, Command, Stdio},
    sync::mpsc,
};

// use std::rc::Rc;
// use std::cell::RefCell;
use std::time::Duration;

#[allow(unused_variables)]
#[allow(unused_mut)]
fn main() {
    let (tx, rx): (mpsc::Sender<i32>, mpsc::Receiver<i32>) = mpsc::channel();
    let t1 = thread::spawn(move || {
        key(tx);
    });
    let t2 = thread::spawn(move || {
        let mut o = ffmpeg(error);

        let recv = rx.recv().unwrap();
        println!("{}", recv);
        let mut out = o.stdin.take().unwrap();
        // interrupt ffmpeg
        out.write_all(b"q").unwrap();
        // thread::sleep(Duration::from_millis(500));
    });
    t2.join().unwrap();
    // 停止主线程以等待文件生成完毕
    thread::sleep(Duration::from_secs(3));
    let t3 = thread::spawn(move || {
        webp();
    });
    t3.join().unwrap();
    // o.stdin.as_mut().ok_or("qq").unwrap().write_all(b"q").unwrap();
    // 中断主进程与主线程
    // std::process::exit(0x0100);
}

/// Reference:
///   - [Virtual-Key Codes](https://docs.microsoft.com/en-us/windows/win32/inputdev/virtual-key-codes)
///   - [RegisterHotKey function](https://docs.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-registerhotkey)
///   - [How to register a single or multiple global hotkeys for a single key in Winforms](https://ourcodeworld.com/articles/read/573/how-to-register-a-single-or-multiple-global-hotkeys-for-a-single-key-in-winforms)
#[allow(dead_code)]
#[allow(unused_variables)]
fn key(tx: mpsc::Sender<i32>) {
    let mut hk = hotkey::Listener::new();
    hk.register_hotkey(0x0000, 0x78 as u32, move || {
        println!("f9");
        tx.send(0).unwrap();
        // std::process::exit(0x0100);
    })
    .unwrap();
    hk.listen();
}

#[allow(dead_code)]
#[allow(unused_variables)]
#[allow(unused_mut)]
fn ffmpeg(err: fn()) -> Child {
    let mut o = Command::new("ffmpeg")
        .arg("-f")
        .arg("gdigrab")
        .arg("-i")
        .arg("desktop")
        .arg("-pix_fmt")
        .arg("yuv420p")
        .arg("-y")
        .arg("H:/backupRecord/b.mp4")
        .stdin(Stdio::piped())
        .stderr(Stdio::piped())
        .stdout(Stdio::piped())
        // .output()
        .spawn()
        .expect("error!");

    // let mut s= String::new();
    // // o.stderr.unwrap().read_to_string(&mut s);
    // let mut errs = o.stderr.take().unwrap();
    // let e = BufReader::new(errs);
    // println!("{}", '2');
    // // errs.read_to_string(&mut s);
    // // errs.
    // e.lines().for_each(|line|
    //     println!("err: {}", line.unwrap())
    // );
    // let c =o.wait().unwrap();

    // match o.try_wait() {
    //     Ok(Some(status)) => println!("exited with: {}", status),
    //     Ok(None) => {
    //         println!("status not ready yet, let's really wait");
    //         let res = o.wait();
    //         println!("result: {:?}", res);
    //     }
    //     Err(e) => println!("error attempting to wait: {}", e),
    // }

    // let c =o.try_wait().unwrap().unwrap();
    // c.success();
    // c.success();

    // let k = Rc::new(RefCell::new(o));

    // let output = k.clone().into_inner().wait_with_output().unwrap();
    // let output = o.wait_with_output().unwrap();
    // if !output.status.success() {
    //     println!("{:#?}",String::from_utf8(output.stderr));
    //     err();
    // }
    // println!("{:#?}",out);
    o
    // let out = o.stdin.take().unwrap();
    // out
}

#[allow(dead_code)]
fn error() {
    let mut child = Command::new("python")
        .stdin(Stdio::piped())
        .stderr(Stdio::piped())
        .stdout(Stdio::piped())
        .spawn()
        .unwrap();

    child.stdin.as_mut().ok_or("python error").unwrap().write_all(b"from notifypy import Notify;notification = Notify();notification.title='Errored';notification.message='ffmpeg run failed';notification.send();exit();").unwrap();
}

#[allow(dead_code)]
fn numname(n: Option<u32>) -> String {
    match n {
        Some(i) => {
            let len = (i + 1).to_string().len();
            let zero = 6 - len;
            "0".repeat(zero) + &(i + 1).to_string()
        }
        None => "000000".to_string(), // None
    }
}

/// Reference:
///   - [Is there a way to force print!/println! to use a Windows new line (CR LF)](https://stackoverflow.com/questions/37558353/is-there-a-way-to-force-print-println-to-use-a-windows-new-line-cr-lf)
#[allow(dead_code)]
#[allow(unused_macros)]
macro_rules! wprintln {
    ($fmt:expr) => (print!(concat!($fmt, "\r\n")));
    ($fmt:expr, $($arg:tt)*) => (print!(concat!($fmt, "\r\n"), $($arg)*));
}

#[allow(dead_code)]
#[allow(unused_mut)]
fn webp() {
    println!("on");
    if Path::new("H:/backupRecord/b.mp4").exists() {
        let mut o = Command::new("ffmpeg")
            .arg("-i")
            .arg("H:/backupRecord/b.mp4")
            .arg("-y")
            .arg(format!("h:/image/PracticeBlender/{}.webp", checkname()))
            .output()
            .expect("error!");
        if !o.status.success() {
            wprintln!("{:#?}", String::from_utf8(o.stderr));
            // err();
        }
    }
}

/// Reference:
///   - [How would I check if a directory is empty in Rust?](https://stackoverflow.com/questions/56744383/how-would-i-check-if-a-directory-is-empty-in-rust)
///   - [Filtering files or directories discovered with fs::read_dir()](https://stackoverflow.com/questions/58062887/filtering-files-or-directories-discovered-with-fsread-dir)
#[allow(dead_code)]
#[allow(unused_must_use)]
fn checkname() -> String {
    let isempty = fs::read_dir("h:/image/PracticeBlender/")
        .unwrap()
        .next()
        .is_none();
    if isempty {
        return numname(None);
    }
    let i = fs::read_dir("h:/image/PracticeBlender/").unwrap();
    // println!("{:?}", i.into_iter().filter(|r|r.is_ok()));
    let mut c:Vec<PathBuf> = i.into_iter()
    .filter(|r|r.is_ok())
    .map(|r|r.unwrap().path())
    .filter(|r|r.is_file())
    .collect();

    let n = c.pop().unwrap()
    .as_path()
    .file_stem().unwrap()
    .to_str().unwrap()
    .parse::<u32>().unwrap();
    numname(Some(n))
}

/// Reference:
///   - [https://github.com/rust-lang/rust/issues/43301](file:///E:/Microsoft%20VS%20Code/resources/app/out/vs/code/electron-browser/workbench/workbench.html)
#[test]
fn test() {
    println!(
        "{}",
        format!("h:/image/PracticeBlender/{}.webp", "0000".to_string())
    );
    println!(
        "{}",
        format!("\"h:/image/PracticeBlender/{}.webp\"", checkname())
    );
    // wprintln!("{}","asd\r\nasdas\r\n");
    // unsafe  {
    //    let lib =  Library::new("./TagLibSharp.dll").unwrap();
    //    lib.get(b"Create");
    // }
}
