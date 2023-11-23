module window

// import os
// #include "windows.h"

// const (
// 	hkey_local_machine = u32(0x80000002)
// 	key_read           = 0x20019
// )

// pub fn reg_open_key_ex() ! {
// 	mut hkey := unsafe { nil }
// 	dword_value_len := u32(1024)
// 	mut value := &u16(0)

// 	mut result := C.RegOpenKeyEx(os.hkey_local_machine, 'SOFTWARE\\Microsoft\\Windows\\CurrentVersion'.to_wide(),
// 		0, windows.key_read, &hkey)

// 	value = unsafe { &u16(malloc(int(1024))) }

// 	result = C.RegQueryValueEx(hkey, 'ProgramFilesDir'.to_wide(), 0, 0, value, &dword_value_len)

// 	dump(result)
// 	unsafe {
// 		dump( string_from_wide(value) )
// 	}
// }

// pub fn reg_open_key_ex() ! {

// 	mut hkey := voidptr(0)
// 	dword_value_len := u32(1024)
// 	mut value := [1024]char{}

// 	mut result := C.RegOpenKeyEx(
// 		hkey_local_machine,
// 		"SOFTWARE\\Microsoft\\Windows\\CurrentVersion".to_wide(),
// 		0,
// 		key_read,
// 		&hkey
// 	)

// 	result = C.RegQueryValueEx(
// 		hkey,
// 		"ProgramFilesDir".to_wide(),
// 		0,
// 		0,
// 		&value,
// 		&dword_value_len
// 	)

// 	dump(result)
// 	dump(to_string(value[..]))
// }
