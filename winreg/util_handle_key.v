module winreg

// get_lenth_reg_value pega o comprimento exato do valor do registro.
//
// Caso ocorra algum erro de falta de permissão, etc... irá retornar um winerror.ErrorRegistry
fn (h HandleKey) get_lenth_reg_value(reg string) !u32 {
	size := u32(0)
	result := C.RegQueryValueEx(h.hkey_ptr, reg.to_wide(), 0, 0, 0, &size)

	if result != winerror.error_success {
		return winerror.ErrorRegistry
		{
			code_error_c:
			result
		}
	}

	return size
}

// get_type_reg_value pega o tipo exato do valor do registro.
// Ex: REG_SZ, REG_DWORD, REG_BINARY, etc...
//
// Caso ocorra algum erro de falta de permissão, etc... irá retornar um winerror.ErrorRegistry
fn (h HandleKey) get_type_reg_value(reg string) !u32 {
	dw_type := u32(0)
	result := C.RegQueryValueEx(h.hkey_ptr, reg.to_wide(), 0, &dw_type, 0, 0)

	if result != winerror.error_success {
		return winerror.ErrorRegistry
		{
			code_error_c:
			result
		}
	}

	return dw_type
}
