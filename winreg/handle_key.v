module winreg

[noinit]
pub struct HandleKey {
	hkey HKEYS
	subkey string
	hkey_ptr voidptr
	mode AccessMode
}

fn HandleKey.new(key HKEYS, subkey string, hkey_ptr voidptr, mode AccessMode) !HandleKey {
	if isnil(hkey_ptr) {
		return error("Fail in handle key registry")
	}
	
	return HandleKey{
		hkey: key
		subkey: subkey
		hkey_ptr: hkey_ptr
		mode: mode
	}
}

pub enum HKEYS as u64 {
	hkey_local_machine = 0x80000002
	hkey_current_user = 0x80000001
	hkey_classes_root = 0x80000000
	hkey_users = 0x80000003
}