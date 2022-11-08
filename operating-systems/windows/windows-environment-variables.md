# Windows Environment Variables

## Variables that are processed for the operating system and in the context of each user

- `%HOMEDRIVE%` or `%SYSTEMDRIVE%`: `C:`
- `%HOMEPATH%`: `\Users\Taogen`
- `%WINDIR%` or `%SYSTEMROOT%`: `C:\Windows`
- `%PROGRAMFILES(X86)%`: `C:\Program Files (x86)`
- `%PATH%`

## Variables that are recognized only in the user context

- `%USERPROFILE%`: `C:\Users\{userName}`
- `%APPDATA%` or `CSIDL_APPDATA`: `C:\Users\{userName}\AppData\Roaming`
- `%LocalAppData%`: `C:\Users\{userName}\AppData\Local`
- `%TEMP%` or `%TMP%`: `%USERPROFILE%\AppData\Local\Temp`

## References

- [Recognized Environment Variables](https://learn.microsoft.com/en-us/windows/deployment/usmt/usmt-recognized-environment-variables)