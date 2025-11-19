# ------------------------------------------------------------------------------
# 4. PROJECT VALIDATION SCRIPT
# ------------------------------------------------------------------------------

# File: validate-project.ps1
param(
    [Parameter(Mandatory=$false)]
    [ValidateSet("setup", "design-system", "templates", "all")]
    [string]$ValidationScope = "all",
    
    [Parameter(Mandatory=$false)]
    [switch]$Detailed = $false
)

function Start-ProjectValidation {
    Write-ColorOutput "🔍 Starting Claude Code project validation..." "Cyan"
    Write-ColorOutput "📋 Validation Scope: $ValidationScope" "Yellow"

    $results = @{
        Setup = @{ Passed = $false; Issues = @(); Warnings = @() }
        DesignSystem = @{ Passed = $false; Issues = @(); Warnings = @() }
        Templates = @{ Passed = $false; Issues = @(); Warnings = @() }
    }

    switch ($ValidationScope) {
        "setup" { 
            Test-SetupValidation -Results $results
        }
        "design-system" { 
            Test-DesignSystemValidation -Results $results
        }
        "templates" { 
            Test-TemplatesValidation -Results $results
        }
        "all" {
            Test-SetupValidation -Results $results
            Test-DesignSystemValidation -Results $results  
            Test-TemplatesValidation -Results $results
        }
    }

    Show-ValidationSummary -Results $results
}

function Test-SetupValidation {
    param($Results)
    
    Write-ColorOutput "`n📁 Validating project setup..." "Yellow"
    
    # Check core directory structure
    $requiredDirs = @(
        ".claude-code",
        ".claude-code\prompts", 
        ".claude-code\templates",
        ".claude-code\context",
        ".claude-code\memory",
        "docs",
        "src"
    )

    foreach ($dir in $requiredDirs) {
        if (-not (Test-Path $dir)) {
            $Results.Setup.Issues += "Missing directory: $dir"
        }
    }

    # Check core files
    $requiredFiles = @(
        ".claude-code\context\constitution.md",
        ".claude-code\context\tech-stack.md"
    )

    foreach ($file in $requiredFiles) {
        if (-not (Test-Path $file)) {
            $Results.Setup.Issues += "Missing file: $file"
        }
    }

    # Check git setup
    if (-not (Test-Path ".git")) {
        $Results.Setup.Warnings += "Git repository not initialized"
    }

    $Results.Setup.Passed = $Results.Setup.Issues.Count -eq 0
    
    if ($Results.Setup.Passed) {
        Write-ColorOutput "✅ Project setup validation passed" "Green"
    } else {
        Write-ColorOutput "❌ Project setup validation failed" "Red"
    }
}

function Test-DesignSystemValidation {
    param($Results)
    
    Write-ColorOutput "`n🎨 Validating design system integration..." "Yellow"
    
    # Check for design system file
    if (-not (Test-Path ".claude-code\design\design_system.json")) {
        $Results.DesignSystem.Issues += "design_system.json not found"
        $Results.DesignSystem.Passed = $false
        Write-ColorOutput "❌ Design system validation failed - no design_system.json" "Red"
        return
    }

    # Validate JSON structure
    try {
        $designSystem = Get-Content ".claude-code\design\design_system.json" | ConvertFrom-Json
        
        # Check required sections
        $requiredSections = @("colors", "typography", "spacing")
        foreach ($section in $requiredSections) {
            if (-not $designSystem.$section) {
                $Results.DesignSystem.Issues += "Missing required section in design_system.json: $section"
            }
        }

        # Check for recommended sections
        $recommendedSections = @("borderRadius", "shadows", "breakpoints", "components")
        foreach ($section in $recommendedSections) {
            if (-not $designSystem.$section) {
                $Results.DesignSystem.Warnings += "Missing recommended section: $section"
            }
        }

        # Validate color structure
        if ($designSystem.colors -and $Detailed) {
            Test-ColorTokenStructure -Colors $designSystem.colors -Results $Results
        }

    } catch {
        $Results.DesignSystem.Issues += "Invalid JSON in design_system.json: $($_.Exception.Message)"
    }

    # Check design-related templates
    $designTemplates = @(
        ".claude-code\prompts\design-analysis.prompt.md",
        ".claude-code\prompts\component-generation.prompt.md"
    )

    foreach ($template in $designTemplates) {
        if (-not (Test-Path $template)) {
            $Results.DesignSystem.Warnings += "Missing design template: $template"
        }
    }

    $Results.DesignSystem.Passed = $Results.DesignSystem.Issues.Count -eq 0
    
    if ($Results.DesignSystem.Passed) {
        Write-ColorOutput "✅ Design system validation passed" "Green"
    } else {
        Write-ColorOutput "❌ Design system validation failed" "Red"
    }
}

function Test-ColorTokenStructure {
    param($Colors, $Results)
    
    # Check for semantic colors
    $semanticSections = @("brand", "neutral", "semantic")
    foreach ($section in $semanticSections) {
        if (-not $Colors.$section) {
            $Results.DesignSystem.Warnings += "Recommended color section missing: $section"
        }
    }

    # Check for proper color scales (50, 100, 500, 600, 900 pattern)
    if ($Colors.brand -and $Colors.brand.primary) {
        $primary = $Colors.brand.primary
        $recommendedStops = @("50", "100", "500", "600", "900")
        
        foreach ($stop in $recommendedStops) {
            if (-not $primary.$stop) {
                $Results.DesignSystem.Warnings += "Missing recommended color stop: brand.primary.$stop"
            }
        }
    }
}

function Test-TemplatesValidation {
    param($Results)
    
    Write-ColorOutput "`n📝 Validating templates..." "Yellow"
    
    # Check core templates
    $coreTemplates = @(
        ".claude-code\prompts\specify.prompt.md",
        ".claude-code\prompts\plan.prompt.md",
        ".claude-code\prompts\tasks.prompt.md",
        ".claude-code\templates\spec.template.md",
        ".claude-code\templates\component.template.md"
    )

    foreach ($template in $coreTemplates) {
        if (-not (Test-Path $template)) {
            $Results.Templates.Issues += "Missing core template: $template"
        }
    }

    # Check project type templates
    if (Test-Path ".claude-code\templates\project-types") {
        $projectTypes = Get-ChildItem ".claude-code\templates\project-types" -Filter "*.template.md"
        if ($projectTypes.Count -eq 0) {
            $Results.Templates.Warnings += "No project type templates found"
        }
    } else {
        $Results.Templates.Issues += "Missing project types directory"
    }

    # Validate template content if detailed validation requested
    if ($Detailed) {
        Test-TemplateContent -Results $Results
    }

    $Results.Templates.Passed = $Results.Templates.Issues.Count -eq 0
    
    if ($Results.Templates.Passed) {
        Write-ColorOutput "✅ Templates validation passed" "Green"
    } else {
        Write-ColorOutput "❌ Templates validation failed" "Red"
    }
}

function Test-TemplateContent {
    param($Results)
    
    # Check if prompts reference design system when it exists
    if (Test-Path ".claude-code\design\design_system.json") {
        $specifyPrompt = Get-Content ".claude-code\prompts\specify.prompt.md" -Raw -ErrorAction SilentlyContinue
        
        if ($specifyPrompt -and $specifyPrompt -notmatch "design_system\.json") {
            $Results.Templates.Warnings += "specify.prompt.md doesn't reference design_system.json"
        }
    }
}

function Show-ValidationSummary {
    param($Results)
    
    Write-ColorOutput "`n📊 VALIDATION SUMMARY" "Cyan"
    Write-ColorOutput "=====================" "Cyan"

    $totalPassed = 0
    $totalIssues = 0
    $totalWarnings = 0

    foreach ($category in $Results.Keys) {
        $result = $Results[$category]
        $status = if ($result.Passed) { "✅ PASSED" } else { "❌ FAILED" }
        $color = if ($result.Passed) { "Green" } else { "Red" }
        
        Write-ColorOutput "`n$category : $status" $color
        
        if ($result.Issues.Count -gt 0) {
            Write-ColorOutput "  Issues:" "Red"
            foreach ($issue in $result.Issues) {
                Write-ColorOutput "    • $issue" "Red"
            }
        }
        
        if ($result.Warnings.Count -gt 0) {
            Write-ColorOutput "  Warnings:" "Yellow"
            foreach ($warning in $result.Warnings) {
                Write-ColorOutput "    • $warning" "Yellow"
            }
        }

        if ($result.Passed) { $totalPassed++ }
        $totalIssues += $result.Issues.Count
        $totalWarnings += $result.Warnings.Count
    }

    Write-ColorOutput "`n📈 FINAL RESULTS:" "Cyan"
    Write-ColorOutput "Categories Passed: $totalPassed/$($Results.Keys.Count)" $(if ($totalPassed -eq $Results.Keys.Count) { "Green" } else { "Yellow" })
    Write-ColorOutput "Total Issues: $totalIssues" $(if ($totalIssues -eq 0) { "Green" } else { "Red" })
    Write-ColorOutput "Total Warnings: $totalWarnings" $(if ($totalWarnings -eq 0) { "Green" } else { "Yellow" })

    if ($totalIssues -eq 0 -and $totalPassed -eq $Results.Keys.Count) {
        Write-ColorOutput "`n🎉 PROJECT VALIDATION SUCCESSFUL!" "Green"
        Write-ColorOutput "Your Claude Code project is properly configured and ready for development." "Green"
    } else {
        Write-ColorOutput "`n⚠️  PROJECT NEEDS ATTENTION" "Yellow"
        Write-ColorOutput "Please address the issues above before proceeding with development." "Yellow"
    }
}

# Execute validation
Start-ProjectValidation