# Define Variables
$dotnetInstallerUrl = "<ARTIFACTORY_URL>/dotnet-runtime-win-x64.exe"
$dotnetInstallerPath = "C:\Temp\dotnet-runtime-win-x64.exe"
$applicationUrl = "<ARTIFACTORY_URL>/SampleApp.zip"
$appZipPath = "C:\Temp\SampleApp.zip"
$appExtractPath = "C:\SampleApp"
$appExecutable = "C:\SampleApp\SampleApp.exe"

# Create Temp Directory
Write-Output "Creating temporary directory for installation..."
New-Item -ItemType Directory -Path "C:\Temp" -Force | Out-Null

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

# Cleanup Temp Files
Write-Output "Cleaning up installation files..."
Remove-Item -Path "C:\Temp" -Recurse -Force

Write-Output "Installation complete. The application is ready to be executed!"
