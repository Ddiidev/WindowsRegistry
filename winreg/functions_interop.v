module winreg

import winreg.winerror

#include <windows.h>

$if windows {
	$if tinyc {
		#flag -ladvapi32
	}
}

fn C.RegQueryValueEx(hKey voidptr, lpValueName &u16, lp_reserved &u32, lpType &u32, lpData &u8, lpcbData &u32) int
fn C.RegDeleteValue(hKey voidptr, lpValueName &u16) int
fn C.RegOpenKeyEx(hKey voidptr, lpSubKey &u16, ulOptions u32, samDesired u32, phkResult voidptr) int
fn C.RegCloseKey(hKey voidptr) int


// open_key Opens a specific Windows registry key.
// 
// How to use:
// ```v
// handle_key := winreg.open_key(.hkey_local_machine, r'SOFTWARE\Microsoft\Windows\CurrentVersion', .key_read)!
// ```
// 
// If any error occurs due to lack of permission, etc... it will return a winerror.ErrorRegistry
pub fn open_key(hkey HKEYS, subkey string, mode AccessMode) !HandleKey {
	mut result_hkey := unsafe { nil }

	mut result := C.RegOpenKeyEx(u64(hkey), subkey.to_wide(), 0, int(mode), &result_hkey)

	if result != winerror.error_success {
		return winerror.ErrorRegistry{
			code_error_c: result
		}
	}

	return HandleKey.new(hkey, subkey, result_hkey, mode)
}

// close closes a connection to windows registry.
// 
// How to use:
// ```v
// handle_key := winreg.open_key(.hkey_local_machine, r'SOFTWARE\Microsoft\Windows\CurrentVersion', .key_read)!
//
// handle_key.close()!
// ```
// 
// If any error occurs due to lack of permission, etc... it will return a winerror.ErrorRegistry
pub fn (h HandleKey) close() ! {
	result := C.RegCloseKey(h.hkey_ptr)

	if result != winerror.error_success {
		return winerror.ErrorRegistry{
			code_error_c: result
		}
	}
}

// reg_get_value takes a value of types REG_SZ and REG_DWORD, and returns it as DwValue.
// If you don't know the type of the value, this function can help a lot.
// 
// How to use:
// ```v
// program_files_dir := handle_key.reg_get_value("ProgramFilesDir")!
//
// if program_files_dir is string {
// 	println('program_files_dir is string: "$program_files_dir"')
// } else {
// 	println('program_files_dir is int: "$program_files_dir"')
// }
// ```
// 
// If any error occurs due to lack of permission, etc... it will return a winerror.ErrorRegistry
pub fn (h HandleKey) reg_get_value(reg string) !DwValue {
	typ := h.get_type_reg_value(reg)!

	return if typ == u32(DwType.reg_dword) {
		h.reg_query_value[int](reg)!
	} else {
		h.reg_query_value[string](reg)!
	}
}

// reg_query_value[T] takes a value of types REG_SZ and REG_DWORD, and returns it with the specified generic type.
// You need to know exactly what type is expected, if the value is a REG_DWORD and T is equal to a string
// Some invalid data will then be returned.
// 
// How to use:
// ```v
// program_files_dir := handle_key.reg_query_value[string]("ProgramFilesDir")!
//
// println('program_files_dir is my string: "$program_files_dir"')
// ```
// 
// If any error occurs due to lack of permission, etc... it will return a winerror.ErrorRegistry
pub fn (h HandleKey) reg_query_value[T](reg string) !T {
	size := h.get_lenth_reg_value(reg)!
	typ := h.get_type_reg_value(reg)!
	value := unsafe { &u16(malloc(int(size))) }
	mut result := 0

	result = C.RegQueryValueEx(h.hkey_ptr, reg.to_wide(), 0, &typ, value, &size)

	if result != winerror.error_success {
		return winerror.ErrorRegistry{
			code_error_c: result
		}
	}

	$if T is $int {
		return *value
	} $else {
		return unsafe { string_from_wide(value) }
	}
}



// reg_delete_value deletes a value from the registry.
// To delete registry values, the application must have elevated permissions on the OS.
// 
// How to use:
// ```v
// handle_key.reg_delete_value("ProgramFilesDir")! // Be careful when testing! ⚠️
// ```
// 
// If any error occurs due to lack of permission, etc... it will return a winerror.ErrorRegistry
pub fn (h HandleKey) reg_delete_value(reg string) ! {
	result := C.RegDeleteValue(h.hkey_ptr, reg.to_wide())

	if result != winerror.error_success {
		return winerror.ErrorRegistry{
			code_error_c: result
		}
	}
}

// change_mode changes the key access mode.
// Ex: .key_read to .key_write or .key_all_acess
// It is important to say that the handle_key must be mutable.
// 
// How to use:
// ```v
// handle_key.change_mode(.key_write)!
// ```
// 
// If any error occurs due to lack of permission, etc... it will return a winerror.ErrorRegistry
pub fn (mut h HandleKey) change_mode(mode AccessMode) ! {
	temp_handle := open_key(h.hkey, h.subkey, mode)!

	h.close()!

	h = temp_handle
}


// reg_set_value modifies and creates a new value in the registry.
// Its REG_SZ and REG_DWORD value is given through the value passed in dw_value.
// 
// How to use:
// ```v
// handle_key.reg_set_value("test", 123)! // REG_DWORD
// handle_key.reg_set_value("test", 123.3)! // REG_SZ
// handle_key.reg_set_value("test", "123")! // REG_SZ
// ```
// 
// If any error occurs due to lack of permission, etc... it will return a winerror.ErrorRegistry
pub fn (h HandleKey) reg_set_value(reg string, dw_value DwValue) ! {
	result := if dw_value is int {
		value := int(dw_value)
		len_value := sizeof(value)

		C.RegSetValueExW(h.hkey_ptr, reg.to_wide(), 0, u32(DwType.reg_dword), &value,
			&len_value)
	} else if dw_value is f32 {
		value := f32(dw_value).str()
		len_value := sizeof(value)

		C.RegSetValueExW(h.hkey_ptr, reg.to_wide(), 0, u32(DwType.reg_sz), &value, &len_value)
	} else if dw_value is string {
		value := dw_value.str().to_wide()
		len_value := sizeof(dw_value)

		C.RegSetValueExW(h.hkey_ptr, reg.to_wide(), 0, u32(DwType.reg_sz), value, &len_value)
	} else {
		return error("'dw_value' type not found")
	}

	if result != winerror.error_success {
		return winerror.ErrorRegistry{
			code_error_c: result
		}
	}
}