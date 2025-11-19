# ------------------------------------------------------------------------------
# 3. PHASE DESIGN WORKFLOW INTEGRATION
# ------------------------------------------------------------------------------

# File: integrate-phase-design.ps1
param(
    [Parameter(Mandatory=$true)]
    [string]$PhaseNumber,
    
    [Parameter(Mandatory=$false)]
    [string]$WorkflowStep = "all"
)

function Start-PhaseDesignWorkflow {
    param([string]$PhaseNumber, [string]$Step)
    
    Write-ColorOutput "🎨 Starting Phase $PhaseNumber design workflow..." "Cyan"
    
    switch ($Step) {
        "all" {
            Step1-SetupDesignStructure -PhaseNumber $PhaseNumber
            Step2-AnalyzeDesigns -PhaseNumber $PhaseNumber  
            Step3-CreateSpecifications -PhaseNumber $PhaseNumber
            Step4-ImplementComponents -PhaseNumber $PhaseNumber
            Step5-ValidateImplementation -PhaseNumber $PhaseNumber
        }
        "setup" { Step1-SetupDesignStructure -PhaseNumber $PhaseNumber }
        "analyze" { Step2-AnalyzeDesigns -PhaseNumber $PhaseNumber }
        "specify" { Step3-CreateSpecifications -PhaseNumber $PhaseNumber }
        "implement" { Step4-ImplementComponents -PhaseNumber $PhaseNumber }
        "validate" { Step5-ValidateImplementation -PhaseNumber $PhaseNumber }
    }
}

function Step1-SetupDesignStructure {
    param([string]$PhaseNumber)
    
    Write-ColorOutput "🏗️ Step 1: Setting up design structure for Phase $PhaseNumber" "Yellow"
    
    # Run the Figma setup script
    & .\setup-phase-figma.ps1 -PhaseNumber $PhaseNumber
    
    Write-ColorOutput "✅ Step 1 complete: Design structure ready" "Green"
    Write-ColorOutput "📝 Next: Export your Figma designs to the created directories" "White"
}

function Step2-AnalyzeDesigns {
    param([string]$PhaseNumber)
    
    Write-ColorOutput "🔍 Step 2: Analyzing Figma designs for Phase $PhaseNumber" "Yellow"
    
    # Validate that assets exist
    $phaseDesignDir = ".claude-code\design\phase-designs\phase-$PhaseNumber"
    if (-not (Test-Path "$phaseDesignDir\screens")) {
        Write-ColorOutput "❌ No Figma exports found. Please export designs first." "Red"
        return
    }

    Write-ColorOutput "🤖 Run this Claude Code command:" "Cyan"
    Write-ColorOutput "claude-code analyze 'Use design-to-phase.prompt.md to analyze Phase $PhaseNumber Figma designs in .claude-code/design/phase-designs/phase-$PhaseNumber/ and create comprehensive design specifications in docs/phases/phase-$PhaseNumber/design-spec.md'" "White"
    
    Write-ColorOutput "✅ Step 2: Design analysis command provided" "Green"
}

function Step3-CreateSpecifications {
    param([string]$PhaseNumber)
    
    Write-ColorOutput "📋 Step 3: Creating implementation specifications for Phase $PhaseNumber" "Yellow"
    
    # Check if design analysis is complete
    if (-not (Test-Path "docs\phases\phase-$PhaseNumber\design-spec.md")) {
        Write-ColorOutput "⚠️ Design specification not found. Complete Step 2 first." "Yellow"
    }

    Write-ColorOutput "🤖 Run this Claude Code command:" "Cyan"
    Write-ColorOutput "claude-code specify 'Update the Phase $PhaseNumber specification in docs/phases/phase-$PhaseNumber/spec.md to include all design requirements from design-spec.md, ensuring functional requirements align with UI designs'" "White"
    
    Write-ColorOutput "✅ Step 3: Specification update command provided" "Green"
}

function Step4-ImplementComponents {
    param([string]$PhaseNumber)
    
    Write-ColorOutput "🏗️ Step 4: Implementing components for Phase $PhaseNumber" "Yellow"
    
    Write-ColorOutput "🤖 Run these Claude Code commands:" "Cyan"
    Write-ColorOutput "# Generate component tasks" "Gray"
    Write-ColorOutput "claude-code tasks 'Use tasks.prompt.md to create detailed implementation tasks for Phase $PhaseNumber based on design-spec.md and spec.md'" "White"
    Write-ColorOutput "" "White"
    Write-ColorOutput "# Implement components" "Gray"  
    Write-ColorOutput "claude-code implement 'Use phase-design-implement.prompt.md to build Phase $PhaseNumber components following the Figma designs exactly, using design system tokens'" "White"
    
    Write-ColorOutput "✅ Step 4: Implementation commands provided" "Green"
}

function Step5-ValidateImplementation {
    param([string]$PhaseNumber)
    
    Write-ColorOutput "🔍 Step 5: Validating implementation for Phase $PhaseNumber" "Yellow"
    
    Write-ColorOutput "🤖 Run this Claude Code command:" "Cyan"
    Write-ColorOutput "claude-code validate 'Compare the implemented Phase $PhaseNumber components against the Figma designs and design specifications. Verify design system token usage, responsive behavior, and accessibility requirements are met.'" "White"
    
    Write-ColorOutput "✅ Step 5: Validation command provided" "Green"
    Write-ColorOutput "🎉 Phase $PhaseNumber design workflow complete!" "Green"
}

# Execute the workflow
Start-PhaseDesignWorkflow -PhaseNumber $PhaseNumber -Step $WorkflowStep