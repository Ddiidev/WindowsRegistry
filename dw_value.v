module winreg

pub type DwValue = f32 | int | string

pub fn (d DwValue) str() string {
	return if d is int {
		d.str()
	} else if d is string {
		d
	} else {
		''
	}
}
