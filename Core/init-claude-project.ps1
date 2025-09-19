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
    
    [Parameter(Mandatory=$false, HelpMessage="Type of project to create")]
    [ValidateSet("web-app", "api-backend", "mobile-client", "worker-service")]
    [string]$ProjectType = "web-app",
    
    [Parameter(Mandatory=$false, HelpMessage="Initialize git repository")]
    [switch]$InitGit = $true,
    
    [Parameter(Mandatory=$false, HelpMessage="Create with design system integration")]
    [switch]$WithDesignSystem = $true
)

function Write-ColorOutput {
    param([string]$Message, [string]$Color = "White")
    Write-Host $Message -ForegroundColor $Color
}

function New-ClaudeCodeProject {
    Write-ColorOutput "🚀 Initializing Claude Code project: $ProjectName" "Cyan"
    Write-ColorOutput "📋 Project Type: $ProjectType" "Yellow"

    # Create project directory
    if (Test-Path $ProjectName) {
        Write-ColorOutput "⚠️  Directory $ProjectName already exists!" "Yellow"
        $overwrite = Read-Host "Do you want to continue? (y/N)"
        if ($overwrite -ne 'y' -and $overwrite -ne 'Y') {
            Write-ColorOutput "❌ Project creation cancelled" "Red"
            return
        }
    }

    New-Item -ItemType Directory -Path $ProjectName -Force | Out-Null
    Set-Location $ProjectName

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
    }

    # Create project-specific structure based on type
    $projectDirs = switch ($ProjectType) {
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
    }

    Write-ColorOutput "✅ Project structure created for $ProjectType" "Green"

    # Create basic files
    New-ClaudeCodeTemplateFiles -ProjectType $ProjectType -WithDesignSystem:$WithDesignSystem
    
    Write-ColorOutput "📁 Next steps:" "Yellow"
    Write-ColorOutput "   1. Review and customize .claude-code/context/constitution.md" "White"
    Write-ColorOutput "   2. Update .claude-code/context/tech-stack.md for your preferences" "White"
    if ($WithDesignSystem) {
        Write-ColorOutput "   3. Place your design_system.json in .claude-code/design/" "White"
    }
    Write-ColorOutput "   4. Run 'claude-code' to start development" "White"
}

function New-ClaudeCodeTemplateFiles {
    param(
        [string]$ProjectType,
        [switch]$WithDesignSystem
    )

    # Create constitution.md
    $constitutionContent = @'
# Project Constitution

## Core Principles
1. **User First** - Every decision prioritizes user experience and value
2. **Security by Design** - Security considerations integrated from the start  
3. **Performance Matters** - Optimize for speed and efficiency
4. **Maintainable Code** - Write code that future developers can easily understand
5. **Test-Driven Quality** - Comprehensive testing strategy for reliability

## Technical Standards
- Code must be readable and self-documenting
- All public APIs must be documented
- Security vulnerabilities must be addressed before deployment
- Performance regressions are not acceptable
- Breaking changes require major version bumps

## Quality Gates
- All code must pass linting and formatting checks
- Test coverage minimum: 80% for critical paths
- Performance budgets must be maintained
- Security scans must pass
- Accessibility requirements must be met (WCAG 2.1 AA)

## Decision Making
- Architectural decisions must be documented
- Trade-offs must be explicitly stated and justified
- Community standards and best practices are preferred
- Innovation is encouraged within established patterns
'@

    $constitutionContent | Out-File -FilePath ".claude-code\context\constitution.md" -Encoding UTF8

    # Create tech-stack.md based on project type
    $techStackContent = Get-TechStackTemplate -ProjectType $ProjectType
    $techStackContent | Out-File -FilePath ".claude-code\context\tech-stack.md" -Encoding UTF8

    # Create prompt files
    New-PromptFiles -WithDesignSystem:$WithDesignSystem

    # Create template files  
    New-TemplateFiles -ProjectType $ProjectType

    # Create memory files
    New-Item -ItemType File -Path ".claude-code\memory\architecture-decisions.md" -Force | Out-Null
    New-Item -ItemType File -Path ".claude-code\memory\patterns.md" -Force | Out-Null
    New-Item -ItemType File -Path ".claude-code\memory\lessons-learned.md" -Force | Out-Null

    if ($WithDesignSystem) {
        New-DesignSystemFiles
    }

    Write-ColorOutput "✅ Template files created successfully" "Green"
}

function Get-TechStackTemplate {
    param([string]$ProjectType)
    
    switch ($ProjectType) {
        "web-app" { 
            return @'
# Technology Stack - Web Application

## Frontend
- **Framework**: React 18+ with TypeScript
- **Build Tool**: Vite
- **Styling**: Tailwind CSS with design system integration
- **State Management**: Zustand (for complex state)
- **HTTP Client**: Axios with interceptors
- **Testing**: Vitest + React Testing Library + Cypress
- **Code Quality**: ESLint + Prettier + Husky

## Development Tools
- **Version Control**: Git with conventional commits
- **Package Manager**: npm/yarn/pnpm
- **IDE**: VSCode with recommended extensions
- **Debugging**: React DevTools, Browser DevTools

## Code Standards
- **TypeScript**: Strict mode enabled
- **Testing**: Minimum 80% coverage for critical paths
- **Documentation**: JSDoc for all public APIs
- **Commits**: Conventional commit format
- **Accessibility**: WCAG 2.1 AA compliance mandatory
'@
        }
        "api-backend" {
            return @'
# Technology Stack - API Backend

## Backend
- **Runtime**: Node.js 18+
- **Framework**: Express.js with TypeScript
- **Database**: PostgreSQL with Prisma ORM
- **Authentication**: JWT with refresh tokens
- **Validation**: Zod for request/response validation
- **Testing**: Jest + Supertest for API testing
- **Documentation**: OpenAPI/Swagger

## Infrastructure
- **Deployment**: Docker containers
- **Database Migrations**: Prisma migrate
- **Logging**: Winston with structured logging
- **Monitoring**: Health checks and metrics endpoints
- **Security**: Helmet.js, rate limiting, input sanitization

## Code Standards
- **TypeScript**: Strict mode with comprehensive types
- **API Design**: RESTful principles with consistent responses
- **Error Handling**: Centralized error handling with proper HTTP codes
- **Testing**: Unit tests, integration tests, and load testing
- **Security**: Regular dependency audits and security scanning
'@
        }
        default {
            return @'
# Technology Stack

## Core Technologies
- **Primary Language**: [Define based on project needs]
- **Framework**: [Choose appropriate framework]
- **Database**: [Database technology if applicable]
- **Testing**: [Testing framework and strategy]

## Development Standards
- **Code Quality**: Linting and formatting rules
- **Version Control**: Git with structured commit messages
- **Documentation**: Comprehensive API and code documentation
- **Testing**: Appropriate test coverage and strategies
'@
        }
    }
}

# Call the main function
New-ClaudeCodeProject