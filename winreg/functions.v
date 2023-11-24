module winreg
import winreg.winerror

#include <windows.h>

fn C.RegOpenKeyEx(hKey voidptr, lpSubKey &u16, ulOptions u32, samDesired u32, phkResult voidptr) int
// fn C.RegOpenKeyExW(hKey voidptr, lpSubKey &u16, ulOptions u32, samDesired u32, phkResult voidptr) int

pub fn open_key(hkey HKEYS, subkey string, permission Permission) !HandleKey {
	mut result_hkey := unsafe { nil }

	mut result := C.RegOpenKeyEx(u64(hkey), subkey.to_wide(), 0, int(permission), &result_hkey)

	if result != winerror.error_success {
		return winerror.ErrorRegistry{
			code_error_c: result
		}
	}

	return HandleKey.new(hkey, result_hkey, permission)
}
