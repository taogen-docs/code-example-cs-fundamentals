@ECHO OFF

set "log_file_dir=%USERPROFILE%\ClearJunkLog"
set "curr_date=%date:~0,4%%date:~5,2%%date:~8,2%"
set "log_filename=clear_junk_%curr_date%.log"
set "log_filepath=%log_file_dir%\%log_filename%"

if not exist "%log_file_dir%" mkdir %log_file_dir%

ECHO =============================================== >> %log_filepath% 2>&1
ECHO start to clear Windows junk >> %log_filepath% 2>&1
ECHO %date:~0,4%-%date:~5,2%-%date:~8,2% %time:~0,2%:%time:~3,2%:%time:~6,2% >> %log_filepath% 2>&1
ECHO =============================================== >> %log_filepath% 2>&1


:: Temp
(ECHO Y | FORFILES /s /p "%USERPROFILE%\AppData\Local\Temp" /M "*" -d -7 -c "cmd /c del /q @path") >> %log_filepath% 2>&1

ECHO clear temporary files is Done! >> %log_filepath% 2>&1


:: Recycle Bin
(ECHO Y | rd /s /q %systemdrive%\$RECYCLE.BIN) >> %log_filepath% 2>&1

ECHO clear recycle bin is Done! >> %log_filepath% 2>&1


:: Application Cache Files
:: WeChat
(del /s /q "%USERPROFILE%\Documents\WeChat Files\*.*") >> %log_filepath% 2>&1

ECHO clear wechat cache files id Done! >> %log_filepath% 2>&1

:: Log Files
cd C:/
(ECHO Y | FORFILES /s /p "C:" /M "*.log" -d -7 -c "cmd /c del /q @path") >> %log_filepath% 2>&1

ECHO clear log files id Done! >> %log_filepath% 2>&1

ECHO =============================================== >> %log_filepath% 2>&1
ECHO Done >> %log_filepath% 2>&1
ECHO %date:~0,4%-%date:~5,2%-%date:~8,2% %time:~0,2%:%time:~3,2%:%time:~6,2% >> %log_filepath% 2>&1
ECHO =============================================== >> %log_filepath% 2>&1

:: PAUSE