module winreg

import winreg.winerror

#include <windows.h>

$if windows {
	$if tinyc {
		#flag -ladvapi32
	}
}

// fn C.RegGetValue(hKey voidptr, lpSubKey u32, lpValue &u16, dwFlags &u32, lpType &u32, lpData &u8, lpcbData &u32) int
fn C.RegQueryValueEx(hKey voidptr, lpValueName &u16, lp_reserved &u32, lpType &u32, lpData &u8, lpcbData &u32) int
fn C.RegOpenKeyEx(hKey voidptr, lpSubKey &u16, ulOptions u32, samDesired u32, phkResult voidptr) int
fn C.RegCloseKey(hKey voidptr) int

pub fn (h HandleKey) reg_get_value(reg string) !string {
	typ := h.get_type_reg_value(reg)!

	return if typ == u32(DwType.reg_dword) {
		h.reg_query_value[int](reg)!.str()
	} else {
		h.reg_query_value[string](reg)!
	}
}

pub fn (h HandleKey) reg_query_value[T](reg string) !T {
	size := h.get_lenth_reg_value(reg)!
	typ := h.get_type_reg_value(reg)!
	value := unsafe { &u16(malloc(int(size))) }
	mut result := 0

	// $if T is string {
	// 	result = C.RegQueryValueEx(h.hkey_ptr, reg.to_wide(), 0, &typ, value, &size)
	// } $else {
		result = C.RegQueryValueEx(h.hkey_ptr, reg.to_wide(), 0, &typ, value, &size)
	// }

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

fn (h HandleKey) get_lenth_reg_value(reg string) !u32 {
	size := u32(0)
	result := C.RegQueryValueEx(h.hkey_ptr, reg.to_wide(), 0, 0, 0, &size)

	if result != winerror.error_success {
		return winerror.ErrorRegistry{
			code_error_c: result
		}
	}

	return size
}

fn (h HandleKey) get_type_reg_value(reg string) !u32 {
	dw_type := u32(0)
	result := C.RegQueryValueEx(h.hkey_ptr, reg.to_wide(), 0, &dw_type, 0, 0)

	if result != winerror.error_success {
		return winerror.ErrorRegistry{
			code_error_c: result
		}
	}

	return dw_type
}

pub fn (mut h HandleKey) change_mode(mode AccessMode) ! {
	temp_handle := open_key(h.hkey, h.subkey, h.mode)!

	h.close()!

	h = temp_handle
}

pub fn (mut h HandleKey) close() ! {
	result := C.RegCloseKey(h.hkey_ptr)

	if result != winerror.error_success {
		return winerror.ErrorRegistry{
			code_error_c: result
		}
	}
}

pub type DwValue = f32 | int | string

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
