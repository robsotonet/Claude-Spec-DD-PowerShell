# ==============================================================================
# manage-phases.ps1 - Phase-Based Development Management Script
# ==============================================================================

param(
    [Parameter(Mandatory=$true, HelpMessage="Action to perform")]
    [ValidateSet("init-roadmap", "create-phase", "plan-phase", "start-phase", "complete-phase", "status")]
    [string]$Action,
    
    [Parameter(Mandatory=$false, HelpMessage="Phase number (1, 2, 3, etc.)")]
    [string]$PhaseNumber = "",
    
    [Parameter(Mandatory=$false, HelpMessage="Phase name/title")]
    [string]$PhaseName = "",
    
    [Parameter(Mandatory=$false, HelpMessage="Enable interactive prompts")]
    [switch]$Interactive = $false
)

# ==============================================================================
# UTILITY FUNCTIONS
# ==============================================================================

function Write-ColorOutput {
    param(
        [Parameter(Mandatory=$true)]
        [string]$Message,
        
        [Parameter(Mandatory=$false)]
        [ValidateSet("Black","Blue","Cyan","DarkBlue","DarkCyan","DarkGray","DarkGreen","DarkMagenta","DarkRed","DarkYellow","Gray","Green","Magenta","Red","White","Yellow")]
        [string]$Color = "White"
    )
    Write-Host $Message -ForegroundColor $Color
}

function Test-PrerequisiteDirectories {
    $requiredDirs = @(
        ".claude-code",
        ".claude-code\context",
        ".claude-code\prompts",
        ".claude-code\templates"
    )
    
    foreach ($dir in $requiredDirs) {
        if (-not (Test-Path $dir)) {
            Write-ColorOutput "Required directory missing: $dir" "Red"
            Write-ColorOutput "Run init-claude-project.ps1 first to set up the project structure" "Yellow"
            return $false
        }
    }
    return $true
}

function New-DirectoryStructure {
    param([string[]]$Directories)
    
    foreach ($dir in $Directories) {
        if (-not (Test-Path $dir)) {
            try {
                New-Item -ItemType Directory -Path $dir -Force | Out-Null
            }
            catch {
                Write-ColorOutput "Failed to create directory: $dir" "Red"
                Write-ColorOutput "   Error: $($_.Exception.Message)" "Red"
                return $false
            }
        }
    }
    return $true
}

# ==============================================================================
# MAIN ACTION FUNCTIONS
# ==============================================================================

function Initialize-ProductRoadmap {
    Write-ColorOutput "🗺️ Initializing product roadmap..." "Cyan"
    
    # Validate prerequisites
    if (-not (Test-PrerequisiteDirectories)) {
        return
    }
    
    # Create phase directories
    $phaseDirs = @(
        "docs\phases",
        "docs\architecture", 
        "src\phases\shared"
    )
    
    if (-not (New-DirectoryStructure -Directories $phaseDirs)) {
        Write-ColorOutput "Failed to create phase directory structure" "Red"
        return
    }

    # Create product vision template
  $productVisionTemplatePath = Join-Path $PSScriptRoot 'templates\phases-productvision.template.md'
  if (Test-Path $productVisionTemplatePath) {
    $productVisionContent = Get-Content $productVisionTemplatePath -Raw
  } else {
    Write-ColorOutput "Template not found: $productVisionTemplatePath" "Red"
    $productVisionContent = ""
  }

    try {
        $productVisionContent | Out-File -FilePath "docs\product-vision.md" -Encoding UTF8
        Write-ColorOutput "Created docs\product-vision.md" "Green"
    }
    catch {
        Write-ColorOutput "\Failed to create product-vision.md: $($_.Exception.Message)" "Red"
        return
    }

    # Create phase roadmap template
  $roadmapTemplatePath = Join-Path $PSScriptRoot 'templates\phases-roadmapcontent.template.md'
  if (Test-Path $roadmapTemplatePath) {
    $roadmapContent = Get-Content $roadmapTemplatePath -Raw
  } else {
    Write-ColorOutput "Template not found: $roadmapTemplatePath" "Red"
    $roadmapContent = ""
  }

    try {
        $roadmapContent | Out-File -FilePath "docs\phase-roadmap.md" -Encoding UTF8
        Write-ColorOutput "Created docs\phase-roadmap.md" "Green"
    }
    catch {
        Write-ColorOutput "Failed to create phase-roadmap.md: $($_.Exception.Message)" "Red"
        return
    }

    # Create architecture decisions template
  $archDecisionsTemplatePath = Join-Path $PSScriptRoot 'templates\phases-archdecisions.template.md'
  if (Test-Path $archDecisionsTemplatePath) {
    $archDecisionsContent = Get-Content $archDecisionsTemplatePath -Raw
  } else {
    Write-ColorOutput "Template not found: $archDecisionsTemplatePath" "Red"
    $archDecisionsContent = ""
  }

    try {
        $archDecisionsContent | Out-File -FilePath "docs\architecture\architecture-decisions.md" -Encoding UTF8
        Write-ColorOutput "Created docs\architecture\architecture-decisions.md" "Green"
    }
    catch {
        Write-ColorOutput "Failed to create architecture-decisions.md: $($_.Exception.Message)" "Red"
        return
    }

    Write-ColorOutput "Product roadmap initialized successfully!" "Green"
    Write-ColorOutput "---" "White"
    Write-ColorOutput "Next steps:" "Yellow"
    Write-ColorOutput "   1. Customize docs\product-vision.md with your specific product details" "White"
    Write-ColorOutput "   2. Review and adjust docs\phase-roadmap.md timeline and features" "White"
    Write-ColorOutput "   3. Run: .\manage-phases.ps1 -Action create-phase -PhaseNumber 1" "White"
}

function New-PhaseSpecification {
    param(
        [Parameter(Mandatory=$true)]
        [string]$PhaseNumber,
        
        [Parameter(Mandatory=$false)]
        [string]$PhaseName
    )
    
    Write-ColorOutput "Creating Phase $PhaseNumber specification..." "Cyan"
    
    # Validate prerequisites
    if (-not (Test-PrerequisiteDirectories)) {
        return
    }
    
    # Create phase directory
    $phaseDir = "docs\phases\phase-$PhaseNumber"
    $srcPhaseDir = "src\phases\phase-$PhaseNumber"
    
    $phaseDirs = @($phaseDir, $srcPhaseDir)
    
    if (-not (New-DirectoryStructure -Directories $phaseDirs)) {
        Write-ColorOutput "Failed to create phase directories" "Red"
        return
    }

    # Get phase details interactively if requested
    if ($Interactive -and -not $PhaseName) {
        $PhaseName = Read-Host "Enter phase name (e.g., 'Foundation & Core Features')"
        $phaseTheme = Read-Host "Enter phase theme/focus"
        $duration = Read-Host "Enter estimated duration (e.g., '6-8 weeks')"
    }
    
    # Set default values if not provided
    if (-not $PhaseName) {
        $PhaseName = "Phase $PhaseNumber"
    }

    # Create comprehensive phase specification using hybrid approach
    $phaseSpecHeader = @()
    $phaseSpecHeader += "# Phase $PhaseNumber : $PhaseName"
    $phaseSpecHeader += ""
    $phaseSpecHeader += "## Phase Overview"
    $phaseSpecHeader += "**Phase Number**: $PhaseNumber"
    $phaseSpecHeader += "**Phase Name**: $PhaseName"
    $phaseSpecHeader += "**Status**: 📋 Planning"
    $phaseSpecHeader += "**Estimated Duration**: 6-8 weeks"
    $phaseSpecHeader += "**Start Date**: [To be determined]"
    $phaseSpecHeader += "**End Date**: [To be determined]"
    $phaseSpecHeader += "**Theme**: [Brief description of what this phase is trying to achieve]"
    $phaseSpecHeader += ""

    # Read the static template content (everything after the header)
    $phaseSpecTemplatePath = Join-Path $PSScriptRoot 'templates' 'phases-phasespec.template.md'
    if (-not (Test-Path $phaseSpecTemplatePath)) {
        Write-ColorOutput "[ERROR] Phase spec template file not found: $phaseSpecTemplatePath" "Red"
        return
    }
    $phaseSpecBody = Get-Content $phaseSpecTemplatePath -Raw

    # Remove the first header block from the template (since we build it dynamically)
    # The template starts with '## Phase Overview' and the next 7 lines are the static header
    $phaseSpecBodyLines = $phaseSpecBody -split "`r?`n"
    $headerEndIndex = ($phaseSpecBodyLines | Select-String -Pattern '^## Phase Objectives' -SimpleMatch).LineNumber
    if ($headerEndIndex) {
        $phaseSpecBody = ($phaseSpecBodyLines[$headerEndIndex-1..($phaseSpecBodyLines.Length-1)] -join "`n")
    } else {
        # Fallback: just use the whole template if the marker is not found
    }

    # Combine the dynamic header and the static body
    $phaseSpecContent = ($phaseSpecHeader -join "`n") + "`n" + $phaseSpecBody

    try {
        $phaseSpecContent | Out-File -FilePath "$phaseDir\spec.md" -Encoding UTF8
        Write-ColorOutput "Created $phaseDir\spec.md" "Green"
    }
    catch {
        Write-ColorOutput "Failed to create spec.md: $($_.Exception.Message)" "Red"
        return
    }

    Write-ColorOutput "✅ Phase $PhaseNumber specification created successfully!" "Green"
    Write-ColorOutput "" "White"
    Write-ColorOutput "📝 Next steps:" "Yellow"
    Write-ColorOutput "   1. Review and customize $phaseDir\spec.md with your specific requirements" "White"
    Write-ColorOutput "   2. Define user stories, acceptance criteria, and success metrics" "White"
    Write-ColorOutput "   3. Run: .\manage-phases.ps1 -Action plan-phase -PhaseNumber $PhaseNumber" "White"
}

function New-PhaseImplementationPlan {
    param(
        [Parameter(Mandatory=$true)]
        [string]$PhaseNumber
    )
    
    Write-ColorOutput "Creating implementation plan for Phase $PhaseNumber..." "Cyan"
    
    $phaseDir = "docs\phases\phase-$PhaseNumber"
    
    # Validate that phase specification exists
    if (-not (Test-Path "$phaseDir\spec.md")) {
        Write-ColorOutput "Phase specification not found at $phaseDir\spec.md" "Red"
        Write-ColorOutput "Run: .\manage-phases.ps1 -Action create-phase -PhaseNumber $PhaseNumber" "Yellow"
        return
    }

    # Create comprehensive phase specification using hybrid approach - rs 
    # Build header and footer dynamically
    $PhasePlanHeader = @()
    $PhasePlanHeader += "# Phase $PhaseNumber Implementation Plan"
    $PhasePlanHeader += "## Phase Overview"
    $PhasePlanHeader += ""

    $PhasePlanFooter = @()
    $PhasePlanFooter += "**Created**: $(Get-Date -Format 'yyyy-MM-dd')"
    $PhasePlanFooter += "**Last Updated**: $(Get-Date -Format 'yyyy-MM-dd') "
    $PhasePlanFooter += "**Approved By**: [Product Owner, Tech Lead, Team]"
    $PhasePlanFooter += "**Next Review**: [Weekly during execution]"

    # Read the static template content (everything after the header)
    $phasePlanTemplatePath = Join-Path $PSScriptRoot 'templates' 'phases-phaseplan.template.md'
    if (-not (Test-Path $phasePlanTemplatePath)) {
        Write-ColorOutput "[ERROR] Phase plan template file not found: $phasePlanTemplatePath" "Red"
        return
    }
    $phasePlanBody = Get-Content $phasePlanTemplatePath -Raw
    $phasePlanBodyLines = $phasePlanBody -split "`r?`n"
    $headerEndIndex = ($phasePlanBodyLines | Select-String -Pattern '^## Implementation Strategy' -SimpleMatch).LineNumber
    if ($headerEndIndex) {
        $phasePlanBody = ($phasePlanBodyLines[$headerEndIndex-1..($phasePlanBodyLines.Length-1)] -join "`n")
    } else {
        # Fallback: just use the whole template if the marker is not found
    }
    # Combine the dynamic header, static body, and footer
    $phasePlanContent = ($PhasePlanHeader -join "`n") + "`n" + $phasePlanBody + "`n" + ($PhasePlanFooter -join "`n")


    try {
        $phasePlanContent | Out-File -FilePath "$phaseDir\plan.md" -Encoding UTF8
        Write-ColorOutput "Created $phaseDir\plan.md" "Green"
    }
    catch {
        Write-ColorOutput "Failed to create plan.md: $($_.Exception.Message)" "Red"
        return
    }

    Write-ColorOutput "Phase $PhaseNumber implementation plan created successfully!" "Green"
    Write-ColorOutput "---" "White"
    Write-ColorOutput "Next steps:" "Yellow"
    Write-ColorOutput "   1. Review and adjust timeline in $phaseDir\plan.md" "White"
    Write-ColorOutput "   2. Assign team members to specific tasks" "White"
    Write-ColorOutput "   3. Run: .\manage-phases.ps1 -Action start-phase -PhaseNumber $PhaseNumber" "White"
}

function Start-PhaseExecution {
    param(
        [Parameter(Mandatory=$true)]
        [string]$PhaseNumber
    )
    
    Write-ColorOutput "Starting Phase $PhaseNumber execution..." "Cyan"
    
    $phaseDir = "docs\phases\phase-$PhaseNumber"
    
    # Validate prerequisites
    $requiredFiles = @(
        "$phaseDir\spec.md",
        "$phaseDir\plan.md"
    )
    
    $missingFiles = @()
    foreach ($file in $requiredFiles) {
        if (-not (Test-Path $file)) {
            $missingFiles += $file
        }
    }
    
    if ($missingFiles.Count -gt 0) {
        Write-ColorOutput "Missing required files:" "Red"
        foreach ($file in $missingFiles) {
            Write-ColorOutput "   • $file" "Red"
        }
        Write-ColorOutput "Complete specification and planning first" "Yellow"
        return
    }

    Write-ColorOutput "Generating detailed task breakdown..." "Yellow"

    $tasksContentHeader = @()
    $tasksContentHeader += "# Phase $PhaseNumber - Development Tasks & Sprint Planning"
    $tasksContentHeader += "## Task Management Overview"
    $tasksContentHeader += "In Progress"
    $tasksContentHeader += "**Start Date**: $(Get-Date -Format 'yyyy-MM-dd')"

    $tasksContentFooter = @()
    $tasksContentFooter += "**Created**: $(Get-Date -Format 'yyyy-MM-dd')"
    $tasksContentFooter += "**Last Updated**: $(Get-Date -Format 'yyyy-MM-dd') "
    $tasksContentFooter += "**Sprint Schedule**: 8 weeks total, 1-week sprints"
    $tasksContentFooter += "**Next Review**: Daily during sprint execution"

    $tasksContentPath = Join-Path $PSScriptRoot 'templates' 'phases-phasetasks.template.md'
    if (-not (Test-Path $tasksContentPath)) {
        Write-ColorOutput "[ERROR] Phase tasks template file not found: $tasksContentPath" "Red"
        return
    }
    $tasksContentBody = Get-Content $tasksContentPath -Raw
    $tasksContentBodyLines = $tasksContentBody -split "`r?`n"
    $headerEndIndex = ($tasksContentBodyLines | Select-String -Pattern '^## Sprint 1 Tasks' -SimpleMatch).LineNumber
    if ($headerEndIndex) {
        $tasksContentBody = ($tasksContentBodyLines[$headerEndIndex-1..($tasksContentBodyLines.Length-1)] -join "`n")
    } else {
        # Fallback: just use the whole template if the marker is not found
    }
    $tasksContent = ($tasksContentHeader -join "`n") + "`n" + $tasksContentBody + "`n" + ($tasksContentFooter -join "`n")

    try {
        $tasksContent | Out-File -FilePath "$phaseDir\tasks.md" -Encoding UTF8
        Write-ColorOutput "Created $phaseDir\tasks.md" "Green"
    }
    catch {
        Write-ColorOutput "Failed to create tasks.md: $($_.Exception.Message)" "Red"
        return
    }

    Write-ColorOutput "Phase $PhaseNumber execution started successfully!" "Green"
    Write-ColorOutput "" "White"
    Write-ColorOutput "Task breakdown created with 8 detailed sprints" "White"
    Write-ColorOutput "Next steps:" "Yellow"
    Write-ColorOutput "   1. Review and customize sprint tasks in $phaseDir\tasks.md" "White"
    Write-ColorOutput "   2. Assign team members to specific tasks" "White"
    Write-ColorOutput "   3. Begin Sprint 1 with team planning meeting" "White"
    Write-ColorOutput "   4. Use Claude Code for individual task implementation:" "White"
    Write-ColorOutput "      claude-code implement 'Build the authentication framework following Phase $PhaseNumber specifications'" "Gray"
}

function Complete-Phase {
    param(
        [Parameter(Mandatory=$true)]
        [string]$PhaseNumber
    )
    
    Write-ColorOutput "Completing Phase $PhaseNumber..." "Cyan"
    
    $phaseDir = "docs\phases\phase-$PhaseNumber"
    
    # Validate that phase files exist
    $requiredFiles = @(
        "$phaseDir\spec.md",
        "$phaseDir\plan.md",
        "$phaseDir\tasks.md"
    )
    
    $missingFiles = @()
    foreach ($file in $requiredFiles) {
        if (-not (Test-Path $file)) {
            $missingFiles += $file
        }
    }
    
    if ($missingFiles.Count -gt 0) {
        Write-ColorOutput "Missing required phase files:" "Red"
        foreach ($file in $missingFiles) {
            Write-ColorOutput "   • $file" "Red"
        }
        Write-ColorOutput "Complete phase development first" "Yellow"
        return
    }

    Write-ColorOutput "Generating Phase $PhaseNumber completion report..." "Yellow"

    $completionReportContentHeader = @()
    $completionReportContentHeader += "# Phase $PhaseNumber Completion Report"
    $completionReportContentHeader += "## Executive Summary"
    $completionReportContentHeader += "**Phase**: $PhaseNumber"
    $completionReportContentHeader += "**Completion Date**: $(Get-Date -Format 'yyyy-MM-dd')"

    $completionReportContentFooter = @()
    $completionReportContentFooter += "**Report Prepared By**: [Name and Role]"
    $completionReportContentFooter += "**Report Review Date**: $(Get-Date -Format 'yyyy-MM-dd')" 
    $completionReportContentFooter += "**Report Approval**: [Stakeholder approval signatures and dates]"
    $completionReportContentFooter += "**Next Phase Start**: [Planned Phase 2 start date]"
    $completionReportContentFooter += "**Archive Location**: [Where this report will be stored for future reference]"
    $completionReportContentFooter += "---
    $completionReportContentFooter += "### Document Distribution"
    $completionReportContentFooter += "- [ ] Product Owner"
    $completionReportContentFooter += "- [ ] Development Team"
    $completionReportContentFooter += "- [ ] Stakeholders"
    $completionReportContentFooter += "- [ ] Executive Leadership"
    $completionReportContentFooter += "- [ ] User Research Team"
    $completionReportContentFooter += "- [ ] Customer Success Team"
    $completionReportContentFooter += "- [ ] Archive/Knowledge Base"
    $completionReportContentFooter += " "
    $completionReportContentFooter += "---"
    $completionReportContentFooter += "**Report Version**: 1.0"
    $completionReportContentFooter += "**Classification**: Internal Use"
    $completionReportContentFooter += "**Retention**: Keep for full product lifecycle"

    $completionReportContentPath = Join-Path $PSScriptRoot 'templates' 'phases-completionreport.template.md'
    if (-not (Test-Path $completionReportContentPath)) {
        Write-ColorOutput "[ERROR] Phase completion report template file not found: $completionReportContentPath" "Red"
        return
    }
    $completionReportContentBody = Get-Content $completionReportContentPath -Raw
    $completionReportContentBodyLines = $completionReportContentBody -split "`r?`n"
    $headerEndIndex = ($completionReportContentBodyLines | Select-String -Pattern '^## Key Achievements' -SimpleMatch).LineNumber
    if ($headerEndIndex) {
        $completionReportContentBody = ($completionReportContentBodyLines[$headerEndIndex-1..($completionReportContentBodyLines.Length-1)] -join "`n")
    } 
    else {
        # Fallback: just use the whole template if the marker is not found
    }
    
    $completionReportContent = ($completionReportContentHeader -join "`n") + "`n" + $completionReportContentBody + "`n" + ($completionReportContentFooter -join "`n")

    
    try {
        $completionReportContent | Out-File -FilePath "$phaseDir\completion-report.md" -Encoding UTF8
        Write-ColorOutput "Created $phaseDir\completion-report.md" "Green"
    }
    catch {
        Write-ColorOutput "Failed to create completion-report.md: $($_.Exception.Message)" "Red"
        return
    }

    Write-ColorOutput "Phase $PhaseNumber completion report generated!" "Green"
    Write-ColorOutput "---" "White"
    Write-ColorOutput "Phase $PhaseNumber officially completed!" "Green"
    Write-ColorOutput "---" "White"
    Write-ColorOutput "Completion report created at $phaseDir\completion-report.md" "White"
    Write-ColorOutput "Next steps:" "Yellow"
    Write-ColorOutput "   1. Fill out the completion report with actual results and metrics" "White"
    Write-ColorOutput "   2. Conduct team retrospective and capture lessons learned" "White"
    Write-ColorOutput "   3. Plan Phase 2 based on Phase 1 learnings and user feedback" "White"
    Write-ColorOutput "   4. Celebrate the team's success! 🎊" "White"
}

function Show-PhaseStatus {
    Write-ColorOutput "Phase Development Status Report" "Cyan"
    Write-ColorOutput "=================================" "Cyan"

    # Check if phases directory exists
    if (-not (Test-Path "docs\phases")) {
        Write-ColorOutput "No phase management setup found." "Red"
        Write-ColorOutput "Run: .\manage-phases.ps1 -Action init-roadmap" "Yellow"
        return
    }

    # Get all phase directories
    $phases = Get-ChildItem "docs\phases" -Directory | Sort-Object { [int]($_.Name -replace "phase-", "") }

    if ($phases.Count -eq 0) {
        Write-ColorOutput "No phases created yet." "Yellow"
        Write-ColorOutput "Run: .\manage-phases.ps1 -Action create-phase -PhaseNumber 1" "Yellow"
        return
    }

    Write-ColorOutput "Found $($phases.Count) phase(s) in development:" "White"
    Write-ColorOutput "---" "White"

    foreach ($phase in $phases) {
        $phaseNumber = $phase.Name -replace "phase-", ""
        $hasSpec = Test-Path "$($phase.FullName)\spec.md"
        $hasPlan = Test-Path "$($phase.FullName)\plan.md"
        $hasTasks = Test-Path "$($phase.FullName)\tasks.md"
        $hasCompletion = Test-Path "$($phase.FullName)\completion-report.md"

        # Determine phase status
        $status = if ($hasCompletion) { 
            "Completed" 
        } elseif ($hasTasks) { 
            "In Progress" 
        } elseif ($hasPlan) { 
            "Planned" 
        } elseif ($hasSpec) { 
            "Specified" 
        } else { 
            "Incomplete Setup" 
        }

        # Determine status color
        $statusColor = if ($hasCompletion) { 
            "Green" 
        } elseif ($hasTasks) { 
            "Yellow" 
        } else { 
            "White" 
        }

        Write-ColorOutput "Phase $phaseNumber : $status" $statusColor
        Write-ColorOutput "  Specification: $(if ($hasSpec) { '✅ Complete' } else { '❌ Missing' })" "White"
        Write-ColorOutput "  Plan: $(if ($hasPlan) { '✅ Complete' } else { '❌ Missing' })" "White"
        Write-ColorOutput "  Tasks: $(if ($hasTasks) { '✅ Complete' } else { '❌ Missing' })" "White"
        Write-ColorOutput "  Completion: $(if ($hasCompletion) { '✅ Complete' } else { '❌ Missing' })" "White"
        
        # Show additional details if available
        if ($hasSpec) {
            try {
                $specContent = Get-Content "$($phase.FullName)\spec.md" -Raw -ErrorAction SilentlyContinue
                if ($specContent -and $specContent -match "Phase Name\*\*: (.+)") {
                    $phaseName = $matches[1].Trim()
                    Write-ColorOutput "  📌 Name: $phaseName" "Gray"
                }
            }
            catch {
                # Ignore errors reading spec file
            }
        }
        
        Write-ColorOutput "" "White"
    }

    # Calculate summary statistics
    $totalPhases = $phases.Count
    $completedPhases = ($phases | Where-Object { Test-Path "$($_.FullName)\completion-report.md" }).Count
    $inProgressPhases = ($phases | Where-Object { 
        (Test-Path "$($_.FullName)\tasks.md") -and 
        -not (Test-Path "$($_.FullName)\completion-report.md") 
    }).Count
    $plannedPhases = ($phases | Where-Object { 
        (Test-Path "$($_.FullName)\plan.md") -and 
        -not (Test-Path "$($_.FullName)\tasks.md") -and
        -not (Test-Path "$($_.FullName)\completion-report.md")
    }).Count
    $specifiedPhases = ($phases | Where-Object { 
        (Test-Path "$($_.FullName)\spec.md") -and 
        -not (Test-Path "$($_.FullName)\plan.md") -and
        -not (Test-Path "$($_.FullName)\completion-report.md")
    }).Count

    Write-ColorOutput "DEVELOPMENT PROGRESS SUMMARY" "Cyan"
    Write-ColorOutput "===============================" "Cyan"
    Write-ColorOutput "Total Phases: $totalPhases" "White"
    Write-ColorOutput "Completed: $completedPhases" "Green"
    Write-ColorOutput "In Progress: $inProgressPhases" "Yellow"
    Write-ColorOutput "Planned: $plannedPhases" "Blue"
    Write-ColorOutput "Specified Only: $specifiedPhases" "Magenta"
    Write-ColorOutput "Incomplete: $($totalPhases - $completedPhases - $inProgressPhases - $plannedPhases - $specifiedPhases)" "Red"

    # Calculate and show progress percentage
    $completionPercentage = if ($totalPhases -gt 0) { 
        [math]::Round(($completedPhases / $totalPhases) * 100, 1) 
    } else { 
        0 
    }
    
    Write-ColorOutput "---" "White"
    Write-ColorOutput "Overall Progress: $completionPercentage% Complete" $(if ($completionPercentage -ge 50) { "Green" } elseif ($completionPercentage -ge 25) { "Yellow" } else { "Red" })

    # Show roadmap status if available
    if (Test-Path "docs\phase-roadmap.md") {
        Write-ColorOutput "Phase roadmap available at docs\phase-roadmap.md" "Gray"
    }
    
    if (Test-Path "docs\product-vision.md") {
        Write-ColorOutput "Product vision available at docs\product-vision.md" "Gray"
    }

    # Provide helpful next steps
    Write-ColorOutput "---" "White"
    Write-ColorOutput "Suggested Next Actions:" "Yellow"
    
    if ($totalPhases -eq 0) {
        Write-ColorOutput "   1. Run: .\manage-phases.ps1 -Action create-phase -PhaseNumber 1" "White"
    }
    elseif ($inProgressPhases -eq 0 -and $completedPhases -lt $totalPhases) {
        $nextPhase = ($phases | Where-Object { 
            -not (Test-Path "$($_.FullName)\completion-report.md") 
        } | Sort-Object { [int]($_.Name -replace "phase-", "") } | Select-Object -First 1)
        
        if ($nextPhase) {
            $nextPhaseNumber = $nextPhase.Name -replace "phase-", ""
            if (-not (Test-Path "$($nextPhase.FullName)\tasks.md")) {
                if (Test-Path "$($nextPhase.FullName)\plan.md") {
                    Write-ColorOutput "   1. Start Phase $nextPhaseNumber: .\manage-phases.ps1 -Action start-phase -PhaseNumber $nextPhaseNumber" "White"
                }
                elseif (Test-Path "$($nextPhase.FullName)\spec.md") {
                    Write-ColorOutput "   1. Plan Phase $nextPhaseNumber: .\manage-phases.ps1 -Action plan-phase -PhaseNumber $nextPhaseNumber" "White"
                }
            }
        }
    }
    elseif ($completedPhases -lt $totalPhases) {
        Write-ColorOutput "   1. Continue development on current phase(s)" "White"
        Write-ColorOutput "   2. Review progress and update task status" "White"
    }
    else {
        Write-ColorOutput "   1. Plan next phase based on completed phase learnings" "White"
        Write-ColorOutput "   2. Consider creating Phase $($totalPhases + 1) specification" "White"
    }
    
    Write-ColorOutput "   Get status anytime: .\manage-phases.ps1 -Action status" "Gray"
}

# ==============================================================================
# MAIN EXECUTION LOGIC
# ==============================================================================

function Invoke-PhaseAction {
    param(
        [string]$Action,
        [string]$PhaseNumber,
        [string]$PhaseName,
        [switch]$Interactive
    )
    
    switch ($Action) {
        "init-roadmap" { 
            Initialize-ProductRoadmap 
        }
        "create-phase" { 
            if (-not $PhaseNumber) {
                do {
                    $PhaseNumber = Read-Host "Enter phase number (1, 2, 3, etc.)"
                } while (-not $PhaseNumber -or $PhaseNumber -notmatch '^\d+')
            }
            
            if ($Interactive -and -not $PhaseName) {
                $PhaseName = Read-Host "Enter phase name (optional, e.g., 'Foundation & Core Features')"
            }
            
            New-PhaseSpecification -PhaseNumber $PhaseNumber -PhaseName $PhaseName
        }
        "plan-phase" { 
            if (-not $PhaseNumber) {
                do {
                    $PhaseNumber = Read-Host "Enter phase number to create implementation plan for"
                } while (-not $PhaseNumber -or $PhaseNumber -notmatch '^\d+')
            }
            
            New-PhaseImplementationPlan -PhaseNumber $PhaseNumber
        }
        "start-phase" { 
            if (-not $PhaseNumber) {
                do {
                    $PhaseNumber = Read-Host "Enter phase number to start development for"
                } while (-not $PhaseNumber -or $PhaseNumber -notmatch '^\d+')
            }
            
            Start-PhaseExecution -PhaseNumber $PhaseNumber
        }
        "complete-phase" { 
            if (-not $PhaseNumber) {
                do {
                    $PhaseNumber = Read-Host "Enter phase number to mark as complete"
                } while (-not $PhaseNumber -or $PhaseNumber -notmatch '^\d+')
            }
            
            Complete-Phase -PhaseNumber $PhaseNumber
        }
        "status" { 
            Show-PhaseStatus 
        }
        default {
            Write-ColorOutput "Unknown action: $Action" "Red"
            Write-ColorOutput "Valid actions: init-roadmap, create-phase, plan-phase, start-phase, complete-phase, status" "Yellow"
        }
    }
}

# Execute the main function with provided parameters
try {
    Invoke-PhaseAction -Action $Action -PhaseNumber $PhaseNumber -PhaseName $PhaseName -Interactive $Interactive
}
catch {
    Write-ColorOutput "Error executing action '$Action': $($_.Exception.Message)" "Red"
    Write-ColorOutput "Please check the error details above and try again" "Yellow"
    exit 1
}

# ==============================================================================
# SCRIPT COMPLETION
# ==============================================================================

Write-ColorOutput "---" "White"
Write-ColorOutput "manage-phases.ps1 execution completed successfully!" "Green"