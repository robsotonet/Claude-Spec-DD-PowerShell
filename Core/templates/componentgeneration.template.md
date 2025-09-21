# Component Implementation with Design System

You are implementing UI components based on Figma designs and design specifications.

## Context Files to Review:
- ``docs/design-requirements.md`` - Component specifications with token mappings
- ``.claude-code/design/design_system.json`` - **MANDATORY: All styling must use these tokens**
- ``.claude-code/design/figma-exports/`` - Visual reference for pixel-perfect implementation
- ``.claude-code/templates/component.template.md`` - Component structure template
- ``.claude-code/context/constitution.md`` - Code quality and accessibility standards

## Design System Usage Rules:
1. **Token References Only**: Never use hardcoded colors, sizes, or spacing values
2. **CSS Custom Properties**: Convert JSON tokens to CSS variables for styling
3. **Component Patterns**: Follow patterns defined in ``design_system.components``
4. **Consistent Naming**: Use design system naming conventions throughout

## Component Implementation Requirements:

### File Structure (Required)
src/components/[ComponentName]/
├── index.ts                           # Export barrel
├── [ComponentName].tsx                # Main component implementation
├── [ComponentName].styles.ts          # Styled components using design tokens
├── [ComponentName].stories.tsx        # Storybook stories with Figma links
├── [ComponentName].test.tsx           # Comprehensive unit tests
├── [ComponentName].types.ts           # TypeScript interfaces
└── README.md                         # Component documentation

### Styled Components Implementation
Always use design tokens, never hardcoded values:

export const StyledComponent = styled.button<StyledProps>
  /* Use design system tokens */
  font-family: [designTokens.typography.fontFamilies.sans];
  font-size: [designTokens.typography.fontSizes.base];
  color: [designTokens.colors.neutral.gray[900]];
  background-color: [designTokens.colors.neutral.white];
  padding: [designTokens.spacing[3]] [designTokens.spacing[4]];
  border-radius: [designTokens.borderRadius.md];
  
  /* Never use hardcoded values like:
  font-size: 16px;
  color: #111827;
  padding: 12px 16px;
  */
  
  /* Responsive behavior */
  @media (min-width: [designTokens.breakpoints.md]) {
    font-size: [designTokens.typography.fontSizes.lg];
  }
;

## Quality Implementation Checklist:

### Design Fidelity
- Visual appearance matches Figma designs exactly
- All spacing uses design system spacing tokens
- Typography matches design system font specifications
- Colors reference design system color tokens
- All component variants implemented as designed

### Accessibility Implementation
- Semantic HTML elements used correctly
- ARIA labels and roles provided where necessary
- Keyboard navigation works for all interactive elements
- Focus indicators visible and meet contrast requirements
- Screen reader support implemented
- Color contrast meets WCAG 2.1 AA standards

### Code Quality
- TypeScript interfaces match component requirements
- All props have appropriate types and defaults
- Component is performant and optimized
- Error boundaries implemented for complex components
- Code follows project conventions

### Testing Coverage
- Unit tests for all component variants and props
- Tests for all interactive states
- Accessibility testing included
- Visual regression tests comparing to Figma
- Performance testing for rendering

## Implementation Output:
Generate complete, production-ready component implementation that:
- Matches Figma designs pixel-perfectly
- Uses only design system tokens for styling
- Includes comprehensive TypeScript types
- Has full test coverage
- Meets all accessibility requirements
- Follows project code standards
