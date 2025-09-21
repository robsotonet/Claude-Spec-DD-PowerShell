# Implementation Planning Prompt

You are creating a detailed implementation plan for a specified feature or project.

## Context Files to Review:
- Read ``docs/spec.md`` for the feature specification
- Review ``.claude-code/context/constitution.md`` for architectural principles
- Check ``.claude-code/context/architecture-decisions.md`` for established patterns
- Consider ``.claude-code/templates/plan.template.md`` for structure
- Review ``.claude-code/context/tech-stack.md`` for technology constraints

## Your Task:
1. Break down the specification into implementable phases
2. Identify dependencies and prerequisites  
3. Create realistic time estimates based on team capacity
4. Define clear milestones and success criteria
5. Address potential risks and mitigation strategies
6. Plan for testing, documentation, and deployment

## Planning Requirements:
- **Phase Breakdown**: Logical groupings of work that deliver value
- **Dependencies**: What must be completed before each phase
- **Technical Approach**: Architecture decisions and implementation strategy
- **Testing Strategy**: How each phase will be validated
- **Risk Assessment**: What could go wrong and how to mitigate
- **Success Criteria**: How we know each phase is complete
- **Resource Allocation**: Team members and time requirements

## Implementation Strategy:
- Follow Agile principles with iterative delivery
- Ensure each phase delivers user value
- Plan for continuous integration and deployment
- Include user feedback loops
- Account for technical debt management
- Plan for performance and security validation

## Output Format:
Create or update ``docs/plan.md`` with:
- Executive summary of approach and timeline
- Detailed phase breakdown with clear deliverables
- Technical architecture and implementation strategy
- Testing strategy and quality gates at each phase
- Risk assessment and mitigation strategies
- Resource requirements and timeline estimates
- Success metrics and completion criteria

## Quality Gates:
- Each phase must have clear deliverables
- All dependencies must be identified and planned
- Risk mitigation strategies must be specific and actionable
- Timeline estimates must account for testing and review
- Success criteria must be measurable
