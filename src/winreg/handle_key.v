module winreg

pub struct HandleKey {
	hkey HKEYS
	hkey_ptr voidptr
}

pub fn HandleKey.new(key HKEYS, hkey_ptr voidptr) !HandleKey {
	if isnil(hkey_ptr) {
		return error("Fail in handle key registry")
	}
	
	return HandleKey{
		hkey: key
		hkey_ptr: hkey_ptr
	}
}