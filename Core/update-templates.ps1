# ------------------------------------------------------------------------------
# 3. TEMPLATE UPDATE SCRIPT
# ------------------------------------------------------------------------------

# File: update-templates.ps1
param(
    [Parameter(Mandatory=$false)]
    [string]$TemplateSource = "",
    
    [Parameter(Mandatory=$false)]
    [switch]$Backup = $true,
    
    [Parameter(Mandatory=$false)]
    [switch]$Force = $false
)

function Update-ClaudeCodeTemplates {
    Write-ColorOutput "🔄 Updating Claude Code templates..." "Cyan"

    # Validate current setup
    if (-not (Test-Path ".claude-code")) {
        Write-ColorOutput "❌ No Claude Code setup found in current directory" "Red"
        Write-ColorOutput "💡 Run init-claude-project.ps1 first" "Yellow"
        return
    }

    # Backup existing templates if requested
    if ($Backup) {
        $backupDir = ".claude-code\backups\$(Get-Date -Format 'yyyy-MM-dd-HHmm')"
        Write-ColorOutput "💾 Creating backup..." "Yellow"
        
        New-Item -ItemType Directory -Path $backupDir -Force | Out-Null
        Copy-Item -Path ".claude-code\*" -Destination $backupDir -Recurse -Force
        Write-ColorOutput "✅ Backup created: $backupDir" "Green"
    }

    # Update templates based on source
    if ($TemplateSource) {
        Update-FromSource -Source $TemplateSource
    } else {
        Update-LocalTemplates
    }

    # Validate updated templates
    Test-TemplateIntegrity

    Write-ColorOutput "✅ Template update completed!" "Green"
}

function Update-FromSource {
    param([string]$Source)
    
    Write-ColorOutput "📥 Fetching templates from: $Source" "Yellow"
    
    # This could be expanded to pull from various sources:
    # - Git repositories
    # - Network shares  
    # - Package managers
    # - REST APIs
    
    if ($Source.StartsWith("http")) {
        # Download from web source
        Write-ColorOutput "🌐 Downloading from web source..." "Yellow"
        # Implementation for web downloads
    } elseif (Test-Path $Source) {
        # Copy from local path
        Write-ColorOutput "📁 Copying from local path..." "Yellow"
        Copy-Item -Path "$Source\*" -Destination ".claude-code\" -Recurse -Force
    } else {
        Write-ColorOutput "❌ Invalid template source: $Source" "Red"
        return
    }
}

function Update-LocalTemplates {
    Write-ColorOutput "🔧 Updating local templates with latest patterns..." "Yellow"
    
    # Update prompt files with latest best practices
    Update-PromptTemplates
    
    # Update component templates
    Update-ComponentTemplates
    
    # Update project type templates
    Update-ProjectTypeTemplates
}

function Update-PromptTemplates {
    # Enhanced specify prompt with design system integration
    $specifyPrompt = @'
# Feature Specification Prompt

You are helping create a detailed specification for a software feature or project.

## Context Files to Review:
- Read `.claude-code/context/constitution.md` for project principles
- Review `.claude-code/templates/spec.template.md` for required sections  
- Check `.claude-code/context/tech-stack.md` for technical constraints
- **IMPORTANT**: If `.claude-code/design/design_system.json` exists, use it for all design decisions
- Consider project type from `.claude-code/templates/project-types/[type].template.md`

## Design System Integration:
If design system exists:
- All colors must reference design system tokens (e.g., `colors.brand.primary.500`)
- All typography must use design system scales (e.g., `typography.fontSizes.lg`)
- All spacing must use design system values (e.g., `spacing.4`)
- All component patterns must follow `design_system.components` definitions

## Your Task:
1. Analyze the natural language description provided
2. Create or update `docs/spec.md` following the template structure
3. Ensure alignment with constitutional principles
4. Include specific acceptance criteria mapped to design system tokens
5. Define clear boundaries and non-goals

## Specification Requirements:
- **User Stories**: Who wants what and why
- **Functional Requirements**: What the system must do
- **Non-Functional Requirements**: Performance, security, usability constraints
- **Design Requirements**: Visual specifications using design system tokens
- **Acceptance Criteria**: Testable conditions for completion
- **Out of Scope**: What we explicitly won't build
- **Dependencies**: External systems or components required
- **Assumptions**: What we're assuming to be true

## Output Format:
- Use the spec template structure exactly
- Be specific and measurable in all requirements
- Include user stories in "As a [user], I want [goal] so that [benefit]" format
- Map all design requirements to design system tokens
- Define technical requirements clearly with metrics where possible
- Ensure every requirement is testable and has clear acceptance criteria
'@

    $specifyPrompt | Out-File -FilePath ".claude-code\prompts\specify.prompt.md" -Encoding UTF8
    Write-ColorOutput "✅ Updated specify.prompt.md" "Green"
}

function Update-ComponentTemplates {
    # Enhanced component template with design system integration
    $componentTemplate = @'
# Component Implementation Template

## File Structure
```
src/components/[ComponentName]/
├── index.ts                    # Export barrel
├── [ComponentName].tsx         # Main component
├── [ComponentName].styles.ts   # Styled components with design tokens
├── [ComponentName].stories.tsx # Storybook stories
├── [ComponentName].test.tsx    # Unit tests
├── [ComponentName].types.ts    # TypeScript interfaces
└── README.md                  # Component documentation
```

## Design System Integration Requirements

### 1. Token Usage (.styles.ts)
```typescript
import styled, { css } from 'styled-components';
// Import design system tokens
import { designTokens } from '../../styles/design-tokens';

export const StyledComponent = styled.button<StyledProps>`
  // ✅ Use design system tokens
  font-family: ${designTokens.typography.fontFamilies.sans};
  font-size: ${designTokens.typography.fontSizes.base};
  color: ${designTokens.colors.brand.primary[500]};
  padding: ${designTokens.spacing[2]} ${designTokens.spacing[4]};
  border-radius: ${designTokens.borderRadius.md};
  
  // ❌ Never use hardcoded values
  // font-size: 16px;
  // color: #3b82f6;
  // padding: 8px 16px;
  
  // Responsive design using design system breakpoints
  @media (min-width: ${designTokens.breakpoints.md}) {
    font-size: ${designTokens.typography.fontSizes.lg};
  }
`;
```

### 2. Component Props Interface (.types.ts)
```typescript
export interface [ComponentName]Props {
  // Visual variant props that map to design system
  variant?: keyof typeof designTokens.components.[componentName].variants;
  size?: keyof typeof designTokens.components.[componentName].sizes;
  
  // Standard props
  children?: React.ReactNode;
  disabled?: boolean;
  loading?: boolean;
  
  // Event handlers
  onClick?: (event: React.MouseEvent) => void;
  
  // Accessibility (always required)
  'aria-label'?: string;
  'aria-describedby'?: string;
  'data-testid'?: string;
}
```

### 3. Quality Checklist
- [ ] All styling uses design system tokens (no hardcoded values)
- [ ] Component variants match design_system.json definitions
- [ ] Responsive behavior follows design system breakpoints
- [ ] All interactive states implemented (hover, focus, active, disabled)
- [ ] WCAG 2.1 AA accessibility compliance
- [ ] Comprehensive unit tests for all variants and states
- [ ] Storybook stories for all component variations
- [ ] TypeScript interfaces for all props
- [ ] Performance optimized (React.memo if needed)
- [ ] Error boundaries for complex components
'@

    $componentTemplate | Out-File -FilePath ".claude-code\templates\component.template.md" -Encoding UTF8
    Write-ColorOutput "✅ Updated component.template.md" "Green"
}

function Update-ProjectTypeTemplates {
    # Update web-app template with modern practices
    $webAppTemplate = @'
# Web Application Template - 2024 Edition

## Architecture Principles
- **Component-First**: Atomic design with reusable components
- **Design System Driven**: All styling through design tokens
- **Performance First**: Core Web Vitals optimization
- **Accessibility First**: WCAG 2.1 AA compliance from day one
- **Type Safety**: Comprehensive TypeScript coverage
- **Testing Pyramid**: Unit → Integration → E2E testing strategy

## Modern Stack Recommendations
- **Framework**: React 18+ with Concurrent Features
- **Build Tool**: Vite 5+ for optimal dev experience
- **Styling**: CSS-in-JS with design system tokens OR Tailwind CSS
- **State Management**: 
  - Simple: React Context + useReducer
  - Complex: Zustand or Redux Toolkit
- **Data Fetching**: TanStack Query (React Query) v5
- **Testing**: Vitest + Testing Library + Playwright
- **Type Checking**: TypeScript 5+ in strict mode

## Required Project Structure
```
src/
├── components/          # Atomic design components
│   ├── atoms/          # Basic building blocks
│   ├── molecules/      # Simple component combinations
│   ├── organisms/      # Complex UI sections
│   └── templates/      # Page layouts
├── pages/              # Route components (Next.js style)
├── hooks/              # Custom React hooks
├── services/           # API calls and external services
├── utils/              # Pure utility functions
├── types/              # TypeScript type definitions
├── styles/             # Global styles and design tokens
├── assets/             # Static assets
└── __tests__/          # Test utilities and setup
```

## Performance Requirements
- **Lighthouse Score**: 95+ on all metrics
- **Bundle Size**: 
  - Initial: < 100KB gzipped
  - Total: < 300KB for main app bundle
- **Core Web Vitals**:
  - LCP: < 1.5s
  - FID: < 100ms  
  - CLS: < 0.1
- **Time to Interactive**: < 3s on 3G networks

## Accessibility Standards
- **Keyboard Navigation**: All interactive elements accessible
- **Screen Readers**: Proper ARIA labels and semantic HTML
- **Color Contrast**: 4.5:1 minimum ratio
- **Focus Management**: Visible focus indicators
- **Reduced Motion**: Respect user preferences

## Security Checklist
- **Content Security Policy**: Strict CSP headers
- **XSS Prevention**: Sanitize all user inputs
- **HTTPS Only**: No mixed content warnings
- **Dependency Audits**: Regular security audits
- **Environment Variables**: Secure secret management

## Quality Gates
- [ ] TypeScript strict mode with zero errors
- [ ] 90%+ test coverage on critical paths
- [ ] Zero accessibility violations in automated tests
- [ ] Performance budgets met in CI/CD
- [ ] Security audit passes
- [ ] Design system compliance verified
'@

    $webAppTemplate | Out-File -FilePath ".claude-code\templates\project-types\web-app.template.md" -Encoding UTF8
    Write-ColorOutput "✅ Updated web-app.template.md" "Green"
}

function Test-TemplateIntegrity {
    Write-ColorOutput "🔍 Validating template integrity..." "Cyan"
    
    $requiredFiles = @(
        ".claude-code\context\constitution.md",
        ".claude-code\prompts\specify.prompt.md",
        ".claude-code\prompts\plan.prompt.md", 
        ".claude-code\prompts\tasks.prompt.md",
        ".claude-code\templates\spec.template.md",
        ".claude-code\templates\component.template.md",
        ".claude-code\templates\project-types\web-app.template.md"
    )

    $missing = @()
    $valid = @()

    foreach ($file in $requiredFiles) {
        if (Test-Path $file) {
            $valid += $file
        } else {
            $missing += $file
        }
    }

    Write-ColorOutput "✅ Valid files: $($valid.Count)" "Green"
    
    if ($missing.Count -gt 0) {
        Write-ColorOutput "❌ Missing files: $($missing.Count)" "Red"
        foreach ($file in $missing) {
            Write-ColorOutput "   • $file" "Red"
        }
    } else {
        Write-ColorOutput "🎉 All template files are present and valid!" "Green"
    }
}

# Execute the update
Update-ClaudeCodeTemplates