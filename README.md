
# WindowsRegistry

Windows registry wrappers for Vlang



## Documentation

[Documentation](https://ldedev.github.io/WindowsRegistry)


## How to use

Getting a string value.

```v
import ldedev.windowsreg.winreg

h := winreg.open_key(.hkey_local_machine, r'SOFTWARE\Microsoft\Windows\CurrentVersion', .key_read)!

value := h.reg_query_value[string]('ProgramFilesDir')!

println(value)
```

It is possible to get a value without needing to know the type of the value in the registry.

```v
import ldedev.windowsreg.winreg

h := winreg.open_key(.hkey_local_machine, r'SOFTWARE\Microsoft\Windows\CurrentVersion', .key_read)!

value := h.reg_get_value('ProgramFilesDir')!

println(value)

if value is string {
    println("value is string")
}
```


Defining and creating new value. (Remembering that you need to be as ADM on Windows)

```v
	value_test := 'my_test'

	h := winreg.open_key(.hkey_local_machine, r'SOFTWARE\Microsoft\Windows\CurrentVersion', .key_write)!

	h.reg_set_value('test', value_test)!
```