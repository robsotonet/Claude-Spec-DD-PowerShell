# ==============================================================================
# Claude Code Design Workflow Management Scripts
# ==============================================================================

# ------------------------------------------------------------------------------
# 1. PROJECT INITIALIZATION SCRIPT
# ------------------------------------------------------------------------------

# File: init-claude-project.ps1
param(
    [Parameter(Mandatory=$true, HelpMessage="Name of the project to create")]
    [string]$ProjectName,  

    [Parameter(Mandatory=$true, HelpMessage="Root directory where the project will be created")]
    [string]$ProjectRoot,

    [Parameter(Mandatory=$true, HelpMessage="Type of project to create")]
    [ValidateSet("web-app", "api-backend", "mobile-client", "worker-service")]
    [string]$ProjectType = "web-app",

    [Parameter(Mandatory=$false, HelpMessage="Initialize git repository")]
    [switch]$InitGit,

    [Parameter(Mandatory=$false, HelpMessage="Create with design system integration")]
    [switch]$WithDesignSystem
    
)

$utilsPath = Join-Path $PSScriptRoot 'Utilities\claude-code-utils.ps1'
if (Test-Path $utilsPath) {
    . $utilsPath
} else {
    Write-Host "Utilities script not found: $utilsPath" -ForegroundColor Red
}

function Write-ColorOutput {
    param([string]$Message, [string]$Color = "White")
    Write-Host $Message -ForegroundColor $Color
}

function New-ClaudeCodeProject {
    Write-ColorOutput "Initializing Claude Code project: $ProjectName" "Cyan"
    Write-ColorOutput "Project Type: $ProjectType" "Yellow"
    Write-ColorOutput "Project Root: $ProjectRoot" "Gray"

    # Ensure the root directory exists
    if (-not (Test-Path $ProjectRoot)) {
        New-Item -ItemType Directory -Path $ProjectRoot -Force | Out-Null
    }

    # Create project directory under the root
    $fullProjectPath = Join-Path $ProjectRoot $ProjectName
    if (Test-Path $fullProjectPath) {
        Write-ColorOutput "Directory $fullProjectPath already exists!" "Yellow"
        $overwrite = Read-Host "Do you want to continue? (y/N)"
        if ($overwrite -ne 'y' -and $overwrite -ne 'Y') {
            Write-ColorOutput "Project creation cancelled" "Red"
            return
        }
    }
    New-Item -ItemType Directory -Path $fullProjectPath -Force | Out-Null
    Set-Location $fullProjectPath

    # Initialize git if requested
    if ($InitGit) {
        git init
        Write-ColorOutput "✅ Git repository initialized" "Green"
    }

    # Create Claude Code structure
    $directories = @(
        ".claude-code\prompts",
        ".claude-code\templates\project-types", 
        ".claude-code\context",
        ".claude-code\memory",
        "docs"
    )

    if ($WithDesignSystem) {
        $directories += @(
            ".claude-code\design\figma-exports\screens",
            ".claude-code\design\figma-exports\components",
            ".claude-code\design\figma-exports\icons",
            ".claude-code\design\figma-exports\assets",
            ".claude-code\design\design-tokens",
            ".claude-code\design\design-specs"
        )
    }

    foreach ($dir in $directories) {
        New-Item -ItemType Directory -Path $dir -Force | Out-Null
        Write-Host "FYI: Created directory for DesignSystem: $dir"
    }

    # Create project-specific structure based on type
    $projectDirs = switch (
        $ProjectType) {
        "web-app" { @(
            "src\components", "src\pages", "src\services", 
            "src\utils", "src\styles", "src\hooks", "src\assets",
            "tests\unit", "tests\integration", "tests\e2e"
        )}
        "api-backend" { @(
            "src\routes", "src\services", "src\models", "src\middleware", 
            "src\utils", "src\config", "src\db",
            "tests\unit", "tests\integration", "tests\load"
        )}
        "mobile-client" { @(
            "src\screens", "src\components", "src\services", "src\utils",
            "src\navigation", "src\assets", "src\hooks",
            "tests\unit", "tests\integration"
        )}
        "worker-service" { @(
            "src\workers", "src\jobs", "src\services", "src\utils",
            "src\config", "src\queues",
            "tests\unit", "tests\integration"
        )}
        default { @("src", "tests") }
    }

    foreach ($dir in $projectDirs) {
        New-Item -ItemType Directory -Path $dir -Force | Out-Null
        Write-Host "FYI: Created directory for Project Type: $dir"
    }

    Write-ColorOutput "Project structure created for $ProjectType" "Green"

    # Create basic files
    New-ClaudeCodeTemplateFiles -ProjectType $ProjectType -WithDesignSystem:$WithDesignSystem
    
    Write-ColorOutput "Next steps:" "Yellow"
    Write-ColorOutput "   1. Review and customize .claude-code/context/constitution.md" "White"
    Write-ColorOutput "   2. Update .claude-code/context/tech-stack.md for your preferences" "White"
    if ($WithDesignSystem) {
        Write-ColorOutput "   3. Place your design_system.json in .claude-code/design/" "White"
    }
    Write-ColorOutput "   4. Run claude-code to start development" "White"
}

function New-ClaudeCodeTemplateFiles {
    param(
        [string]$ProjectType,
        [switch]$WithDesignSystem
    )

    # Create constitution. md from external template
    $constitutionTemplatePath = Join-Path $PSScriptRoot 'templates\constitution.template.md'
    Write-Host "Constitution file at: $constitutionTemplatePath"
    if (Test-Path $constitutionTemplatePath) {
        $constitutionContent = Get-Content $constitutionTemplatePath -Raw
        $constitutionContent | Out-File -FilePath ".claude-code\context\constitution.md" -Encoding UTF8
    } 
    else {
        Write-ColorOutput "Constitution template not found at $constitutionTemplatePath. Skipping constitution.md creation." "Red"
    }

    # Create tech-stack.md based on project type
    Write-Host "Creating tech-stack.md for project type: $ProjectType"
    $techStackContent = Get-TechStackTemplate -ProjectType $ProjectType
    $techStackContent | Out-File -FilePath ".claude-code\context\tech-stack.md" -Encoding UTF8

    # Create prompt files
    Write-Host "Running prompt file creation..."
    New-PromptFiles -WithDesignSystem:$WithDesignSystem

    # Create template files  
    Write-Host "Running template file creation..."
    New-TemplateFiles -ProjectType $ProjectType

    # Create memory files
    New-Item -ItemType File -Path ".claude-code\memory\architecture-decisions.md" -Force | Out-Null
    Write-Host "Creating memory architecture-decisions.md..."
    New-Item -ItemType File -Path ".claude-code\memory\patterns.md" -Force | Out-Null
    Write-Host "Creating memory patterns.md..."
    New-Item -ItemType File -Path ".claude-code\memory\lessons-learned.md" -Force | Out-Null
    Write-Host "Creating memory lessons-learned.md..."

    if ($WithDesignSystem) {
        Write-Host "Running design system file creation..."
        New-DesignSystemFiles
    }

    Write-ColorOutput "Template files created successfully" "Green"
}

function Get-TechStackTemplate {
    param([string]$ProjectType)
    
    switch ($ProjectType) {
        "web-app" {
            $webAppTemplatePath = Join-Path $PSScriptRoot 'templates\projecttype.webapp.template.md'
            if (Test-Path $webAppTemplatePath) {
                return Get-Content $webAppTemplatePath -Raw
            } else {
                Write-ColorOutput "Web-app tech stack template not found at $webAppTemplatePath." "Red"
                return "[Tech stack template for web-app not found]"
            }
        }
        "api-backend" {
            $apiBackendTemplatePath = Join-Path $PSScriptRoot 'templates\projecttype.apibackend.template.md'
            if (Test-Path $apiBackendTemplatePath) {
                return Get-Content $apiBackendTemplatePath -Raw
            } else {
                Write-ColorOutput "API-backend tech stack template not found at $apiBackendTemplatePath." "Red"
                return "[Tech stack template for api-backend not found]"
            }
        }
        default {
            $defaultTemplatePath = Join-Path $PSScriptRoot 'templates\projecttype.default.template.md'
            if (Test-Path $defaultTemplatePath) {
                return Get-Content $defaultTemplatePath -Raw
            } else {
                Write-ColorOutput "Default tech stack template not found at $defaultTemplatePath." "Red"
                return "[Tech stack template for default not found]"
            }
        }
    }
}

function New-PromptFiles {
    param(
        [Parameter(Mandatory=$false)]
        [switch]$WithDesignSystem = $false
    )
    
    Write-ColorOutput "Creating Claude Code prompt templates..." "Yellow"
    
    # Create prompts directory if it doesn't exist
    $promptsDir = ".claude-code\prompts"
    if (-not (Test-Path $promptsDir)) {
        New-Item -ItemType Directory -Path $promptsDir -Force | Out-Null
    }

    # 1. SPECIFICATION PROMPT (read from external template)
    $specifyTemplatePath = Join-Path $PSScriptRoot 'templates\specify.template.md'
    if (Test-Path $specifyTemplatePath) {
        try {
            $specifyPromptContent = Get-Content $specifyTemplatePath -Raw
            $specifyPromptContent | Out-File -FilePath "$promptsDir\specify.prompt.md" -Encoding UTF8
            Write-ColorOutput "  Created specify.prompt.md" "Green"
        }
        catch {
            Write-ColorOutput "  Failed to create specify.prompt.md: $($_.Exception.Message)" "Red"
            return $false
        }
    } else {
        Write-ColorOutput "  specify.template.md not found at $specifyTemplatePath. Skipping specify.prompt.md creation." "Red"
    }

    # 2. PLANNING PROMPT (read from external template)
    $planTemplatePath = Join-Path $PSScriptRoot 'templates\plan.template.md'
    if (Test-Path $planTemplatePath) {
        try {
            $planPromptContent = Get-Content $planTemplatePath -Raw
            $planPromptContent | Out-File -FilePath "$promptsDir\plan.prompt.md" -Encoding UTF8
            Write-ColorOutput "  Created plan.prompt.md" "Green"
        }
        catch {
            Write-ColorOutput "  Failed to create plan.prompt.md: $($_.Exception.Message)" "Red"
            return $false
        }
    } else {
        Write-ColorOutput "  plan.template.md not found at $planTemplatePath. Skipping plan.prompt.md creation." "Red"
    }

    # 3. TASK GENERATION PROMPT (read from external template)
    $tasksTemplatePath = Join-Path $PSScriptRoot 'templates\tasks.template.md'
    if (Test-Path $tasksTemplatePath) {
        try {
            $tasksPromptContent = Get-Content $tasksTemplatePath -Raw
            $tasksPromptContent | Out-File -FilePath "$promptsDir\tasks.prompt.md" -Encoding UTF8
            Write-ColorOutput "  Created tasks.prompt.md" "Green"
        }
        catch {
            Write-ColorOutput "  Failed to create tasks.prompt.md: $($_.Exception.Message)" "Red"
            return $false
        }
    } else {
        Write-ColorOutput "  tasks.template.md not found at $tasksTemplatePath. Skipping tasks.prompt.md creation." "Red"
    }

    # 4. REVIEW PROMPT
    # 4. REVIEW PROMPT (read from external template)
    $reviewTemplatePath = Join-Path $PSScriptRoot 'templates\review.template.md'
    if (Test-Path $reviewTemplatePath) {
        try {
            $reviewPromptContent = Get-Content $reviewTemplatePath -Raw
            $reviewPromptContent | Out-File -FilePath "$promptsDir\review.prompt.md" -Encoding UTF8
            Write-ColorOutput "  Created review.prompt.md" "Green"
        }
        catch {
            Write-ColorOutput "  Failed to create review.prompt.md: $($_.Exception.Message)" "Red"
            return $false
        }
    } 
    else {
        Write-ColorOutput "  review.template.md not found at $reviewTemplatePath. Skipping review.prompt.md creation." "Red"
    }

    # CREATE DESIGN SYSTEM PROMPTS (if enabled)
    if ($WithDesignSystem) {
        Write-ColorOutput "  Creating design system integration prompts..." "Yellow"
        # 5. DESIGN ANALYSIS PROMPT (read from external template)
        $designAnalysisTemplatePath = Join-Path $PSScriptRoot 'templates\designanalysis.template.md'
        if (Test-Path $designAnalysisTemplatePath) {
            try {
                $designAnalysisContent = Get-Content $designAnalysisTemplatePath -Raw
                $designAnalysisContent | Out-File -FilePath "$promptsDir\design-analysis.prompt.md" -Encoding UTF8
                Write-ColorOutput "  Created design-analysis.prompt.md" "Green"
            }
            catch {
                Write-ColorOutput "  Failed to create design-analysis.prompt.md: $($_.Exception.Message)" "Red"
                return $false
            }
        } 
        else {
            Write-ColorOutput "  designanalysis.template.md not found at $designAnalysisTemplatePath. Skipping design-analysis.prompt.md creation." "Red"
        }

        # 6. COMPONENT GENERATION PROMPT (read from external template)
        $componentGenerationTemplatePath = Join-Path $PSScriptRoot 'templates\componentgeneration.template.md'
        if (Test-Path $componentGenerationTemplatePath) {
            try {
                $componentGenerationContent = Get-Content $componentGenerationTemplatePath -Raw
                $componentGenerationContent | Out-File -FilePath "$promptsDir\component-generation.prompt.md" -Encoding UTF8
                Write-ColorOutput "  Created component-generation.prompt.md" "Green"
            }
            catch {
                Write-ColorOutput "  Failed to create component-generation.prompt.md: $($_.Exception.Message)" "Red"
                return $false
            }
        } 
        else {
            Write-ColorOutput "  componentgeneration.template.md not found at $componentGenerationTemplatePath. Skipping component-generation.prompt.md creation." "Red"
        }
    }

    # Summary of created files
    $createdFiles = @(
        "specify.prompt.md - Converts requirements into detailed specifications",
        "plan.prompt.md - Creates implementation plans from specifications", 
        "tasks.prompt.md - Breaks plans into specific development tasks",
        "review.prompt.md - Reviews completed work for quality and compliance"
    )
    
    if ($WithDesignSystem) {
        $createdFiles += @(
            "design-analysis.prompt.md - Analyzes Figma designs for implementation",
            "component-generation.prompt.md - Implements components from design specs"
        )
    }
    
    Write-ColorOutput "All Claude Code prompt templates created successfully!" "Green"
    Write-ColorOutput "Created prompt files:" "Cyan"
    foreach ($file in $createdFiles) {
        Write-ColorOutput "  -  $file" "White"
    }
    
    Write-ColorOutput "Usage examples:" "Yellow"
    Write-ColorOutput "   claude-code specify Build user authentication system" "Gray"
    Write-ColorOutput "   claude-code plan Create implementation plan for auth system" "Gray"
    Write-ColorOutput "   claude-code tasks Break down auth plan into development tasks" "Gray"
    if ($WithDesignSystem) {
        Write-ColorOutput "   claude-code implement  -> Use component-generation.prompt.md to build LoginForm", "Gray"
    }
    
    return $true
}


# Call the main function
New-ClaudeCodeProject