
use std::io::Read;
use std::io::Write;

const MAX_HEAP_SIZE: usize = 16 * 1024 * 1024;

pub struct Runtime {
    heap: Vec<u8>,
    pointer: usize,
}

impl Runtime {
    pub fn new() -> Runtime {
        Runtime {
            heap: vec![0; 1024 * 1024],
            pointer: 0,
        }
    }

    fn heap_value(&mut self) -> &mut u8 {
        unsafe { self.heap.get_unchecked_mut(self.pointer) }
    }

    fn heap_value_at(&mut self, pointer: isize) -> &mut u8 {
        let pointer = pointer.max(0) as usize;
        unsafe { self.heap.get_unchecked_mut(pointer) }
    }

    fn heap_value_at_offset(&mut self, ptr_offset: isize) -> &mut u8 {
        let pointer = self.pointer as isize + ptr_offset;

        let pointer = pointer.max(0) as usize;

        unsafe { self.heap.get_unchecked_mut(pointer) }
    }

    fn inc_ptr(&mut self, count: usize) {
        self.pointer = self.pointer.wrapping_add(count)
    }

    fn dec_ptr(&mut self, count: usize) {
        self.pointer = self.pointer.wrapping_sub(count)
    }

    fn inc(&mut self, count: u8) {
        let value = self.heap_value();
        *value = value.wrapping_add(count);
    }

    fn set(&mut self, value: u8) {
        *self.heap_value() = value;
    }

    fn dec(&mut self, count: u8) {
        let value = self.heap_value();
        *value = value.wrapping_sub(count);
    }

    fn get_char(&mut self) {
        let mut buf = [0];

        std::io::stdin().read_exact(&mut buf).unwrap();

        *self.heap_value() = buf[0];
    }

    fn add(&mut self, ptr_offset: isize, multi: u8) {
        let source = *self.heap_value();
        let target = self.heap_value_at_offset(ptr_offset);
        *target = target.wrapping_add(source.wrapping_mul(multi));
        *self.heap_value() = 0;
    }

    fn sub(&mut self, ptr_offset: isize, multi: u8) {
        let source = *self.heap_value();
        let target = self.heap_value_at_offset(ptr_offset);
        *target = target.wrapping_sub(source.wrapping_mul(multi));
        *self.heap_value() = 0;
    }

    fn search_zero(&mut self, step: isize) {
        let mut pointer = self.pointer as isize;

        loop {
            let value = self.heap_value_at(pointer);

            if *value == 0 {
                break;
            }

            pointer += step;
        }

        self.pointer = pointer as usize;
    }

    fn put_char(&mut self) {
        let ch = *self.heap_value();

        if ch.is_ascii() {
            write!(std::io::stdout(), "{}", ch as char)
        } else {
            write!(std::io::stdout(), "\\0x{:x}", ch)
        }.unwrap()
    }
}

fn main() {
    let mut rt = Runtime::new();

    {{CODE}}
}
