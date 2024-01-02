module tests

import winreg

const subkey_current_version = r'SOFTWARE\Microsoft\Windows\CurrentVersion'

fn test_set_value_string() ! {
	value_test := 'my_test'

	h_write := winreg.open_key(.hkey_local_machine, tests.subkey_current_version, .key_write)!
	h_read := winreg.open_key(.hkey_local_machine, tests.subkey_current_version, .key_read)!

	h_write.set_value('test', value_test)!

	h_write.close()!

	assert h_read.query_value[string]('test')! == value_test

	h_read.close()!
}

fn test_set_value_int() ! {
	value_test := 12345

	h_write := winreg.open_key(.hkey_local_machine, tests.subkey_current_version, .key_write)!
	h_read := winreg.open_key(.hkey_local_machine, tests.subkey_current_version, .key_read)!

	h_write.set_value('test', value_test)!

	h_write.close()!

	assert h_read.query_value[int]('test')! == value_test

	h_read.close()!
}
