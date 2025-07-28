[Setup]
AppName=FreshTally Connector
AppVersion=1.0
DefaultDirName={pf}\FreshTally
DefaultGroupName=FreshTally
UninstallDisplayIcon={app}\main.exe
OutputDir=.
OutputBaseFilename=FreshTallyInstaller
SetupIconFile=C:\Users\user\Desktop\freshtall_connector\icon.ico
LicenseFile=C:\Users\user\Desktop\freshtall_connector\license.txt
Compression=lzma
SolidCompression=yes

[Files]
Source: "C:\Users\user\Desktop\freshtall_connector\dist\main\main.exe"; DestDir: "{app}"; Flags: ignoreversion
Source: "C:\Users\user\Desktop\freshtall_connector\serviceAccountKey.json"; DestDir: "{app}"; Flags: ignoreversion
Source: "C:\Users\user\Desktop\freshtall_connector\config.json"; DestDir: "{app}"; Flags: onlyifdoesntexist

[Icons]
Name: "{group}\FreshTally Connector"; Filename: "{app}\main.exe"
Name: "{group}\Uninstall FreshTally Connector"; Filename: "{uninstallexe}"

[Run]
Filename: "{app}\main.exe"; Description: "Launch FreshTally Connector"; Flags: nowait postinstall skipifsilent
