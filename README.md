
# WindowsRegistry

Windows registry wrappers for Vlang



## Documentation

[Documentation](https://WIP)


## How to use

Getting a string value.

```v
import ldedev.windowsreg.winreg

h := winreg.open_key(.hkey_local_machine, tests.subkey_current_version, .key_read)!

value := h.reg_query_value[string](tests.program_file_dir)!

println(value)
```

It is possible to get a value without needing to know the type of the value in the registry.

```v
import ldedev.windowsreg.winreg

h := winreg.open_key(.hkey_local_machine, tests.subkey_current_version, .key_read)!

value := h.reg_get_value(tests.program_file_dir)!

println(value)

if value is string {
    println("value is string")
}
```


Defining and creating new value. (Remembering that you need to be as ADM on Windows)

```v
	value_test := 'my_test'

	h := winreg.open_key(.hkey_local_machine, tests.subkey_current_version, .key_write)!

	h.reg_set_value('test', value_test)!
```