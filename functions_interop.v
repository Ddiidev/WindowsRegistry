module winreg

fn C.RegQueryValueEx(hKey voidptr, lpValueName &u16, lp_reserved &u32, lpType &u32, lpData &u8, lpcbData &u32) int
fn C.RegDeleteValue(hKey voidptr, lpValueName &u16) int
fn C.RegOpenKeyEx(hKey voidptr, lpSubKey &u16, ulOptions u32, samDesired u32, phkResult voidptr) int
fn C.RegCloseKey(hKey voidptr) int
fn C.RegEnumValue(hKey voidptr, dwIndex u32, lpValueName &u16, lpcchValueName &u32, lpReserved &u32, lpType &u32, lpData &u8, lpcbData &u32) int
