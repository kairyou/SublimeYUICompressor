@echo off

:: NOTE: Reference: taobao YUI Compressor

SETLOCAL ENABLEEXTENSIONS

echo YUI Compressor

:: select *.js || *.css
if "%~x1" NEQ ".js" (
    if "%~x1" NEQ ".css" (
        echo NOTE: Please select a js or css file
        goto End
    )
)

:: check the JAVA
if "%JAVA_HOME%" == "" goto NoJavaHome
if not exist "%JAVA_HOME%\bin\java.exe" goto NoJavaHome
if not exist "%JAVA_HOME%\bin\native2ascii.exe" goto NoJavaHome

:: filename.source.js to filename.js or filename.js to filename.min.js
set RESULT_FILE=%~n1.min%~x1
dir /b "%~f1" | find ".source." > nul
if %ERRORLEVEL% == 0 (
    for %%a in ("%~n1") do (
        set RESULT_FILE=%%~na%~x1
    )
)

:: yuicompressor
:: shell scripts is more powerful than dos batch
set has_error="0"
set ret_file=ret.tmp
"%JAVA_HOME%\bin\java.exe" -jar "%~dp0yuicompressor-2.4.7.jar" --charset GB18030 "%~nx1" -o "%RESULT_FILE%" > "%ret_file%" 2>&1
setLocal enableDELAYedexpansion
for /f "tokens=*" %%i in (%ret_file%) do (
    set str=%%i
    set str=!str:] =] %~f1 !
    set start=!str:~0,3!
    if not "!start!"=="org" (
        if not "!start!"=="at " (
            echo !str!
        )
    )
    set has_error="1"
)
del /q "%ret_file%"

:: unicode to ascii
copy /y "%RESULT_FILE%" "%RESULT_FILE%.tmp" > nul
"%JAVA_HOME%\bin\native2ascii.exe" -encoding GB18030 "%RESULT_FILE%.tmp" "%RESULT_FILE%"

del /q "%RESULT_FILE%.tmp"

:: css fix: replace \uxxxx to \xxxx, ie6 first-letter bug
if "%~x1" == ".css" (
    "%~dp0fr.exe" "%RESULT_FILE%" -f:\u -t:\
    "%~dp0fr.exe" "%RESULT_FILE%" -f:":first-letter{" -t:":first-letter {"
)

:: print result
:: if %ERRORLEVEL% == 0 (
if %has_error% == "0" (
    echo Compress %~nx1 to %RESULT_FILE%
    for %%a in ("%RESULT_FILE%") do (
        echo size from %~z1 bytes to %%~za bytes
    )
) else (
	goto End
)
goto End

:NoJavaHome
echo NOTE: You must set the JAVA_HOME environment variable.

:End
ENDLOCAL
:: pause
