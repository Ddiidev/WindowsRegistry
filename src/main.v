module main

import winreg
// import windows

fn main() {
	hkey := winreg.open_key(.hkey_local_machine, "SOFTWARE\\Microsoft\\Windows\\CurrentVersion", .key_read)!

	prog := hkey.reg_query_value("ProgramFilesDir")
	println(prog)
}

