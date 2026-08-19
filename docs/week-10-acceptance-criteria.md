# Week 10 Acceptance Criteria

This document tracks the requirements for Week 10 completion. Each item below must be verified before moving to Week 11.

## Architecture and Planning

- [ ] Architecture decision record created (`week-10/architecture-decision.md`)
- [ ] ML task chosen: Severity classifier OR Time-to-resolution predictor
- [ ] Feature set defined from incidents table
- [ ] Model library specified (scikit-learn with specific estimator)
- [ ] Metrics to track identified (accuracy, MAE, RMSE, F1, etc.)
- [ ] MLflow deployment details documented (port, backend, artifact store)
- [ ] FastAPI deployment details documented (port, request/response format)
- [ ] Flask integration approach documented

## Backlog Definition

- [ ] Week 11 backlog created (`week-11/backlog.md`) with estimated stories
- [ ] Week 12 backlog created (`week-12/backlog.md`) with estimated stories
- [ ] Each story has assigned owner or pair
- [ ] Story points estimated (should total 20-30 points per week)
- [ ] Dependencies between stories identified

## Ansible Setup

- [ ] `ansible/roles/mlflow/` directory created
- [ ] `ansible/roles/mlflow/tasks/main.yml` exists
- [ ] `ansible/roles/mlflow/defaults/main.yml` exists
- [ ] `ansible/roles/mlflow/handlers/main.yml` exists
- [ ] `ansible/roles/mlflow/vars/main.yml` exists
- [ ] `ansible/roles/mlflow/templates/` directory exists (empty for now)

## Documentation Structure

- [ ] `docs/environment-log.md` template created
- [ ] `docs/week-10-acceptance-criteria.md` created (this file)
- [ ] `docs/week-11-acceptance-criteria.md` created
- [ ] `docs/week-12-acceptance-criteria.md` created
- [ ] `docs/week-13-acceptance-criteria.md` created
- [ ] `docs/week-14-acceptance-criteria.md` created
- [ ] `docs/sprint-5-retrospective.md` template created
- [ ] `docs/sprint-6-retrospective.md` template created
- [ ] `docs/sprint-7-retrospective.md` template created
- [ ] `docs/qa-report-5.md` template created (or similar naming)

## Git Repository

- [ ] Repository initialized as git (`.git/` directory exists)
- [ ] `.gitignore` file created with appropriate entries
- [ ] All Week 10 files committed
- [ ] Commit messages are descriptive
- [ ] No uncommitted changes
- [ ] `git log` shows Week 10 commits

## Sprint 5 Retrospective

- [ ] `docs/sprint-5-retrospective.md` filled in
- [ ] All team members contributed answers
- [ ] Sprint close checklist completed
- [ ] Handoff notes for Sprint 6 documented

## Team Coordination

- [ ] Team roles assigned for Weeks 11-12
- [ ] Tech Lead identified for MLflow/Ansible
- [ ] Backend Engineer identified for FastAPI/Flask
- [ ] Data/ML role identified for model training
- [ ] QA/Ops role identified for testing/verification
- [ ] Team communication norms established

## Risk and Assumptions

- [ ] Risks documented (data quality, model performance, deployment, integration)
- [ ] Mitigations planned for each risk
- [ ] Assumptions documented (PostgreSQL access, Python environment, container privileges)
- [ ] Unknowns flagged for resolution in Week 11

## Verification

Run the Week 10 validation script:

```bash
./scripts/check-week-10.sh
```

Expected output: All checks should pass.

## Sign-Off

- [ ] Tech Lead approved architecture decision
- [ ] QA Lead approved acceptance criteria
- [ ] All team members ready for Week 11 kickoff
- [ ] No blockers or dependencies preventing Week 11 start

## Notes

[Document any deviations from the standard plan or special circumstances]
