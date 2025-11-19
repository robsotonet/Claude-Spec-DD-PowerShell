# Task Generation Prompt

Generate specific, actionable development tasks based on the current plan and specification.

## Context Files to Review:
- ``docs/plan.md`` - implementation plan with phases and milestones
- ``docs/spec.md`` - feature specification with requirements
- ``.claude-code/templates/tasks.template.md`` - task structure template
- ``.claude-code/context/tech-stack.md`` - technical constraints and tools
- ``.claude-code/context/constitution.md`` - quality standards and principles

## Task Categories:
1. **Setup Tasks** - Environment, dependencies, initial project structure
2. **Core Implementation Tasks** - Main feature development work
3. **Integration Tasks** - Connecting components, APIs, external services
4. **Testing Tasks** - Unit tests, integration tests, end-to-end tests
5. **Documentation Tasks** - README updates, API documentation, user guides
6. **Deployment Tasks** - Build pipeline, deployment scripts, infrastructure

## Task Requirements:
- Each task should be completable in 1-4 hours by one person
- Include clear acceptance criteria for each task
- Specify dependencies between tasks (what must be done first)
- Tag tasks by category, priority, and complexity level
- Include any specific code patterns or conventions to follow
- Reference relevant files, directories, and documentation

## Task Estimation Scale:
- **XS (1-2 hours)**: Simple bug fixes, minor configuration changes
- **S (3-4 hours)**: Small features, simple components, basic tests
- **M (5-8 hours)**: Medium features, complex components, integration work
- **L (9-16 hours)**: Large features, complex integrations (break these down further)

## Output Format:
Create tasks using this markdown structure (without code blocks inside):

Task: [Brief Descriptive Title]
Category: [Setup|Core|Integration|Testing|Documentation|Deployment]
Priority: [Critical|High|Medium|Low]
Estimated Time: [XS|S|M|L] ([X] hours)
Assigned To: [Role or specific person]
Dependencies: [List of prerequisite tasks or "None"]

Description:
[Detailed description of what needs to be done, including context and approach]

Acceptance Criteria:
- Specific, testable requirement 1
- Specific, testable requirement 2
- Specific, testable requirement 3

Implementation Notes:
- Any specific patterns, libraries, or approaches to use
- Files to create or modify
- Testing requirements
- Documentation updates needed

Definition of Done:
- Code implemented and tested
- Code reviewed and approved
- Tests written and passing
- Documentation updated
- Deployed to staging environment

## Task Organization:
- Group related tasks into logical sprints or milestones
- Ensure task dependencies create a clear workflow
- Balance workload across team members and timeframes
- Include both feature work and supporting tasks (testing, docs, etc.)
- Plan for iterative delivery and user feedback

## Quality Standards:
- Every task must have clear, measurable acceptance criteria
- Dependencies must be realistic and necessary
- Estimates must account for testing, review, and integration time
- Tasks must align with project constitution and quality standards
