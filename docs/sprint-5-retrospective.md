# Sprint 5 Retrospective

**Sprint Dates:** [Week 10 start date] to [Week 10 end date]

**Sprint Focus:** Challenge Track Kickoff - Machine Learning and AI Architecture and Planning

## Sprint Close: What Was Completed

**Completed Items:**

- [ ] Architecture decision recorded (ML task, features, model type)
- [ ] Week 11 backlog estimated and populated
- [ ] Week 12 backlog estimated and populated
- [ ] Team roles assigned for challenge track
- [ ] Ansible role directory structure created
- [ ] All acceptance criteria documents initialized
- [ ] Risk assessment and mitigation planning completed
- [ ] Database schema and data quality verified

**Incomplete Items:**

[List any items that did not finish, with one-sentence notes on why]

## Team Reflection Questions

Answer these as a team during the Sprint Review (Week 10 closing session). Record in this file:

### 1. What did you contribute to Sprint 5?

Each team member should briefly state their contributions:

- **[Team Member 1 Name]:** [Your contributions - e.g., "Led architecture decision discussion, documented ML task choice"]
- **[Team Member 2 Name]:** [Your contributions - e.g., "Estimated Week 11-12 backlog, created Ansible role structure"]
- **[Team Member 3 Name]:** [Your contributions - e.g., "Verified PostgreSQL data quality, identified risks"]
- **[Team Member 4 Name - optional]:** [Your contributions - e.g., "Researched FastAPI and MLflow best practices, suggested implementation approach"]

### 2. What is the most important thing the team shipped in Sprint 5?

[Team consensus - typically: "A clear, documented architecture and detailed backlog that gives us confidence moving into Weeks 11-12"]

### 3. What would you do differently if Sprint 5 started again?

[Team reflection on process improvements - e.g., "We would have created the Ansible role structure earlier in the week to give ourselves more time for questions", or "We would have done a quick proof-of-concept with MLflow and FastAPI before finalizing the architecture"]

## Detailed Team Reflection

### Architecture Confidence

**On a scale of 1-5, how confident is the team in the chosen architecture?**

Rating: [1-5]

Reasoning: [Why this rating? Any concerns?]

### Data Quality Assessment

**What did we learn about the incident data that will affect our ML approach?**

- Data observation 1: [e.g., "Only 40 incidents in database, may need synthetic data"]
- Data observation 2: [e.g., "Severity field has null values, may need imputation strategy"]
- Data observation 3: [e.g., "Time-to-resolution varies widely (1 hour to 30 days), may affect prediction difficulty"]

### Risk Assessment

**Top 3 risks identified and mitigation plans:**

1. **Risk:** [e.g., "Insufficient training data for accurate model"]
   - **Mitigation:** [e.g., "Generate synthetic incidents, use data augmentation, lower accuracy target"]

2. **Risk:** [e.g., "MLflow/FastAPI integration complexity"]
   - **Mitigation:** [e.g., "Start with simple endpoint, test early and often, pair programming on Flask integration"]

3. **Risk:** [e.g., "Ansible deployment challenges"]
   - **Mitigation:** [e.g., "Test playbook early, document all paths, prepare troubleshooting guide"]

### Assumptions Documented

**Critical assumptions for Weeks 11-12:**

1. Assumption: [e.g., "PostgreSQL connection string is correct and will remain stable"]
   - Verification plan: [e.g., "Test connection weekly"]

2. Assumption: [e.g., "Python 3.8+ with pip is available in container"]
   - Verification plan: [e.g., "Verify in first task of Week 11"]

3. Assumption: [e.g., "Container has internet access for pip install"]
   - Verification plan: [e.g., "Test pip install in Week 10"]

## Notes for Sprint 6

[Handoff information that Sprint 6 needs to know about. This should include:
- Any unknowns or dependencies preventing Week 11 start
- Critical decisions that team agreed on (model choice, feature selection, etc.)
- Recommended starting tasks for Week 11
- Any blockers that need instructor attention
]

**Example:**

"Sprint 6 (Weeks 11-12) is ready to start. Key decisions made:
- Using severity classifier as ML task (4 classes)
- Features: title + description (text) + severity category (numeric)
- Target accuracy: 85% or higher
- MLflow backend: file-based (simpler than PostgreSQL for now)
- FastAPI port: 8000 (default)

Week 11 should start with MLflow installation and configuration, then immediately move to data preparation and model training. Week 12 can proceed in parallel with FastAPI development while models are training.

No blockers identified. Team ready to proceed."

## Lessons Learned

### Technical Lessons

- Lesson 1: [e.g., "SQLAlchemy connection strings are finicky with special characters - document the exact format"]
- Lesson 2: [e.g., "scikit-learn RandomForest can be slow on large datasets - consider using ExtraTree for speed"]

### Process Lessons

- Lesson 1: [e.g., "Starting architecture design on paper before implementing would have saved time"]
- Lesson 2: [e.g., "Verifying data quality in Week 10 prevented Week 11 surprises"]

### Team Collaboration

- Observation 1: [e.g., "Strong collaboration on architecture decision - all voices heard"]
- Observation 2: [e.g., "Would benefit from more technical deep-dives on tool choices"]

## Sprint Metrics

- **Sprint Goal:** [Achieved / Partially Achieved / Not Achieved]
- **Planned vs Actual:** [Estimate how much work actually occurred vs estimated]
- **Team Velocity (if using story points):** [X points completed]
- **Quality:** [All acceptance criteria met / Some rework needed / Significant issues]

## Preparation for Demo Day (Looking Ahead)

**Actions to take in Weeks 11-14 to ensure successful Demo Day:**

- [ ] Test Ansible playbook early (Week 11)
- [ ] Create demo script by end of Week 12
- [ ] Rehearse demo in Week 13
- [ ] Document all decisions and implementations as you go
- [ ] Capture screenshots of MLflow UI and Flask integration
- [ ] Plan contingencies for potential technical failures

## Team Signature / Approval

**Sprint 5 Retrospective approved by:**

- **Tech Lead:** _____________________________ Date: _________
- **Backend Lead:** __________________________ Date: _________
- **ML/Data Lead:** _________________________ Date: _________
- **QA Lead:** ______________________________ Date: _________

---

**Sprint 5 Status:** CLOSED

Ready to move to Sprint 6 (Weeks 11-12) Core Build phase.
