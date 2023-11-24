module winreg

pub enum HKEYS as u64 {
	hkey_local_machine = 0x80000002
	hkey_current_user = 0x80000001
	hkey_classes_root = 0x80000000
	hkey_users = 0x80000003
}