module winerror

pub const error_success = 0
pub const error_file_not_found = 2
pub const error_access_denied = 5
pub const error_baddb = 1009
pub const error_badkey = 1010
pub const error_cantopen = 1011
pub const error_cantread = 1012
pub const error_cantwrite = 1013
pub const error_more_data = 234
pub const error_no_more_items = 259
pub const error_not_enough_memory = 8
pub const error_outofmemory = 14
pub const error_invalid_parameter = 87
pub const error_shutdown_in_progress = 1115
pub const error_timeout = 1460
pub const error_busy = 142
pub const error_invalid_handle = 6

pub struct ErrorRegistry {
	Error
	code_error_c int
}

pub fn (e ErrorRegistry) code() int {
	return e.code_error_c
}

pub fn (e ErrorRegistry) msg() string {
	return match e.code_error_c {
		winerror.error_file_not_found {
			'Key registry does not found'
		}
		winerror.error_access_denied {
			'Access is denied.'
		}
		winerror.error_baddb {
			'The registry database is corrupted.'
		}
		winerror.error_badkey {
			'The registry key is not valid.'
		}
		winerror.error_cantopen {
			'The registry key cannot be opened.'
		}
		winerror.error_cantread {
			'The registry key cannot be read.'
		}
		winerror.error_cantwrite {
			'The registry key cannot be written.'
		}
		winerror.error_no_more_items {
			'There are no more items in the registry.'
		}
		winerror.error_not_enough_memory {
			'There is not enough memory to complete the operation.'
		}
		winerror.error_outofmemory {
			'There is not enough memory to complete the operation.'
		}
		winerror.error_invalid_parameter {
			'One of the parameters is invalid.'
		}
		winerror.error_shutdown_in_progress {
			'The system is shutting down.'
		}
		winerror.error_timeout {
			'The operation has timed out.'
		}
		winerror.error_busy {
			'The registry is busy.'
		}
		else {
			'Fail with code ${e.code_error_c}'
		}
	}
}
