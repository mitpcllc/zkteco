@echo off
cls

:: BatchGotAdmin
:-------------------------------------
REM  --> Check for permissions
>nul 2>&1 "%SYSTEMROOT%\system32\cacls.exe" "%SYSTEMROOT%\system32\config\system"

REM --> If error flag set, we don't have admin.
if %errorlevel% NEQ 0 (
    echo Requesting administrative privileges...
    goto UACPrompt
) else (
    goto gotAdmin
)

:UACPrompt
echo Set UAC = CreateObject^("Shell.Application"^) > "%temp%\getadmin.vbs"
echo UAC.ShellExecute "%~s0", "", "", "runas", 1 >> "%temp%\getadmin.vbs"

"%temp%\getadmin.vbs"
exit /B

:gotAdmin
if exist "%temp%\getadmin.vbs" (
    del "%temp%\getadmin.vbs"
)
:: ---------------------- Your script content -------------------------

mkdir "C:\.Medsoft"
cd "C:\.Medsoft"

:: ---------------------- Driver -------------------------
set "driverFolder=C:\Program Files (x86)\FPSensor\bin"
set "javaFolder=C:\Program Files\Java\jdk-17\bin"
set "serviceInstaller=C:\.Medsoft\zkteco.exe"
set "serviceInstallerXml=C:\.Medsoft\zkteco.xml"
set "jarPath=C:\.Medsoft\medsoft-tkteco-client.jar"

if not exist "%driverFolder%" (
    echo Downloading Driver...
    powershell -Command "& {Invoke-WebRequest -Uri 'https://github.com/mitpcllc/zkteco/raw/main/driver.exe' -OutFile 'driver.exe'}"
    echo Driver downloaded.

    echo Installing Driver...
    start /wait driver.exe /S
    echo Driver has been installed.

    echo Deleting Driver Installer file...
    del driver.exe
    echo Driver Installer deleted.
) else (
    echo Driver Already Installed
)


:: ---------------------- Java 17 -------------------------

if not exist "%javaFolder%" (
    echo Downloading Java 17...
    powershell -Command "& {Invoke-WebRequest -Uri 'https://download.oracle.com/java/17/archive/jdk-17.0.9_windows-x64_bin.exe' -OutFile 'java.exe'}"
    echo Java 17 downloaded.

    echo Installing Java 17...
    start /wait java.exe
    echo Java 17 has been installed.

    echo Deleting Java 17 Installer file...
    del java.exe
    echo Java 17 Installer deleted.
) else (
    echo Java 17 Already Installed
)

:CheckDotNet
reg query "HKLM\SOFTWARE\Microsoft\NET Framework Setup\NDP\v3.5" >nul 2>&1
if %errorlevel% neq 0 (
    echo .NET 3.5 is not installed. Installing...
    start /wait DISM /Online /Enable-Feature /FeatureName:NetFx3 /All /NoRestart
    echo .NET 3.5 has been installed.
    goto :MainScript
) else (
    echo .NET 3.5 is installed. Proceeding with the script.
    goto :MainScript
)

:MainScript
:: ---------------------- Service Installer -------------------------

if not exist "%serviceInstaller%" (
	echo Downloading Service Installer...
	powershell -Command "& {Invoke-WebRequest -Uri 'https://github.com/mitpcllc/zkteco/raw/main/zkteco.exe' -OutFile 'zkteco.exe'}"
	echo Service Installer downloaded.
	
	echo zkteco.exe starting
	start /wait .\zkteco.exe
) else (
	echo Service Installer Exists
	start /wait .\zkteco.exe
)


:: ---------------------- Jar -------------------------

if exist "%jarPath%" (
	echo zkteco.exe stoping
	start /wait .\zkteco.exe stop
	del medsoft-tkteco-client.jar
	
	echo Downloading Jar...
	powershell -Command "& {Invoke-WebRequest -Uri 'https://github.com/mitpcllc/zkteco/raw/main/medsoft-tkteco-client.jar' -OutFile 'medsoft-tkteco-client.jar'}"
	echo Jar downloaded.

	echo zkteco.exe starting
	start /wait .\zkteco.exe install
	start /wait .\zkteco.exe start
) else (
	echo Downloading Jar...
	powershell -Command "& {Invoke-WebRequest -Uri 'https://github.com/mitpcllc/zkteco/raw/main/medsoft-tkteco-client.jar' -OutFile 'medsoft-tkteco-client.jar'}"
	echo Jar downloaded.
)


:: ---------------------- Service Installer XML -------------------------

if not exist "%serviceInstallerXml%" (
    echo Downloading Service Installer XML...
    powershell -Command "& {Invoke-WebRequest -Uri 'https://github.com/mitpcllc/zkteco/raw/main/zkteco.xml' -OutFile 'zkteco.xml'}"
    echo Service Installer XML downloaded.
    
    echo Installing Service...
    start /wait .\zkteco.exe install
    echo Service installation completed.
    
    echo Starting Service...
    start /wait .\zkteco.exe start
    echo Service started.
) else (
    echo Service Installer XML Exists
)

pause
