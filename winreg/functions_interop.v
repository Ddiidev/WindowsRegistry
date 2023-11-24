module winreg

// import winreg.winerror

#include <windows.h>

fn C.RegQueryValueEx(hKey voidptr, lpValueName &u16, lp_reserved &u32, lpType &u32, lpData &u8, lpcbData &u32) int

pub fn (h HandleKey) reg_query_value(reg string) string {
	size := h.get_lenth_reg_key_value(reg)
	
	value := unsafe { &u16(malloc(int(size))) }
	C.RegQueryValueEx(h.hkey_ptr, reg.to_wide(), 0, 0, value, &size)
	return unsafe { string_from_wide(value) }
}

fn (h HandleKey) get_lenth_reg_key_value(reg string) u32 {
	size := u32(0)
	C.RegQueryValueEx(h.hkey_ptr, reg.to_wide(), 0, 0, 0, &size)

	return size
}