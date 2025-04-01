# Define Variables
$dotnetInstallerUrl = "<ARTIFACTORY_URL>/dotnet-runtime-win-x64.exe"
$dotnetInstallerPath = "C:\ImagePOC\dotnet-runtime-win-x64.exe"
$applicationUrl = "<ARTIFACTORY_URL>/SampleApp.zip"
$appZipPath = "C:\ImagePOC\SampleApp.zip"
$appExtractPath = "C:\ImagePOC\SampleApp"
$appExecutable = "$appExtractPath\SampleApp.exe"
$serviceName = "SampleAppService"
$logFile = "C:\ImagePOC\app-log.txt"

# Create ImagePOC Directory
Write-Output "Creating ImagePOC directory..."
New-Item -ItemType Directory -Path "C:\ImagePOC" -Force | Out-Null

# Download .NET Runtime from Artifactory
Write-Output "Downloading .NET Runtime from Artifactory..."
Invoke-WebRequest -Uri $dotnetInstallerUrl -OutFile $dotnetInstallerPath -Headers @{"X-JFrog-Art-Api"="<API_KEY>"}

# Install .NET Runtime
Write-Output "Installing .NET Runtime..."
Start-Process -FilePath $dotnetInstallerPath -ArgumentList "/quiet /norestart" -Wait -NoNewWindow

# Verify .NET Installation
Write-Output "Verifying .NET Installation..."
$dotnetVersion = & "C:\Program Files\dotnet\dotnet.exe" --version
if ($dotnetVersion) {
    Write-Output "Installed .NET Version: $dotnetVersion"
} else {
    Write-Output "ERROR: .NET installation failed!"
    exit 1
}

# Download Application from Artifactory
Write-Output "Downloading Sample Application from Artifactory..."
Invoke-WebRequest -Uri $applicationUrl -OutFile $appZipPath -Headers @{"X-JFrog-Art-Api"="<API_KEY>"}

# Extract Application
Write-Output "Extracting Sample Application..."
Expand-Archive -Path $appZipPath -DestinationPath $appExtractPath -Force

# Verify Extraction
if (Test-Path $appExecutable) {
    Write-Output "Application extracted successfully!"
} else {
    Write-Output "ERROR: Application extraction failed!"
    exit 1
}

# Compile .NET Application (If Source Code is Provided)
if (Test-Path "$appExtractPath\Program.cs") {
    Write-Output "Compiling .NET Application..."
    & "C:\Program Files\dotnet\dotnet.exe" publish "$appExtractPath" -c Release -o "$appExtractPath"
}

# Create a Windows Service to Run the Application
Write-Output "Registering Application as a Windows Service..."
$servicePath = "$appExtractPath\SampleApp.exe"

# Remove Existing Service (If Any)
if (Get-Service -Name $serviceName -ErrorAction SilentlyContinue) {
    Stop-Service -Name $serviceName -Force
    sc.exe delete $serviceName
    Start-Sleep -Seconds 3
}

# Register New Service
sc.exe create $serviceName binPath= $servicePath start= auto
Start-Service -Name $serviceName

# Log Application Start
Write-Output "[$(Get-Date)] Application Service Started." | Out-File -Append -FilePath $logFile

# Cleanup Installation Files
Write-Output "Cleaning up installation files..."
Remove-Item -Path $dotnetInstallerPath -Force
Remove-Item -Path $appZipPath -Force

Write-Output "Installation complete. The application is running as a Windows Service!"
