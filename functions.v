module winreg

import winerror

#include <windows.h>

$if windows {
	$if tinyc {
		#flag -ladvapi32
	}
}

// open_key Opens a specific Windows registry key.
//
// ### How to use:
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
// ### How to use:
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

// get_value takes a value of types REG_SZ and REG_DWORD, and returns it as DwValue.
// If you don't know the type of the value, this function can help a lot.
//
// ### How to use:
// ```v
// program_files_dir := handle_key.get_value("ProgramFilesDir")!
//
// if program_files_dir is string {
// 	println('program_files_dir is string: "$program_files_dir"')
// } else {
// 	println('program_files_dir is int: "$program_files_dir"')
// }
// ```
//
// If any error occurs due to lack of permission, etc... it will return a winerror.ErrorRegistry
pub fn (h HandleKey) get_value(reg string) !DwValue {
	typ := h.get_type_reg_value(reg)!

	return if typ == u32(DwType.reg_dword) {
		h.query_value[int](reg)!
	} else {
		h.query_value[string](reg)!
	}
}

// query_value[T] takes a value of types REG_SZ and REG_DWORD, and returns it with the specified generic type.
// You need to know exactly what type is expected, if the value is a REG_DWORD and T is equal to a string
// Some invalid data will then be returned.
//
// ### How to use:
// ```v
// program_files_dir := handle_key.query_value[string]("ProgramFilesDir")!
//
// println('program_files_dir is my string: "$program_files_dir"')
// ```
//
// If any error occurs due to lack of permission, etc... it will return a winerror.ErrorRegistry
pub fn (h HandleKey) query_value[T](reg string) !T {
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

// enumerate_values_info Enumerates the values information of a registry key.
// Retrieves information about all the values present in the registry key.
//
// ### How to use:
// ```v
//  h := winreg.open_key(.hkey_current_user, r"Software\Microsoft\Windows\CurrentVersion")
//
//  values := h.enumerate_values_info()!
//
//	for value in values {
//
//		println("Value Name: ${value.name} | Value Type: ${value.typ}")
//
//	}
// ```
//
// If any error occurs due to lack of permission, etc... it will return a winerror.ErrorRegistry
pub fn (h HandleKey) enumerate_values_info() ![]InfoValues {
	mut values := []InfoValues{}

	mut i := 0
	for {
		values << h.info_value(i, 0) or {
			if err.code() == winerror.error_no_more_items {
				break
			} else {
				return err
			}
		}

		i++
	}

	return values
}

// info_value returns information about a specific value in the Windows registry.
// Parameter:
// - index: the index of the value to be queried.
// - initial_name_size: the initial size for memory allocation of the value name (256 default).
// Return:
// - InfoValues: structure containing name and type of the value.
// - !ErrorRegistry: in case of error, returns an ErrorRegistry containing the error code (.code()) and error message (.msg()).
//
// If any error occurs due to lack of permission, etc... it will return a winerror.ErrorRegistry
@[manualfree]
fn (h HandleKey) info_value(index int, initial_name_size int) !InfoValues {
	mut value := InfoValues{}
	mut name_len := u32(256)
	if initial_name_size > 0 {
		name_len = u32(initial_name_size)
	}
	mut name := unsafe { &u16(malloc(name_len)) }
	mut typ := u32(0)

	result := C.RegEnumValue(h.hkey_ptr, index, name, &name_len, 0, &typ, 0, 0)

	if result == winerror.error_more_data {
		value = h.info_value(index, name_len * 2)!
	} else if result == winerror.error_success {
		value.name = unsafe { string_from_wide(name) }
		value.typ = DwType.get(typ)!
	} else {
		return winerror.ErrorRegistry{
			code_error_c: result
		}
	}

	unsafe {
		free(name)
	}

	return value
}

// delete_value deletes a value from the registry.
// To delete registry values, the application must have elevated permissions on the OS.
//
// ### How to use:
// ```v
// handle_key.delete_value("ProgramFilesDir")! // Be careful when testing! ⚠️
// ```
//
// If any error occurs due to lack of permission, etc... it will return a winerror.ErrorRegistry
pub fn (h HandleKey) delete_value(reg string) ! {
	result := C.RegDeleteValue(h.hkey_ptr, reg.to_wide())

	if result != winerror.error_success {
		return winerror.ErrorRegistry{
			code_error_c: result
		}
	}
}

// set_value modifies and creates a new value in the registry.
// Its REG_SZ and REG_DWORD value is given through the value passed in dw_value.
//
// ### How to use:
// ```v
// handle_key.set_value("test", 123)! // REG_DWORD
// handle_key.set_value("test", 123.3)! // REG_SZ
// handle_key.set_value("test", "123")! // REG_SZ
// ```
//
// If any error occurs due to lack of permission, etc... it will return a winerror.ErrorRegistry
pub fn (h HandleKey) set_value(reg string, dw_value DwValue) ! {
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
