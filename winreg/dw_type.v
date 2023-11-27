module winreg

pub enum DwType as u32 {
   reg_none = 0
   reg_sz = 1
   reg_expand_sz = 2
   reg_binary = 3
   reg_dword = 4
   reg_dword_big_endian = 5
   reg_multi_sz = 7
   reg_qword = 11
}