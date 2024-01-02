module tests

import winreg

fn test_get_enumerate_values() {
	mut h := winreg.open_key(.hkey_local_machine, r'SYSTEM\CurrentControlSet\Services\Netlogon\Parameters',
		.key_read)!

	info_values := h.enumerate_values_info()!

	assert info_values.len > 0
}
