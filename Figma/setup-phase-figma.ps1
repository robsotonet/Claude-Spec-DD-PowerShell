# ==============================================================================
# Figma Integration Scripts for Phase-Based Development
# ==============================================================================

# ------------------------------------------------------------------------------
# 1. PHASE FIGMA SETUP SCRIPT
# ------------------------------------------------------------------------------

# File: setup-phase-figma.ps1
param(
    [Parameter(Mandatory=$true, HelpMessage="Phase number to set up Figma integration for")]
    [string]$PhaseNumber,
    
    [Parameter(Mandatory=$false, HelpMessage="Figma file URL for this phase")]
    [string]$FigmaUrl = "",
    
    [Parameter(Mandatory=$false, HelpMessage="Create interactive prompts")]
    [switch]$Interactive = $false
)

function Write-ColorOutput {
    param([string]$Message, [string]$Color = "White")
    Write-Host $Message -ForegroundColor $Color
}

function Initialize-PhaseFigmaStructure {
    param([string]$PhaseNumber)
    
    Write-ColorOutput "🎨 Setting up Figma integration for Phase $PhaseNumber..." "Cyan"
    
    # Create phase-specific design directories
    $phaseDirs = @(
        ".claude-code\design\phase-designs\phase-$PhaseNumber\screens",
        ".claude-code\design\phase-designs\phase-$PhaseNumber\components",
        ".claude-code\design\phase-designs\phase-$PhaseNumber\flows",
        ".claude-code\design\phase-designs\phase-$PhaseNumber\specs",
        ".claude-code\design\phase-designs\phase-$PhaseNumber\assets"
    )

    foreach ($dir in $phaseDirs) {
        New-Item -ItemType Directory -Path $dir -Force | Out-Null
    }

    # Create phase-specific figma links file
    $figmaLinksContent = @"
# Phase $PhaseNumber Figma Design References

## Phase Overview
**Phase Number**: $PhaseNumber
**Design Status**: In Progress
**Last Updated**: $(Get-Date -Format 'yyyy-MM-dd')

## Figma Files
### Main Phase Design File
- **Figma URL**: $FigmaUrl
- **Design System**: [Link to design system Figma file]
- **Prototype URL**: [Link to interactive prototype if available]

### Design Access
- **View Access**: [team@company.com]
- **Edit Access**: [designers@company.com]  
- **Developer Handoff**: [developers@company.com]

## Phase $PhaseNumber Screens
### Authentication Screens (if Phase 1)
- **Login**: login.png
- **Register**: register.png  
- **Password Reset**: password-reset.png
- **Email Verification**: email-verification.png

### Dashboard Screens
- **Main Dashboard**: dashboard.png
- **User Profile**: profile.png

### Contact Management Screens (if Phase 1)
- **Contact List**: contacts-list.png
- **Contact Detail**: contact-detail.png
- **Add/Edit Contact**: contact-form.png
- **Contact Import**: contact-import.png

### Task Management Screens (if Phase 1)
- **Task List**: tasks-list.png
- **Task Detail**: task-detail.png
- **Task Creation**: task-form.png
- **Task Categories**: task-categories.png

### Social Authentication Screens (if Phase 2)
- **Social Login Options**: social-login.png
- **OAuth Consent**: oauth-consent.png
- **Account Linking**: account-linking.png

### Reminder/Notification Screens (if Phase 2)
- **Notification Settings**: notification-settings.png
- **Reminder Setup**: reminder-setup.png
- **Notification History**: notification-history.png

## Component Library
### Phase $PhaseNumber Specific Components
- **Component Name**: filename.png
- **Component Name**: filename.png

## User Flows  
### Core User Flows for Phase $PhaseNumber
- **Authentication Flow**: auth-flow.png
- **Task Creation Flow**: task-creation-flow.png
- **Contact Management Flow**: contact-flow.png

## Export Settings
### Screens
- **Format**: PNG
- **Resolution**: 2x (Retina)
- **Background**: Include background
- **Naming**: [screen-name].png

### Components
- **Format**: PNG + SVG (for icons)
- **Resolution**: 2x for PNG
- **Background**: Transparent for components
- **Naming**: [component-name].png

### Assets
- **Icons**: SVG format
- **Images**: PNG/JPG optimized
- **Illustrations**: SVG preferred

## Design Specifications
### Design Token Mapping
All design elements should map to design system tokens:
- **Colors**: Reference colors from design_system.json
- **Typography**: Use typography scale from design system
- **Spacing**: Follow spacing system
- **Components**: Align with component specifications

### Responsive Design
- **Breakpoints**: Mobile (320px), Tablet (768px), Desktop (1024px+)
- **Mobile-First**: Design mobile experience first
- **Progressive Enhancement**: Add complexity for larger screens

### Accessibility Requirements
- **Color Contrast**: 4.5:1 minimum ratio
- **Focus States**: Clear focus indicators
- **Touch Targets**: Minimum 44px touch targets
- **Screen Reader**: Proper heading hierarchy and labels

## Implementation Notes
### Development Handoff
- **Figma Dev Mode**: Use for accurate spacing and measurements
- **Design Tokens**: All measurements should reference design system
- **Component States**: Document all interactive states
- **Animation**: Specify transitions and micro-interactions

### Quality Checklist
- [ ] All screens exported at correct resolution
- [ ] Components follow design system consistently  
- [ ] User flows clearly documented
- [ ] Interactive states defined
- [ ] Responsive behavior specified
- [ ] Accessibility requirements noted
- [ ] Design tokens properly mapped
"@

    $figmaLinksContent | Out-File -FilePath ".claude-code\design\phase-designs\phase-$PhaseNumber\figma-links.md" -Encoding UTF8

    # Create phase design specification template
    $designSpecContent = @"
# Phase $PhaseNumber Design Specifications

## Overview
**Phase**: $PhaseNumber
**Design Theme**: [Theme for this phase's visual design]
**Target Completion**: [Design completion date]

## Design Objectives
1. **User Experience Goal**: [What UX outcome this phase should achieve]
2. **Visual Design Goal**: [What visual identity this phase establishes]
3. **Usability Goal**: [What usability improvements this phase delivers]

## Screen Specifications

### Screen: [Screen Name]
**File**: .claude-code/design/phase-designs/phase-$PhaseNumber/screens/[screen-name].png
**Figma Link**: [Direct link to this screen in Figma]

#### Layout Structure
- **Header**: [Description of header elements]
- **Main Content**: [Description of main content area]
- **Navigation**: [Description of navigation elements]
- **Footer**: [Description of footer if applicable]

#### Design System Usage
- **Primary Colors**: `colors.brand.primary.500`, `colors.brand.primary.600`
- **Text Colors**: `colors.neutral.gray.900`, `colors.neutral.gray.600`
- **Background**: `colors.neutral.white`, `colors.neutral.gray.50`
- **Typography**: 
  - Headings: `typography.fontSizes.2xl`, `typography.fontWeights.bold`
  - Body: `typography.fontSizes.base`, `typography.fontWeights.normal`
- **Spacing**: `spacing.4`, `spacing.6`, `spacing.8`
- **Border Radius**: `borderRadius.md`

#### Interactive Elements
- **Buttons**: 
  - Primary: Uses `colors.brand.primary.500` background
  - Secondary: Uses `colors.neutral.gray.100` background  
  - States: Hover, active, disabled, loading
- **Form Inputs**:
  - Default state styling
  - Focus state with `colors.brand.primary.500` border
  - Error state with `colors.semantic.error.main`
  - Success state with `colors.semantic.success.main`

#### Responsive Behavior
- **Mobile (320px-767px)**: [Mobile-specific layout changes]
- **Tablet (768px-1023px)**: [Tablet-specific layout changes]  
- **Desktop (1024px+)**: [Desktop layout specifications]

#### Accessibility Requirements
- **Color Contrast**: All text meets 4.5:1 contrast ratio
- **Focus Indicators**: All interactive elements have visible focus states
- **Keyboard Navigation**: Tab order follows logical flow
- **Screen Reader**: Proper heading hierarchy and ARIA labels

## Component Specifications

### Component: [Component Name]
**File**: .claude-code/design/phase-designs/phase-$PhaseNumber/components/[component-name].png
**Usage**: [Where and how this component is used]

#### Design System Mapping
```css
.component-name {
  /* Colors */
  color: var(--colors-neutral-gray-900);
  background-color: var(--colors-neutral-white);
  border-color: var(--colors-neutral-gray-200);
  
  /* Typography */
  font-family: var(--typography-fontFamilies-sans);
  font-size: var(--typography-fontSizes-base);
  font-weight: var(--typography-fontWeights-medium);
  
  /* Spacing */
  padding: var(--spacing-3) var(--spacing-4);
  margin-bottom: var(--spacing-2);
  
  /* Layout */
  border-radius: var(--borderRadius-md);
  box-shadow: var(--shadows-sm);
}
```

#### Component States
- **Default**: [Default appearance and styling]
- **Hover**: [Hover state changes]
- **Active/Selected**: [Active state styling]  
- **Disabled**: [Disabled state appearance]
- **Loading**: [Loading state with spinner or skeleton]
- **Error**: [Error state styling]

#### Component Variants
- **Size Variants**: small, medium, large
- **Style Variants**: primary, secondary, outline, ghost
- **Context Variants**: Different styling for different contexts

## User Flow Specifications

### Flow: [Flow Name]
**File**: .claude-code/design/phase-designs/phase-$PhaseNumber/flows/[flow-name].png

#### Flow Steps
1. **Step 1**: [Description of first step]
   - **Screen**: [Which screen]
   - **User Action**: [What user does]
   - **System Response**: [How system responds]
   
2. **Step 2**: [Description of second step]
   - **Screen**: [Which screen]
   - **User Action**: [What user does]
   - **System Response**: [How system responds]

#### Error Handling
- **Error Scenario 1**: [How errors are handled]
- **Error Scenario 2**: [Alternative error handling]

#### Success Criteria
- **User Successfully**: [What constitutes successful flow completion]
- **System State**: [What system state indicates success]

## Animation and Interaction Specifications

### Micro-Interactions
- **Button Hover**: 150ms ease-out transition
- **Form Focus**: 200ms ease-in-out border color change
- **Loading States**: Smooth spinner or skeleton animation
- **Page Transitions**: 300ms slide or fade transitions

### Motion Design Principles
- **Respect Motion Preferences**: Honor prefers-reduced-motion
- **Performance**: Use CSS transforms for better performance
- **Purposeful**: Animations should provide feedback or guide attention
- **Consistent**: Same timing and easing throughout phase

## Implementation Priorities

### Must-Have (P0)
- [ ] Core screens pixel-perfect implementation
- [ ] All interactive states functional
- [ ] Responsive design working across breakpoints
- [ ] Accessibility requirements met

### Should-Have (P1)  
- [ ] All micro-interactions implemented
- [ ] Performance optimizations applied
- [ ] Cross-browser testing completed
- [ ] Design system compliance verified

### Nice-to-Have (P2)
- [ ] Advanced animations and transitions
- [ ] Enhanced loading states
- [ ] Additional responsive optimizations
- [ ] Extra polish and refinements

## Quality Assurance

### Design QA Checklist
- [ ] All screens match Figma designs exactly
- [ ] Design system tokens used consistently
- [ ] Interactive states work as designed
- [ ] Responsive behavior matches specifications
- [ ] Accessibility requirements implemented
- [ ] Performance impact assessed
- [ ] Cross-browser compatibility verified

### Designer-Developer Handoff
- [ ] All design specifications documented
- [ ] Edge cases and error states defined
- [ ] Animation specifications provided
- [ ] Responsive behavior clarified
- [ ] Design system token mapping complete
- [ ] Implementation priorities agreed upon
"@

    $designSpecContent | Out-File -FilePath "docs\phases\phase-$PhaseNumber\design-spec.md" -Encoding UTF8

    Write-ColorOutput "✅ Figma integration structure created for Phase $PhaseNumber" "Green"
    Write-ColorOutput "📁 Directories created:" "White"
    Write-ColorOutput "   • .claude-code\design\phase-designs\phase-$PhaseNumber\" "Gray"
    Write-ColorOutput "   • docs\phases\phase-$PhaseNumber\design-spec.md" "Gray"
}

function New-FigmaPrompts {
    Write-ColorOutput "📝 Creating Figma-to-development prompts..." "Yellow"

    # Create design-to-phase prompt
    $designToPhasePrompt = @'
# Design-to-Phase Specification Prompt

You are analyzing Figma designs to create phase-specific implementation specifications.

## Context Files to Review:
- `.claude-code/design/phase-designs/phase-[X]/figma-links.md` - Phase Figma references
- `.claude-code/design/phase-designs/phase-[X]/screens/` - Screen exports
- `.claude-code/design/phase-designs/phase-[X]/components/` - Component exports
- `.claude-code/design/design_system.json` - Design system tokens
- `docs/phases/phase-[X]/spec.md` - Phase functional specification
- `.claude-code/context/constitution.md` - Project principles

## Your Task:
Analyze the provided Figma designs and create comprehensive implementation specifications that bridge design and development for this specific phase.

## Phase Design Analysis Requirements:

### 1. Screen Analysis
For each screen in the phase:
- **Visual Hierarchy**: Identify information hierarchy and layout structure
- **Design Token Mapping**: Map all visual elements to design_system.json tokens
- **Interactive Elements**: Identify all clickable, hoverable, or interactive areas
- **Content Requirements**: Specify text, image, and data requirements
- **State Variations**: Document loading, error, empty, and success states

### 2. Component Analysis
For each new component in this phase:
- **Atomic Design Classification**: Atom, molecule, organism, or template
- **Props and Variations**: Identify all component variants and configurations
- **Design System Compliance**: Ensure alignment with existing design system
- **Reusability**: Identify opportunities for cross-phase component usage
- **Implementation Complexity**: Assess development effort and dependencies

### 3. User Flow Analysis
For each user flow shown in Figma:
- **Flow Steps**: Break down each step in the user journey
- **Decision Points**: Identify where users make choices or system responds
- **Error Handling**: Document error states and recovery flows
- **Success Criteria**: Define what constitutes successful flow completion
- **Performance Considerations**: Identify potential performance bottlenecks

### 4. Responsive Design Analysis
- **Breakpoint Behavior**: Document how design adapts across screen sizes
- **Mobile-First Considerations**: Identify mobile-specific design decisions
- **Touch Interactions**: Specify touch target sizes and gestures
- **Content Priority**: Determine what content is most important at each breakpoint

### 5. Integration Points
- **Previous Phase Dependencies**: How this phase builds on previous work
- **Shared Components**: Which components are reused from earlier phases
- **Data Flow**: How data flows between screens and components
- **API Requirements**: What backend endpoints are needed for these designs

## Implementation Specification Format:
Create detailed specifications that include:

```markdown
## Screen: [Screen Name]
### Visual Design
- **Layout**: [Grid system, spacing, alignment]
- **Typography**: [Heading hierarchy, text styles using design tokens]
- **Color Usage**: [Color scheme using design system tokens]
- **Imagery**: [Image requirements, aspect ratios, placeholder states]

### Functional Requirements  
- **User Actions**: [What users can do on this screen]
- **System Responses**: [How system reacts to user actions]
- **Data Requirements**: [What data is displayed and where it comes from]
- **Navigation**: [How users move to/from this screen]

### Implementation Details
- **Component Breakdown**: [Which components make up this screen]
- **State Management**: [What state needs to be managed]
- **API Calls**: [What backend requests are needed]
- **Performance**: [Loading strategies, optimization opportunities]

### Quality Requirements
- **Accessibility**: [ARIA labels, keyboard navigation, screen reader support]
- **Performance**: [Load time targets, image optimization]
- **Browser Support**: [Cross-browser compatibility requirements]
- **Testing**: [Key user flows to test]
```

## Design System Integration:
- **ALWAYS use design system tokens** - never suggest hardcoded values
- **Maintain consistency** with previous phases
- **Identify gaps** in design system that need to be filled
- **Suggest improvements** to design system based on phase needs

## Output Requirements:
1. Update `docs/phases/phase-[X]/design-spec.md` with comprehensive specifications
2. Identify any missing design system tokens needed for this phase
3. Create component implementation priorities (P0, P1, P2)
4. Document any design decisions that differ from previous phases
5. Specify acceptance criteria for design implementation quality

## Quality Standards:
- Every visual element must map to a design system token
- Every interactive element must have defined states
- Every user flow must have error handling specified
- Every component must have responsive behavior documented
- Every screen must meet accessibility requirements
'@

    $designToPhasePrompt | Out-File -FilePath ".claude-code\prompts\design-to-phase.prompt.md" -Encoding UTF8

    # Create phase design implementation prompt
    $phaseDesignImplementPrompt = @'
# Phase Design Implementation Prompt

You are implementing UI components and screens based on phase-specific Figma designs.

## Context Files to Review:
- `docs/phases/phase-[X]/design-spec.md` - Detailed design specifications for this phase
- `.claude-code/design/phase-designs/phase-[X]/` - All Figma exports for this phase
- `.claude-code/design/design_system.json` - Design system tokens
- `docs/phases/phase-[X]/spec.md` - Phase functional requirements
- `.claude-code/templates/component.template.md` - Component structure template

## Implementation Strategy:
1. **Design Fidelity**: Implement pixel-perfect matches to Figma designs
2. **Token Usage**: Use only design system tokens, never hardcoded values
3. **Component Reuse**: Reuse components from previous phases where possible
4. **Phase Integration**: Ensure new components integrate with existing phase work
5. **Quality First**: Include all states, responsive behavior, and accessibility

## Implementation Priorities:

### Phase [X] Core Screens (P0 - Must Have)
Implement these screens exactly as designed:
- [List of core screens for this phase]

### Phase [X] Components (P0 - Must Have)  
Build these new components:
- [List of new components needed for this phase]

### Enhanced Features (P1 - Should Have)
- All micro-interactions and animations
- Advanced responsive optimizations
- Enhanced loading and error states

### Polish Items (P2 - Nice to Have)
- Additional animations and transitions
- Extra responsive refinements
- Performance optimizations

## Component Implementation Requirements:

### File Structure for Each Component
```
src/phases/phase-[X]/components/[ComponentName]/
├── index.ts                           # Export barrel
├── [ComponentName].tsx                # Main component
├── [ComponentName].styles.ts          # Styled components with design tokens
├── [ComponentName].stories.tsx        # Storybook stories showing Figma designs
├── [ComponentName].test.tsx           # Unit tests
├── [ComponentName].types.ts           # TypeScript interfaces
└── README.md                         # Component documentation with Figma links
```

### Required Implementation Elements
```typescript
// Every component must include:
export interface ComponentProps {
  // Props that match Figma component variations
  variant?: 'primary' | 'secondary' | 'outline';
  size?: 'sm' | 'md' | 'lg';
  state?: 'default' | 'loading' | 'error' | 'success';
  
  // Standard React props
  children?: React.ReactNode;
  disabled?: boolean;
  
  // Accessibility props (required)
  'aria-label'?: string;
  'data-testid'?: string;
}

// Styled components using design tokens
const StyledComponent = styled.div<StyledProps>`
  // ✅ Use design system tokens
  color: ${designTokens.colors.neutral.gray[900]};
  background: ${designTokens.colors.neutral.white};
  padding: ${designTokens.spacing[4]};
  border-radius: ${designTokens.borderRadius.md};
  
  // ❌ Never hardcode values
  // color: #111827;
  // background: #ffffff;
  // padding: 16px;
  
  // Responsive behavior from Figma specs
  @media (min-width: ${designTokens.breakpoints.md}) {
    padding: ${designTokens.spacing[6]};
  }
`;
```

## Screen Implementation Requirements:

### Page Component Structure
```
src/phases/phase-[X]/pages/[ScreenName]/
├── index.ts                           # Export barrel
├── [ScreenName].tsx                   # Main page component
├── [ScreenName].styles.ts             # Page-specific styles
├── [ScreenName].test.tsx              # Page integration tests
├── components/                        # Screen-specific components
│   ├── [LocalComponent]/             # Components only used on this screen
└── hooks/                            # Screen-specific hooks
    └── use[ScreenName]Data.ts        # Data fetching logic
```

## Quality Implementation Checklist:

### Design Fidelity
- [ ] Visual appearance matches Figma exactly
- [ ] All spacing and sizing uses design system tokens
- [ ] Typography matches design system specifications
- [ ] Colors use design system token references
- [ ] All component variants implemented as designed

### Responsive Design
- [ ] Mobile-first implementation approach
- [ ] All Figma breakpoints properly implemented
- [ ] Touch targets meet minimum size requirements (44px)
- [ ] Content hierarchy maintained across screen sizes
- [ ] Navigation patterns work on all devices

### Interactive States
- [ ] Default state matches Figma design
- [ ] Hover states implemented with design system colors
- [ ] Focus states visible and accessible
- [ ] Active states provide clear feedback
- [ ] Disabled states appropriately styled
- [ ] Loading states use consistent patterns
- [ ] Error states clearly communicate issues

### Accessibility Implementation
- [ ] Semantic HTML elements used appropriately
- [ ] ARIA labels provided where needed
- [ ] Keyboard navigation works for all interactions
- [ ] Screen reader announcements for dynamic content
- [ ] Color contrast meets WCAG 2.1 AA standards
- [ ] Focus management for modal and overlay interactions

### Phase Integration
- [ ] New components integrate with existing phase components
- [ ] Shared state management works across phase screens
- [ ] Routing between screens functions properly
- [ ] Data flow between components works correctly
- [ ] Previous phase functionality remains intact

### Performance
- [ ] Images optimized and properly sized
- [ ] Lazy loading implemented where appropriate
- [ ] Bundle size impact assessed
- [ ] Rendering performance optimized
- [ ] Memory usage considerations addressed

## Testing Requirements:

### Unit Tests
- Test all component variants and props
- Test all interactive states
- Test responsive behavior
- Test accessibility features

### Integration Tests  
- Test user flows from Figma prototypes
- Test data flow between components
- Test error handling and recovery
- Test phase-to-phase navigation

### Visual Regression Tests
- Compare rendered components to Figma exports
- Test across different screen sizes
- Test all component states and variants

## Documentation Requirements:
- Update component README with Figma links
- Document any deviations from Figma designs
- Record design system token usage
- Note accessibility implementation details
- Document responsive behavior decisions

This prompt ensures your implementation perfectly matches the Figma designs while maintaining code quality and consistency with your design system and previous phases.
'@

    $phaseDesignImplementPrompt | Out-File -FilePath ".claude-code\prompts\phase-design-implement.prompt.md" -Encoding UTF8

    Write-ColorOutput "✅ Figma integration prompts created" "Green"
}

# Main execution
if ($Interactive) {
    if (-not $FigmaUrl) {
        $FigmaUrl = Read-Host "Enter Figma URL for Phase $PhaseNumber (optional)"
    }
}

Initialize-PhaseFigmaStructure -PhaseNumber $PhaseNumber
New-FigmaPrompts

Write-ColorOutput "🎨 Figma integration setup complete for Phase $PhaseNumber!" "Green"
Write-ColorOutput "📝 Next steps:" "Yellow"
Write-ColorOutput "   1. Add your Figma exports to .claude-code\design\phase-designs\phase-$PhaseNumber\" "White"  
Write-ColorOutput "   2. Update the Figma URL in figma-links.md" "White"
Write-ColorOutput "   3. Use Claude Code with design-to-phase.prompt.md to analyze your designs" "White"
Write-ColorOutput "   4. Use phase-design-implement.prompt.md to build components" "White"
