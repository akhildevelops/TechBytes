use std::{
    fs::OpenOptions,
    io::{Read, Write},
    mem::MaybeUninit,
};
#[derive(Debug)]
struct Rng {
    seed: u64,
}

impl Iterator for Rng {
    type Item = u64;
    fn next(&mut self) -> Option<Self::Item> {
        self.seed ^= self.seed << 13;
        self.seed ^= self.seed >> 17;
        self.seed ^= self.seed << 5;
        Some(self.seed)
    }
}
fn main() {
    let mut file = OpenOptions::new().read(true).open("/dev/random").unwrap();
    let mut rng = unsafe { MaybeUninit::<Rng>::uninit().assume_init() };
    unsafe {
        let buffer: &mut [u8; 8] = std::mem::transmute(&mut rng.seed);
        file.read_exact(buffer).unwrap();
    }
    let stdout = std::io::stdout();
    let mut handle = stdout.lock();
    loop {
        write!(handle, "{}", rng.seed).unwrap();
    }
}
