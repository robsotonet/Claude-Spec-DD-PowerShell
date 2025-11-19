# Design Analysis and Specification Prompt

You are analyzing Figma designs to create implementation specifications for developers.

## Context Files to Review:
- ``.claude-code/design/figma-links.md`` - Figma file references and export guidelines
- ``.claude-code/design/design_system.json`` - **PRIMARY DESIGN TOKEN SOURCE**
- ``.claude-code/design/figma-exports/`` - Exported Figma screens, components, and assets
- ``.claude-code/context/design-system.md`` - Design system guidelines and principles
- ``.claude-code/context/constitution.md`` - Project principles and quality standards

## Available Design Assets:
- Screen exports in ``.claude-code/design/figma-exports/screens/``
- Component exports in ``.claude-code/design/figma-exports/components/``
- Icon exports in ``.claude-code/design/figma-exports/icons/``
- User flow diagrams in ``.claude-code/design/figma-exports/flows/``

## Your Task:
1. Analyze the provided Figma exports and design assets systematically
2. Extract component specifications and implementation requirements
3. Identify responsive behavior and breakpoint requirements
4. Map all design elements to design_system.json tokens
5. Create comprehensive component implementation specifications
6. Document user interaction patterns and micro-interactions

## Design Token Mapping:
- **ALWAYS reference tokens** from ``design_system.json`` using dot notation
- **Color Usage**: Map all colors to ``colors.brand.primary.500``, ``colors.neutral.gray.900``, etc.
- **Typography**: Use ``typography.fontSizes.lg``, ``typography.fontWeights.medium``, etc.
- **Spacing**: Reference ``spacing.4``, ``spacing.6``, ``spacing.8`` for all margins and padding
- **Layout Properties**: Use ``borderRadius.md``, ``shadows.sm``, etc.

## Token Usage Examples:
Wrong - Hardcoded values:
color: #3b82f6;
font-size: 18px;
padding: 16px;
border-radius: 6px;

Correct - Design system tokens:
color: var(--colors-brand-primary-500);
font-size: var(--typography-fontSizes-lg);  
padding: var(--spacing-4);
border-radius: var(--borderRadius-md);

## Output Format:
Create or update ``docs/design-requirements.md`` with component specifications including:
- Visual design references and Figma links
- Complete design token mappings for all visual properties
- Component props interface definitions
- Responsive behavior specifications
- Accessibility requirements
- Implementation priority levels

## Quality Standards:
- Every design element must map to a design system token
- Every interactive element must have all states defined
- Every component must have responsive behavior specified
- Every accessibility requirement must be documented
- Missing design tokens must be identified and flagged for addition
