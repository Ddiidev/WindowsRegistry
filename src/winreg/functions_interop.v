module winreg

// import winreg.winerror

#include <windows.h>

fn C.RegQueryValueEx(hKey voidptr, lpValueName &u16, lp_reserved &u32, lpType &u32, lpData &u8, lpcbData &u32) int

pub fn (h HandleKey) reg_query_value(reg string) {
	// value := unsafe { nil }
	dword_value_len := u32(0)

	result := C.RegQueryValueEx(h.hkey_ptr, reg.to_wide(), unsafe { nil }, unsafe { nil }, unsafe { nil }, &dword_value_len)

	dump(dword_value_len)
	dump(result)

	// result := C.RegQueryValueEx(hkey, reg.to_wide(), 0, 0, value, &dword_value_len)
}
