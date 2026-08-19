# Week 11 Acceptance Criteria

This document tracks the requirements for Week 11 completion. Each item below must be verified before moving to Week 12.

## MLflow Tracking Server

- [ ] MLflow installed via pip
- [ ] MLflow server running on port 5001
- [ ] Health check endpoint responds: `curl http://localhost:5001/health`
- [ ] MLflow UI accessible in browser at `http://localhost:5001/`
- [ ] Backend storage configured (file-based or PostgreSQL)
- [ ] Artifact store configured and accessible
- [ ] Service is stable (verified by running for 30+ minutes without restart)

## Data Preparation

- [ ] PostgreSQL connection string tested and verified
- [ ] Incidents table queried successfully
- [ ] Data fetch script created (`week-11/fetch-incidents.py`)
- [ ] Data fetch script runs without errors
- [ ] Sample data verified for quality (no critical missing values)
- [ ] Feature set matches Week 10 architecture decision
- [ ] Train/test split implemented correctly (80/20 or similar)

## Model Training and Logging

- [ ] Training script created (`week-11/train-model.py`)
- [ ] Training script runs without errors
- [ ] Model trained successfully on incident data
- [ ] Model metrics logged to MLflow:
  - [ ] Accuracy (or RMSE if regression)
  - [ ] Precision (or MAE)
  - [ ] Recall (or R2)
  - [ ] F1 Score (or other relevant metric)
- [ ] Model artifacts saved (pickle, joblib, or sklearn format)
- [ ] MLflow experiment created with descriptive name
- [ ] Training run visible in MLflow UI

## Model Registration

- [ ] Model registered in MLflow Model Registry
- [ ] Model version accessible via MLflow API
- [ ] Model can be loaded via `mlflow.sklearn.load_model()`
- [ ] Loaded model makes predictions on test data
- [ ] Model performance meets expectations (accuracy >= threshold)

## Ansible Role Implementation

- [ ] `ansible/roles/mlflow/tasks/main.yml` has MLflow installation tasks
- [ ] Installation task uses pip module and installs:
  - [ ] mlflow
  - [ ] scikit-learn
  - [ ] pandas
  - [ ] sqlalchemy
  - [ ] psycopg2-binary
- [ ] Tasks create MLflow data directory (`/opt/mlflow`)
- [ ] Tasks create MLflow artifacts directory (`/opt/mlflow/artifacts`)
- [ ] Handler for restarting MLflow service created
- [ ] MLflow systemd service template created (`ansible/roles/mlflow/templates/mlflow.service.j2`)
- [ ] Service template starts MLflow on port 5001
- [ ] Tasks deploy service file and enable on boot

## Playbook Integration and Testing

- [ ] MLflow role included in `ansible/site.yml`
- [ ] Playbook runs in check mode without errors: `ansible-playbook -i ansible/inventory ansible/site.yml --check`
- [ ] Playbook runs in production mode without errors
- [ ] MLflow service starts automatically after playbook runs
- [ ] Health check passes after playbook: `curl http://localhost:5001/health`
- [ ] Second playbook run is idempotent (changed=0 for most tasks)

## Documentation

- [ ] `docs/environment-log.md` updated with Week 11 section
- [ ] MLflow version documented
- [ ] Model name and version documented
- [ ] Training script location and run time documented
- [ ] Feature set documented
- [ ] Metrics and results documented
- [ ] Any issues and resolutions documented
- [ ] `docs/week-11-acceptance-criteria.md` completed (this file)

## Verification Script

- [ ] `./scripts/check-week-11.sh` created and executable
- [ ] Script verifies MLflow health check
- [ ] Script verifies model can be loaded
- [ ] Script output is clear and actionable
- [ ] All verification checks pass: `./scripts/check-week-11.sh`

## Git Commits

- [ ] All Week 11 files committed to git
- [ ] Commit messages are descriptive
- [ ] No uncommitted changes remain
- [ ] Commits available in git log

## Team Artifacts

- [ ] Backlog stories updated with actual time/points spent
- [ ] Completed stories marked as Done
- [ ] Incomplete stories documented with blockers or dependencies
- [ ] Knowledge shared across team (pair programming or documentation)

## Performance and Reliability

- [ ] Model training completes consistently (no random failures)
- [ ] MLflow UI responsive and loads within 2 seconds
- [ ] Model predictions have consistent latency
- [ ] No memory leaks after extended MLflow operation (check with `top` or similar)

## Sign-Off

- [ ] ML Engineer / Data Specialist: Model quality verified
- [ ] Tech Lead: MLflow deployment and Ansible role verified
- [ ] QA Lead: All acceptance criteria verified
- [ ] No blockers or issues preventing Week 12 start

## Notes

[Document any deviations, workarounds, or special circumstances]

## Rollover to Week 12

**Assumptions for Week 12:**

- MLflow is running and stable
- Model is trained, registered, and can be loaded
- Ansible playbook includes MLflow role and runs successfully
- PostgreSQL and Flask app are still running from Weeks 1-9

**Deliverables passed to Week 12:**

- Trained model in MLflow registry
- MLflow tracking server running on port 5001
- Ansible playbook that can be extended with FastAPI role
- Working training pipeline that can be re-run if needed
