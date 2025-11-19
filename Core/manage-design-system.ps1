# ------------------------------------------------------------------------------
# 2. DESIGN SYSTEM MANAGEMENT SCRIPT
# ------------------------------------------------------------------------------

# File: manage-design-system.ps1
param(
    [Parameter(Mandatory=$true)]
    [ValidateSet("setup", "extract-tokens", "validate", "update", "generate-css")]
    [string]$Action,
    
    [Parameter(Mandatory=$false)]
    [string]$DesignSystemPath = "",
    
    [Parameter(Mandatory=$false)]
    [string]$OutputPath = ".claude-code\design"
)

function Invoke-DesignSystemAction {
    switch ($Action) {
        "setup" { 
            Set-DesignSystemStructure 
        }
        "extract-tokens" { 
            Extract-DesignTokens -SourcePath $DesignSystemPath
        }
        "validate" { 
            Test-DesignSystemIntegrity 
        }
        "update" { 
            Update-DesignSystem -SourcePath $DesignSystemPath
        }
        "generate-css" { 
            New-CSSVariables 
        }
    }
}

function Set-DesignSystemStructure {
    Write-ColorOutput "🎨 Setting up design system structure..." "Cyan"
    
    $designDirs = @(
        ".claude-code\design",
        ".claude-code\design\figma-exports\screens",
        ".claude-code\design\figma-exports\components",
        ".claude-code\design\figma-exports\icons",
        ".claude-code\design\figma-exports\assets",
        ".claude-code\design\design-tokens",
        ".claude-code\design\design-specs"
    )

    foreach ($dir in $designDirs) {
        New-Item -ItemType Directory -Path $dir -Force | Out-Null
    }

    # Create figma-links.md
    $figmaLinksContent = @'
# Figma Design References

## Main Design File
- **Figma URL**: [Add your Figma file URL here]
- **Last Updated**: [Update date when changes are made]
- **Design System**: [Add design system Figma URL if separate]

## Access and Permissions
- **View Access**: [team@company.com]
- **Edit Access**: [designers@company.com]
- **Developer Handoff**: [developers@company.com]

## Export Locations
- **Screens**: .claude-code/design/figma-exports/screens/
- **Components**: .claude-code/design/figma-exports/components/
- **Icons**: .claude-code/design/figma-exports/icons/
- **Assets**: .claude-code/design/figma-exports/assets/

## Export Settings
- **Screens**: PNG at 2x resolution for reference
- **Components**: PNG at 2x + SVG for icons
- **Specifications**: Use Figma Dev Mode or manual annotation
'@

    $figmaLinksContent | Out-File -FilePath ".claude-code\design\figma-links.md" -Encoding UTF8

    Write-ColorOutput "✅ Design system structure created" "Green"
}

function Extract-DesignTokens {
    param([string]$SourcePath)
    
    if (-not $SourcePath -or -not (Test-Path $SourcePath)) {
        Write-ColorOutput "❌ Please provide a valid path to design_system.json" "Red"
        return
    }

    Write-ColorOutput "🔧 Extracting design tokens..." "Cyan"

    try {
        $designSystem = Get-Content $SourcePath | ConvertFrom-Json
        
        # Copy main design system file
        Copy-Item -Path $SourcePath -Destination ".claude-code\design\design_system.json" -Force

        # Create token directory
        New-Item -ItemType Directory -Path ".claude-code\design\design-tokens" -Force | Out-Null

        # Extract individual token categories
        if ($designSystem.colors) {
            $designSystem.colors | ConvertTo-Json -Depth 10 | 
                Out-File ".claude-code\design\design-tokens\colors.json" -Encoding UTF8
        }

        if ($designSystem.typography) {
            $designSystem.typography | ConvertTo-Json -Depth 10 | 
                Out-File ".claude-code\design\design-tokens\typography.json" -Encoding UTF8
        }

        if ($designSystem.spacing) {
            $designSystem.spacing | ConvertTo-Json -Depth 10 | 
                Out-File ".claude-code\design\design-tokens\spacing.json" -Encoding UTF8
        }

        if ($designSystem.components) {
            $designSystem.components | ConvertTo-Json -Depth 10 | 
                Out-File ".claude-code\design\design-tokens\components.json" -Encoding UTF8
        }

        Write-ColorOutput "✅ Design tokens extracted successfully" "Green"
        Write-ColorOutput "📁 Tokens available in .claude-code\design\design-tokens\" "White"

    } catch {
        Write-ColorOutput "❌ Error extracting tokens: $($_.Exception.Message)" "Red"
    }
}

function Test-DesignSystemIntegrity {
    Write-ColorOutput "🔍 Validating design system integrity..." "Cyan"
    
    $errors = @()
    $warnings = @()

    # Check if design_system.json exists
    if (-not (Test-Path ".claude-code\design\design_system.json")) {
        $errors += "design_system.json not found in .claude-code\design\"
    } else {
        try {
            $designSystem = Get-Content ".claude-code\design\design_system.json" | ConvertFrom-Json
            
            # Validate structure
            $requiredSections = @("colors", "typography", "spacing")
            foreach ($section in $requiredSections) {
                if (-not $designSystem.$section) {
                    $warnings += "Missing recommended section: $section"
                }
            }

            Write-ColorOutput "✅ Design system JSON is valid" "Green"
            
        } catch {
            $errors += "Invalid JSON in design_system.json: $($_.Exception.Message)"
        }
    }

    # Check template files
    $requiredTemplates = @(
        ".claude-code\prompts\design-analysis.prompt.md",
        ".claude-code\prompts\component-generation.prompt.md"
    )

    foreach ($template in $requiredTemplates) {
        if (-not (Test-Path $template)) {
            $warnings += "Missing design template: $template"
        }
    }

    # Report results
    if ($errors.Count -eq 0) {
        Write-ColorOutput "✅ Design system validation passed" "Green"
    } else {
        Write-ColorOutput "❌ Design system validation failed:" "Red"
        foreach ($error in $errors) {
            Write-ColorOutput "   • $error" "Red"
        }
    }

    if ($warnings.Count -gt 0) {
        Write-ColorOutput "⚠️  Warnings:" "Yellow"
        foreach ($warning in $warnings) {
            Write-ColorOutput "   • $warning" "Yellow"
        }
    }
}

function Update-DesignSystem {
    param([string]$SourcePath)
    
    if (-not $SourcePath -or -not (Test-Path $SourcePath)) {
        Write-ColorOutput "❌ Please provide a valid path to updated design_system.json" "Red"
        return
    }

    Write-ColorOutput "🔄 Updating design system..." "Cyan"

    # Backup existing design system
    if (Test-Path ".claude-code\design\design_system.json") {
        $backupName = "design_system.backup.$(Get-Date -Format 'yyyyMMdd-HHmm').json"
        Copy-Item ".claude-code\design\design_system.json" ".claude-code\design\$backupName"
        Write-ColorOutput "✅ Backup created: $backupName" "Green"
    }

    # Update design system
    Copy-Item -Path $SourcePath -Destination ".claude-code\design\design_system.json" -Force
    
    # Re-extract tokens
    Extract-DesignTokens -SourcePath ".claude-code\design\design_system.json"
    
    # Generate new CSS variables
    New-CSSVariables

    Write-ColorOutput "✅ Design system updated successfully" "Green"
}

function New-CSSVariables {
    Write-ColorOutput "🎨 Generating CSS variables..." "Cyan"

    if (-not (Test-Path ".claude-code\design\design_system.json")) {
        Write-ColorOutput "❌ design_system.json not found" "Red"
        return
    }

    try {
        $designSystem = Get-Content ".claude-code\design\design_system.json" | ConvertFrom-Json
        
        $cssContent = ":root {`n"
        
        # Process colors
        if ($designSystem.colors) {
            $cssContent += "  /* Colors */`n"
            $cssContent += ConvertTo-CSSVariables -Object $designSystem.colors -Prefix "colors"
        }
        
        # Process typography
        if ($designSystem.typography) {
            $cssContent += "`n  /* Typography */`n"
            $cssContent += ConvertTo-CSSVariables -Object $designSystem.typography -Prefix "typography"
        }
        
        # Process spacing
        if ($designSystem.spacing) {
            $cssContent += "`n  /* Spacing */`n"
            $cssContent += ConvertTo-CSSVariables -Object $designSystem.spacing -Prefix "spacing"
        }

        # Process other properties
        $otherProperties = @("borderRadius", "shadows", "breakpoints", "zIndex")
        foreach ($prop in $otherProperties) {
            if ($designSystem.$prop) {
                $cssContent += "`n  /* $prop */`n"
                $cssContent += ConvertTo-CSSVariables -Object $designSystem.$prop -Prefix $prop
            }
        }
        
        $cssContent += "}`n"
        
        # Output CSS file
        $cssContent | Out-File "src\styles\design-tokens.css" -Encoding UTF8
        Write-ColorOutput "✅ CSS variables generated in src\styles\design-tokens.css" "Green"
        
    } catch {
        Write-ColorOutput "❌ Error generating CSS variables: $($_.Exception.Message)" "Red"
    }
}

function ConvertTo-CSSVariables {
    param(
        [PSCustomObject]$Object,
        [string]$Prefix,
        [string]$CurrentPath = ""
    )
    
    $css = ""
    $properties = $Object | Get-Member -MemberType NoteProperty
    
    foreach ($prop in $properties) {
        $key = $prop.Name
        $value = $Object.$key
        $fullPath = if ($CurrentPath) { "$CurrentPath-$key" } else { "$Prefix-$key" }
        
        if ($value -is [PSCustomObject]) {
            $css += ConvertTo-CSSVariables -Object $value -Prefix $Prefix -CurrentPath $fullPath
        } else {
            $css += "  --$fullPath: $value;`n"
        }
    }
    
    return $css
}

# Execute the action
Invoke-DesignSystemAction