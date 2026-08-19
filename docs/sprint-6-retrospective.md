# Sprint 6 Retrospective

**Sprint Dates:** [Week 11 start date] to [Week 12 end date]

**Sprint Focus:** Core Build - MLflow and Model Training (Week 11), FastAPI and Flask Integration (Week 12)

## Sprint Close: What Was Completed

**Completed Items:**

- [ ] MLflow tracking server installed and running
- [ ] Model trained on incident data and registered
- [ ] Model metrics logged to MLflow (accuracy, precision, recall, F1)
- [ ] FastAPI inference endpoint built and tested
- [ ] Flask application integrated with FastAPI
- [ ] Ansible role for MLflow created and tested
- [ ] End-to-end pipeline tested and verified
- [ ] Documentation updated with Week 11-12 progress
- [ ] Demo script started

**Incomplete Items:**

[List any items that did not finish, with one-sentence notes on why]

## Team Reflection Questions

Answer these as a team during the Sprint Review (end of Week 12). Record in this file:

### 1. What did you contribute to Sprint 6?

Each team member should briefly state their contributions:

- **[Team Member 1 Name]:** [Contributions - e.g., "Built and deployed MLflow server, created systemd service"]
- **[Team Member 2 Name]:** [Contributions - e.g., "Trained severity classifier model, logged metrics to MLflow"]
- **[Team Member 3 Name]:** [Contributions - e.g., "Built FastAPI inference endpoint, integrated with Flask"]
- **[Team Member 4 Name - optional]:** [Contributions - e.g., "Created Ansible role, tested playbook, wrote test scripts"]

### 2. What is the most important thing the team shipped in Sprint 6?

[Team consensus - typically: "A fully integrated ML pipeline that trains models, serves predictions, and integrates seamlessly with the existing Flask application"]

### 3. What would you do differently if Sprint 6 started again?

[Team reflection - e.g., "We would have created the FastAPI service earlier to avoid last-minute integration issues", or "We would have set up Ansible role development in parallel rather than sequentially"]

## Detailed Technical Reflection

### Week 11: MLflow and Model Training

**What went well:**
- [Success 1]
- [Success 2]

**Challenges encountered:**
- Challenge 1: [Description and how resolved]
- Challenge 2: [Description and how resolved]

**Model Performance:**
- Accuracy/MAE achieved: [Value]
- Target vs actual: [Were expectations met?]
- Model quality assessment: [Good / Acceptable / Needs improvement]

### Week 12: FastAPI and Flask Integration

**What went well:**
- [Success 1]
- [Success 2]

**Challenges encountered:**
- Challenge 1: [Description and how resolved]
- Challenge 2: [Description and how resolved]

**Integration Quality:**
- Flask-FastAPI latency: [XX ms]
- Error handling robustness: [Tested scenarios]
- User experience: [How does it feel in the UI?]

### Model Serving Performance

**Response times measured:**
- MLflow inference: [XX ms]
- FastAPI endpoint: [XX ms]
- Flask to FastAPI call: [XX ms]
- Total user-perceived latency: [XX ms]

**Acceptable?** YES / NO / NEEDS OPTIMIZATION

## Architecture Validation

**Did the architecture chosen in Week 10 hold up?**

- [ ] MLflow server deployment worked as expected
- [ ] Model training process was smooth (data → model → registry)
- [ ] FastAPI integration was easier/harder than expected (reason)
- [ ] Flask integration required changes to original design (describe)
- [ ] Ansible automation was straightforward / required iteration (describe)

**Any architectural changes recommended for Week 13 or future projects?**

[e.g., "Consider using PostgreSQL backend for MLflow if tracking more experiments", or "FastAPI request validation worked great - recommend for future Flask integration"]

## Risk Review

**Original risks from Sprint 5 - how did they play out?**

1. **Risk:** [Original risk from Sprint 5]
   - **Outcome:** [Actually occurred / Was avoided / Handled better than expected]
   - **What we learned:** [Lesson for future]

2. **Risk:** [Original risk from Sprint 5]
   - **Outcome:** [Actually occurred / Was avoided / Handled better than expected]
   - **What we learned:** [Lesson for future]

**New risks emerged in Sprint 6:**

1. **Risk:** [New risk discovered]
   - **Mitigation for Week 13-14:** [How we'll handle it]

## Sprint 6 Metrics

- **Week 11 Velocity:** [X points completed]
- **Week 12 Velocity:** [Y points completed]
- **Total Sprint 6 Velocity:** [X+Y points]
- **Quality:** [Defects, rework required, acceptance criteria met]
- **Team Morale:** High / Moderate / Low (explain)

## Lessons Learned in Sprint 6

### Technical Learnings

- **About MLflow:** [e.g., "MLflow's model registry makes version management trivial", "File backend worked fine for this scale"]
- **About FastAPI:** [e.g., "Pydantic validation is powerful", "Dependency injection in FastAPI is elegant"]
- **About Flask integration:** [e.g., "httpx timeouts prevent hanging requests", "Error handling from FastAPI in Flask needs explicit tests"]
- **About Ansible:** [e.g., "Systemd services are robust", "Template variables make configurations flexible"]

### Process Learnings

- **Better practices:** [e.g., "Testing integrations early saves time", "Documentation while coding prevents gaps"]
- **Avoid in future:** [e.g., "Don't wait until Week 12 to test Ansible playbook", "Don't skip edge case testing"]

### Team Collaboration

- **What worked:** [e.g., "Pair programming on FastAPI-Flask integration was efficient"]
- **What to improve:** [e.g., "More frequent code reviews would catch issues earlier"]

## Status of Demo Readiness

**By end of Sprint 6, are we demo-ready?**

Rating: READY / MOSTLY READY / NEEDS WORK

- [ ] MLflow UI accessible and shows trained model
- [ ] FastAPI endpoint responds to test requests
- [ ] Flask UI shows predictions (or logs them appropriately)
- [ ] Ansible playbook runs without errors
- [ ] All three services start after playbook

**Demo script started:** YES / NO

**What needs to happen in Sprint 7 to be fully demo-ready:**

1. [Task 1]
2. [Task 2]
3. [Task 3]

## Notes for Sprint 7 (Weeks 13-14)

[Handoff information for Sprint 7:
- Current status of each component
- Known issues or workarounds applied
- Recommended first tasks for Week 13
- Critical dependencies or assumptions
- Confidence level in Demo Day success
]

**Example:**

"Sprint 6 complete. All core components working:
- MLflow tracking and model serving: STABLE
- FastAPI inference: PERFORMANT (avg 45ms latency)
- Flask integration: FUNCTIONAL

Week 13 focus:
1. Finalize and rehearse demo script
2. Run Ansible playbook dry-run and fix any issues
3. Test edge cases (service failures, invalid input)
4. Capture screenshots for demo reference

Week 14 will:
1. Wipe container completely
2. Rebuild via Ansible from scratch
3. Retrain model
4. Execute demo for instructor

Confidence in Demo Day success: HIGH"

## Sprint 6 Sign-Off

**Sprint 6 Retrospective approved by:**

- **Tech Lead (Infrastructure):** _________________ Date: _______
- **Backend Lead (FastAPI/Flask):** ______________ Date: _______
- **ML/Data Lead (Model Training):** ____________ Date: _______
- **QA Lead (Testing/Verification):** ___________ Date: _______

---

**Sprint 6 Status:** CLOSED

All core deliverables complete. Ready to move to Sprint 7 (Weeks 13-14) Demo Preparation.
