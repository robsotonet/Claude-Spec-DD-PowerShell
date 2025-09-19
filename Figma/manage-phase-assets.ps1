# ------------------------------------------------------------------------------
# 2. FIGMA ASSET MANAGEMENT SCRIPT  
# ------------------------------------------------------------------------------

# File: manage-phase-assets.ps1
param(
    [Parameter(Mandatory=$true)]
    [ValidateSet("organize", "validate", "extract-specs", "sync-tokens", "generate-components")]
    [string]$Action,
    
    [Parameter(Mandatory=$false)]
    [string]$PhaseNumber = "",
    
    [Parameter(Mandatory=$false)]
    [string]$SourcePath = ""
)

function Invoke-PhaseAssetAction {
    Write-ColorOutput "🎨 Managing Phase $PhaseNumber Figma assets..." "Cyan"
    
    switch ($Action) {
        "organize" { 
            Organize-PhaseAssets -PhaseNumber $PhaseNumber -SourcePath $SourcePath
        }
        "validate" { 
            Test-PhaseAssetCompleteness -PhaseNumber $PhaseNumber
        }
        "extract-specs" { 
            Extract-DesignSpecifications -PhaseNumber $PhaseNumber
        }
        "sync-tokens" { 
            Sync-DesignTokensWithPhase -PhaseNumber $PhaseNumber
        }
        "generate-components" { 
            New-ComponentsFromFigma -PhaseNumber $PhaseNumber
        }
    }
}

function Organize-PhaseAssets {
    param([string]$PhaseNumber, [string]$SourcePath)
    
    Write-ColorOutput "📁 Organizing Figma assets for Phase $PhaseNumber..." "Yellow"
    
    if (-not $SourcePath -or -not (Test-Path $SourcePath)) {
        Write-ColorOutput "❌ Please provide a valid source path with Figma exports" "Red"
        return
    }

    $phaseDesignDir = ".claude-code\design\phase-designs\phase-$PhaseNumber"
    
    # Organize exports by type
    $assetTypes = @{
        "screens" = @("*dashboard*", "*login*", "*register*", "*profile*", "*settings*")
        "components" = @("*button*", "*card*", "*form*", "*input*", "*modal*")
        "flows" = @("*flow*", "*journey*", "*wireframe*")
        "assets" = @("*icon*", "*logo*", "*illustration*", "*image*")
    }

    foreach ($type in $assetTypes.Keys) {
        $targetDir = "$phaseDesignDir\$type"
        
        foreach ($pattern in $assetTypes[$type]) {
            $files = Get-ChildItem -Path $SourcePath -Filter "$pattern.png" -ErrorAction SilentlyContinue
            foreach ($file in $files) {
                Copy-Item -Path $file.FullName -Destination $targetDir -Force
                Write-ColorOutput "  ✅ Moved $($file.Name) to $type/" "Green"
            }
        }
    }

    Write-ColorOutput "✅ Phase $PhaseNumber assets organized successfully" "Green"
}

function Test-PhaseAssetCompleteness {
    param([string]$PhaseNumber)
    
    Write-ColorOutput "🔍 Validating Phase $PhaseNumber asset completeness..." "Yellow"
    
    $phaseDesignDir = ".claude-code\design\phase-designs\phase-$PhaseNumber"
    $issues = @()
    $warnings = @()

    # Check if phase design directory exists
    if (-not (Test-Path $phaseDesignDir)) {
        $issues += "Phase $PhaseNumber design directory not found"
        Write-ColorOutput "❌ Phase $PhaseNumber asset validation failed" "Red"
        return
    }

    # Check required directories
    $requiredDirs = @("screens", "components", "flows", "specs")
    foreach ($dir in $requiredDirs) {
        if (-not (Test-Path "$phaseDesignDir\$dir")) {
            $warnings += "Missing directory: $dir"
        }
    }

    # Check for design specification
    if (-not (Test-Path "docs\phases\phase-$PhaseNumber\design-spec.md")) {
        $issues += "Design specification missing for Phase $PhaseNumber"
    }

    # Check for Figma links
    if (-not (Test-Path "$phaseDesignDir\figma-links.md")) {
        $warnings += "Figma links documentation missing"
    }

    # Count assets
    $screenCount = (Get-ChildItem "$phaseDesignDir\screens" -Filter "*.png" -ErrorAction SilentlyContinue).Count
    $componentCount = (Get-ChildItem "$phaseDesignDir\components" -Filter "*.png" -ErrorAction SilentlyContinue).Count
    
    Write-ColorOutput "📊 Phase $PhaseNumber Asset Summary:" "Cyan"
    Write-ColorOutput "   Screens: $screenCount" "White"
    Write-ColorOutput "   Components: $componentCount" "White"
    Write-ColorOutput "   Issues: $($issues.Count)" $(if ($issues.Count -eq 0) { "Green" } else { "Red" })
    Write-ColorOutput "   Warnings: $($warnings.Count)" $(if ($warnings.Count -eq 0) { "Green" } else { "Yellow" })

    if ($issues.Count -gt 0) {
        Write-ColorOutput "❌ Issues found:" "Red"
        foreach ($issue in $issues) {
            Write-ColorOutput "   • $issue" "Red"
        }
    }

    if ($warnings.Count -gt 0) {
        Write-ColorOutput "⚠️ Warnings:" "Yellow"
        foreach ($warning in $warnings) {
            Write-ColorOutput "   • $warning" "Yellow"
        }
    }

    if ($issues.Count -eq 0) {
        Write-ColorOutput "✅ Phase $PhaseNumber assets validation passed" "Green"
    }
}

function Extract-DesignSpecifications {
    param([string]$PhaseNumber)
    
    Write-ColorOutput "📋 Extracting design specifications for Phase $PhaseNumber..." "Yellow"
    
    # This would typically involve calling Claude Code with the design analysis prompt
    Write-ColorOutput "🤖 Use Claude Code with this command:" "Cyan"
    Write-ColorOutput "claude-code analyze 'Use design-to-phase.prompt.md to analyze Phase $PhaseNumber Figma designs and create comprehensive design specifications'" "White"
    
    Write-ColorOutput "📁 Expected outputs:" "Yellow"
    Write-ColorOutput "   • Updated docs\phases\phase-$PhaseNumber\design-spec.md" "White"
    Write-ColorOutput "   • Component specifications" "White"
    Write-ColorOutput "   • Screen implementation requirements" "White"
    Write-ColorOutput "   • Design token mapping" "White"
}

function Sync-DesignTokensWithPhase {
    param([string]$PhaseNumber)
    
    Write-ColorOutput "🔄 Syncing design tokens with Phase $PhaseNumber requirements..." "Yellow"
    
    # Check if design system needs updates for this phase
    if (Test-Path ".claude-code\design\design_system.json") {
        Write-ColorOutput "✅ Design system found - analyzing phase requirements..." "Green"
        
        # This would involve analyzing the phase designs against current tokens
        Write-ColorOutput "🤖 Use Claude Code to:" "Cyan"
        Write-ColorOutput "   1. Analyze Phase $PhaseNumber designs" "White"
        Write-ColorOutput "   2. Identify missing design tokens" "White"
        Write-ColorOutput "   3. Update design_system.json if needed" "White"
        Write-ColorOutput "   4. Generate updated CSS variables" "White"
        
    } else {
        Write-ColorOutput "❌ Design system not found - create design_system.json first" "Red"
    }
}

function New-ComponentsFromFigma {
    param([string]$PhaseNumber)
    
    Write-ColorOutput "🏗️ Generating components from Phase $PhaseNumber Figma designs..." "Yellow"
    
    $phaseComponentsDir = ".claude-code\design\phase-designs\phase-$PhaseNumber\components"
    
    if (-not (Test-Path $phaseComponentsDir)) {
        Write-ColorOutput "❌ Phase $PhaseNumber components directory not found" "Red"
        return
    }

    $componentFiles = Get-ChildItem $phaseComponentsDir -Filter "*.png"
    
    Write-ColorOutput "📦 Found $($componentFiles.Count) components to implement:" "Cyan"
    foreach ($file in $componentFiles) {
        $componentName = $file.BaseName -replace '-', ''
        Write-ColorOutput "   • $componentName" "White"
    }

    Write-ColorOutput "🤖 Use Claude Code commands:" "Cyan"
    Write-ColorOutput "claude-code implement 'Use phase-design-implement.prompt.md to build Phase $PhaseNumber components from Figma designs'" "White"
}

# Execute the specified action
if (-not $PhaseNumber) {
    $PhaseNumber = Read-Host "Enter phase number"
}

Invoke-PhaseAssetAction