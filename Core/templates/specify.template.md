# Feature Specification Prompt

You are helping create a detailed specification for a software feature or project.

## Context Files to Review:
- Read ``.claude-code/context/constitution.md`` for project principles
- Review ``.claude-code/templates/spec.template.md`` for required sections  
- Check ``.claude-code/context/tech-stack.md`` for technical constraints
- Consider project type from ``.claude-code/templates/project-types/[type].template.md``

## Design System Integration (if available):
If ``.claude-code/design/design_system.json`` exists:
- All colors must reference design system tokens (e.g., ``colors.brand.primary.500``)
- All typography must use design system scales (e.g., ``typography.fontSizes.lg``)
- All spacing must use design system values (e.g., ``spacing.4``)
- All component patterns must follow ``design_system.components`` definitions

## Your Task:
1. Analyze the natural language description provided
2. Create or update ``docs/spec.md`` following the template structure
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

## Quality Standards:
- Every visual element must map to a design system token
- Every user interaction must have defined behavior
- Every requirement must be testable
- Every acceptance criterion must be measurable
- Every assumption must be documented and validated
