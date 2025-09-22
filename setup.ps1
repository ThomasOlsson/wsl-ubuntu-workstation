# Pure Cloud-Init WSL Setup
# This script simply sets up cloud-init and lets it handle everything

param(
    [string]$InstanceName = "ubuntu-workstation"
)

# Colors for output
$Green = @{ ForegroundColor = 'Green' }
$Yellow = @{ ForegroundColor = 'Yellow' }
$Red = @{ ForegroundColor = 'Red' }
$Cyan = @{ ForegroundColor = 'Cyan' }

function Write-Status {
    param([string]$Message, [string]$Color = 'White')
    Write-Host "[$((Get-Date).ToString('HH:mm:ss'))] $Message" -ForegroundColor $Color
}

function Main {
    Write-Host ""
    Write-Host "🚀 WSL Ubuntu Workstation Setup" @Green
    Write-Host "============================" @Green
    Write-Host ""
    
    # Setup cloud-init directory
    $cloudInitDir = "$env:USERPROFILE\.cloud-init"
    $userDataFile = "$InstanceName.user-data"
    $cloudInitFile = "$cloudInitDir\$InstanceName.user-data"
    
    Write-Status "Setting up cloud-init configuration..." "Cyan"
    
    # Check if user-data file exists
    if (-not (Test-Path $userDataFile)) {
        Write-Status "User-data file '$userDataFile' not found!" "Red"
        Write-Status "Make sure you're running this from the directory containing the user-data file." "Yellow"
        exit 1
    }
    
    # Create cloud-init directory if it doesn't exist
    if (-not (Test-Path $cloudInitDir)) {
        New-Item -ItemType Directory -Path $cloudInitDir -Force | Out-Null
        Write-Status "Created cloud-init directory: $cloudInitDir" "Green"
    }
    
    # Copy user-data file to cloud-init directory
    Copy-Item $userDataFile $cloudInitFile -Force
    Write-Status "Deployed cloud-init configuration to: $cloudInitFile" "Green"
    
    # Check if WSL instance already exists
    $existingInstances = wsl --list --quiet
    if ($existingInstances -contains $InstanceName) {
        Write-Status "WSL instance '$InstanceName' already exists!" "Yellow"
        $response = Read-Host "Do you want to remove it and create a fresh instance? (y/N)"
        
        if ($response -eq 'y' -or $response -eq 'Y') {
            Write-Status "Removing existing instance..." "Yellow"
            wsl --unregister $InstanceName
            if ($LASTEXITCODE -eq 0) {
                Write-Status "Successfully removed existing instance" "Green"
            } else {
                Write-Status "Failed to remove existing instance" "Red"
                exit 1
            }
        } else {
            Write-Status "Keeping existing instance. Cloud-init will only run on first boot." "Yellow"
            Write-Status "To use the new configuration, remove the instance manually:" "Yellow"
            Write-Status "  wsl --unregister $InstanceName" "Yellow"
            exit 0
        }
    }
    
    # Install Ubuntu (using Ubuntu-24.04 as base, then rename)
    Write-Status "Installing Ubuntu 24.04 as '$InstanceName'..." "Cyan"
    Write-Status "This may take several minutes..." "Yellow"
    
    wsl --install Ubuntu-24.04 --no-launch
    
    if ($LASTEXITCODE -eq 0) {
        Write-Status "Successfully installed Ubuntu-24.04" "Green"
        
        # Rename to custom instance name if different
        if ($InstanceName -ne "Ubuntu-24.04") {
            Write-Status "Renaming to '$InstanceName'..." "Cyan"
            
            # Export, unregister, and import with new name
            $tempPath = "$env:TEMP\ubuntu-workstation.tar"
            wsl --export Ubuntu-24.04 $tempPath
            wsl --unregister Ubuntu-24.04
            wsl --import $InstanceName "$env:LOCALAPPDATA\WSL\$InstanceName" $tempPath
            Remove-Item $tempPath -Force
            
            Write-Status "Successfully renamed to '$InstanceName'" "Green"
        }
    } else {
        Write-Status "Failed to install Ubuntu-24.04" "Red"
        exit 1
    }
    
    # Launch instance to trigger cloud-init
    Write-Status "Starting instance to trigger cloud-init..." "Cyan"
    Write-Status "Cloud-init will now configure the system automatically..." "Yellow"
    
    wsl -d $InstanceName -- exit
    
    # Wait for cloud-init to complete
    Write-Status "Waiting for cloud-init to complete..." "Yellow"
    $maxAttempts = 30
    $attempt = 0
    
    do {
        Start-Sleep -Seconds 10
        $attempt++
        Write-Status "Checking cloud-init status (attempt $attempt/$maxAttempts)..." "Yellow"
        
        $status = wsl -d $InstanceName -- sudo cloud-init status 2>&1
        
        if ($status -match "status: done") {
            Write-Status "Cloud-init completed successfully!" "Green"
            break
        } elseif ($status -match "status: error") {
            Write-Status "Cloud-init completed with errors" "Yellow"
            break
        }
        
        if ($attempt -ge $maxAttempts) {
            Write-Status "Cloud-init is taking longer than expected" "Yellow"
            Write-Status "You can check status manually with: wsl -d $InstanceName -- sudo cloud-init status" "Yellow"
            break
        }
    } while ($true)
    
    # Restart WSL to apply wsl.conf changes (especially default user)
    Write-Status "Restarting WSL to apply default user configuration..." "Cyan"
    wsl --shutdown
    Start-Sleep -Seconds 2
    
    # Show final status
    Write-Host ""
    Write-Host "🎉 Setup Complete!" @Green
    Write-Host ""
    Write-Host "✅ Cloud-init configuration deployed" @Green
    Write-Host "✅ WSL instance '$InstanceName' created" @Green
    Write-Host "✅ System configured automatically by cloud-init" @Green
    Write-Host ""
    Write-Host "🚀 To access your new WSL instance:" @Cyan
    Write-Host "  wsl -d $InstanceName" @Yellow
    Write-Host "  cd ~  # Important: Go to home directory" @Yellow
    Write-Host ""
    Write-Host "🔥 Ready for dotfiles! Just 2 steps:" @Cyan
    Write-Host "  1. Copy private SSH key: ~/.ssh/id_ed25519" @Yellow
    Write-Host "  2. Pull dotfiles: yadm pull `&`& yadm bootstrap" @Yellow
    Write-Host ""
    Write-Host "📋 Useful commands:" @Cyan
    Write-Host "  wsl -d $InstanceName -- sudo cloud-init status     # Check cloud-init status" @Yellow
    Write-Host "  wsl -d $InstanceName -- cloud-init query userdata  # View applied config" @Yellow
    Write-Host "  wsl --shutdown                                     # Restart all WSL instances" @Yellow
}

# Run the main function
Main