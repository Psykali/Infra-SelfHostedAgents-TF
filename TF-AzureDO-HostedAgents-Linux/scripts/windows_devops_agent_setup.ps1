param(
    [string]$DevOpsOrg,
    [string]$DevOpsPAT,
    [string]$AgentPool = "Default",
    [string]$AgentName
)

# Create DevOps Agent directory
$AgentDir = "C:\DevOpsAgent"
if (!(Test-Path $AgentDir)) {
    New-Item -ItemType Directory -Path $AgentDir -Force
}

Set-Location $AgentDir

# Download the Azure DevOps agent
Write-Host "Downloading Azure DevOps agent..."
$AgentVersion = (Invoke-RestMethod -Uri "https://api.github.com/repos/microsoft/azure-pipelines-agent/releases/latest").tag_name.TrimStart('v')
$AgentZip = "vsts-agent-win-x64-$AgentVersion.zip"
$DownloadUrl = "https://vstsagentpackage.azureedge.net/agent/$AgentVersion/$AgentZip"

Invoke-WebRequest -Uri $DownloadUrl -OutFile $AgentZip

# Extract the agent
Write-Host "Extracting agent..."
Expand-Archive -Path $AgentZip -DestinationPath . -Force

# Configure the agent
Write-Host "Configuring agent..."
.\config.cmd --unattended `
    --url "https://dev.azure.com/$DevOpsOrg" `
    --auth pat `
    --token $DevOpsPAT `
    --pool $AgentPool `
    --agent $AgentName `
    --replace `
    --acceptTeeEula `
    --runAsService `
    --windowsLogonAccount "NT AUTHORITY\NETWORK SERVICE"

Write-Host "Azure DevOps agent setup completed successfully for $AgentName!"