module tests

import winreg
import winreg.winerror { ErrorRegistry }

const subkey_current_version = r'SOFTWARE\Microsoft\Windows\CurrentVersion'
const subkey_file_system = r'SYSTEM\CurrentControlSet\Control\FileSystem'

const program_file_dir = 'ProgramFilesDir'
const long_path_enabled = r'LongPathsEnabled'
// retro compatible
fn test_get_value_string() ! {
	h := winreg.open_key(.hkey_local_machine, tests.subkey_current_version, .key_read)!

	value := h.query_value[string](tests.program_file_dir)!

	assert value == r'C:\Program Files'
}

fn test_get_value_int() ! {
	h := winreg.open_key(.hkey_local_machine, tests.subkey_file_system, .key_read)!

	value := h.query_value[int](tests.long_path_enabled)!

	assert value == 1
}

fn test_get_value_auto() ! {
	h := winreg.open_key(.hkey_local_machine, tests.subkey_current_version, .key_read)!

	value := h.get_value(tests.program_file_dir)!

	assert value.str() == r'C:\Program Files'
}

fn test_get_value_force_fail() ! {
	h := winreg.open_key(.hkey_local_machine, r'SOFTWARE\Microsoft\Windows\CurrentVersionForceFail',
		.key_read) or {
		if err is ErrorRegistry {
			assert err.code() == winerror.error_file_not_found
			return
		}

		assert false
		return
	}
}
