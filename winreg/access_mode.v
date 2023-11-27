module winreg

pub enum AccessMode {
	key_read      = 0x20019
	key_write     = 0x20006
	key_all_acess = 0xF003F
}

pub fn (p AccessMode) teste() string {
	return 'opa'
}
