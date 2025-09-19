# ==============================================================================
# manage-phases.ps1 - Phase-Based Development Management Script
# ==============================================================================

param(
    [Parameter(Mandatory=$true, HelpMessage="Action to perform")]
    [ValidateSet("init-roadmap", "create-phase", "plan-phase", "start-phase", "complete-phase", "status")]
    [string]$Action,
    
    [Parameter(Mandatory=$false, HelpMessage="Phase number (1, 2, 3, etc.)")]
    [string]$PhaseNumber = "",
    
    [Parameter(Mandatory=$false, HelpMessage="Phase name/title")]
    [string]$PhaseName = "",
    
    [Parameter(Mandatory=$false, HelpMessage="Enable interactive prompts")]
    [switch]$Interactive = $false
)

# ==============================================================================
# UTILITY FUNCTIONS
# ==============================================================================

function Write-ColorOutput {
    param(
        [Parameter(Mandatory=$true)]
        [string]$Message,
        
        [Parameter(Mandatory=$false)]
        [ValidateSet("Black","Blue","Cyan","DarkBlue","DarkCyan","DarkGray","DarkGreen","DarkMagenta","DarkRed","DarkYellow","Gray","Green","Magenta","Red","White","Yellow")]
        [string]$Color = "White"
    )
    Write-Host $Message -ForegroundColor $Color
}

function Test-PrerequisiteDirectories {
    $requiredDirs = @(
        ".claude-code",
        ".claude-code\context",
        ".claude-code\prompts",
        ".claude-code\templates"
    )
    
    foreach ($dir in $requiredDirs) {
        if (-not (Test-Path $dir)) {
            Write-ColorOutput "❌ Required directory missing: $dir" "Red"
            Write-ColorOutput "💡 Run init-claude-project.ps1 first to set up the project structure" "Yellow"
            return $false
        }
    }
    return $true
}

function New-DirectoryStructure {
    param([string[]]$Directories)
    
    foreach ($dir in $Directories) {
        if (-not (Test-Path $dir)) {
            try {
                New-Item -ItemType Directory -Path $dir -Force | Out-Null
            }
            catch {
                Write-ColorOutput "❌ Failed to create directory: $dir" "Red"
                Write-ColorOutput "   Error: $($_.Exception.Message)" "Red"
                return $false
            }
        }
    }
    return $true
}

# ==============================================================================
# MAIN ACTION FUNCTIONS
# ==============================================================================

function Initialize-ProductRoadmap {
    Write-ColorOutput "🗺️ Initializing product roadmap..." "Cyan"
    
    # Validate prerequisites
    if (-not (Test-PrerequisiteDirectories)) {
        return
    }
    
    # Create phase directories
    $phaseDirs = @(
        "docs\phases",
        "docs\architecture", 
        "src\phases\shared"
    )
    
    if (-not (New-DirectoryStructure -Directories $phaseDirs)) {
        Write-ColorOutput "❌ Failed to create phase directory structure" "Red"
        return
    }

    # Create product vision template
    $productVisionContent = @'
# Product Vision

## Product Overview
**Product Name**: [Your Product Name]
**Target Audience**: [Primary user segments]
**Value Proposition**: [Core value delivered to users]

## Long-term Vision (12-24 months)
[Describe the ultimate vision for the product - what will it accomplish and how will it transform user workflows]

## Success Metrics
- **User Engagement**: [How you'll measure user adoption and engagement]
- **Business Metrics**: [Revenue targets, growth rates, user retention goals]
- **Technical Metrics**: [Performance benchmarks, reliability targets, scalability goals]

## Core User Personas

### Primary Persona: [Name/Title]
- **Role**: [Job title or primary role]
- **Goals**: [What they want to achieve with your product]
- **Pain Points**: [Current challenges they face]
- **Success Criteria**: [How they'll know the product is working for them]
- **Technical Comfort**: [How comfortable they are with technology]

### Secondary Persona: [Name/Title]  
- **Role**: [Job title or primary role]
- **Goals**: [What they want to achieve with your product]
- **Pain Points**: [Current challenges they face]
- **Success Criteria**: [How they'll know the product is working for them]
- **Technical Comfort**: [How comfortable they are with technology]

## Competitive Landscape
- **Direct Competitors**: [Products that solve the same problem]
- **Indirect Competitors**: [Alternative solutions users might choose]
- **Competitive Advantages**: [What makes your approach unique and better]

## Technical Vision
- **Architecture Goals**: [Scalability, maintainability, performance objectives]
- **Technology Choices**: [Key technology decisions and reasoning]
- **Integration Requirements**: [External systems, APIs, services needed]
- **Security Requirements**: [Data protection, privacy, compliance needs]
'@

    try {
        $productVisionContent | Out-File -FilePath "docs\product-vision.md" -Encoding UTF8
        Write-ColorOutput "✅ Created docs\product-vision.md" "Green"
    }
    catch {
        Write-ColorOutput "❌ Failed to create product-vision.md: $($_.Exception.Message)" "Red"
        return
    }

    # Create phase roadmap template
    $roadmapContent = @'
# Phase Roadmap

## Phase Strategy
**Development Approach**: Incremental delivery with user validation after each phase
**Typical Phase Duration**: 6-8 weeks per phase
**Success Criteria**: Each phase must deliver measurable user value and validate key assumptions

## Phase Overview

### Phase 1: Foundation & Core Features
**Duration**: [Start date] - [End date]  
**Theme**: Establish core user value and technical foundation
**Primary Goal**: Get users successfully completing core workflows

**Features**:
- User authentication (email/password registration and login)
- Contact management system (add, edit, delete, search contacts)
- Basic task management (create, edit, complete tasks)
- Responsive web interface for mobile and desktop
- Basic user profile management

**Success Criteria**:
- [ ] Users can register and authenticate securely
- [ ] Users can successfully manage their contact list
- [ ] Users can create, edit, and complete basic tasks  
- [ ] System passes security audit and performance benchmarks
- [ ] Mobile-responsive design works on major devices
- [ ] 70% of test users complete onboarding successfully

**Key Assumptions to Validate**:
- Users find value in combining contacts and tasks
- Email/password authentication is sufficient initially
- Basic task management meets core user needs

**Dependencies**:
- Design system finalized and approved
- Database schema designed and reviewed
- Authentication service/approach selected
- Hosting and deployment platform chosen

---

### Phase 2: Enhanced Authentication & Automation  
**Duration**: [Start date] - [End date]
**Theme**: Expand authentication options and add automation features
**Primary Goal**: Reduce user friction and add workflow automation

**Features**:
- Social media authentication (Google, Facebook, GitHub)
- Task reminder system with email notifications
- Contact import from external sources (Gmail, Outlook, CSV)
- Advanced task filtering, sorting, and search
- Task categories and priority levels
- Basic reporting and analytics

**Success Criteria**:
- [ ] Social authentication working for top 3 providers
- [ ] Reminder system delivering notifications reliably (95%+ delivery rate)
- [ ] Contact import working from major email providers
- [ ] Advanced task management features adopted by 60%+ of users
- [ ] User retention improves by 25% over Phase 1

**Key Assumptions to Validate**:
- Social login significantly improves user onboarding
- Automated reminders increase task completion rates
- Contact import is a valuable feature for user adoption

**Dependencies**:
- Phase 1 completed with stable user base
- OAuth integrations approved and configured
- Email notification service implemented and tested
- User feedback from Phase 1 incorporated

---

### Phase 3: Collaboration & Integration
**Duration**: [Start date] - [End date]  
**Theme**: Enable collaboration and external system integrations
**Primary Goal**: Transform from personal tool to team collaboration platform

**Features**:
- Shared task lists and contact groups
- Calendar integration (Google Calendar, Outlook, Apple Calendar)
- Team collaboration features (assign tasks, comments, activity feed)
- Mobile app (iOS/Android) or PWA
- Advanced permissions and privacy controls
- Integration with popular productivity tools

**Success Criteria**:
- [ ] Users can effectively share and collaborate on tasks
- [ ] Calendar synchronization works bidirectionally
- [ ] Team collaboration features increase user engagement by 40%
- [ ] Mobile app maintains feature parity with web version
- [ ] Integration usage demonstrates clear user value

**Key Assumptions to Validate**:
- Users want team collaboration features
- Calendar integration is essential for adoption
- Mobile access significantly increases daily usage

**Dependencies**:
- Phase 2 user feedback incorporated and successful
- Calendar API integrations tested and approved
- Mobile development resources and expertise available
- Team collaboration features designed and tested

---

### Phase 4: Advanced Features & Intelligence
**Duration**: [Start date] - [End date]
**Theme**: Advanced functionality and intelligent automation  
**Primary Goal**: Differentiate through smart features and business insights

**Features**:
- AI-powered task suggestions and smart categorization
- Advanced reporting, analytics, and business intelligence
- Workflow automation and custom integrations
- Enterprise features (SSO, admin controls, bulk operations)
- API for third-party integrations
- Advanced search with natural language processing

**Success Criteria**:
- [ ] AI suggestions demonstrably improve user productivity
- [ ] Analytics provide actionable insights for users and business
- [ ] Automation features reduce manual work by 30%+
- [ ] Enterprise features drive premium plan conversions
- [ ] API adoption shows ecosystem development

**Key Assumptions to Validate**:
- AI features provide genuine value vs. complexity
- Advanced analytics are valued by target users
- Enterprise market represents significant opportunity

**Dependencies**:
- Phase 3 adoption and success metrics achieved
- AI/ML infrastructure and expertise available
- Enterprise sales and support processes established
- API design and developer experience validated

## Inter-Phase Dependencies & Architecture

### Data Migration Strategy
- Each phase must maintain full backward compatibility
- Database migrations must be reversible and tested
- User data integrity maintained throughout all transitions
- Performance must not degrade with additional features

### User Experience Consistency
- Design system maintained and evolved across all phases
- User interface patterns remain consistent
- Learning curve minimized for new features
- Accessibility standards maintained throughout

### Technical Architecture Evolution
- System must scale to support each phase's user growth
- Performance standards maintained: <2s page loads, 99.9% uptime
- Security model must accommodate all planned features
- Code quality and maintainability standards enforced

### Business Model Progression
- Phase 1: Establish product-market fit
- Phase 2: Optimize for user growth and retention  
- Phase 3: Enable premium features and team plans
- Phase 4: Scale to enterprise and platform model

## Risk Mitigation Strategy

### Technical Risks
- **Database Performance**: Early load testing, query optimization, caching strategy
- **Third-party Integrations**: Fallback plans, rate limiting, error handling
- **Mobile Development**: Progressive web app as backup to native apps
- **AI/ML Complexity**: Start with simple rules, gradually introduce learning

### Market Risks  
- **Competition**: Continuous user research, rapid iteration, unique value props
- **User Adoption**: Strong onboarding, user feedback loops, feature validation
- **Monetization**: Test pricing early, multiple revenue streams, value demonstration

### Resource Risks
- **Team Scaling**: Hire ahead of need, strong documentation, knowledge sharing
- **Technical Debt**: Regular refactoring sprints, code review standards
- **External Dependencies**: Multiple vendor relationships, service agreements

## Success Measurement Framework

### Phase Completion Criteria
Each phase is considered successful when:
- All defined features are implemented and tested
- Success criteria metrics are achieved or on clear trajectory
- User feedback validates core assumptions
- Technical performance meets defined standards
- Next phase prerequisites are satisfied

### Key Performance Indicators (KPIs)
- **User Engagement**: Daily/Weekly/Monthly active users, session duration
- **Feature Adoption**: % of users utilizing new features within 30 days
- **User Satisfaction**: Net Promoter Score, user feedback ratings
- **Technical Performance**: Page load times, error rates, uptime
- **Business Metrics**: User acquisition cost, lifetime value, churn rate

## Communication & Reporting

### Stakeholder Updates
- **Weekly**: Development progress, blockers, metrics
- **Bi-weekly**: User research findings, feature adoption data
- **Monthly**: Business metrics, strategic decisions, next phase planning
- **Quarterly**: Overall roadmap review and adjustment

### Decision Making Process
- Product decisions based on user research and data
- Technical decisions documented with reasoning and trade-offs
- Major pivots require stakeholder alignment and user validation
- Regular retrospectives to improve development process
'@

    try {
        $roadmapContent | Out-File -FilePath "docs\phase-roadmap.md" -Encoding UTF8
        Write-ColorOutput "✅ Created docs\phase-roadmap.md" "Green"
    }
    catch {
        Write-ColorOutput "❌ Failed to create phase-roadmap.md: $($_.Exception.Message)" "Red"
        return
    }

    # Create architecture decisions template
    $archDecisionsContent = @'
# Architecture Decisions Record

## Decision Format
Each architectural decision should include:
- **Date**: When the decision was made
- **Status**: Proposed | Accepted | Deprecated | Superseded
- **Context**: What forces led to this decision
- **Decision**: What we decided to do
- **Consequences**: Positive and negative outcomes expected

## Decisions Log

### $(Get-Date -Format 'yyyy-MM-dd') - Initial Technology Stack
**Status**: Accepted  
**Context**: Starting new web application project requiring modern, scalable architecture
**Decision**: 
- Frontend: React 18+ with TypeScript for type safety and developer experience
- Backend: Node.js with Express for rapid development and team expertise
- Database: PostgreSQL for relational data integrity and scalability
- Deployment: Docker containers on cloud platform for consistency and scaling

**Consequences**:
- ✅ Strong type safety reduces runtime errors
- ✅ Large ecosystem and community support
- ✅ Team has expertise in chosen technologies
- ✅ Modern tooling and development experience
- ❌ Learning curve for team members new to TypeScript
- ❌ Additional complexity in build pipeline

### [Date] - Authentication Strategy  
**Status**: Proposed
**Context**: Need secure user authentication supporting future social login integration
**Decision**: [To be determined]
**Consequences**: [To be documented]

### [Date] - Database Schema Design
**Status**: Proposed  
**Context**: Need flexible data model supporting contacts, tasks, and future collaboration features
**Decision**: [To be determined]
**Consequences**: [To be documented]
'@

    try {
        $archDecisionsContent | Out-File -FilePath "docs\architecture\architecture-decisions.md" -Encoding UTF8
        Write-ColorOutput "✅ Created docs\architecture\architecture-decisions.md" "Green"
    }
    catch {
        Write-ColorOutput "❌ Failed to create architecture-decisions.md: $($_.Exception.Message)" "Red"
        return
    }

    Write-ColorOutput "✅ Product roadmap initialized successfully!" "Green"
    Write-ColorOutput "" "White"
    Write-ColorOutput "📝 Next steps:" "Yellow"
    Write-ColorOutput "   1. Customize docs\product-vision.md with your specific product details" "White"
    Write-ColorOutput "   2. Review and adjust docs\phase-roadmap.md timeline and features" "White"
    Write-ColorOutput "   3. Run: .\manage-phases.ps1 -Action create-phase -PhaseNumber 1" "White"
}

function New-PhaseSpecification {
    param(
        [Parameter(Mandatory=$true)]
        [string]$PhaseNumber,
        
        [Parameter(Mandatory=$false)]
        [string]$PhaseName
    )
    
    Write-ColorOutput "📋 Creating Phase $PhaseNumber specification..." "Cyan"
    
    # Validate prerequisites
    if (-not (Test-PrerequisiteDirectories)) {
        return
    }
    
    # Create phase directory
    $phaseDir = "docs\phases\phase-$PhaseNumber"
    $srcPhaseDir = "src\phases\phase-$PhaseNumber"
    
    $phaseDirs = @($phaseDir, $srcPhaseDir)
    
    if (-not (New-DirectoryStructure -Directories $phaseDirs)) {
        Write-ColorOutput "❌ Failed to create phase directories" "Red"
        return
    }

    # Get phase details interactively if requested
    if ($Interactive -and -not $PhaseName) {
        $PhaseName = Read-Host "Enter phase name (e.g., 'Foundation & Core Features')"
        $phaseTheme = Read-Host "Enter phase theme/focus"
        $duration = Read-Host "Enter estimated duration (e.g., '6-8 weeks')"
    }
    
    # Set default values if not provided
    if (-not $PhaseName) {
        $PhaseName = "Phase $PhaseNumber"
    }

    # Create comprehensive phase specification
    $phaseSpecContent = @"
# Phase $PhaseNumber: $PhaseName

## Phase Overview
**Phase Number**: $PhaseNumber
**Phase Name**: $PhaseName
**Status**: 📋 Planning
**Estimated Duration**: 6-8 weeks
**Start Date**: [To be determined]
**End Date**: [To be determined]
**Theme**: [Brief description of what this phase is trying to achieve]

## Phase Objectives
**Primary Goal**: [What is the main outcome this phase should achieve]
**Success Vision**: [How will you know this phase was successful]
**User Value**: [What specific value will users get from this phase]

## User Stories and Epics

### Epic 1: [Main Feature Area Name]
**Epic Goal**: As a [user type], I want [high-level capability] so that [business value].

#### Story 1.1: [Specific Feature Name]
- **As a** [specific user type]
- **I want** [specific functionality]  
- **So that** [specific benefit]
- **Priority**: High | Medium | Low
- **Effort**: [Story points or time estimate]
- **Acceptance Criteria**:
  - [ ] [Specific, testable condition]
  - [ ] [Specific, testable condition]
  - [ ] [Specific, testable condition]

#### Story 1.2: [Specific Feature Name]
- **As a** [specific user type]
- **I want** [specific functionality]
- **So that** [specific benefit]
- **Priority**: High | Medium | Low
- **Effort**: [Story points or time estimate]
- **Acceptance Criteria**:
  - [ ] [Specific, testable condition]
  - [ ] [Specific, testable condition]

### Epic 2: [Secondary Feature Area Name]
**Epic Goal**: As a [user type], I want [high-level capability] so that [business value].

[Repeat story structure for additional features]

## Functional Requirements

### Core Features
1. **[Feature Name]**
   - **Description**: [Detailed description of what this feature does]
   - **User Interaction**: [How users will interact with this feature]
   - **System Behavior**: [How the system responds and behaves]
   - **Business Rules**: [Any business logic or rules that apply]
   - **Edge Cases**: [What happens in unusual situations]
   - **Integration Points**: [How this connects to other features or systems]

2. **[Feature Name]**
   - **Description**: [Detailed description of what this feature does]
   - **User Interaction**: [How users will interact with this feature]
   - **System Behavior**: [How the system responds and behaves]
   - **Business Rules**: [Any business logic or rules that apply]
   - **Edge Cases**: [What happens in unusual situations]
   - **Integration Points**: [How this connects to other features or systems]

### API Requirements
#### New Endpoints Required
- **POST** `/api/[endpoint]` - [Description of what this endpoint does]
- **GET** `/api/[endpoint]` - [Description of what this endpoint does]
- **PUT** `/api/[endpoint]` - [Description of what this endpoint does]
- **DELETE** `/api/[endpoint]` - [Description of what this endpoint does]

#### Modified Endpoints
- **[METHOD]** `/api/[endpoint]` - [What changes are needed and why]

#### Authentication & Authorization
- [Define authentication requirements for this phase]
- [Specify authorization rules and permissions]
- [Document any new security requirements]

### Database Schema Changes
#### New Tables
- **[table_name]**: [Purpose and key fields]
- **[table_name]**: [Purpose and key fields]

#### Modified Tables  
- **[existing_table]**: [What columns or constraints are being added/changed]

#### Data Migrations
- [Describe any data migration requirements]
- [Note any data transformation or cleanup needed]
- [Document rollback strategy]

## Non-Functional Requirements

### Performance Requirements
- **Page Load Time**: Maximum 2 seconds for initial page load
- **API Response Time**: 95% of requests complete within 500ms
- **Database Queries**: No query should take longer than 1 second
- **Concurrent Users**: System must handle [X] simultaneous users
- **Throughput**: [Expected requests per minute/hour]

### Security Requirements
- **Authentication**: [Specify authentication methods and requirements]
- **Authorization**: [Define permission model and access controls] 
- **Data Protection**: [Specify encryption and data handling requirements]
- **Input Validation**: [Define validation and sanitization requirements]
- **Audit Logging**: [Specify what actions need to be logged]

### Usability Requirements
- **User Experience**: [Define UX standards and expectations]
- **Accessibility**: WCAG 2.1 AA compliance required
- **Browser Support**: [Specify supported browsers and versions]
- **Mobile Experience**: [Define mobile-specific requirements]
- **Internationalization**: [Specify multi-language support needs]

### Reliability Requirements
- **Uptime**: 99.9% availability during business hours
- **Error Rate**: Less than 1% of requests should result in errors
- **Data Integrity**: Zero data loss tolerance
- **Backup & Recovery**: [Define backup and recovery requirements]

## Design Requirements

### User Interface Requirements
#### New UI Components Needed
- **[Component Name]**: [Purpose and key functionality]
- **[Component Name]**: [Purpose and key functionality]

#### Modified UI Components  
- **[Existing Component]**: [What changes are needed]

#### Design System Extensions
- **New Design Tokens**: [Any new colors, typography, spacing needed]
- **New Patterns**: [Any new UI patterns or guidelines needed]
- **Component Variants**: [New variations of existing components]

### User Experience Flows
1. **[Flow Name]**: [Description of complete user journey]
   - Step 1: [User action and system response]
   - Step 2: [User action and system response]
   - Step 3: [User action and system response]
   - Success: [What constitutes successful completion]
   - Errors: [How errors are handled and user is guided]

2. **[Flow Name]**: [Description of complete user journey]
   - [Repeat flow structure]

### Responsive Design Requirements
- **Mobile (320px-767px)**: [Specific mobile behavior and layout]
- **Tablet (768px-1023px)**: [Specific tablet behavior and layout]
- **Desktop (1024px+)**: [Desktop layout and functionality]

## Technical Architecture

### Frontend Architecture Changes
#### New Modules/Pages
- **[Module/Page Name]**: [Purpose and key functionality]
- **[Module/Page Name]**: [Purpose and key functionality]

#### State Management Strategy
- [Define how application state will be managed for new features]
- [Specify any new state management patterns needed]
- [Document data flow between components]

#### Routing Changes
- **New Routes**: [List new application routes]
- **Modified Routes**: [Any changes to existing routes]
- **Route Protection**: [Authentication/authorization for routes]

#### Third-party Integrations
- **[Service Name]**: [What integration is needed and why]
- **[Service Name]**: [What integration is needed and why]

### Backend Architecture Changes
#### New Services
- **[Service Name]**: [Purpose and key responsibilities]
- **[Service Name]**: [Purpose and key responsibilities]

#### Modified Services
- **[Existing Service]**: [What changes are needed]

#### External API Integrations
- **[API Name]**: [What data/functionality will be integrated]
- **[API Name]**: [What data/functionality will be integrated]

#### Background Jobs & Processing
- **[Job Name]**: [What background processing is needed]
- **[Job Name]**: [What background processing is needed]

### Infrastructure Requirements
#### New Infrastructure Components
- [Any new servers, databases, services needed]
- [Caching requirements]
- [CDN or asset delivery needs]

#### Monitoring & Alerting
- [New metrics that need to be tracked]
- [Alerts that should be configured]
- [Logging requirements for new features]

#### Deployment Changes
- [Any changes to deployment process]
- [New environment variables or configuration]
- [Rollback procedures for this phase]

## Dependencies

### Internal Dependencies (Must be completed first)
#### Previous Phase Requirements
- [ ] [Specific deliverable from previous phase]
- [ ] [Specific deliverable from previous phase]

#### Shared Infrastructure
- [ ] [Database changes deployed]
- [ ] [Shared components available]
- [ ] [Authentication system ready]

### External Dependencies
#### Third-party Services
- [ ] [Service account created and configured]
- [ ] [API access granted and tested]
- [ ] [Service level agreements in place]

#### Team Dependencies
- [ ] **Design**: [Specific design deliverables needed]
- [ ] **DevOps**: [Infrastructure or deployment work needed]
- [ ] **QA**: [Testing resources and timeline]
- [ ] **Legal/Compliance**: [Any approvals or reviews needed]

### Resource Dependencies
- [ ] **Development Team**: [Required team composition and availability]
- [ ] **Budget**: [Any costs for services, tools, or resources]
- [ ] **Timeline**: [External deadlines that could impact the phase]

## Acceptance Criteria & Definition of Done

### Phase Completion Criteria
This phase is considered complete when ALL of the following are met:

#### Functional Completeness
- [ ] All user stories completed and tested
- [ ] All acceptance criteria verified
- [ ] All API endpoints implemented and documented
- [ ] All database changes deployed and tested

#### Quality Standards
- [ ] All code reviewed and approved
- [ ] Test coverage meets requirements (minimum 80% for critical paths)
- [ ] Performance requirements validated
- [ ] Security requirements implemented and verified
- [ ] Accessibility requirements tested and confirmed

#### User Experience
- [ ] All UI components implemented per design specifications
- [ ] User flows tested end-to-end
- [ ] Mobile responsive design verified
- [ ] Cross-browser compatibility confirmed

#### Documentation & Deployment
- [ ] Technical documentation updated
- [ ] User documentation created
- [ ] Deployment completed successfully
- [ ] Monitoring and alerting configured

### Success Metrics
#### User Engagement Metrics
- **Feature Adoption**: [X]% of users try new features within 30 days
- **Task Completion**: [X]% of users successfully complete core workflows
- **User Retention**: [X]% of users return within 7 days
- **Session Duration**: Average session increases by [X] minutes

#### Technical Performance Metrics
- **Page Load Performance**: <2 seconds average load time
- **API Performance**: <500ms average response time
- **Error Rates**: <1% of requests result in errors
- **System Uptime**: >99.9% availability

#### Business Metrics
- **User Acquisition**: [Target number] of new registrations
- **User Satisfaction**: >4.0/5.0 average rating
- **Support Load**: <5% of users contact support
- **Feature Usage**: Core features used by >70% of active users

### Testing Requirements
#### Unit Testing
- [ ] All business logic covered by unit tests
- [ ] All utility functions tested
- [ ] Edge cases and error conditions tested
- [ ] Test coverage reports generated

#### Integration Testing
- [ ] API endpoints tested with various inputs
- [ ] Database operations tested
- [ ] Third-party integrations tested
- [ ] End-to-end user workflows tested

#### Performance Testing
- [ ] Load testing completed for expected traffic
- [ ] Database query performance verified
- [ ] Frontend bundle size optimized
- [ ] Mobile performance tested on real devices

#### Security Testing
- [ ] Input validation tested
- [ ] Authentication and authorization verified
- [ ] Data protection measures tested
- [ ] Vulnerability scanning completed

## Risk Assessment & Mitigation

### High-Priority Risks
#### Risk 1: [Risk Description]
- **Impact**: High | Medium | Low
- **Probability**: High | Medium | Low
- **Mitigation Strategy**: [How to reduce or handle this risk]
- **Contingency Plan**: [What to do if the risk materializes]
- **Owner**: [Who is responsible for monitoring this risk]

#### Risk 2: [Risk Description]
- **Impact**: High | Medium | Low
- **Probability**: High | Medium | Low
- **Mitigation Strategy**: [How to reduce or handle this risk]
- **Contingency Plan**: [What to do if the risk materializes]
- **Owner**: [Who is responsible for monitoring this risk]

### Medium-Priority Risks
[Follow same format for medium-priority risks]

### Risk Monitoring
- **Review Frequency**: Weekly risk assessment in team meetings
- **Escalation Criteria**: [When risks should be escalated to stakeholders]
- **Risk Register**: [Where risks are tracked and updated]

## Out of Scope
**Explicitly excluded from this phase:**
- [Feature or capability intentionally not included]
- [Integration or platform not supported in this phase]
- [Advanced functionality deferred to later phase]
- [Nice-to-have features that could cause scope creep]

**Deferred to Future Phases:**
- [Features that are planned but not in this phase]
- [Improvements that will be addressed later]
- [Scalability enhancements for future growth]

## Phase Transition Criteria

### Ready for Next Phase When:
- [ ] All acceptance criteria met and verified
- [ ] Success metrics achieved or on clear trajectory to achievement
- [ ] User feedback collected and major issues addressed
- [ ] Technical debt documented and prioritized
- [ ] System stable in production for minimum 2 weeks
- [ ] Team retrospective completed and improvements identified
- [ ] Next phase dependencies satisfied
- [ ] Stakeholder approval received

### Handoff Documentation Required:
- [ ] Technical architecture decisions documented
- [ ] API documentation complete and current
- [ ] Deployment procedures updated
- [ ] Known issues and technical debt cataloged
- [ ] User feedback summary and recommendations
- [ ] Performance baselines and monitoring setup
- [ ] Security audit results and any required follow-up

## Approval & Sign-off

**Specification Approved By:**
- [ ] Product Owner: _________________ Date: _________
- [ ] Technical Lead: ________________ Date: _________  
- [ ] Design Lead: __________________ Date: _________
- [ ] QA Lead: _____________________ Date: _________

**Change Management:**
Any changes to this specification after approval must be:
- Documented with rationale and impact assessment
- Approved by original signatories
- Communicated to all stakeholders
- Updated in project tracking systems

---
**Document Version**: 1.0
**Created**: $(Get-Date -Format 'yyyy-MM-dd')
**Last Updated**: $(Get-Date -Format 'yyyy-MM-dd')
**Next Review**: [Schedule regular review dates]
"@

    try {
        $phaseSpecContent | Out-File -FilePath "$phaseDir\spec.md" -Encoding UTF8
        Write-ColorOutput "✅ Created $phaseDir\spec.md" "Green"
    }
    catch {
        Write-ColorOutput "❌ Failed to create spec.md: $($_.Exception.Message)" "Red"
        return
    }

    Write-ColorOutput "✅ Phase $PhaseNumber specification created successfully!" "Green"
    Write-ColorOutput "" "White"
    Write-ColorOutput "📝 Next steps:" "Yellow"
    Write-ColorOutput "   1. Review and customize $phaseDir\spec.md with your specific requirements" "White"
    Write-ColorOutput "   2. Define user stories, acceptance criteria, and success metrics" "White"
    Write-ColorOutput "   3. Run: .\manage-phases.ps1 -Action plan-phase -PhaseNumber $PhaseNumber" "White"
}

function New-PhaseImplementationPlan {
    param(
        [Parameter(Mandatory=$true)]
        [string]$PhaseNumber
    )
    
    Write-ColorOutput "📊 Creating implementation plan for Phase $PhaseNumber..." "Cyan"
    
    $phaseDir = "docs\phases\phase-$PhaseNumber"
    
    # Validate that phase specification exists
    if (-not (Test-Path "$phaseDir\spec.md")) {
        Write-ColorOutput "❌ Phase specification not found at $phaseDir\spec.md" "Red"
        Write-ColorOutput "💡 Run: .\manage-phases.ps1 -Action create-phase -PhaseNumber $PhaseNumber" "Yellow"
        return
    }

    $phasePlanContent = @"
# Phase $PhaseNumber Implementation Plan

## Phase Overview
**Current Status**: 📋 Planning
**Planned Start Date**: [To be set when planning is complete]
**Target End Date**: [To be set based on team capacity and complexity]
**Team Size**: [Number of team members assigned]
**Total Effort Estimate**: [Story points or hours estimated]

## Implementation Strategy

### Development Approach
- **Methodology**: Agile development with 1-week sprint cycles
- **Team Structure**: Cross-functional team with clear roles and responsibilities
- **Quality Gates**: Code review, testing, and stakeholder approval at each milestone
- **Risk Management**: Weekly risk assessment and mitigation planning
- **Communication**: Daily standups, weekly stakeholder updates, bi-weekly demos

### Team Roles & Responsibilities
- **Product Owner**: Requirements clarification, acceptance testing, stakeholder communication
- **Tech Lead**: Architecture decisions, code review, technical risk management
- **Senior Developer**: Complex feature implementation, mentoring, technical guidance
- **Developer**: Feature implementation, unit testing, code review participation
- **Designer**: UI/UX design, design system maintenance, user testing
- **QA Engineer**: Test planning, automated testing, quality assurance

### Quality Standards
- **Code Review**: All code reviewed by at least one other team member
- **Testing**: Minimum 80% test coverage for business logic
- **Performance**: All features meet performance requirements before deployment
- **Accessibility**: WCAG 2.1 AA compliance verified for all user-facing features
- **Security**: Security review completed for all new endpoints and features

## Implementation Phases & Milestones

### Milestone 1: Foundation & Setup
**Duration**: Week 1
**Goal**: Establish technical foundation and development environment
**Team Focus**: Full team collaboration on setup

#### Tasks & Deliverables
- [ ] **DEV-001**: Development environment setup and configuration
  - **Owner**: DevOps Engineer + Tech Lead
  - **Effort**: 8 hours
  - **Deliverable**: All developers can run project locally
  - **Acceptance Criteria**:
    - [ ] Local development environment runs without errors
    - [ ] Database connections and migrations work
    - [ ] Hot reloading and debugging functional
    - [ ] Environment variables properly configured

- [ ] **ARCH-001**: Database schema design and implementation
  - **Owner**: Tech Lead + Senior Developer
  - **Effort**: 12 hours
  - **Deliverable**: Database migrations and models
  - **Acceptance Criteria**:
    - [ ] All required tables created with proper relationships
    - [ ] Indexes and constraints implemented
    - [ ] Migration scripts tested and documented
    - [ ] Rollback procedures verified

- [ ] **UI-001**: Design system integration and base components
  - **Owner**: Designer + Frontend Developer
  - **Effort**: 16 hours
  - **Deliverable**: Reusable UI component library
  - **Acceptance Criteria**:
    - [ ] Design tokens properly integrated
    - [ ] Base components (Button, Input, Form) implemented
    - [ ] Storybook setup with component documentation
    - [ ] Responsive behavior verified

#### Milestone 1 Success Criteria
- [ ] All team members productive in development environment
- [ ] Database schema supports all Phase requirements
- [ ] UI component foundation ready for feature development
- [ ] CI/CD pipeline functional and tested

---

### Milestone 2: Core Authentication System
**Duration**: Weeks 2-3
**Goal**: Implement complete user authentication and account management
**Team Focus**: Backend + Frontend collaboration

#### Tasks & Deliverables
- [ ] **AUTH-001**: User registration API and validation
  - **Owner**: Backend Developer
  - **Effort**: 12 hours
  - **Dependencies**: ARCH-001
  - **Deliverable**: Registration endpoint with validation
  - **Acceptance Criteria**:
    - [ ] User registration endpoint accepts email/password
    - [ ] Email validation and duplicate checking
    - [ ] Password strength requirements enforced
    - [ ] Account activation email sent
    - [ ] Proper error handling and responses

- [ ] **AUTH-002**: User login/logout API and session management
  - **Owner**: Backend Developer
  - **Effort**: 10 hours
  - **Dependencies**: AUTH-001
  - **Deliverable**: Authentication endpoints and middleware
  - **Acceptance Criteria**:
    - [ ] Login endpoint authenticates users
    - [ ] JWT tokens issued with appropriate expiration
    - [ ] Logout endpoint invalidates tokens
    - [ ] Session middleware protects protected routes
    - [ ] Rate limiting implemented for login attempts

- [ ] **AUTH-003**: Password reset functionality
  - **Owner**: Backend Developer
  - **Effort**: 8 hours
  - **Dependencies**: AUTH-001
  - **Deliverable**: Password reset flow
  - **Acceptance Criteria**:
    - [ ] Password reset request sends secure email
    - [ ] Reset tokens expire appropriately
    - [ ] New password validation and update
    - [ ] User notification of password change
    - [ ] Security logging of password reset events

- [ ] **AUTH-004**: User registration UI
  - **Owner**: Frontend Developer
  - **Effort**: 14 hours
  - **Dependencies**: UI-001, AUTH-001
  - **Deliverable**: Registration form and flow
  - **Acceptance Criteria**:
    - [ ] Registration form with proper validation
    - [ ] Real-time form validation feedback
    - [ ] Error handling and user messaging
    - [ ] Email verification confirmation screen
    - [ ] Responsive design across all devices

- [ ] **AUTH-005**: User login UI and navigation
  - **Owner**: Frontend Developer
  - **Effort**: 12 hours
  - **Dependencies**: UI-001, AUTH-002
  - **Deliverable**: Login form and authenticated navigation
  - **Acceptance Criteria**:
    - [ ] Login form with validation and error handling
    - [ ] Remember me functionality
    - [ ] Navigation updates based on authentication state
    - [ ] Proper routing for authenticated/unauthenticated users
    - [ ] Loading states during authentication

- [ ] **AUTH-006**: User profile management
  - **Owner**: Frontend Developer + Backend Developer
  - **Effort**: 16 hours
  - **Dependencies**: AUTH-002
  - **Deliverable**: User profile viewing and editing
  - **Acceptance Criteria**:
    - [ ] Users can view their profile information
    - [ ] Users can update name, email, password
    - [ ] Email change requires verification
    - [ ] Profile picture upload and display
    - [ ] Account deletion functionality

#### Milestone 2 Success Criteria
- [ ] Users can register, login, and manage accounts
- [ ] All authentication flows work correctly
- [ ] Security requirements met and tested
- [ ] UI matches design specifications
- [ ] Mobile experience optimized

---

### Milestone 3: Contact Management System
**Duration**: Weeks 3-4
**Goal**: Implement comprehensive contact management functionality
**Team Focus**: Feature development with parallel backend/frontend work

#### Tasks & Deliverables
- [ ] **CONTACT-001**: Contact data model and API
  - **Owner**: Backend Developer
  - **Effort**: 14 hours
  - **Dependencies**: ARCH-001
  - **Deliverable**: Contact CRUD API
  - **Acceptance Criteria**:
    - [ ] Contact model with required fields
    - [ ] Create, read, update, delete endpoints
    - [ ] Search and filtering functionality
    - [ ] Pagination for large contact lists
    - [ ] User-based contact isolation

- [ ] **CONTACT-002**: Contact list UI with search and filtering
  - **Owner**: Frontend Developer
  - **Effort**: 18 hours
  - **Dependencies**: UI-001, CONTACT-001
  - **Deliverable**: Contact list page with functionality
  - **Acceptance Criteria**:
    - [ ] Paginated contact list display
    - [ ] Search by name, email, phone
    - [ ] Filter by categories or tags
    - [ ] Sort by various criteria
    - [ ] Responsive grid/list view options

- [ ] **CONTACT-003**: Add/Edit contact form and functionality
  - **Owner**: Frontend Developer
  - **Effort**: 16 hours
  - **Dependencies**: UI-001, CONTACT-001
  - **Deliverable**: Contact creation and editing forms
  - **Acceptance Criteria**:
    - [ ] Form with all required contact fields
    - [ ] Field validation and error handling
    - [ ] Image/avatar upload functionality
    - [ ] Success/error feedback to users
    - [ ] Mobile-optimized form experience

- [ ] **CONTACT-004**: Contact import functionality
  - **Owner**: Backend Developer + Frontend Developer
  - **Effort**: 20 hours
  - **Dependencies**: CONTACT-001
  - **Deliverable**: CSV and external contact import
  - **Acceptance Criteria**:
    - [ ] CSV file upload and parsing
    - [ ] Field mapping interface for imports
    - [ ] Duplicate detection and handling
    - [ ] Bulk import progress indication
    - [ ] Import error reporting and handling

- [ ] **CONTACT-005**: Contact categories and tagging
  - **Owner**: Backend Developer + Frontend Developer
  - **Effort**: 14 hours
  - **Dependencies**: CONTACT-001
  - **Deliverable**: Contact organization features
  - **Acceptance Criteria**:
    - [ ] Contact categories/tags management
    - [ ] Assign categories to contacts
    - [ ] Filter contacts by category
    - [ ] Bulk category assignment
    - [ ] Category-based contact organization

#### Milestone 3 Success Criteria
- [ ] Complete contact management system functional
- [ ] Users can efficiently manage their contact lists
- [ ] Search and filtering perform well with large datasets
- [ ] Import functionality works with common formats
- [ ] Mobile experience optimized for contact management

---

### Milestone 4: Task Management System
**Duration**: Weeks 4-6
**Goal**: Implement comprehensive task management with contact integration
**Team Focus**: Complex feature development requiring tight coordination

#### Tasks & Deliverables
- [ ] **TASK-001**: Task data model and relationships
  - **Owner**: Backend Developer
  - **Effort**: 16 hours
  - **Dependencies**: ARCH-001, CONTACT-001
  - **Deliverable**: Task API with contact relationships
  - **Acceptance Criteria**:
    - [ ] Task model with all required fields
    - [ ] Task-contact relationship management
    - [ ] Task categories and priority levels
    - [ ] Due date and reminder functionality
    - [ ] Task status and completion tracking

- [ ] **TASK-002**: Task CRUD API with advanced features
  - **Owner**: Backend Developer
  - **Effort**: 18 hours
  - **Dependencies**: TASK-001
  - **Deliverable**: Complete task management API
  - **Acceptance Criteria**:
    - [ ] Create, read, update, delete task endpoints
    - [ ] Task search and filtering capabilities
    - [ ] Bulk task operations (complete, delete, update)
    - [ ] Task sorting by various criteria
    - [ ] Performance optimized for large task lists

- [ ] **TASK-003**: Task list UI with filtering and sorting
  - **Owner**: Frontend Developer
  - **Effort**: 20 hours
  - **Dependencies**: UI-001, TASK-002
  - **Deliverable**: Task list interface
  - **Acceptance Criteria**:
    - [ ] Paginated task list with multiple views
    - [ ] Filter by status, priority, due date, contact
    - [ ] Sort by creation, due date, priority
    - [ ] Bulk selection and operations
    - [ ] Responsive design for mobile devices

- [ ] **TASK-004**: Task creation and editing forms
  - **Owner**: Frontend Developer
  - **Effort**: 18 hours
  - **Dependencies**: UI-001, TASK-002
  - **Deliverable**: Task form interfaces
  - **Acceptance Criteria**:
    - [ ] Task creation form with all fields
    - [ ] Contact selection and linking
    - [ ] Due date picker and reminder setup
    - [ ] Priority and category selection
    - [ ] Rich text description editing

- [ ] **TASK-005**: Task-contact integration features
  - **Owner**: Frontend Developer + Backend Developer
  - **Effort**: 16 hours
  - **Dependencies**: TASK-002, CONTACT-001
  - **Deliverable**: Integrated task-contact workflows
  - **Acceptance Criteria**:
    - [ ] View tasks associated with specific contacts
    - [ ] Create tasks from contact views
    - [ ] Contact information available in task views
    - [ ] Task completion updates contact interaction history
    - [ ] Seamless navigation between tasks and contacts

- [ ] **TASK-006**: Task completion and progress tracking
  - **Owner**: Frontend Developer + Backend Developer
  - **Effort**: 12 hours
  - **Dependencies**: TASK-002
  - **Deliverable**: Task completion workflows
  - **Acceptance Criteria**:
    - [ ] Mark tasks as complete with timestamp
    - [ ] Track task completion statistics
    - [ ] Completed task archiving and retrieval
    - [ ] Progress visualization and reports
    - [ ] Completion notifications and feedback

#### Milestone 4 Success Criteria
- [ ] Complete task management system operational
- [ ] Task-contact integration working seamlessly
- [ ] Users can efficiently create, manage, and complete tasks
- [ ] Performance acceptable with realistic data volumes
- [ ] Mobile task management experience optimized

---

### Milestone 5: Integration, Testing & Polish
**Duration**: Week 6-7
**Goal**: Ensure all features work together seamlessly and meet quality standards
**Team Focus**: Quality assurance, integration testing, performance optimization

#### Tasks & Deliverables
- [ ] **INT-001**: End-to-end integration testing
  - **Owner**: QA Engineer + Full Team
  - **Effort**: 24 hours
  - **Dependencies**: All previous milestones
  - **Deliverable**: Comprehensive test suite and results
  - **Acceptance Criteria**:
    - [ ] All user workflows tested end-to-end
    - [ ] Cross-feature integration verified
    - [ ] Error handling tested in all scenarios
    - [ ] Data integrity confirmed across features
    - [ ] Performance benchmarks met

- [ ] **PERF-001**: Performance optimization and monitoring
  - **Owner**: Tech Lead + DevOps Engineer
  - **Effort**: 16 hours
  - **Dependencies**: All features implemented
  - **Deliverable**: Performance-optimized application
  - **Acceptance Criteria**:
    - [ ] Page load times under 2 seconds
    - [ ] API response times under 500ms
    - [ ] Database queries optimized
    - [ ] Frontend bundle size optimized
    - [ ] Performance monitoring implemented

- [ ] **UX-001**: User experience refinement
  - **Owner**: Designer + Frontend Developer
  - **Effort**: 20 hours
  - **Dependencies**: All UI implemented
  - **Deliverable**: Polished user experience
  - **Acceptance Criteria**:
    - [ ] UI/UX review and refinement completed
    - [ ] Accessibility requirements verified
    - [ ] Mobile experience optimized
    - [ ] User feedback incorporated
    - [ ] Loading states and error handling polished

- [ ] **SEC-001**: Security review and hardening
  - **Owner**: Tech Lead + Security Consultant
  - **Effort**: 12 hours
  - **Dependencies**: All features implemented
  - **Deliverable**: Security-validated application
  - **Acceptance Criteria**:
    - [ ] Security audit completed
    - [ ] Vulnerability scanning performed
    - [ ] Input validation verified
    - [ ] Authentication security confirmed
    - [ ] Data protection measures validated

- [ ] **DOC-001**: Documentation completion
  - **Owner**: Tech Lead + Team
  - **Effort**: 16 hours
  - **Dependencies**: All features implemented
  - **Deliverable**: Complete documentation set
  - **Acceptance Criteria**:
    - [ ] API documentation complete and current
    - [ ] User documentation written
    - [ ] Technical documentation updated
    - [ ] Deployment procedures documented
    - [ ] Troubleshooting guides created

#### Milestone 5 Success Criteria
- [ ] All features integrated and working together
- [ ] Performance requirements met
- [ ] Security standards achieved
- [ ] Documentation complete and accessible
- [ ] Application ready for production deployment

---

### Milestone 6: Deployment & Launch
**Duration**: Week 7-8
**Goal**: Deploy to production and successfully launch Phase 1
**Team Focus**: Deployment, monitoring, and launch support

#### Tasks & Deliverables
- [ ] **DEPLOY-001**: Production environment setup
  - **Owner**: DevOps Engineer
  - **Effort**: 16 hours
  - **Dependencies**: All development complete
  - **Deliverable**: Production-ready environment
  - **Acceptance Criteria**:
    - [ ] Production servers configured and secured
    - [ ] Database deployed with migrations
    - [ ] SSL certificates and domain setup
    - [ ] Load balancing and scaling configured
    - [ ] Backup and recovery procedures tested

- [ ] **DEPLOY-002**: Monitoring and alerting configuration
  - **Owner**: DevOps Engineer + Tech Lead
  - **Effort**: 12 hours
  - **Dependencies**: DEPLOY-001
  - **Deliverable**: Comprehensive monitoring system
  - **Acceptance Criteria**:
    - [ ] Application performance monitoring
    - [ ] Error tracking and alerting
    - [ ] Uptime monitoring and notifications
    - [ ] Database performance monitoring
    - [ ] User analytics and behavior tracking

- [ ] **LAUNCH-001**: Launch preparation and execution
  - **Owner**: Product Owner + Full Team
  - **Effort**: 20 hours
  - **Dependencies**: DEPLOY-002
  - **Deliverable**: Successful product launch
  - **Acceptance Criteria**:
    - [ ] Launch checklist completed
    - [ ] User onboarding materials ready
    - [ ] Support documentation available
    - [ ] Team trained on support procedures
    - [ ] Launch communications executed

- [ ] **SUPPORT-001**: Post-launch monitoring and support
  - **Owner**: Full Team
  - **Effort**: 24 hours (first week)
  - **Dependencies**: LAUNCH-001
  - **Deliverable**: Stable production operation
  - **Acceptance Criteria**:
    - [ ] 24/7 monitoring during launch week
    - [ ] User support processes operational
    - [ ] Issue tracking and resolution
    - [ ] Performance monitoring and optimization
    - [ ] User feedback collection and analysis

#### Milestone 6 Success Criteria
- [ ] Application running stably in production
- [ ] Monitoring and alerting functional
- [ ] User onboarding and support operational
- [ ] Launch metrics targets achieved
- [ ] Team ready for ongoing operation and Phase 2 planning

## Resource Planning & Allocation

### Team Composition & Availability
- **Product Owner**: 20 hours/week (requirements, testing, stakeholder communication)
- **Tech Lead**: 40 hours/week (architecture, code review, technical decisions)
- **Senior Frontend Developer**: 40 hours/week (UI implementation, component library)
- **Backend Developer**: 40 hours/week (API development, database design)
- **Designer**: 15 hours/week (UI design, user experience, design system)
- **DevOps Engineer**: 10 hours/week (infrastructure, deployment, monitoring)
- **QA Engineer**: 20 hours/week (testing, quality assurance, user acceptance)

### Technology Stack & Tools
- **Frontend**: React 18+, TypeScript, Tailwind CSS, Vite
- **Backend**: Node.js, Express, TypeScript, PostgreSQL
- **Development**: VSCode, Git, npm/yarn, Docker
- **Testing**: Jest, React Testing Library, Cypress
- **Deployment**: Docker, AWS/Azure/GCP, CI/CD pipeline
- **Monitoring**: Application monitoring, error tracking, analytics

### Budget & Resource Requirements
- **Development Team**: [Calculate based on team composition and duration]
- **Infrastructure**: [Cloud hosting, database, CDN, monitoring services]
- **Tools & Services**: [Development tools, third-party services, licenses]
- **Contingency**: [10-20% buffer for unexpected requirements or delays]

## Risk Management Strategy

### High-Priority Risks & Mitigation

#### Risk: Database Performance with Large Datasets
- **Impact**: High - Could affect user experience and system scalability
- **Probability**: Medium - Depends on user adoption and data growth
- **Mitigation**: 
  - Early load testing with realistic data volumes
  - Database query optimization and indexing
  - Caching strategy implementation
  - Database performance monitoring
- **Contingency**: Database schema optimization, caching layer implementation
- **Owner**: Tech Lead
- **Monitor**: Weekly performance testing and monitoring

#### Risk: Third-party Service Integration Failures
- **Impact**: Medium - Could delay features dependent on external services
- **Probability**: Medium - External services may have downtime or API changes
- **Mitigation**:
  - Fallback mechanisms for critical integrations
  - Regular testing of external service connections
  - Service-level agreements and support contacts
  - Error handling and user communication
- **Contingency**: Alternative service providers or simplified functionality
- **Owner**: Backend Developer
- **Monitor**: Daily integration health checks

#### Risk: Mobile Responsive Design Complexity
- **Impact**: Medium - Poor mobile experience could reduce user adoption
- **Probability**: Medium - Complex UI features may not translate well to mobile
- **Mitigation**:
  - Mobile-first development approach
  - Regular testing on actual mobile devices
  - Progressive enhancement strategy
  - User testing on mobile platforms
- **Contingency**: Simplified mobile interface or dedicated mobile app
- **Owner**: Designer + Frontend Developer
- **Monitor**: Weekly mobile experience testing

#### Risk: Security Vulnerabilities
- **Impact**: High - Could compromise user data and trust
- **Probability**: Low - With proper development practices
- **Mitigation**:
  - Regular security code reviews
  - Automated vulnerability scanning
  - Secure coding standards and training
  - External security audit before launch
- **Contingency**: Immediate patch deployment and user notification procedures
- **Owner**: Tech Lead + Security Consultant
- **Monitor**: Continuous automated scanning and monthly reviews

### Risk Monitoring & Escalation
- **Daily**: Team lead monitors technical risks during standup meetings
- **Weekly**: Risk register review in team meetings
- **Bi-weekly**: Stakeholder risk briefing and escalation as needed
- **Monthly**: Comprehensive risk assessment and mitigation plan updates

## Success Measurement & KPIs

### Phase Success Criteria
This phase will be considered successful when:
- All functional requirements implemented and tested
- User acceptance criteria met for all features
- Performance benchmarks achieved (page loads <2s, API responses <500ms)
- Security requirements validated through audit
- User onboarding success rate >70%
- System uptime >99.9% during first month

### Key Performance Indicators

#### Development Metrics
- **Velocity**: Story points completed per sprint
- **Quality**: Defect rate and time to resolution
- **Efficiency**: Code review time and deployment frequency
- **Technical Debt**: Code quality metrics and refactoring needs

#### User Engagement Metrics
- **Adoption Rate**: Percentage of registered users who complete onboarding
- **Feature Usage**: Percentage of users utilizing core features (contacts, tasks)
- **Session Duration**: Average time users spend in the application
- **Return Rate**: Percentage of users who return within 7 days of registration

#### Technical Performance Metrics
- **Response Time**: Average API response times across all endpoints
- **Page Load Speed**: Average page load times across different pages
- **Error Rates**: Percentage of requests resulting in errors
- **Uptime**: System availability percentage

#### Business Metrics
- **User Registration**: Number of new user registrations per week
- **User Retention**: Percentage of users active after 30 days
- **Support Load**: Number of support tickets per active user
- **User Satisfaction**: User feedback scores and ratings

### Measurement Tools & Reporting
- **Analytics**: Google Analytics or similar for user behavior
- **Performance**: Application performance monitoring (APM) tools
- **Uptime**: Uptime monitoring and alerting services
- **User Feedback**: In-app feedback collection and user surveys
- **Business Intelligence**: Dashboard for key metrics and trends

## Communication & Reporting Plan

### Daily Communication
- **Team Standup**: 15-minute daily sync on progress, blockers, and plans
- **Slack Updates**: Continuous communication and quick issue resolution
- **Code Reviews**: Ongoing peer review and knowledge sharing

### Weekly Communication
- **Sprint Planning**: Plan upcoming week's work and priorities
- **Stakeholder Update**: Progress report to product and business stakeholders
- **Risk Review**: Assess risks and adjust mitigation strategies
- **Metrics Review**: Analyze KPIs and performance indicators

### Bi-weekly Communication
- **Sprint Demo**: Demonstration of completed features to stakeholders
- **Retrospective**: Team reflection on process improvements
- **User Research**: User testing results and feedback incorporation

### Monthly Communication
- **Business Review**: Comprehensive progress and metrics review
- **Budget Review**: Resource utilization and budget status
- **Roadmap Update**: Adjustments to overall product roadmap

## Phase Completion & Transition

### Phase Completion Checklist
- [ ] All user stories completed and accepted
- [ ] All acceptance criteria verified
- [ ] Performance requirements met
- [ ] Security audit completed and passed
- [ ] Documentation complete and reviewed
- [ ] Production deployment successful
- [ ] Monitoring and alerting operational
- [ ] User feedback collected and analyzed
- [ ] Success metrics achieved or on trajectory
- [ ] Technical debt documented and prioritized

### Knowledge Transfer & Documentation
- [ ] Technical architecture documented
- [ ] API documentation complete and current
- [ ] Deployment procedures documented and tested
- [ ] Troubleshooting guides created
- [ ] User manuals and help documentation
- [ ] Team knowledge sharing sessions completed

### Phase 2 Transition Preparation
- [ ] Phase 2 requirements reviewed and understood
- [ ] Technical dependencies for Phase 2 satisfied
- [ ] Team capacity planned for Phase 2
- [ ] Lessons learned documented and shared
- [ ] Architecture decisions logged for future reference
- [ ] User feedback prioritized for Phase 2 planning

### Success Celebration & Team Recognition
- [ ] Phase completion celebration planned
- [ ] Individual and team contributions recognized
- [ ] Lessons learned and improvements identified
- [ ] Team satisfaction and feedback collected
- [ ] Process improvements planned for next phase

---

**Plan Version**: 1.0
**Created**: $(Get-Date -Format 'yyyy-MM-dd')
**Last Updated**: $(Get-Date -Format 'yyyy-MM-dd')  
**Approved By**: [Product Owner, Tech Lead, Team]
**Next Review**: [Weekly during execution]
"@

    try {
        $phasePlanContent | Out-File -FilePath "$phaseDir\plan.md" -Encoding UTF8
        Write-ColorOutput "✅ Created $phaseDir\plan.md" "Green"
    }
    catch {
        Write-ColorOutput "❌ Failed to create plan.md: $($_.Exception.Message)" "Red"
        return
    }

    Write-ColorOutput "✅ Phase $PhaseNumber implementation plan created successfully!" "Green"
    Write-ColorOutput "" "White"
    Write-ColorOutput "📝 Next steps:" "Yellow"
    Write-ColorOutput "   1. Review and adjust timeline in $phaseDir\plan.md" "White"
    Write-ColorOutput "   2. Assign team members to specific tasks" "White"
    Write-ColorOutput "   3. Run: .\manage-phases.ps1 -Action start-phase -PhaseNumber $PhaseNumber" "White"
}

function Start-PhaseExecution {
    param(
        [Parameter(Mandatory=$true)]
        [string]$PhaseNumber
    )
    
    Write-ColorOutput "🚀 Starting Phase $PhaseNumber execution..." "Cyan"
    
    $phaseDir = "docs\phases\phase-$PhaseNumber"
    
    # Validate prerequisites
    $requiredFiles = @(
        "$phaseDir\spec.md",
        "$phaseDir\plan.md"
    )
    
    $missingFiles = @()
    foreach ($file in $requiredFiles) {
        if (-not (Test-Path $file)) {
            $missingFiles += $file
        }
    }
    
    if ($missingFiles.Count -gt 0) {
        Write-ColorOutput "❌ Missing required files:" "Red"
        foreach ($file in $missingFiles) {
            Write-ColorOutput "   • $file" "Red"
        }
        Write-ColorOutput "💡 Complete specification and planning first" "Yellow"
        return
    }

    Write-ColorOutput "📋 Generating detailed task breakdown..." "Yellow"
    
    $tasksContent = @"
# Phase $PhaseNumber - Development Tasks & Sprint Planning

## Task Management Overview
**Phase**: $PhaseNumber
**Status**: 🚀 In Progress  
**Start Date**: $(Get-Date -Format 'yyyy-MM-dd')
**Team**: [Define team composition]
**Sprint Duration**: 1 week
**Total Estimated Duration**: 7-8 weeks

## Sprint Planning Framework

### Sprint Methodology
- **Sprint Length**: 1 week (5 working days)
- **Planning**: Monday morning sprint planning
- **Daily Standups**: Every day at [time]
- **Review/Demo**: Friday afternoon
- **Retrospective**: Friday end of day
- **Definition of Done**: Code complete, reviewed, tested, deployed to staging

### Task Categories & Estimation
- **Setup Tasks**: Environment, infrastructure, foundational work
- **Core Development**: Feature implementation and business logic
- **Integration Tasks**: Component integration and data flow
- **Testing Tasks**: Unit, integration, and end-to-end testing
- **Documentation**: Technical docs, user guides, API documentation
- **Deployment**: Production deployment and monitoring setup

### Estimation Scale
- **XS (1-2 hours)**: Simple bug fixes, minor updates
- **S (3-4 hours)**: Small features, simple components
- **M (5-8 hours)**: Medium features, complex components
- **L (9-16 hours)**: Large features, complex integrations
- **XL (17+ hours)**: Epic-sized work (should be broken down)

## Sprint 1: Foundation Setup & Authentication Framework
**Sprint Goal**: Establish development foundation and basic authentication structure
**Duration**: Week 1 (5 days)
**Team Focus**: Infrastructure and authentication foundation

### Setup & Infrastructure Tasks
#### Task: ENV-001 - Development Environment Setup
- **Category**: Setup
- **Priority**: Critical
- **Estimated Effort**: S (4 hours)
- **Assigned To**: DevOps Engineer + Tech Lead
- **Dependencies**: None
- **Description**: Set up complete local development environment for all team members
- **Acceptance Criteria**:
  - [ ] All developers can clone and run project locally
  - [ ] Database connections working (local PostgreSQL)
  - [ ] Hot reloading functional for frontend and backend
  - [ ] Environment variables configured correctly
  - [ ] Git hooks and commit standards configured
  - [ ] IDE setup with recommended extensions documented

#### Task: DB-001 - Database Schema Implementation  
- **Category**: Core Development
- **Priority**: Critical
- **Estimated Effort**: M (6 hours)
- **Assigned To**: Backend Developer
- **Dependencies**: ENV-001
- **Description**: Implement database schema for users, contacts, and tasks
- **Acceptance Criteria**:
  - [ ] User table with authentication fields
  - [ ] Contact table with all required fields and relationships
  - [ ] Task table with contact relationships and metadata
  - [ ] Proper indexes for performance
  - [ ] Migration scripts tested and documented
  - [ ] Rollback procedures verified

#### Task: AUTH-001 - Authentication Framework Setup
- **Category**: Core Development
- **Priority**: Critical  
- **Estimated Effort**: M (8 hours)
- **Assigned To**: Senior Backend Developer
- **Dependencies**: DB-001
- **Description**: Implement JWT-based authentication framework
- **Acceptance Criteria**:
  - [ ] JWT token generation and validation
  - [ ] Authentication middleware for protected routes
  - [ ] Password hashing with bcrypt
  - [ ] User session management
  - [ ] Security headers and CORS configuration
  - [ ] Rate limiting for authentication endpoints

### UI Foundation Tasks
#### Task: UI-001 - Design System Integration
- **Category**: Core Development
- **Priority**: High
- **Estimated Effort**: M (8 hours)
- **Assigned To**: Frontend Developer + Designer
- **Dependencies**: ENV-001
- **Description**: Integrate design system tokens and create base components
- **Acceptance Criteria**:
  - [ ] Design tokens imported and accessible
  - [ ] Button component with all variants (primary, secondary, ghost)
  - [ ] Input component with validation states
  - [ ] Form component with error handling
  - [ ] Loading component with design system styling
  - [ ] All components responsive and accessible

#### Task: AUTH-UI-001 - Authentication UI Components
- **Category**: Core Development
- **Priority**: High
- **Estimated Effort**: M (6 hours)
- **Assigned To**: Frontend Developer
- **Dependencies**: UI-001, AUTH-001
- **Description**: Create login and registration form components
- **Acceptance Criteria**:
  - [ ] Login form with email/password validation
  - [ ] Registration form with password confirmation
  - [ ] Form validation with real-time feedback
  - [ ] Loading states during authentication
  - [ ] Error handling and user messaging
  - [ ] Responsive design for mobile devices

### Testing & Quality Tasks
#### Task: TEST-001 - Testing Framework Setup
- **Category**: Testing
- **Priority**: High
- **Estimated Effort**: S (4 hours)
- **Assigned To**: QA Engineer + Tech Lead
- **Dependencies**: ENV-001
- **Description**: Set up comprehensive testing framework
- **Acceptance Criteria**:
  - [ ] Jest configured for unit testing
  - [ ] React Testing Library for component testing
  - [ ] Cypress configured for E2E testing
  - [ ] Test coverage reporting setup
  - [ ] CI/CD integration for automated testing
  - [ ] Testing documentation and guidelines

### Sprint 1 Daily Breakdown
**Monday (Sprint Planning + Setup Start)**
- Sprint planning meeting (2 hours)
- ENV-001: Begin development environment setup
- DB-001: Start database schema design

**Tuesday (Environment & Database Focus)**  
- ENV-001: Complete development environment setup
- DB-001: Implement database schema and migrations
- AUTH-001: Begin authentication framework

**Wednesday (Authentication & UI Foundation)**
- AUTH-001: Complete authentication framework
- UI-001: Begin design system integration
- TEST-001: Start testing framework setup

**Thursday (UI Components & Testing)**
- UI-001: Complete base components
- AUTH-UI-001: Begin authentication UI components
- TEST-001: Complete testing framework setup

**Friday (Integration & Sprint Review)**
- AUTH-UI-001: Complete authentication UI
- Integration testing of completed components
- Sprint review and demo preparation
- Sprint retrospective and next sprint planning

### Sprint 1 Success Criteria
- [ ] All team members productive in development environment
- [ ] Database schema supports authentication and basic features
- [ ] Authentication framework ready for user registration/login
- [ ] Base UI components available for feature development
- [ ] Testing framework operational and integrated

---

## Sprint 2: User Registration & Login Implementation  
**Sprint Goal**: Complete user registration and login functionality
**Duration**: Week 2 (5 days)
**Team Focus**: Authentication features and user account management

### Authentication API Tasks
#### Task: AUTH-002 - User Registration API
- **Category**: Core Development
- **Priority**: Critical
- **Estimated Effort**: M (6 hours)
- **Assigned To**: Backend Developer
- **Dependencies**: AUTH-001
- **Description**: Implement user registration endpoint with validation
- **Acceptance Criteria**:
  - [ ] POST /api/auth/register endpoint
  - [ ] Email uniqueness validation
  - [ ] Password strength requirements
  - [ ] User account creation in database
  - [ ] Email verification token generation
  - [ ] Welcome email sending
  - [ ] Proper error responses for validation failures

#### Task: AUTH-003 - User Login API
- **Category**: Core Development
- **Priority**: Critical
- **Estimated Effort**: S (4 hours)
- **Assigned To**: Backend Developer
- **Dependencies**: AUTH-002
- **Description**: Implement user login endpoint with JWT tokens
- **Acceptance Criteria**:
  - [ ] POST /api/auth/login endpoint
  - [ ] Email/password validation
  - [ ] JWT token generation with appropriate expiration
  - [ ] Refresh token implementation
  - [ ] Login attempt rate limiting
  - [ ] Security logging for failed attempts

#### Task: AUTH-004 - Password Reset API
- **Category**: Core Development
- **Priority**: High
- **Estimated Effort**: M (6 hours)
- **Assigned To**: Backend Developer
- **Dependencies**: AUTH-002
- **Description**: Implement complete password reset flow
- **Acceptance Criteria**:
  - [ ] POST /api/auth/forgot-password endpoint
  - [ ] Secure reset token generation and email
  - [ ] POST /api/auth/reset-password endpoint
  - [ ] Token validation and expiration handling
  - [ ] Password update with security notifications
  - [ ] Rate limiting for reset requests

### Authentication UI Implementation
#### Task: AUTH-UI-002 - Registration Page Implementation
- **Category**: Core Development
- **Priority**: Critical
- **Estimated Effort**: M (8 hours)
- **Assigned To**: Frontend Developer
- **Dependencies**: AUTH-UI-001, AUTH-002
- **Description**: Complete user registration page with full functionality
- **Acceptance Criteria**:
  - [ ] Registration form with all required fields
  - [ ] Real-time validation feedback
  - [ ] Password strength indicator
  - [ ] Terms of service acceptance
  - [ ] Success confirmation with email verification prompt
  - [ ] Error handling for all failure scenarios
  - [ ] Loading states and user feedback

#### Task: AUTH-UI-003 - Login Page Implementation
- **Category**: Core Development
- **Priority**: Critical
- **Estimated Effort**: M (6 hours)
- **Assigned To**: Frontend Developer
- **Dependencies**: AUTH-UI-001, AUTH-003
- **Description**: Complete login page with authentication flow
- **Acceptance Criteria**:
  - [ ] Login form with email/password fields
  - [ ] Remember me functionality
  - [ ] Forgot password link integration
  - [ ] Success redirect to dashboard
  - [ ] Error handling for authentication failures
  - [ ] Loading states during login process

#### Task: AUTH-UI-004 - Password Reset Flow UI
- **Category**: Core Development
- **Priority**: High
- **Estimated Effort**: S (4 hours)
- **Assigned To**: Frontend Developer
- **Dependencies**: AUTH-UI-001, AUTH-004
- **Description**: Implement password reset user interface
- **Acceptance Criteria**:
  - [ ] Forgot password form page
  - [ ] Email confirmation page
  - [ ] Password reset form with token validation
  - [ ] Success confirmation page
  - [ ] Error handling for expired/invalid tokens
  - [ ] Navigation back to login

### User Management Features
#### Task: USER-001 - User Profile API
- **Category**: Core Development
- **Priority**: High
- **Estimated Effort**: S (4 hours)
- **Assigned To**: Backend Developer
- **Dependencies**: AUTH-003
- **Description**: Implement user profile management endpoints
- **Acceptance Criteria**:
  - [ ] GET /api/user/profile endpoint
  - [ ] PUT /api/user/profile endpoint
  - [ ] Profile field validation
  - [ ] Email change verification process
  - [ ] User preferences storage
  - [ ] Profile picture upload handling

### Testing Tasks
#### Task: TEST-002 - Authentication Test Suite
- **Category**: Testing
- **Priority**: High
- **Estimated Effort**: M (8 hours)
- **Assigned To**: QA Engineer
- **Dependencies**: AUTH-002, AUTH-003, AUTH-004
- **Description**: Comprehensive testing of authentication features
- **Acceptance Criteria**:
  - [ ] Unit tests for all authentication endpoints
  - [ ] Integration tests for authentication flows
  - [ ] Security testing for token handling
  - [ ] Rate limiting tests
  - [ ] Error scenario testing
  - [ ] Performance testing for auth endpoints

### Sprint 2 Success Criteria
- [ ] Users can register accounts with email verification
- [ ] Users can log in and receive JWT tokens
- [ ] Password reset flow working end-to-end
- [ ] All authentication features tested and secure
- [ ] UI matches design specifications and is responsive

---

## Sprint 3: Contact Management Foundation
**Sprint Goal**: Implement core contact management functionality
**Duration**: Week 3 (5 days)
**Team Focus**: Contact data model and basic CRUD operations

### Contact API Development
#### Task: CONTACT-001 - Contact Data Model & API
- **Category**: Core Development
- **Priority**: Critical
- **Estimated Effort**: M (8 hours)
- **Assigned To**: Backend Developer
- **Dependencies**: AUTH-003 (for user association)
- **Description**: Implement complete contact management API
- **Acceptance Criteria**:
  - [ ] Contact model with all required fields
  - [ ] POST /api/contacts - Create contact
  - [ ] GET /api/contacts - List contacts with pagination
  - [ ] GET /api/contacts/:id - Get single contact
  - [ ] PUT /api/contacts/:id - Update contact
  - [ ] DELETE /api/contacts/:id - Delete contact
  - [ ] User-based contact isolation and security

#### Task: CONTACT-002 - Contact Search & Filtering API
- **Category**: Core Development
- **Priority**: High
- **Estimated Effort**: M (6 hours)
- **Assigned To**: Backend Developer
- **Dependencies**: CONTACT-001
- **Description**: Implement search and filtering capabilities
- **Acceptance Criteria**:
  - [ ] Search by name, email, phone number
  - [ ] Filter by contact categories/tags
  - [ ] Sort by name, creation date, last modified
  - [ ] Pagination with configurable page sizes
  - [ ] Performance optimization for large contact lists
  - [ ] Case-insensitive search implementation

### Contact UI Implementation
#### Task: CONTACT-UI-001 - Contact List Page
- **Category**: Core Development
- **Priority**: Critical
- **Estimated Effort**: L (12 hours)
- **Assigned To**: Frontend Developer
- **Dependencies**: UI-001, CONTACT-001
- **Description**: Implement contact list page with full functionality
- **Acceptance Criteria**:
  - [ ] Paginated contact list display
  - [ ] Search bar with real-time filtering
  - [ ] Sort controls (name, date, etc.)
  - [ ] Contact cards with key information
  - [ ] Quick actions (edit, delete, favorite)
  - [ ] Empty state when no contacts
  - [ ] Loading states for data fetching
  - [ ] Responsive grid layout for different screen sizes

#### Task: CONTACT-UI-002 - Add/Edit Contact Form
- **Category**: Core Development
- **Priority**: Critical
- **Estimated Effort**: M (8 hours)
- **Assigned To**: Frontend Developer
- **Dependencies**: UI-001, CONTACT-001
- **Description**: Create contact creation and editing forms
- **Acceptance Criteria**:
  - [ ] Contact form with all fields (name, email, phone, etc.)
  - [ ] Field validation with real-time feedback
  - [ ] Contact photo/avatar upload functionality
  - [ ] Save and cancel actions
  - [ ] Success/error messaging
  - [ ] Form auto-save for long forms
  - [ ] Mobile-optimized form layout

#### Task: CONTACT-UI-003 - Contact Detail View
- **Category**: Core Development
- **Priority**: High
- **Estimated Effort**: M (6 hours)
- **Assigned To**: Frontend Developer
- **Dependencies**: CONTACT-UI-001, CONTACT-001
- **Description**: Detailed contact view with all information
- **Acceptance Criteria**:
  - [ ] Complete contact information display
  - [ ] Contact interaction history
  - [ ] Quick edit functionality
  - [ ] Contact sharing options
  - [ ] Related tasks display (for future integration)
  - [ ] Delete confirmation dialog
  - [ ] Navigation to edit form

### Contact Categories & Organization
#### Task: CONTACT-003 - Contact Categories API
- **Category**: Core Development
- **Priority**: Medium
- **Estimated Effort**: S (4 hours)
- **Assigned To**: Backend Developer
- **Dependencies**: CONTACT-001
- **Description**: Implement contact categorization system
- **Acceptance Criteria**:
  - [ ] Category model and API endpoints
  - [ ] Assign/remove categories from contacts
  - [ ] Default categories (Work, Personal, Family, etc.)
  - [ ] Custom category creation
  - [ ] Category-based filtering in contact list
  - [ ] Bulk category assignment

### Testing & Quality
#### Task: TEST-003 - Contact Management Tests
- **Category**: Testing
- **Priority**: High
- **Estimated Effort**: M (6 hours)
- **Assigned To**: QA Engineer
- **Dependencies**: CONTACT-001, CONTACT-002
- **Description**: Comprehensive testing of contact features
- **Acceptance Criteria**:
  - [ ] Unit tests for contact API endpoints
  - [ ] Integration tests for contact workflows
  - [ ] Performance tests with large contact datasets
  - [ ] Security tests for user data isolation
  - [ ] UI automation tests for contact management
  - [ ] Cross-browser compatibility testing

### Sprint 3 Success Criteria
- [ ] Users can create, read, update, and delete contacts
- [ ] Contact search and filtering working efficiently
- [ ] Contact categorization system functional
- [ ] All contact features tested and performant
- [ ] Mobile-responsive contact management interface

---

## Sprint 4: Task Management Foundation
**Sprint Goal**: Implement core task management with contact integration
**Duration**: Week 4 (5 days)
**Team Focus**: Task CRUD operations and task-contact relationships

### Task Data Model & API
#### Task: TASK-001 - Task Data Model & Core API
- **Category**: Core Development
- **Priority**: Critical
- **Estimated Effort**: L (10 hours)
- **Assigned To**: Backend Developer
- **Dependencies**: CONTACT-001 (for task-contact relationships)
- **Description**: Implement comprehensive task management API
- **Acceptance Criteria**:
  - [ ] Task model with all fields (title, description, due date, priority, status)
  - [ ] POST /api/tasks - Create task
  - [ ] GET /api/tasks - List tasks with filtering and pagination
  - [ ] GET /api/tasks/:id - Get single task with details
  - [ ] PUT /api/tasks/:id - Update task
  - [ ] DELETE /api/tasks/:id - Delete task
  - [ ] PATCH /api/tasks/:id/complete - Mark task as complete
  - [ ] Task-contact relationship management

#### Task: TASK-002 - Task Categories & Priorities
- **Category**: Core Development
- **Priority**: High
- **Estimated Effort**: M (6 hours)
- **Assigned To**: Backend Developer
- **Dependencies**: TASK-001
- **Description**: Implement task organization features
- **Acceptance Criteria**:
  - [ ] Task categories (Work, Personal, Urgent, etc.)
  - [ ] Priority levels (High, Medium, Low)
  - [ ] Task status management (Todo, In Progress, Complete)
  - [ ] Due date and reminder functionality
  - [ ] Task filtering by category, priority, status
  - [ ] Bulk task operations (complete, delete, update category)

### Task UI Implementation
#### Task: TASK-UI-001 - Task List Page
- **Category**: Core Development
- **Priority**: Critical
- **Estimated Effort**: L (12 hours)
- **Assigned To**: Frontend Developer
- **Dependencies**: UI-001, TASK-001
- **Description**: Implement task list page with full functionality
- **Acceptance Criteria**:
  - [ ] Task list with different view options (list, card, kanban)
  - [ ] Filter by status, priority, category, due date
  - [ ] Sort by creation date, due date, priority
  - [ ] Quick actions (complete, edit, delete)
  - [ ] Bulk selection and operations
  - [ ] Search functionality across task titles and descriptions
  - [ ] Pagination and infinite scroll options
  - [ ] Responsive design for mobile devices

#### Task: TASK-UI-002 - Create/Edit Task Form
- **Category**: Core Development
- **Priority**: Critical
- **Estimated Effort**: M (8 hours)
- **Assigned To**: Frontend Developer
- **Dependencies**: UI-001, TASK-001
- **Description**: Task creation and editing interface
- **Acceptance Criteria**:
  - [ ] Task form with all fields (title, description, due date, priority)
  - [ ] Contact selection and linking
  - [ ] Category and priority selection
  - [ ] Due date picker with calendar interface
  - [ ] Rich text editor for task descriptions
  - [ ] Form validation and error handling
  - [ ] Auto-save functionality
  - [ ] Mobile-optimized form experience

#### Task: TASK-UI-003 - Task Detail View
- **Category**: Core Development
- **Priority**: High
- **Estimated Effort**: M (6 hours)
- **Assigned To**: Frontend Developer
- **Dependencies**: TASK-UI-001, TASK-001
- **Description**: Detailed task view with all information and actions
- **Acceptance Criteria**:
  - [ ] Complete task information display
  - [ ] Associated contact information
  - [ ] Task completion toggle
  - [ ] Quick edit functionality
  - [ ] Task activity/history log
  - [ ] Delete confirmation
  - [ ] Navigation to related contacts

### Task-Contact Integration
#### Task: TASK-003 - Task-Contact Relationships
- **Category**: Integration
- **Priority**: High
- **Estimated Effort**: M (6 hours)
- **Assigned To**: Backend Developer + Frontend Developer
- **Dependencies**: TASK-001, CONTACT-001
- **Description**: Implement task-contact relationship features
- **Acceptance Criteria**:
  - [ ] Link tasks to one or more contacts
  - [ ] View tasks associated with specific contacts
  - [ ] Create tasks directly from contact pages
  - [ ] Contact information display in task views
  - [ ] Task completion updates contact interaction history
  - [ ] Bulk task assignment to contacts

### Testing & Performance
#### Task: TEST-004 - Task Management Test Suite
- **Category**: Testing
- **Priority**: High
- **Estimated Effort**: M (8 hours)
- **Assigned To**: QA Engineer
- **Dependencies**: TASK-001, TASK-002, TASK-003
- **Description**: Comprehensive testing of task management features
- **Acceptance Criteria**:
  - [ ] Unit tests for task API endpoints
  - [ ] Integration tests for task-contact relationships
  - [ ] Performance tests with large task datasets
  - [ ] UI automation tests for task management workflows
  - [ ] Cross-browser testing for task interfaces
  - [ ] Mobile device testing for task management

### Sprint 4 Success Criteria
- [ ] Users can create, manage, and complete tasks
- [ ] Task-contact relationships working seamlessly
- [ ] Task filtering, sorting, and search functional
- [ ] All task features tested and performant
- [ ] Mobile task management experience optimized

---

## Sprint 5: Advanced Features & Integration
**Sprint Goal**: Implement advanced features and ensure system integration
**Duration**: Week 5 (5 days)
**Team Focus**: Feature completion and system integration

### Advanced Contact Features
#### Task: CONTACT-004 - Contact Import Functionality
- **Category**: Core Development
- **Priority**: High
- **Estimated Effort**: L (10 hours)
- **Assigned To**: Backend Developer + Frontend Developer
- **Dependencies**: CONTACT-001
- **Description**: Implement contact import from external sources
- **Acceptance Criteria**:
  - [ ] CSV file upload and parsing
  - [ ] Field mapping interface for different CSV formats
  - [ ] Duplicate contact detection and merging options
  - [ ] Import progress indication and error reporting
  - [ ] Rollback functionality for failed imports
  - [ ] Support for common contact export formats

#### Task: CONTACT-005 - Contact Export & Backup
- **Category**: Core Development
- **Priority**: Medium
- **Estimated Effort**: M (6 hours)
- **Assigned To**: Backend Developer
- **Dependencies**: CONTACT-001
- **Description**: Implement contact export functionality
- **Acceptance Criteria**:
  - [ ] Export contacts to CSV format
  - [ ] Export selected contacts or all contacts
  - [ ] Include all contact fields and categories
  - [ ] Email export file to user
  - [ ] Export progress indication
  - [ ] Data backup scheduling options

### Advanced Task Features
#### Task: TASK-004 - Task Reminders & Notifications
- **Category**: Core Development
- **Priority**: High
- **Estimated Effort**: M (8 hours)
- **Assigned To**: Backend Developer
- **Dependencies**: TASK-001
- **Description**: Implement task reminder and notification system
- **Acceptance Criteria**:
  - [ ] Email reminders for upcoming due dates
  - [ ] In-app notification system
  - [ ] Configurable reminder timing (1 day, 1 hour, etc.)
  - [ ] Reminder preferences in user settings
  - [ ] Overdue task notifications
  - [ ] Bulk reminder management

#### Task: TASK-005 - Task Analytics & Reporting
- **Category**: Core Development
- **Priority**: Medium
- **Estimated Effort**: M (6 hours)
- **Assigned To**: Frontend Developer + Backend Developer
- **Dependencies**: TASK-001
- **Description**: Basic task analytics and reporting
- **Acceptance Criteria**:
  - [ ] Task completion statistics
  - [ ] Productivity trends over time
  - [ ] Category and priority breakdowns
  - [ ] Contact-based task analytics
  - [ ] Visual charts and graphs
  - [ ] Export reports functionality

### System Integration & Polish
#### Task: INT-001 - Cross-Feature Integration
- **Category**: Integration
- **Priority**: Critical
- **Estimated Effort**: M (8 hours)
- **Assigned To**: Full Team
- **Dependencies**: All previous features
- **Description**: Ensure all features work together seamlessly
- **Acceptance Criteria**:
  - [ ] Navigation between contacts and tasks works smoothly
  - [ ] Data consistency across all features
  - [ ] Shared components work in all contexts
  - [ ] User preferences apply globally
  - [ ] Search works across contacts and tasks
  - [ ] Bulk operations work across features

#### Task: UI-002 - UI/UX Polish & Refinement
- **Category**: Core Development
- **Priority**: High
- **Estimated Effort**: M (8 hours)
- **Assigned To**: Designer + Frontend Developer
- **Dependencies**: All UI components implemented
- **Description**: Polish user interface and improve user experience
- **Acceptance Criteria**:
  - [ ] Consistent design system usage across all components
  - [ ] Smooth animations and transitions
  - [ ] Improved loading states and error handling
  - [ ] Enhanced mobile responsive design
  - [ ] Accessibility improvements (WCAG 2.1 AA)
  - [ ] User feedback incorporation

### Testing & Quality Assurance
#### Task: TEST-005 - End-to-End Integration Testing
- **Category**: Testing
- **Priority**: Critical
- **Estimated Effort**: L (10 hours)
- **Assigned To**: QA Engineer + Full Team
- **Dependencies**: All features implemented
- **Description**: Comprehensive end-to-end testing of complete system
- **Acceptance Criteria**:
  - [ ] Complete user journey testing
  - [ ] Cross-feature integration testing
  - [ ] Performance testing with realistic data loads
  - [ ] Security testing and vulnerability assessment
  - [ ] Browser compatibility testing
  - [ ] Mobile device testing on real devices

### Sprint 5 Success Criteria
- [ ] All advanced features implemented and functional
- [ ] System integration working seamlessly
- [ ] User interface polished and consistent
- [ ] Comprehensive testing completed
- [ ] System ready for production deployment

---

## Sprint 6: Performance, Security & Documentation
**Sprint Goal**: Optimize performance, secure the application, and complete documentation
**Duration**: Week 6 (5 days)
**Team Focus**: Production readiness and quality assurance

### Performance Optimization
#### Task: PERF-001 - Frontend Performance Optimization
- **Category**: Performance
- **Priority**: High
- **Estimated Effort**: M (8 hours)
- **Assigned To**: Frontend Developer + Tech Lead
- **Dependencies**: All UI features complete
- **Description**: Optimize frontend performance for production
- **Acceptance Criteria**:
  - [ ] Bundle size optimization and code splitting
  - [ ] Image optimization and lazy loading
  - [ ] Caching strategies for API calls
  - [ ] Component rendering optimization
  - [ ] Performance monitoring implementation
  - [ ] Page load times under 2 seconds

#### Task: PERF-002 - Backend Performance Optimization
- **Category**: Performance
- **Priority**: High
- **Estimated Effort**: M (8 hours)
- **Assigned To**: Backend Developer + Tech Lead
- **Dependencies**: All API endpoints complete
- **Description**: Optimize backend performance and database queries
- **Acceptance Criteria**:
  - [ ] Database query optimization and indexing
  - [ ] API response caching implementation
  - [ ] Database connection pooling
  - [ ] Slow query identification and optimization
  - [ ] Memory usage optimization
  - [ ] API response times under 500ms

### Security Hardening
#### Task: SEC-001 - Security Audit & Hardening
- **Category**: Security
- **Priority**: Critical
- **Estimated Effort**: L (12 hours)
- **Assigned To**: Tech Lead + Security Consultant
- **Dependencies**: All features complete
- **Description**: Comprehensive security audit and hardening
- **Acceptance Criteria**:
  - [ ] Vulnerability scanning and remediation
  - [ ] Input validation and sanitization verification
  - [ ] Authentication security review
  - [ ] Data encryption at rest and in transit
  - [ ] Security headers implementation
  - [ ] Penetration testing and issue resolution

#### Task: SEC-002 - Data Privacy & Compliance
- **Category**: Security
- **Priority**: High
- **Estimated Effort**: M (6 hours)
- **Assigned To**: Tech Lead + Legal Consultant
- **Dependencies**: SEC-001
- **Description**: Ensure data privacy compliance and user rights
- **Acceptance Criteria**:
  - [ ] GDPR compliance verification
  - [ ] User data export functionality
  - [ ] User account deletion with data cleanup
  - [ ] Privacy policy implementation
  - [ ] Cookie consent and tracking policies
  - [ ] Data retention policy implementation

### Documentation & Knowledge Transfer
#### Task: DOC-001 - Technical Documentation
- **Category**: Documentation
- **Priority**: High
- **Estimated Effort**: M (8 hours)
- **Assigned To**: Tech Lead + Development Team
- **Dependencies**: All features complete
- **Description**: Complete technical documentation for maintenance and future development
- **Acceptance Criteria**:
  - [ ] API documentation with examples
  - [ ] Database schema documentation
  - [ ] Architecture decision records
  - [ ] Deployment and configuration guides
  - [ ] Troubleshooting and maintenance guides
  - [ ] Code documentation and comments

#### Task: DOC-002 - User Documentation & Help System
- **Category**: Documentation
- **Priority**: High
- **Estimated Effort**: M (6 hours)
- **Assigned To**: Product Owner + Designer
- **Dependencies**: All user features complete
- **Description**: Create comprehensive user documentation and help system
- **Acceptance Criteria**:
  - [ ] User onboarding guide
  - [ ] Feature documentation with screenshots
  - [ ] FAQ and common issues
  - [ ] Video tutorials for key workflows
  - [ ] In-app help and tooltips
  - [ ] User support contact information

### Monitoring & Alerting Setup
#### Task: MON-001 - Production Monitoring Setup
- **Category**: Infrastructure
- **Priority**: Critical
- **Estimated Effort**: M (6 hours)
- **Assigned To**: DevOps Engineer
- **Dependencies**: Performance optimization complete
- **Description**: Set up comprehensive production monitoring
- **Acceptance Criteria**:
  - [ ] Application performance monitoring (APM)
  - [ ] Error tracking and alerting
  - [ ] Uptime monitoring and notifications
  - [ ] Database performance monitoring
  - [ ] User analytics and behavior tracking
  - [ ] Resource usage monitoring and alerts

### Sprint 6 Success Criteria
- [ ] Application optimized for production performance
- [ ] Security audit completed and issues resolved
- [ ] Comprehensive documentation available
- [ ] Monitoring and alerting operational
- [ ] System fully prepared for production deployment

---

## Sprint 7: Production Deployment & Launch Preparation
**Sprint Goal**: Deploy to production and prepare for user launch
**Duration**: Week 7 (5 days)
**Team Focus**: Deployment, final testing, and launch preparation

### Production Environment Setup
#### Task: DEPLOY-001 - Production Infrastructure Setup
- **Category**: Deployment
- **Priority**: Critical
- **Estimated Effort**: L (10 hours)
- **Assigned To**: DevOps Engineer
- **Dependencies**: All development complete
- **Description**: Set up and configure production environment
- **Acceptance Criteria**:
  - [ ] Production servers configured and secured
  - [ ] Database deployed with all migrations
  - [ ] SSL certificates and domain configuration
  - [ ] Load balancing and auto-scaling setup
  - [ ] Backup and disaster recovery procedures
  - [ ] Environment variables and secrets management

#### Task: DEPLOY-002 - CI/CD Pipeline Configuration
- **Category**: Deployment
- **Priority**: Critical
- **Estimated Effort**: M (6 hours)
- **Assigned To**: DevOps Engineer + Tech Lead
- **Dependencies**: DEPLOY-001
- **Description**: Configure automated deployment pipeline
- **Acceptance Criteria**:
  - [ ] Automated build and test pipeline
  - [ ] Deployment automation with rollback capability
  - [ ] Environment-specific configuration management
  - [ ] Database migration automation
  - [ ] Deployment notifications and logging
  - [ ] Blue-green deployment strategy

### Production Deployment & Testing
#### Task: DEPLOY-003 - Production Deployment
- **Category**: Deployment
- **Priority**: Critical
- **Estimated Effort**: M (8 hours)
- **Assigned To**: DevOps Engineer + Tech Lead
- **Dependencies**: DEPLOY-002
- **Description**: Deploy application to production environment
- **Acceptance Criteria**:
  - [ ] Application successfully deployed to production
  - [ ] Database migrations executed successfully
  - [ ] All services running and healthy
  - [ ] SSL and security configurations verified
  - [ ] Performance benchmarks met in production
  - [ ] Rollback procedures tested and documented

#### Task: TEST-006 - Production Smoke Testing
- **Category**: Testing
- **Priority**: Critical
- **Estimated Effort**: S (4 hours)
- **Assigned To**: QA Engineer + Full Team
- **Dependencies**: DEPLOY-003
- **Description**: Comprehensive testing in production environment
- **Acceptance Criteria**:
  - [ ] All critical user paths tested in production
  - [ ] Performance verified in production environment
  - [ ] Security configurations validated
  - [ ] Monitoring and alerting tested
  - [ ] Backup and recovery procedures verified
  - [ ] Load testing with expected user volumes

### Launch Preparation
#### Task: LAUNCH-001 - User Onboarding System
- **Category**: Core Development
- **Priority**: High
- **Estimated Effort**: M (6 hours)
- **Assigned To**: Frontend Developer + Designer
- **Dependencies**: Production deployment complete
- **Description**: Implement user onboarding flow for new users
- **Acceptance Criteria**:
  - [ ] Welcome tour for new users
  - [ ] Sample data creation for demonstration
  - [ ] Getting started checklist
  - [ ] Feature introduction tooltips
  - [ ] User progress tracking
  - [ ] Onboarding completion celebration

#### Task: LAUNCH-002 - Launch Communications Preparation
- **Category**: Marketing/Communications
- **Priority**: Medium
- **Estimated Effort**: S (4 hours)
- **Assigned To**: Product Owner + Marketing Team
- **Dependencies**: All features complete
- **Description**: Prepare launch communications and materials
- **Acceptance Criteria**:
  - [ ] Launch announcement prepared
  - [ ] Social media content created
  - [ ] Press release and media outreach
  - [ ] User communication email templates
  - [ ] Support team training materials
  - [ ] Launch metrics and success criteria defined

### Support System Setup
#### Task: SUPPORT-001 - User Support System
- **Category**: Infrastructure
- **Priority**: High
- **Estimated Effort**: M (6 hours)
- **Assigned To**: Product Owner + Customer Success
- **Dependencies**: Production deployment
- **Description**: Set up user support and feedback systems
- **Acceptance Criteria**:
  - [ ] Help desk and ticketing system operational
  - [ ] User feedback collection mechanisms
  - [ ] Support email and contact forms
  - [ ] Knowledge base and FAQ system
  - [ ] Support team training and procedures
  - [ ] Escalation procedures for critical issues

### Sprint 7 Success Criteria
- [ ] Application successfully running in production
- [ ] All systems monitored and healthy
- [ ] User onboarding system functional
- [ ] Support systems operational and team trained
- [ ] Launch communications prepared and ready

---

## Sprint 8: Launch & Post-Launch Support
**Sprint Goal**: Execute launch and provide intensive post-launch support
**Duration**: Week 8 (5 days)
**Team Focus**: Launch execution, monitoring, and user support

### Launch Execution
#### Task: LAUNCH-003 - Launch Execution
- **Category**: Launch
- **Priority**: Critical
- **Estimated Effort**: S (4 hours)
- **Assigned To**: Product Owner + Full Team
- **Dependencies**: All launch preparation complete
- **Description**: Execute the product launch plan
- **Acceptance Criteria**:
  - [ ] Launch announcement published
  - [ ] User registration opened
  - [ ] Social media campaign launched
  - [ ] Press outreach completed
  - [ ] Launch metrics monitoring activated
  - [ ] Team on standby for immediate support

### Intensive Monitoring & Support
#### Task: SUPPORT-002 - Launch Week Monitoring
- **Category**: Support
- **Priority**: Critical
- **Estimated Effort**: L (40 hours team effort)
- **Assigned To**: Full Team
- **Dependencies**: LAUNCH-003
- **Description**: Intensive monitoring and support during launch week
- **Acceptance Criteria**:
  - [ ] 24/7 monitoring during first 72 hours
  - [ ] Immediate response to critical issues
  - [ ] User registration and onboarding monitoring
  - [ ] Performance and uptime tracking
  - [ ] User feedback collection and analysis
  - [ ] Daily team check-ins and issue resolution

#### Task: SUPPORT-003 - User Feedback Collection & Analysis
- **Category**: Support
- **Priority**: High
- **Estimated Effort**: M (6 hours)
- **Assigned To**: Product Owner + QA Engineer
- **Dependencies**: LAUNCH-003
- **Description**: Collect and analyze initial user feedback
- **Acceptance Criteria**:
  - [ ] User feedback surveys deployed
  - [ ] Support ticket analysis and categorization
  - [ ] User behavior analytics review
  - [ ] Common issues identification and documentation
  - [ ] Feedback summary report for stakeholders
  - [ ] Priority issue list for immediate fixes

### Issue Resolution & Optimization
#### Task: FIX-001 - Critical Issue Resolution
- **Category**: Bug Fixes
- **Priority**: Critical
- **Estimated Effort**: Variable (as needed)
- **Assigned To**: Development Team
- **Dependencies**: Issues identified from launch
- **Description**: Rapid resolution of critical issues discovered during launch
- **Acceptance Criteria**:
  - [ ] Critical issues identified and prioritized
  - [ ] Hot fixes deployed within 2 hours for critical issues
  - [ ] User communication about known issues and resolutions
  - [ ] Issue tracking and status updates
  - [ ] Post-resolution testing and verification
  - [ ] Issue resolution documentation

### Launch Success Assessment
#### Task: ASSESS-001 - Launch Success Assessment
- **Category**: Assessment
- **Priority**: High
- **Estimated Effort**: S (4 hours)
- **Assigned To**: Product Owner + Tech Lead
- **Dependencies**: One week of launch data
- **Description**: Assess launch success against defined criteria
- **Acceptance Criteria**:
  - [ ] Launch metrics analysis and reporting
  - [ ] User adoption and retention measurement
  - [ ] Technical performance assessment
  - [ ] User satisfaction measurement
  - [ ] Support load and issue analysis
  - [ ] Success criteria achievement evaluation

### Sprint 8 Success Criteria
- [ ] Successful product launch executed
- [ ] All critical launch issues resolved
- [ ] User adoption targets met or exceeded
- [ ] System performance stable under real user load
- [ ] User feedback collected and analyzed
- [ ] Phase 1 officially completed and successful

---

## Phase Completion Assessment

### Phase 1 Success Metrics Review
At the end of Phase 1, evaluate success against these criteria:

#### Technical Success Metrics
- [ ] **Performance**: Page load times averaging <2 seconds
- [ ] **Reliability**: >99.9% uptime during first month
- [ ] **Security**: Zero critical security vulnerabilities
- [ ] **Quality**: <1% error rate across all user interactions
- [ ] **Scalability**: System handles expected user load without degradation

#### User Success Metrics
- [ ] **User Adoption**: >70% of registered users complete onboarding
- [ ] **Feature Usage**: >80% of active users use both contacts and tasks
- [ ] **User Satisfaction**: >4.0/5.0 average user rating
- [ ] **User Retention**: >60% of users active after 30 days
- [ ] **Support Load**: <5% of users contact support

#### Business Success Metrics
- [ ] **Registration Target**: Achieve planned user registration numbers
- [ ] **User Engagement**: Average session duration meets targets
- [ ] **Feature Adoption**: Core features adopted by target percentages
- [ ] **Market Validation**: User feedback validates product-market fit

### Phase 1 Completion Checklist
- [ ] All user stories completed and accepted
- [ ] All acceptance criteria verified and documented
- [ ] Performance requirements met and sustained
- [ ] Security audit passed with no critical issues
- [ ] User documentation complete and accessible
- [ ] Technical documentation complete and current
- [ ] Support systems operational and team trained
- [ ] Monitoring and alerting systems functional
- [ ] User feedback collected and analyzed
- [ ] Success metrics achieved or on clear trajectory
- [ ] Phase 2 prerequisites identified and planned
- [ ] Team retrospective completed with lessons learned

### Transition to Phase 2
Upon successful completion of Phase 1:
- [ ] Phase 1 completion report generated
- [ ] User feedback prioritized for Phase 2 planning
- [ ] Technical debt documented and prioritized
- [ ] Architecture decisions logged for future phases
- [ ] Team capacity planned for Phase 2
- [ ] Phase 2 specification reviewed and updated based on Phase 1 learnings

---

**Task Management Document Version**: 1.0  
**Created**: $(Get-Date -Format 'yyyy-MM-dd')  
**Last Updated**: $(Get-Date -Format 'yyyy-MM-dd')  
**Sprint Schedule**: 8 weeks total, 1-week sprints  
**Next Review**: Daily during sprint execution
"@

    try {
        $tasksContent | Out-File -FilePath "$phaseDir\tasks.md" -Encoding UTF8
        Write-ColorOutput "✅ Created $phaseDir\tasks.md" "Green"
    }
    catch {
        Write-ColorOutput "❌ Failed to create tasks.md: $($_.Exception.Message)" "Red"
        return
    }

    Write-ColorOutput "✅ Phase $PhaseNumber execution started successfully!" "Green"
    Write-ColorOutput "" "White"
    Write-ColorOutput "📋 Task breakdown created with 8 detailed sprints" "White"
    Write-ColorOutput "📝 Next steps:" "Yellow"
    Write-ColorOutput "   1. Review and customize sprint tasks in $phaseDir\tasks.md" "White"
    Write-ColorOutput "   2. Assign team members to specific tasks" "White"
    Write-ColorOutput "   3. Begin Sprint 1 with team planning meeting" "White"
    Write-ColorOutput "   4. Use Claude Code for individual task implementation:" "White"
    Write-ColorOutput "      claude-code implement 'Build the authentication framework following Phase $PhaseNumber specifications'" "Gray"
}

function Complete-Phase {
    param(
        [Parameter(Mandatory=$true)]
        [string]$PhaseNumber
    )
    
    Write-ColorOutput "🎯 Completing Phase $PhaseNumber..." "Cyan"
    
    $phaseDir = "docs\phases\phase-$PhaseNumber"
    
    # Validate that phase files exist
    $requiredFiles = @(
        "$phaseDir\spec.md",
        "$phaseDir\plan.md",
        "$phaseDir\tasks.md"
    )
    
    $missingFiles = @()
    foreach ($file in $requiredFiles) {
        if (-not (Test-Path $file)) {
            $missingFiles += $file
        }
    }
    
    if ($missingFiles.Count -gt 0) {
        Write-ColorOutput "❌ Missing required phase files:" "Red"
        foreach ($file in $missingFiles) {
            Write-ColorOutput "   • $file" "Red"
        }
        Write-ColorOutput "💡 Complete phase development first" "Yellow"
        return
    }

    Write-ColorOutput "📊 Generating Phase $PhaseNumber completion report..." "Yellow"
    
    $completionReportContent = @"
# Phase $PhaseNumber Completion Report

## Executive Summary
**Phase**: $PhaseNumber
**Completion Date**: $(Get-Date -Format 'yyyy-MM-dd')
**Status**: ✅ Completed
**Overall Success**: [Success Rating: Excellent / Good / Satisfactory / Needs Improvement]
**Duration**: [Actual duration vs planned]
**Team Size**: [Number of team members]
**Total Effort**: [Actual hours/story points vs estimated]

## Phase Objectives Achievement

### Primary Objectives Assessment
- [ ] **Objective 1**: [Original objective] 
  - **Status**: ✅ Fully Achieved / ⚠️ Partially Achieved / ❌ Not Met
  - **Evidence**: [Specific evidence of achievement]
  - **Impact**: [Business impact and user value delivered]

- [ ] **Objective 2**: [Original objective]
  - **Status**: ✅ Fully Achieved / ⚠️ Partially Achieved / ❌ Not Met
  - **Evidence**: [Specific evidence of achievement]
  - **Impact**: [Business impact and user value delivered]

- [ ] **Objective 3**: [Original objective]
  - **Status**: ✅ Fully Achieved / ⚠️ Partially Achieved / ❌ Not Met
  - **Evidence**: [Specific evidence of achievement]
  - **Impact**: [Business impact and user value delivered]

### Success Metrics Results
#### User Engagement Metrics
- **User Adoption Rate**: [Actual]% vs [Target]% - ✅/⚠️/❌
- **Feature Usage Rate**: [Actual]% vs [Target]% - ✅/⚠️/❌
- **User Retention (30-day)**: [Actual]% vs [Target]% - ✅/⚠️/❌
- **Average Session Duration**: [Actual] minutes vs [Target] minutes - ✅/⚠️/❌

#### Technical Performance Metrics
- **Page Load Time**: [Actual]s vs <2s target - ✅/⚠️/❌
- **API Response Time**: [Actual]ms vs <500ms target - ✅/⚠️/❌
- **System Uptime**: [Actual]% vs >99.9% target - ✅/⚠️/❌
- **Error Rate**: [Actual]% vs <1% target - ✅/⚠️/❌

#### Business Metrics
- **User Registrations**: [Actual] vs [Target] - ✅/⚠️/❌
- **User Satisfaction Score**: [Actual]/5.0 vs >4.0 target - ✅/⚠️/❌
- **Support Ticket Rate**: [Actual]% vs <5% target - ✅/⚠️/❌
- **Feature Adoption**: Core features used by [Actual]% vs >80% target - ✅/⚠️/❌

## Deliverables Completion Status

### Functional Deliverables
#### User Authentication System
- ✅ **User Registration**: Email/password registration with email verification
- ✅ **User Login**: Secure login with JWT token management
- ✅ **Password Reset**: Complete password reset flow with email verification
- ✅ **User Profile**: Profile management and settings
- **Completion**: 100% - All authentication features fully functional

#### Contact Management System
- ✅ **Contact CRUD**: Create, read, update, delete contacts
- ✅ **Contact Search**: Search and filter contacts by various criteria
- ✅ **Contact Categories**: Organize contacts with categories and tags
- ✅ **Contact Import**: CSV import with duplicate detection
- **Completion**: 100% - All contact management features operational

#### Task Management System
- ✅ **Task CRUD**: Create, read, update, delete tasks with full functionality
- ✅ **Task Organization**: Categories, priorities, due dates, and status tracking
- ✅ **Task-Contact Integration**: Link tasks to contacts with seamless workflow
- ✅ **Task Filtering**: Advanced filtering and sorting capabilities
- **Completion**: 100% - All task management features complete

#### User Interface & Experience
- ✅ **Responsive Design**: Mobile-first responsive interface across all features
- ✅ **Design System**: Consistent design token usage throughout application
- ✅ **Accessibility**: WCAG 2.1 AA compliance verified and tested
- ✅ **User Onboarding**: Complete onboarding flow with guided tour
- **Completion**: 100% - UI/UX meets all design and usability requirements

### Technical Deliverables
#### Backend Infrastructure
- ✅ **Database Schema**: Complete schema with proper relationships and indexing
- ✅ **API Endpoints**: All required endpoints implemented and documented
- ✅ **Authentication Security**: JWT-based security with proper token management
- ✅ **Data Validation**: Comprehensive input validation and sanitization
- **Completion**: 100% - Backend infrastructure production-ready

#### Frontend Application
- ✅ **Component Library**: Reusable component library based on design system
- ✅ **State Management**: Efficient state management for user data and UI state
- ✅ **Performance Optimization**: Bundle optimization and lazy loading implemented
- ✅ **Error Handling**: Comprehensive error handling and user feedback
- **Completion**: 100% - Frontend application fully implemented

#### DevOps & Infrastructure
- ✅ **Production Deployment**: Automated deployment pipeline functional
- ✅ **Monitoring & Alerting**: Comprehensive monitoring and alerting setup
- ✅ **Security Configuration**: Production security hardening completed
- ✅ **Backup & Recovery**: Backup procedures and disaster recovery tested
- **Completion**: 100% - Infrastructure production-ready and operational

### Quality Assurance Results
#### Testing Completion
- ✅ **Unit Testing**: 95% test coverage achieved (target: 80%)
- ✅ **Integration Testing**: All API endpoints and workflows tested
- ✅ **End-to-End Testing**: Complete user journeys automated and verified
- ✅ **Performance Testing**: Load testing completed with expected user volumes
- ✅ **Security Testing**: Security audit passed with no critical vulnerabilities
- ✅ **Accessibility Testing**: WCAG 2.1 AA compliance verified

#### Code Quality Metrics
- **Code Review Coverage**: 100% of code reviewed before merge
- **Bug Density**: [X] bugs per 1000 lines of code
- **Technical Debt**: [Low/Medium/High] - documented and prioritized
- **Documentation Coverage**: 100% of public APIs documented

## Challenges Encountered & Resolutions

### Major Challenges
#### Challenge 1: [Challenge Description]
- **Impact**: [How this affected timeline, quality, or team]
- **Root Cause**: [Analysis of why this challenge occurred]
- **Resolution**: [How the challenge was addressed]
- **Timeline Impact**: [Delay caused and mitigation]
- **Lessons Learned**: [What the team learned from this challenge]
- **Prevention Strategy**: [How to avoid similar issues in future phases]

#### Challenge 2: [Challenge Description]
- **Impact**: [How this affected timeline, quality, or team]
- **Root Cause**: [Analysis of why this challenge occurred]
- **Resolution**: [How the challenge was addressed]
- **Timeline Impact**: [Delay caused and mitigation]
- **Lessons Learned**: [What the team learned from this challenge]
- **Prevention Strategy**: [How to avoid similar issues in future phases]

#### Challenge 3: [Challenge Description]
- **Impact**: [How this affected timeline, quality, or team]
- **Root Cause**: [Analysis of why this challenge occurred]
- **Resolution**: [How the challenge was addressed]
- **Timeline Impact**: [Delay caused and mitigation]
- **Lessons Learned**: [What the team learned from this challenge]
- **Prevention Strategy**: [How to avoid similar issues in future phases]

### Technical Debt Accumulated
#### High-Priority Technical Debt
- **Item 1**: [Description and business impact]
  - **Estimated Effort**: [Time to resolve]
  - **Recommended Timeline**: [When this should be addressed]
  - **Risk Level**: High/Medium/Low

- **Item 2**: [Description and business impact]
  - **Estimated Effort**: [Time to resolve]
  - **Recommended Timeline**: [When this should be addressed]
  - **Risk Level**: High/Medium/Low

#### Medium-Priority Technical Debt
- [List medium-priority technical debt items with similar detail]

### Risk Management Outcomes
#### Risks That Materialized
- **Risk**: [Original risk identified]
  - **Impact**: [Actual impact when it occurred]
  - **Mitigation Effectiveness**: [How well mitigation worked]
  - **Lessons**: [What was learned about risk management]

#### Risks Successfully Mitigated
- **Risk**: [Original risk identified]
  - **Mitigation**: [How it was prevented]
  - **Outcome**: [Successful prevention outcome]

## Team Performance Analysis

### Team Velocity & Productivity
- **Planned Story Points**: [Original estimate]
- **Completed Story Points**: [Actual completion]
- **Velocity**: [Average story points per sprint]
- **Productivity Trend**: [Increasing/Stable/Decreasing with explanation]
- **Team Efficiency Rating**: [Excellent/Good/Satisfactory/Needs Improvement]

### Individual Contributions & Recognition
#### Outstanding Contributions
- **[Team Member Name]**: [Specific contributions and impact]
- **[Team Member Name]**: [Specific contributions and impact]
- **[Team Member Name]**: [Specific contributions and impact]

#### Areas for Growth Identified
- **[Area]**: [Team-wide growth opportunity with development plan]
- **[Area]**: [Team-wide growth opportunity with development plan]

### Team Collaboration Assessment
- **Communication Effectiveness**: [Rating and observations]
- **Conflict Resolution**: [How well team handled disagreements]
- **Knowledge Sharing**: [Assessment of knowledge transfer and documentation]
- **Cross-functional Collaboration**: [How well different roles worked together]

### Process Effectiveness
#### What Worked Well
- **Daily Standups**: [Effectiveness and team feedback]
- **Sprint Planning**: [Quality of planning and estimation accuracy]
- **Code Reviews**: [Process effectiveness and quality improvement]
- **Testing Process**: [Quality assurance process effectiveness]

#### Areas for Process Improvement
- **[Process Area]**: [Specific improvement needed and proposed solution]
- **[Process Area]**: [Specific improvement needed and proposed solution]

## User Feedback & Market Validation

### User Acceptance Testing Results
- **Participants**: [Number of users who participated in testing]
- **Completion Rate**: [Percentage who completed testing scenarios]
- **Overall Satisfaction**: [Average rating and distribution]
- **Task Completion Success**: [Percentage who successfully completed core tasks]

### User Feedback Themes
#### Positive Feedback
- **[Theme 1]**: [Summary of positive feedback with quotes]
- **[Theme 2]**: [Summary of positive feedback with quotes]
- **[Theme 3]**: [Summary of positive feedback with quotes]

#### Areas for Improvement
- **[Theme 1]**: [User-requested improvements with priority assessment]
- **[Theme 2]**: [User-requested improvements with priority assessment]
- **[Theme 3]**: [User-requested improvements with priority assessment]

#### Feature Requests for Future Phases
- **High Priority**: [Features users most want to see next]
- **Medium Priority**: [Features that would add value]
- **Nice to Have**: [Features mentioned but not critical]

### Usage Analytics (First 30 Days)
#### User Behavior Metrics
- **Daily Active Users**: [Number and trend]
- **Weekly Active Users**: [Number and retention rate]
- **Monthly Active Users**: [Number and growth rate]
- **Average Session Duration**: [Time and engagement level]
- **Pages/Actions per Session**: [User engagement depth]

#### Feature Usage Statistics
- **Most Used Features**: [Ranking of features by usage frequency]
- **Feature Adoption Rate**: [How quickly users adopt each feature]
- **User Journey Analysis**: [Common paths through the application]
- **Drop-off Points**: [Where users commonly leave or encounter issues]

## Business Impact Assessment

### Key Business Achievements
#### User Acquisition & Growth
- **Total Registrations**: [Number achieved vs target]
- **User Acquisition Cost**: [If applicable and measurable]
- **Organic Growth Rate**: [User referrals and word-of-mouth]
- **Market Penetration**: [Market share or reach achieved]

#### User Engagement & Retention
- **User Onboarding Success**: [Percentage completing onboarding]
- **Feature Adoption**: [Percentage of users using core features]
- **User Retention Rates**: [7-day, 30-day retention percentages]
- **User Satisfaction Score**: [NPS or CSAT scores]

#### Revenue Impact (if applicable)
- **Direct Revenue**: [Any direct monetization achieved]
- **Cost Savings**: [Operational efficiencies gained]
- **Value Creation**: [Long-term value building indicators]

### Market Validation Results
#### Product-Market Fit Indicators
- **User Retention**: [Strong retention indicates fit]
- **User Engagement**: [Deep engagement with core features]
- **User Feedback**: [Enthusiastic user response and referrals]
- **Market Demand**: [Interest from target market segments]

#### Competitive Positioning
- **Unique Value Proposition**: [How users perceive our differentiation]
- **Competitive Advantages**: [Features or experience advantages identified]
- **Market Response**: [Industry or competitor reaction to launch]

## Financial Performance

### Budget Performance
- **Total Budget**: [$X planned vs $Y actual]
- **Development Costs**: [Personnel, tools, services]
- **Infrastructure Costs**: [Hosting, third-party services, monitoring]
- **Marketing/Launch Costs**: [User acquisition and launch expenses]
- **Variance Analysis**: [Where budget differed from plan and why]

### Return on Investment
- **Development Investment**: [Total cost of Phase 1]
- **Value Created**: [User value, market positioning, capability building]
- **Future Value Potential**: [Platform for Phase 2 and beyond]
- **ROI Assessment**: [Quantitative and qualitative ROI analysis]

## Lessons Learned & Knowledge Capture

### Technical Lessons
#### Architecture & Design
- **[Lesson 1]**: [What was learned about system architecture]
- **[Lesson 2]**: [What was learned about API design]
- **[Lesson 3]**: [What was learned about database design]
- **[Lesson 4]**: [What was learned about frontend architecture]

#### Development Process
- **[Lesson 1]**: [What was learned about development workflow]
- **[Lesson 2]**: [What was learned about testing strategy]
- **[Lesson 3]**: [What was learned about deployment process]

### Product & User Experience Lessons
#### User Needs & Behavior
- **[Lesson 1]**: [What was learned about user needs]
- **[Lesson 2]**: [What was learned about user behavior]
- **[Lesson 3]**: [What was learned about user onboarding]

#### Product Strategy
- **[Lesson 1]**: [What was learned about product positioning]
- **[Lesson 2]**: [What was learned about feature prioritization]
- **[Lesson 3]**: [What was learned about market validation]

### Team & Process Lessons
#### Team Dynamics
- **[Lesson 1]**: [What was learned about team collaboration]
- **[Lesson 2]**: [What was learned about communication]
- **[Lesson 3]**: [What was learned about remote/distributed work]

#### Project Management
- **[Lesson 1]**: [What was learned about estimation and planning]
- **[Lesson 2]**: [What was learned about risk management]
- **[Lesson 3]**: [What was learned about stakeholder management]

## Recommendations for Future Phases

### Immediate Recommendations (Phase 2)
#### High-Priority Features
1. **[Feature Name]**: [Why this should be prioritized and expected impact]
2. **[Feature Name]**: [Why this should be prioritized and expected impact]
3. **[Feature Name]**: [Why this should be prioritized and expected impact]

#### Technical Improvements
1. **[Improvement]**: [Technical debt or enhancement needed]
2. **[Improvement]**: [Performance or scalability enhancement]
3. **[Improvement]**: [Security or reliability improvement]

### Process & Team Recommendations
#### Development Process
- **[Recommendation 1]**: [Process improvement with expected benefit]
- **[Recommendation 2]**: [Tool or workflow enhancement]
- **[Recommendation 3]**: [Quality assurance improvement]

#### Team Development
- **[Recommendation 1]**: [Team skill development or resource need]
- **[Recommendation 2]**: [Team structure or role optimization]

### Strategic Recommendations
#### Product Strategy
- **[Recommendation 1]**: [Strategic product direction based on learnings]
- **[Recommendation 2]**: [Market positioning or competitive strategy]

#### Business Strategy
- **[Recommendation 1]**: [Business model or monetization consideration]
- **[Recommendation 2]**: [Market expansion or user growth strategy]

## Phase 2 Preparation & Dependencies

### Phase 2 Prerequisites Satisfied
- [ ] **Technical Foundation**: Phase 1 system stable and scalable for Phase 2 features
- [ ] **User Base**: Sufficient user base and engagement for Phase 2 validation
- [ ] **Feedback Integration**: User feedback from Phase 1 incorporated into Phase 2 planning
- [ ] **Technical Debt**: Critical technical debt addressed or planned for resolution
- [ ] **Team Readiness**: Team prepared and available for Phase 2 development
- [ ] **Infrastructure**: Infrastructure can support Phase 2 feature load and complexity

### Phase 2 Planning Inputs
#### User Research Insights
- **Primary User Needs**: [Top user needs identified for Phase 2]
- **Feature Requests**: [Most requested features from user feedback]
- **Usage Patterns**: [Insights from Phase 1 usage that inform Phase 2]

#### Technical Considerations
- **Scalability Requirements**: [Expected growth and technical needs for Phase 2]
- **Integration Points**: [How Phase 2 features will integrate with Phase 1]
- **Performance Considerations**: [Performance impact and optimization needs]

#### Resource Requirements
- **Team Composition**: [Recommended team structure for Phase 2]
- **Timeline Estimate**: [Preliminary Phase 2 timeline based on Phase 1 learnings]
- **Budget Considerations**: [Cost implications and resource needs for Phase 2]

## Risk Assessment for Future Development

### Technical Risks
- **[Risk 1]**: [Potential technical challenge for Phase 2]
  - **Impact**: High/Medium/Low
  - **Mitigation**: [Recommended prevention strategy]
  
- **[Risk 2]**: [Potential technical challenge for Phase 2]
  - **Impact**: High/Medium/Low
  - **Mitigation**: [Recommended prevention strategy]

### Business Risks
- **[Risk 1]**: [Potential business or market risk]
  - **Impact**: High/Medium/Low
  - **Mitigation**: [Recommended prevention strategy]

### Team & Process Risks
- **[Risk 1]**: [Potential team or process risk]
  - **Impact**: High/Medium/Low
  - **Mitigation**: [Recommended prevention strategy]

## Conclusion & Final Assessment

### Overall Phase Success
**Phase 1 Success Rating**: [Excellent / Good / Satisfactory / Needs Improvement]

**Rationale**: [Detailed explanation of success rating based on objectives achievement, user feedback, technical quality, and business impact]

### Key Achievements Summary
1. **[Achievement 1]**: [Major accomplishment and its significance]
2. **[Achievement 2]**: [Major accomplishment and its significance]  
3. **[Achievement 3]**: [Major accomplishment and its significance]

### Critical Success Factors
- **[Factor 1]**: [What made this phase successful]
- **[Factor 2]**: [What contributed most to achieving objectives]
- **[Factor 3]**: [Key decisions or actions that drove success]

### Foundation for Future Success
**Phase 1 as Foundation**: [How Phase 1 creates a strong foundation for future phases and long-term product success]

**Market Position**: [How Phase 1 establishes market position and user base for growth]

**Technical Platform**: [How the technical foundation supports future feature development and scaling]

### Next Steps & Immediate Actions
#### Immediate Actions (Next 2 Weeks)
1. **[Action 1]**: [Immediate follow-up action with owner and timeline]
2. **[Action 2]**: [Immediate follow-up action with owner and timeline]
3. **[Action 3]**: [Immediate follow-up action with owner and timeline]

#### Phase 2 Kickoff Preparation (Next 4 Weeks)
1. **[Action 1]**: [Phase 2 preparation activity]
2. **[Action 2]**: [Phase 2 preparation activity]
3. **[Action 3]**: [Phase 2 preparation activity]

### Stakeholder Communication
#### Success Celebration
- **Team Recognition**: [Plan for celebrating team achievements]
- **Stakeholder Communication**: [How success will be communicated to stakeholders]
- **User Community**: [How to celebrate with and thank user community]

#### Continuous Improvement
- **Feedback Integration**: [How feedback will be continuously collected and used]
- **Process Evolution**: [How development process will evolve based on learnings]
- **Knowledge Sharing**: [How lessons learned will be shared across organization]

---

**Report Prepared By**: [Name and Role]
**Report Review Date**: $(Get-Date -Format 'yyyy-MM-dd')
**Report Approval**: [Stakeholder approval signatures and dates]
**Next Phase Start**: [Planned Phase 2 start date]
**Archive Location**: [Where this report will be stored for future reference]

### Document Distribution
- [ ] Product Owner
- [ ] Development Team  
- [ ] Stakeholders
- [ ] Executive Leadership
- [ ] User Research Team
- [ ] Customer Success Team
- [ ] Archive/Knowledge Base

---
**Report Version**: 1.0
**Classification**: Internal Use
**Retention**: Keep for full product lifecycle
"@

    try {
        $completionReportContent | Out-File -FilePath "$phaseDir\completion-report.md" -Encoding UTF8
        Write-ColorOutput "✅ Created $phaseDir\completion-report.md" "Green"
    }
    catch {
        Write-ColorOutput "❌ Failed to create completion-report.md: $($_.Exception.Message)" "Red"
        return
    }

    Write-ColorOutput "✅ Phase $PhaseNumber completion report generated!" "Green"
    Write-ColorOutput "" "White"
    Write-ColorOutput "🎉 Phase $PhaseNumber officially completed!" "Green"
    Write-ColorOutput "" "White"
    Write-ColorOutput "📊 Completion report created at $phaseDir\completion-report.md" "White"
    Write-ColorOutput "📝 Next steps:" "Yellow"
    Write-ColorOutput "   1. Fill out the completion report with actual results and metrics" "White"
    Write-ColorOutput "   2. Conduct team retrospective and capture lessons learned" "White"
    Write-ColorOutput "   3. Plan Phase 2 based on Phase 1 learnings and user feedback" "White"
    Write-ColorOutput "   4. Celebrate the team's success! 🎊" "White"
}

function Show-PhaseStatus {
    Write-ColorOutput "📊 Phase Development Status Report" "Cyan"
    Write-ColorOutput "=================================" "Cyan"

    # Check if phases directory exists
    if (-not (Test-Path "docs\phases")) {
        Write-ColorOutput "❌ No phase management setup found." "Red"
        Write-ColorOutput "💡 Run: .\manage-phases.ps1 -Action init-roadmap" "Yellow"
        return
    }

    # Get all phase directories
    $phases = Get-ChildItem "docs\phases" -Directory | Sort-Object { [int]($_.Name -replace "phase-", "") }

    if ($phases.Count -eq 0) {
        Write-ColorOutput "📋 No phases created yet." "Yellow"
        Write-ColorOutput "💡 Run: .\manage-phases.ps1 -Action create-phase -PhaseNumber 1" "Yellow"
        return
    }

    Write-ColorOutput "📈 Found $($phases.Count) phase(s) in development:" "White"
    Write-ColorOutput "" "White"

    foreach ($phase in $phases) {
        $phaseNumber = $phase.Name -replace "phase-", ""
        $hasSpec = Test-Path "$($phase.FullName)\spec.md"
        $hasPlan = Test-Path "$($phase.FullName)\plan.md"
        $hasTasks = Test-Path "$($phase.FullName)\tasks.md"
        $hasCompletion = Test-Path "$($phase.FullName)\completion-report.md"

        # Determine phase status
        $status = if ($hasCompletion) { 
            "✅ Completed" 
        } elseif ($hasTasks) { 
            "🚀 In Progress" 
        } elseif ($hasPlan) { 
            "📋 Planned" 
        } elseif ($hasSpec) { 
            "📝 Specified" 
        } else { 
            "❓ Incomplete Setup" 
        }

        # Determine status color
        $statusColor = if ($hasCompletion) { 
            "Green" 
        } elseif ($hasTasks) { 
            "Yellow" 
        } else { 
            "White" 
        }

        Write-ColorOutput "Phase $phaseNumber : $status" $statusColor
        Write-ColorOutput "  📋 Specification: $(if ($hasSpec) { '✅ Complete' } else { '❌ Missing' })" "White"
        Write-ColorOutput "  📊 Plan: $(if ($hasPlan) { '✅ Complete' } else { '❌ Missing' })" "White"
        Write-ColorOutput "  📝 Tasks: $(if ($hasTasks) { '✅ Complete' } else { '❌ Missing' })" "White"
        Write-ColorOutput "  🎯 Completion: $(if ($hasCompletion) { '✅ Complete' } else { '❌ Missing' })" "White"
        
        # Show additional details if available
        if ($hasSpec) {
            try {
                $specContent = Get-Content "$($phase.FullName)\spec.md" -Raw -ErrorAction SilentlyContinue
                if ($specContent -and $specContent -match "Phase Name\*\*: (.+)") {
                    $phaseName = $matches[1].Trim()
                    Write-ColorOutput "  📌 Name: $phaseName" "Gray"
                }
            }
            catch {
                # Ignore errors reading spec file
            }
        }
        
        Write-ColorOutput "" "White"
    }

    # Calculate summary statistics
    $totalPhases = $phases.Count
    $completedPhases = ($phases | Where-Object { Test-Path "$($_.FullName)\completion-report.md" }).Count
    $inProgressPhases = ($phases | Where-Object { 
        (Test-Path "$($_.FullName)\tasks.md") -and 
        -not (Test-Path "$($_.FullName)\completion-report.md") 
    }).Count
    $plannedPhases = ($phases | Where-Object { 
        (Test-Path "$($_.FullName)\plan.md") -and 
        -not (Test-Path "$($_.FullName)\tasks.md") -and
        -not (Test-Path "$($_.FullName)\completion-report.md")
    }).Count
    $specifiedPhases = ($phases | Where-Object { 
        (Test-Path "$($_.FullName)\spec.md") -and 
        -not (Test-Path "$($_.FullName)\plan.md") -and
        -not (Test-Path "$($_.FullName)\completion-report.md")
    }).Count

    Write-ColorOutput "📊 DEVELOPMENT PROGRESS SUMMARY" "Cyan"
    Write-ColorOutput "===============================" "Cyan"
    Write-ColorOutput "Total Phases: $totalPhases" "White"
    Write-ColorOutput "✅ Completed: $completedPhases" "Green"
    Write-ColorOutput "🚀 In Progress: $inProgressPhases" "Yellow"
    Write-ColorOutput "📋 Planned: $plannedPhases" "Blue"
    Write-ColorOutput "📝 Specified Only: $specifiedPhases" "Magenta"
    Write-ColorOutput "❓ Incomplete: $($totalPhases - $completedPhases - $inProgressPhases - $plannedPhases - $specifiedPhases)" "Red"

    # Calculate and show progress percentage
    $completionPercentage = if ($totalPhases -gt 0) { 
        [math]::Round(($completedPhases / $totalPhases) * 100, 1) 
    } else { 
        0 
    }
    
    Write-ColorOutput "" "White"
    Write-ColorOutput "📈 Overall Progress: $completionPercentage% Complete" $(if ($completionPercentage -ge 50) { "Green" } elseif ($completionPercentage -ge 25) { "Yellow" } else { "Red" })

    # Show roadmap status if available
    if (Test-Path "docs\phase-roadmap.md") {
        Write-ColorOutput "📋 Phase roadmap available at docs\phase-roadmap.md" "Gray"
    }
    
    if (Test-Path "docs\product-vision.md") {
        Write-ColorOutput "🎯 Product vision available at docs\product-vision.md" "Gray"
    }

    # Provide helpful next steps
    Write-ColorOutput "" "White"
    Write-ColorOutput "💡 Suggested Next Actions:" "Yellow"
    
    if ($totalPhases -eq 0) {
        Write-ColorOutput "   1. Run: .\manage-phases.ps1 -Action create-phase -PhaseNumber 1" "White"
    }
    elseif ($inProgressPhases -eq 0 -and $completedPhases -lt $totalPhases) {
        $nextPhase = ($phases | Where-Object { 
            -not (Test-Path "$($_.FullName)\completion-report.md") 
        } | Sort-Object { [int]($_.Name -replace "phase-", "") } | Select-Object -First 1)
        
        if ($nextPhase) {
            $nextPhaseNumber = $nextPhase.Name -replace "phase-", ""
            if (-not (Test-Path "$($nextPhase.FullName)\tasks.md")) {
                if (Test-Path "$($nextPhase.FullName)\plan.md") {
                    Write-ColorOutput "   1. Start Phase $nextPhaseNumber: .\manage-phases.ps1 -Action start-phase -PhaseNumber $nextPhaseNumber" "White"
                }
                elseif (Test-Path "$($nextPhase.FullName)\spec.md") {
                    Write-ColorOutput "   1. Plan Phase $nextPhaseNumber: .\manage-phases.ps1 -Action plan-phase -PhaseNumber $nextPhaseNumber" "White"
                }
            }
        }
    }
    elseif ($completedPhases -lt $totalPhases) {
        Write-ColorOutput "   1. Continue development on current phase(s)" "White"
        Write-ColorOutput "   2. Review progress and update task status" "White"
    }
    else {
        Write-ColorOutput "   1. Plan next phase based on completed phase learnings" "White"
        Write-ColorOutput "   2. Consider creating Phase $($totalPhases + 1) specification" "White"
    }
    
    Write-ColorOutput "   💬 Get status anytime: .\manage-phases.ps1 -Action status" "Gray"
}

# ==============================================================================
# MAIN EXECUTION LOGIC
# ==============================================================================

function Invoke-PhaseAction {
    param(
        [string]$Action,
        [string]$PhaseNumber,
        [string]$PhaseName,
        [bool]$Interactive
    )
    
    switch ($Action) {
        "init-roadmap" { 
            Initialize-ProductRoadmap 
        }
        "create-phase" { 
            if (-not $PhaseNumber) {
                do {
                    $PhaseNumber = Read-Host "Enter phase number (1, 2, 3, etc.)"
                } while (-not $PhaseNumber -or $PhaseNumber -notmatch '^\d+)
            }
            
            if ($Interactive -and -not $PhaseName) {
                $PhaseName = Read-Host "Enter phase name (optional, e.g., 'Foundation & Core Features')"
            }
            
            New-PhaseSpecification -PhaseNumber $PhaseNumber -PhaseName $PhaseName
        }
        "plan-phase" { 
            if (-not $PhaseNumber) {
                do {
                    $PhaseNumber = Read-Host "Enter phase number to create implementation plan for"
                } while (-not $PhaseNumber -or $PhaseNumber -notmatch '^\d+)
            }
            
            New-PhaseImplementationPlan -PhaseNumber $PhaseNumber
        }
        "start-phase" { 
            if (-not $PhaseNumber) {
                do {
                    $PhaseNumber = Read-Host "Enter phase number to start development for"
                } while (-not $PhaseNumber -or $PhaseNumber -notmatch '^\d+)
            }
            
            Start-PhaseExecution -PhaseNumber $PhaseNumber
        }
        "complete-phase" { 
            if (-not $PhaseNumber) {
                do {
                    $PhaseNumber = Read-Host "Enter phase number to mark as complete"
                } while (-not $PhaseNumber -or $PhaseNumber -notmatch '^\d+)
            }
            
            Complete-Phase -PhaseNumber $PhaseNumber
        }
        "status" { 
            Show-PhaseStatus 
        }
        default {
            Write-ColorOutput "❌ Unknown action: $Action" "Red"
            Write-ColorOutput "Valid actions: init-roadmap, create-phase, plan-phase, start-phase, complete-phase, status" "Yellow"
        }
    }
}

# Execute the main function with provided parameters
try {
    Invoke-PhaseAction -Action $Action -PhaseNumber $PhaseNumber -PhaseName $PhaseName -Interactive $Interactive
}
catch {
    Write-ColorOutput "❌ Error executing action '$Action': $($_.Exception.Message)" "Red"
    Write-ColorOutput "💡 Please check the error details above and try again" "Yellow"
    exit 1
}

# ==============================================================================
# SCRIPT COMPLETION
# ==============================================================================

Write-ColorOutput "" "White"
Write-ColorOutput "✅ manage-phases.ps1 execution completed successfully!" "Green"