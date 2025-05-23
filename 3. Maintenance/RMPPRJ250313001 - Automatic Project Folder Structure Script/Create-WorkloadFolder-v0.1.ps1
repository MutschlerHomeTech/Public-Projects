# Workload Folder Creation Script
# This script creates folders for Changes, Incidents, or Projects following the specified naming convention

# Function to validate input is not empty
function Test-Input {
    param (
        [string]$userInput
    )
    
    return -not [string]::IsNullOrWhiteSpace($input)
}

# Get the base workload folder path
$workloadBasePath = Join-Path -Path $env:USERPROFILE -ChildPath "Documents\Workload"

# Check if the workload folder exists, create it if not
if (-not (Test-Path -Path $workloadBasePath)) {
    Write-Host "Creating base Workload folder structure..."
    New-Item -Path $workloadBasePath -ItemType Directory | Out-Null
    
    # Create main category folders
    $categories = @("Changes", "Incidents", "Projects")
    foreach ($category in $categories) {
        $categoryPath = Join-Path -Path $workloadBasePath -ChildPath $category
        New-Item -Path $categoryPath -ItemType Directory | Out-Null
        
        # Create subcategories based on the parent folder
        $subcategories = @()
        switch ($category) {
            "Changes" {
                $subcategories = @(
                    "1. Discovery", 
                    "2. Testing", 
                    "3. Implementation", 
                    "4. Completed", 
                    "99. Uncategorized"
                )
            }
            "Incidents" {
                $subcategories = @(
                    "1. Investigation", 
                    "2. On Hold", 
                    "3. Resolved", 
                    "99. Uncategorized"
                )
            }
            "Projects" {
                $subcategories = @(
                    "1. Discovery", 
                    "2. Implementation", 
                    "3. Maintenance", 
                    "4. Decommissioned", 
                    "99. Uncategorized"
                )
            }
        }
        
        # Create each subcategory folder
        foreach ($subcategory in $subcategories) {
            $subcategoryPath = Join-Path -Path $categoryPath -ChildPath $subcategory
            New-Item -Path $subcategoryPath -ItemType Directory | Out-Null
        }
    }
    Write-Host "Base folder structure created successfully."
}

# Main script execution starts here
Write-Host "=== Workload Folder Creation Tool ===" -ForegroundColor Cyan
Write-Host "This script will create a new folder for your workload item."

# Prompt for workload type
$validSelection = $false
$workloadType = ""
$prefix = ""

while (-not $validSelection) {
    Write-Host "`nSelect the type of workload:" -ForegroundColor Yellow
    Write-Host "1. Change"
    Write-Host "2. Incident"
    Write-Host "3. Project"
    $selection = Read-Host "Enter your selection (1-3)"
    
    switch ($selection) {
        "1" {
            $workloadType = "Changes"
            $prefix = "RMCHG"
            $validSelection = $true
        }
        "2" {
            $workloadType = "Incidents"
            $prefix = "RMINC"
            $validSelection = $true
        }
        "3" {
            $workloadType = "Projects"
            $prefix = "RMPRJ"
            $validSelection = $true
        }
        default {
            Write-Host "Invalid selection. Please enter a number between 1 and 3." -ForegroundColor Red
        }
    }
}

# Get the workload name
$workloadName = ""
while (-not (Test-Input -userInput $workloadName)) {
    $workloadName = Read-Host "Enter the name of the $($workloadType.TrimEnd('s'))"
    
    if (-not (Test-Input -userInput $workloadName)) {
        Write-Host "Name cannot be empty. Please enter a valid name." -ForegroundColor Red
    }
}

# Get current date in the required format (YYMMdd)
$currentDate = Get-Date -Format "yyMMdd"

# Build the folder name
$folderName = "$prefix$currentDate - $workloadName"

# Prompt for subcategory
Write-Host "`nSelect the subcategory:" -ForegroundColor Yellow
$subcategories = @()
switch ($workloadType) {
    "Changes" {
        Write-Host "1. Discovery"
        Write-Host "2. Testing"
        Write-Host "3. Implementation"
        Write-Host "4. Completed"
        Write-Host "5. Uncategorized"
        $subcategories = @(
            "1. Discovery", 
            "2. Testing", 
            "3. Implementation", 
            "4. Completed", 
            "99. Uncategorized"
        )
    }
    "Incidents" {
        Write-Host "1. Investigation"
        Write-Host "2. On Hold"
        Write-Host "3. Resolved"
        Write-Host "4. Uncategorized"
        $subcategories = @(
            "1. Investigation", 
            "2. On Hold", 
            "3. Resolved", 
            "99. Uncategorized"
        )
    }
    "Projects" {
        Write-Host "1. Discovery"
        Write-Host "2. Implementation"
        Write-Host "3. Maintenance"
        Write-Host "4. Decommissioned"
        Write-Host "5. Uncategorized"
        $subcategories = @(
            "1. Discovery", 
            "2. Implementation", 
            "3. Maintenance", 
            "4. Decommissioned", 
            "99. Uncategorized"
        )
    }
}

$validSubcategory = $false
$subcategoryPath = ""

while (-not $validSubcategory) {
    $maxOption = if ($workloadType -eq "Incidents") { 4 } else { 5 }
    $subcategorySelection = Read-Host "Enter your selection (1-$maxOption)"
    
    $subcategoryIndex = [int]$subcategorySelection - 1
    
    # Handle "Uncategorized" as special case
    if ($subcategorySelection -eq $maxOption.ToString()) {
        $subcategoryIndex = $subcategories.Count - 1
    }
    
    if ($subcategoryIndex -ge 0 -and $subcategoryIndex -lt $subcategories.Count) {
        $subcategoryPath = Join-Path -Path $workloadBasePath -ChildPath "$workloadType\$($subcategories[$subcategoryIndex])"
        $validSubcategory = $true
    }
    else {
        Write-Host "Invalid selection. Please enter a number between 1 and $maxOption." -ForegroundColor Red
    }
}

# Create the full path for the new folder
$newFolderPath = Join-Path -Path $subcategoryPath -ChildPath $folderName

# Check if the folder already exists
if (Test-Path -Path $newFolderPath) {
    Write-Host "`nWarning: A folder with this name already exists at this location." -ForegroundColor Yellow
    $confirmation = Read-Host "Would you like to create it anyway? (Y/N)"
    
    if ($confirmation.ToUpper() -ne "Y") {
        Write-Host "Operation cancelled by user." -ForegroundColor Red
        exit
    }
}

# Create the folder
try {
    New-Item -Path $newFolderPath -ItemType Directory | Out-Null
    Write-Host "`nSuccess! Created folder:" -ForegroundColor Green
    Write-Host $newFolderPath
    
    # Open the folder in Explorer
    $openFolder = Read-Host "Would you like to open the folder now? (Y/N)"
    if ($openFolder.ToUpper() -eq "Y") {
        Invoke-Item -Path $newFolderPath
    }
}
catch {
    Write-Host "`nError creating folder: $_" -ForegroundColor Red
}
