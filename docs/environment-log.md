# Environment Log

This document tracks the current state of the ML pipeline environment across all weeks.

## Overview

- **Track:** Track 4 - Machine Learning and AI
- **Team:** [Team name]
- **Start Date:** [Week 10 start date]
- **Last Updated:** [Today's date]

## Container and Host Information

- **Container Platform:** [Docker / k3d / other]
- **Host OS:** [Ubuntu / CentOS / other]
- **Container Hostname:** [hostname]
- **Container IP:** [IP address]
- **Disk Space (df -h):** [Output of df -h]
- **Docker Storage (docker system df):** [Output of docker system df]

## Database

### PostgreSQL

- **Version:** [output of psql --version]
- **Host:** localhost
- **Port:** 5432
- **Username:** appuser
- **Database:** statustracker
- **Status:** Running
- **Row count in incidents table:** [SELECT COUNT(*) FROM incidents;]
- **Connection verified:** [Date]

### Sample Query

```sql
SELECT COUNT(*) as incident_count, status
FROM incidents
GROUP BY status
ORDER BY status;
```

**Result:**
[Paste output]

## Python Environment

- **Python version:** [output of python3 --version]
- **pip version:** [output of pip --version]
- **Virtual environment:** [Yes/No, path if yes]
- **Installed packages:**

```
mlflow           [version]
scikit-learn     [version]
pandas           [version]
sqlalchemy       [version]
psycopg2-binary  [version]
fastapi          [version]
uvicorn          [version]
httpx            [version]
pydantic         [version]
```

**Full pip list (as of [date]):**
[Paste output of pip list]

## Week 10: Architecture and Planning

**Date Completed:** [Date]

### Architecture Decision

- **ML Task:** [Severity classifier / Time-to-resolution predictor]
- **Model Library:** scikit-learn
- **Feature Set:** [List of columns]
- **Metrics:** [List of metrics]

### Backlog Estimates

- **Week 11 stories:** [X points]
- **Week 12 stories:** [Y points]
- **Total estimated:** [X+Y points]

## Week 11: MLflow and Model Training

**Date Completed:** [Date]

### MLflow Tracking Server

- **MLflow version:** [output of mlflow --version]
- **Host:** 0.0.0.0
- **Port:** 5001
- **Backend:** file:./mlflow
- **Artifact store:** ./mlflow/artifacts
- **Status:** Running
- **Last verified:** [Date/time]

### Model Training

- **Model name:** incident-status-classifier
- **Training script:** week-11/train-model.py
- **Data source:** PostgreSQL statustracker.incidents table (appuser)
- **Incidents loaded:** ~50,000
- **Train/test split:** 80/20
- **Model type:** RandomForestClassifier with TF-IDF vectorizer

### Training Metrics

- **Accuracy:** [0.XX]
- **Precision:** [0.XX]
- **Recall:** [0.XX]
- **F1 Score:** [0.XX]
- (Or for regression: MAE, RMSE, R2)

### MLflow Experiment

- **Experiment name:** incident-severity-classifier
- **Run ID:** [abc123...]
- **Artifacts:** model/, logs/
- **Status:** Logged successfully

### Issues Encountered

- [Issue 1]: [Description and resolution]
- [Issue 2]: [Description and resolution]

## Week 12: FastAPI Endpoint and Flask Integration

**Date Completed:** [Date]

### FastAPI Inference Server

- **FastAPI version:** [output of pip show fastapi]
- **Uvicorn version:** [output of pip show uvicorn]
- **Host:** 0.0.0.0
- **Port:** 8000
- **Model loaded:** incident-severity-classifier
- **Status:** Running
- **Last verified:** [Date/time]

### FastAPI Endpoints

**Health Check:**
- URL: GET http://localhost:8000/health
- Response: {"status":"ok","model_loaded":true}
- Latency: [XX] ms

**Prediction Endpoint:**
- URL: POST http://localhost:8000/predict
- Request: {"title":"...","description":"..."}
- Response: {"prediction":"...","confidence":0.XX}
- Latency: [XX] ms

### Flask Integration

- **Endpoint:** /incident/<id>/suggest-severity
- **Method:** GET or POST
- **Response:** JSON with prediction
- **Error handling:** 503 when inference service down
- **Last tested:** [Date]

### Sample Predictions

**Sample 1:**
```
Request: {"title": "Database Error", "description": "Connection timeout"}
Response: {"prediction": "high", "confidence": 0.89}
```

**Sample 2:**
```
Request: {"title": "Network Issue", "description": "Intermittent connectivity"}
Response: {"prediction": "medium", "confidence": 0.76}
```

### Issues Encountered

- [Issue 1]: [Description and resolution]
- [Issue 2]: [Description and resolution]

## Week 13: Ansible Playbook and Demo Prep

**Date Completed:** [Date]

### Ansible Playbook Status

- **Playbook:** ansible/site.yml
- **Role included:** mlflow
- **Check mode:** PASS
- **Production run:** PASS
- **Idempotency verified:** YES
- **Last run date:** [Date]

**Playbook Execution Stats (last run):**
- Changed: [X]
- OK: [Y]
- Failed: 0
- Unreachable: 0
- Execution time: [M] minutes

### Services Started by Playbook

- [ ] MLflow (systemd)
- [ ] FastAPI (systemd)
- [ ] Flask (systemd or manual)

**Verification after playbook:**

```bash
$ curl http://localhost:5001/health
{"status":"ok"}

$ curl http://localhost:8000/health
{"status":"ok","model_loaded":true}

$ systemctl status mlflow
Active: active (running)

$ systemctl status fastapi
Active: active (running)
```

### Demo Script

- **File:** week-13/demo-script.md
- **Status:** Ready
- **Rehearsal date:** [Date]
- **Rehearsal participants:** [Names]
- **Demo timing:** [X] minutes

### Edge Case Testing

- **Test 1:** MLflow down / FastAPI graceful failure
  - Status: PASS
  - Notes: Returns 503 with fallback value

- **Test 2:** Invalid input to FastAPI
  - Status: PASS
  - Notes: Returns 422 with validation error

- **Test 3:** Service recovery after restart
  - Status: PASS
  - Notes: Services restart cleanly

## Week 14: Demo Day

**Date Completed:** [Date]

### Pre-Demo Status

- **All services running:** YES
- **Git clean:** YES
- **Demo script rehearsed:** YES
- **Screenshots ready:** YES

### Demo Execution

- **Demo date:** [Date]
- **Demo time:** [Time]
- **Instructor present:** [Name]
- **Duration:** [X] minutes
- **Status:** SUCCESSFUL / FAILED / PARTIAL

**Components Demonstrated:**
- [X] PostgreSQL incident data
- [X] MLflow experiment and metrics
- [X] FastAPI inference endpoint
- [X] Flask UI integration
- [X] Ansible playbook rebuild

### Post-Wipe and Rebuild

- **Wipe time:** [timestamp]
- **Services stopped:** OK
- **Data cleaned:** OK
- **Rebuild started:** [timestamp]
- **Playbook completed:** YES
- **Rebuild time:** [X] minutes
- **Services running after rebuild:** YES

**Services Status Post-Rebuild:**
```
MLflow: http://localhost:5001/health -> {"status":"ok"}
FastAPI: http://localhost:8000/health -> {"status":"ok","model_loaded":true}
Flask: http://localhost:8080/ -> OK
```

### Model Restoration

- **Method:** Retrain via week-11/train-model.py
- **Training time:** [X] minutes
- **Model registered:** YES
- **Metrics:** [Accuracy: XX%, etc.]

### End-to-End Verification

- **test-pipeline.sh results:** ALL PASS
- **Manual tests:** ALL PASS
- **MLflow UI accessible:** YES
- **Flask prediction functional:** YES

### Feedback from Instructor

[Notes on feedback, suggestions, questions asked]

### Final Status

- **Pipeline complete and working:** YES
- **All deliverables met:** YES
- **Grade/approval:** [To be filled by instructor]

## Post-Track Reflection

### What Worked Well

- [Point 1]
- [Point 2]
- [Point 3]

### Challenges and Solutions

- [Challenge 1]: [How resolved]
- [Challenge 2]: [How resolved]

### Lessons for Future Tracks

- [Learning 1]
- [Learning 2]

### Total Time Invested

- **Week 10:** [X] hours
- **Week 11:** [X] hours
- **Week 12:** [X] hours
- **Week 13:** [X] hours
- **Week 14:** [X] hours
- **Total:** [X] hours

## Appendix: Command Reference

### Health Checks

```bash
# MLflow
curl -s http://localhost:5001/health

# FastAPI
curl -s http://localhost:8000/health

# Flask
curl -s http://localhost:8080/
```

### Service Management

```bash
# Check status
sudo systemctl status mlflow
sudo systemctl status fastapi

# Start/stop
sudo systemctl start mlflow
sudo systemctl stop mlflow

# View logs
sudo journalctl -u mlflow -n 50
sudo journalctl -u fastapi -n 50
```

### Useful Queries

```bash
# Count incidents by status
psql -U appuser -d statustracker -c "SELECT status, COUNT(*) FROM incidents GROUP BY status;"

# Check model registration
mlflow models list

# View experiment runs
mlflow runs list -e incident-status-classifier
```
