# Code and Implementation Review Prompt

You are reviewing completed development work to ensure it meets specifications and quality standards.

## Context Files to Review:
- ``docs/spec.md`` - original requirements and acceptance criteria
- ``docs/plan.md`` - implementation plan and approach
- ``.claude-code/context/constitution.md`` - project quality standards
- ``.claude-code/context/tech-stack.md`` - technology standards and conventions

## Review Scope:
Choose the appropriate review type:
- **Feature Review**: Complete feature implementation against specifications
- **Code Review**: Code quality, standards compliance, and best practices
- **Design Review**: UI/UX implementation against design specifications
- **Security Review**: Security best practices and vulnerability assessment
- **Performance Review**: Performance optimization and benchmarking

## Review Checklist:

### Functional Requirements
- All specified functionality is implemented
- All acceptance criteria are met
- Edge cases are handled appropriately
- Error scenarios are managed gracefully
- User experience follows specified workflows

### Code Quality
- Code follows project conventions and style guide
- Code is readable and well-documented
- Functions and classes have single responsibilities
- No code duplication or unnecessary complexity
- Proper error handling and logging

### Design System Compliance (if applicable)
- All styling uses design system tokens
- Components follow established patterns
- Responsive design works across breakpoints
- Accessibility requirements are met
- Visual design matches specifications exactly

### Testing Requirements
- Unit tests cover business logic and edge cases
- Integration tests verify component interactions
- End-to-end tests validate user workflows
- Test coverage meets project standards (typically 80%+)
- All tests pass consistently

### Security Standards
- Input validation and sanitization implemented
- Authentication and authorization working correctly
- Sensitive data properly protected
- No security vulnerabilities introduced
- Security best practices followed

### Performance Standards
- Performance requirements met (load times, response times)
- Code is optimized for efficiency
- Database queries are optimized
- Frontend bundle size is reasonable
- Memory usage is appropriate

## Review Output Format:

Review Report: [Feature/Component Name]

Overall Assessment:
Status: Approved / Approved with Minor Issues / Requires Changes
Review Type: [Feature|Code|Design|Security|Performance]
Reviewer: [Name]
Review Date: [Date]

Requirements Compliance:
- Functional Requirements: [Pass/Fail] [Summary]
- Acceptance Criteria: [Pass/Fail] [Summary]
- Design Specifications: [Pass/Fail] [Summary]

Quality Assessment:
- Code Quality: [Excellent|Good|Satisfactory|Needs Improvement]
- Test Coverage: [X]% ([Excellent|Good|Satisfactory|Insufficient])
- Documentation: [Complete|Adequate|Incomplete]
- Performance: [Excellent|Good|Satisfactory|Poor]

Issues Found:

Critical Issues (Must Fix):
- [Issue description and suggested resolution]

Minor Issues (Should Fix):
- [Issue description and suggested resolution]

Suggestions (Nice to Have):
- [Improvement suggestions]

Recommendations:
- [Specific actions to take before approval]
- [Future improvements to consider]
- [Lessons learned for next implementations]

## Approval Criteria:
- All critical issues must be resolved
- Code must meet project quality standards
- All acceptance criteria must be satisfied
- Security and performance requirements must be met
- Documentation must be complete and accurate
