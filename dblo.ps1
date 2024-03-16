# Define a list of apps to remove
$AppsToRemove = @(
    "Microsoft.BingWeather",
    "Microsoft.DesktopAppInstaller",
    "Microsoft.GetHelp",
    "Microsoft.Getstarted",
    "Microsoft.Messaging",
    "Microsoft.Microsoft3DViewer",
    "Microsoft.MicrosoftOfficeHub",
    "Microsoft.MicrosoftSolitaireCollection",
    "Microsoft.MicrosoftStickyNotes",
    "Microsoft.MixedReality.Portal",
    "Microsoft.MSPaint",
    "Microsoft.Office.OneNote",
    "Microsoft.OneConnect",
    "Microsoft.People",
    "Microsoft.Print3D",
    "Microsoft.SkypeApp",
    "Microsoft.StorePurchaseApp",
    "Microsoft.VP9VideoExtensions",
    "Microsoft.Windows.Photos",
    "Microsoft.WindowsAlarms",
    "Microsoft.WindowsCalculator",
    "Microsoft.WindowsCamera",
    "Microsoft.WindowsFeedbackHub",
    "Microsoft.WindowsMaps",
    "Microsoft.WindowsSoundRecorder",
    "Microsoft.WindowsStore",
    "Microsoft.Xbox.TCUI",
    "Microsoft.XboxApp",
    "Microsoft.XboxGameOverlay",
    "Microsoft.XboxGamingOverlay",
    "Microsoft.XboxIdentityProvider",
    "Microsoft.XboxSpeechToTextOverlay"
)

# Define a list of features to disable
$FeaturesToDisable = @(
    "Internet-Explorer-Optional-amd64",
    "WindowsMediaPlayer",
    "MicrosoftWindowsPowerShellV2",
    "Microsoft-Windows-Subsystem-Linux",
    "Microsoft-Windows-Subsystem-Linux-WSL2",
    "XPS-Viewer",
    "WorkFolders-Client",
    "TelnetClient",
    "SMB1Protocol",
    "Printing-XPSServices-Features",
    "RDC"
)

# Define a list of services to disable
$ServicesToDisable = @(
    "AdobeARMservice",
    "AJRouter",
    "ALG",
    "AppIDSvc",
    "Appinfo",
    "AppMgmt",
    "AppReadiness",
    "AppXSvc",
    "BDESVC",
    "BrokerInfrastructure",
    "BthAvctpSvc",
    "CDPSvc",
    "ConsentUxUserSvc",
    "CredentialEnrollmentManagerUserSvc",
    "CscService",
    "DcpSvc",
    "DeviceAssociationService",
    "DeviceInstall",
    "DevicePickerUserSvc",
    "DevicesFlowUserSvc",
    "DeviceManagement",
    "DeviceManagementBroker",
    "DevicePicker",
    "DevicePickerUserSvc",
    "DevQueryBroker",
    "DiagTrack",
    "DmEnrollmentSvc",
    "DmEnrollmentUserSvc",
    "DmUserBroker",
    "dmwappushservice",
    "DPS",
    "embeddedmode",
    "Fax",
    "FDResPub",
    "FontCache",
    "FontCache3.0.0.0",
    "GoogleChromeElevationService",
    "icssvc",
    "IKEEXT",
    "lfsvc",
    "MapsBroker",
    "MessagingService_48b30",
    "MicrosoftEdgeElevationService",
    "NaturalAuthentication",
    "Netlogon",
    "NgcCtnrSvc",
    "NgcSvc",
    "NgcSvc",
    "NlaSvc",
    "NpCloudPrint",
    "ose",
    "PcaSvc",
    "PimIndexMaintenanceSvc",
    "PrintNotify",
    "RetailDemo",
    "RetailDemoOffline",
    "RpcEptMapper",
    "RSCSVC",
    "SCardSvr",
    "ScDeviceEnum",
    "SCPolicySvc",
    "SDRSVC",
    "SEMgrSvc",
    "SENS",
    "Sense",
    "SensorDataService",
    "SensorService",
    "SgrmBroker",
    "SharedAccess",
    "ShellHWDetection",
    "smphost",
    "spectrum",
    "SSDPSRV",
    "stisvc",
    "StorSvc",
    "SysMain",
    "TabletInputService",
    "TapiSrv",
    "TermService",
    "TimeBrokerSvc",
    "TrkWks",
    "UnistoreSvc",
    "upnphost",
    "UserManager",
    "UsoSvc",
    "VaultSvc",
    "wbengine",
    "Wcmsvc",
    "WdiServiceHost",
    "WdiSystemHost",
    "WdNisSvc",
    "WdNisSvc",
    "Wecsvc",
    "WerSvc",
    "WFDSConMgrSvc",
    "WiaRpc",
    "wisvc",
    "wlpasvc",
    "wlidsvc",
    "WManSvc",
    "WPCSvc",
    "wscsvc",
    "WSearch",
    "WSService",
    "WSService",
    "WwanSvc",
    "XblAuthManager",
    "XblGameSave",
    "XboxNetApiSvc",
    "XboxNetApiSvc",
    "XblAuthManager",
    "XblGameSave",
    "XboxNetApiSvc"
)

# Define lists to track failures
$FailedToRemoveApps = @()
$FailedToDisableFeatures = @()
$FailedToDisableServices = @()

# Remove built-in apps
foreach ($App in $AppsToRemove) {
    try {
        Get-AppxPackage -AllUsers | Where-Object { $_.Name -eq $App } | Remove-AppxPackage -ErrorAction Stop
        Write-Host "Removed $App"
    } catch {
        $FailedToRemoveApps += $App
    }
}

# Disable unnecessary features
foreach ($Feature in $FeaturesToDisable) {
    try {
        Disable-WindowsOptionalFeature -Online -FeatureName $Feature -NoRestart -ErrorAction Stop
        Write-Host "Disabled $Feature"
    } catch {
        $FailedToDisableFeatures += $Feature
    }
}

# Disable unnecessary services
foreach ($Service in $ServicesToDisable) {
    try {
        Stop-Service -Name $Service -ErrorAction SilentlyContinue
        Set-Service -Name $Service -StartupType Disabled -ErrorAction Stop
        Write-Host "Disabled service: $Service"
    } catch {
        $FailedToDisableServices += $Service
    }
}

# Load assembly for Windows API functions with error handling
try {
    Add-Type -TypeDefinition @"
    using System;
    using System.Runtime.InteropServices;
    public class Win32Interop {
        [DllImport("kernel32.dll", SetLastError = true)]
        [return: MarshalAs(UnmanagedType.Bool)]
        public static extern bool GetConsoleScreenBufferInfo(IntPtr hConsoleOutput, out CONSOLE_SCREEN_BUFFER_INFO lpConsoleScreenBufferInfo);

        [StructLayout(LayoutKind.Sequential)]
        public struct COORD {
            public short X;
            public short Y;
        }

        [StructLayout(LayoutKind.Sequential)]
        public struct SMALL_RECT {
            public short Left;
            public short Top;
            public short Right;
            public short Bottom;
        }

        [StructLayout(LayoutKind.Sequential)]
        public struct CONSOLE_SCREEN_BUFFER_INFO {
            public COORD dwSize;
            public COORD dwCursorPosition;
            public ushort wAttributes;
            public SMALL_RECT srWindow;
            public COORD dwMaximumWindowSize;
        }
    }
"@
} catch {
    Write-Host "Failed to load assembly for Windows API functions: $_"
}

# Get console window size using Windows API with error handling
try {
    $consoleInfo = New-Object Win32Interop+CONSOLE_SCREEN_BUFFER_INFO
    $consoleHandle = [Console]::OpenStandardOutput().Handle
    [Win32Interop]::GetConsoleScreenBufferInfo($consoleHandle, [ref]$consoleInfo) | Out-Null
    $TerminalWidth = $consoleInfo.srWindow.Right - $consoleInfo.srWindow.Left + 1
} catch {
    Write-Host "Failed to get console window size: $_"
}

# Output summary of failures with adjusted table width based on console window size
if ($FailedToRemoveApps -or $FailedToDisableFeatures -or $FailedToDisableServices) {
    $table = @()
    if ($FailedToRemoveApps) { $table += "Failed to remove apps: $($FailedToRemoveApps -join ', ')" }
    if ($FailedToDisableFeatures) { $table += "Failed to disable features: $($FailedToDisableFeatures -join ', ')" }
    if ($FailedToDisableServices) { $table += "Failed to disable services: $($FailedToDisableServices -join ', ')" }

    if ($TerminalWidth) {
        $maxTableWidth = $TerminalWidth - 4
        # Output table with adjusted width
        $table | Format-Table -Wrap -AutoSize -Property @{Label="Details";Expression={$_}} -Width $maxTableWidth
    } else {
        # Output table without adjusting width
        $table | Format-Table -Wrap -AutoSize -Property @{Label="Details";Expression={$_}}
    }
} else {
    Write-Host "It worked"
}
