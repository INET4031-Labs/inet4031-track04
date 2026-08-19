---
**Week 1-9 Prerequisite**

Weeks 10-14 assume your completed Weeks 1-9 repositories are available as peer directories in `Student Repositories/`. This track's Ansible roles reference your prior work:
- `mlflow` role uses your Flask application from Week 2 (`../week-02/`)
- `mlflow` role connects to your PostgreSQL database from Week 4 (`../week-04/` or `../infrastructure/`)

Your track repo does NOT copy these — it integrates with them. Ensure your Week 1-9 work is complete and accessible before Week 11.

---

# Week 10: Challenge Kickoff - Machine Learning and AI

**Sprint 5 Continuation | Synchronous**

## Overview

Week 10 is your challenge track kickoff. In this week, your team will define the
architecture for the ML model serving pipeline, decide on the specific ML task (severity
classifier or time-to-resolution predictor), allocate work, and populate the backlog for
Weeks 11 and 12.

By the end of this week, you will have:

1. A documented architecture decision covering MLflow, model training, FastAPI inference,
   and Flask integration
2. A backlog with estimated stories for Weeks 11 and 12
3. Role and task assignments for each team member
4. An agreed-upon ML model choice and feature set

## Prerequisites

- Complete Week 9 (or your team's prior sprint backlog and retrospective)
- Your team's shared container is running with PostgreSQL and Flask application from
  Weeks 1-9
- All team members can access the container and clone this repository

## Part 1: Understand the Track Requirements (30 min)

Read through the main README.md of this repository and review the high-level challenge
description. Specifically understand:

- What MLflow is and how it will track experiment runs and register models
- What FastAPI is and how it will serve inference requests
- How the Flask application will integrate by calling the inference endpoint
- The capstone requirement: Ansible must rebuild everything in Week 14

As a team, discuss and document:

1. What ML task will your model solve? (Severity classifier or time-to-resolution
   predictor?)
   - Severity classifier: Predict incident severity (critical, high, medium, low) from
     title and description
   - Time-to-resolution predictor: Predict incident resolution time (in hours) from
     title, description, and current status
2. What features will you use from the incidents table?
3. What metrics will you track in MLflow (accuracy, RMSE, precision, recall, etc.)?

Document your choices in a short architecture decision record (see Part 3).

## Part 2: Architecture and Design (1 hour)

Create an architecture diagram or text description covering:

### Components

1. **MLflow Tracking Server**
   - Deployment (container port, host port)
   - Backend store (file-based or PostgreSQL)
   - Artifact store (local or S3-like)
   - Health check endpoint
   - Security considerations (access control, credentials)

2. **Model Training Pipeline**
   - Input: incidents table (PostgreSQL)
   - Feature engineering: how you'll prepare data from incidents
   - Model library: scikit-learn (or specify alternative)
   - Output: trained model logged to MLflow with metrics

3. **FastAPI Inference Endpoint**
   - Request format (what fields the inference accepts)
   - Response format (model prediction output)
   - Health check endpoint
   - Error handling for invalid input

4. **Flask Application Integration**
   - Which page or endpoint will call the inference service?
   - How will you display predictions in the UI (if at all)?
   - Error handling if inference service is down

5. **Ansible Role**
   - Installing MLflow, scikit-learn, FastAPI
   - Creating systemd service for MLflow tracking server
   - Creating systemd service for FastAPI inference server
   - Idempotency: how will re-running the role behave?

### Data Flow Diagram

Sketch or describe the flow:

```
PostgreSQL (incidents table)
  |
  +-> Model Training Script (scikit-learn)
      |
      +-> MLflow (logs metrics, artifacts, model)
          |
          +-> MLflow Model Registry (stores model URI)
              |
              +-> FastAPI Endpoint (loads registered model, serves predictions)
                  |
                  +-> Flask App (calls endpoint, displays results)
```

## Part 3: Architecture Decision Record

Create a file `week-10/architecture-decision.md` with the following structure:

```markdown
# Architecture Decision Record: ML Pipeline for Track 4

## Decision Date
[Today's date]

## ML Task
[Severity classifier / Time-to-resolution predictor]

## Feature Set
[List the columns from incidents table you will use]

## Model Library
[scikit-learn (and which estimator type: RandomForest, LogisticRegression, etc.)]

## Metrics to Track
[List MLflow-tracked metrics: accuracy, RMSE, precision, etc.]

## MLflow Deployment
- Container port: [e.g., 5001]
- Backend: [file-based or PostgreSQL backend]
- Artifact store: [local directory]
- Health check: http://localhost:5001/health

## FastAPI Deployment
- Container port: [e.g., 8000 or 8001]
- Request format:
  ```json
  {
    "field1": "value",
    "field2": 123
  }
  ```
- Response format:
  ```json
  {
    "prediction": "value",
    "confidence": 0.95
  }
  ```
- Health check: GET /health

## Flask Integration
- Endpoint that calls inference: [e.g., /incidents/predict]
- User flow: [describe what a user sees]

## Risks and Mitigations
[List any potential issues and how you will address them]

## Timeline
- Week 11: MLflow server + model training
- Week 12: FastAPI endpoint + Flask integration
- Week 13: Ansible playbook refinement
- Week 14: Demo Day rebuild
```

## Part 4: Define the Backlog (1 hour)

Working as a team, populate your backlog for Weeks 11 and 12. Use the following template
and assign each story to a team member (or pair):

### Week 11 Backlog (MLflow and Model Training)

Create a file `week-11/backlog.md`:

```markdown
# Week 11 Backlog

## Story 1: Set Up MLflow Tracking Server
- [ ] Install MLflow in container via pip
- [ ] Create MLflow systemd service (runs on port 5001)
- [ ] Configure MLflow backend (file-based or PostgreSQL)
- [ ] Verify http://localhost:5001/ is accessible
- [ ] Verify health check endpoint responds
- Points: [5-8]
- Assigned to: [team member]

## Story 2: Prepare Training Data from PostgreSQL
- [ ] Write Python script to fetch incidents from PostgreSQL
- [ ] Implement feature engineering (select and transform columns)
- [ ] Handle missing values and data types
- [ ] Create train/test split
- [ ] Points: [5]
- Assigned to: [team member]

## Story 3: Build and Train ML Model
- [ ] Implement scikit-learn model (train, fit, predict)
- [ ] Set up MLflow experiment and run context
- [ ] Log model to MLflow with artifacts
- [ ] Log metrics (accuracy, precision, recall, or RMSE as appropriate)
- [ ] Test that model can be loaded from MLflow
- [ ] Points: [8]
- Assigned to: [team member]

## Story 4: Ansible Role for MLflow
- [ ] Create ansible/roles/mlflow/ directory and structure
- [ ] Write tasks to install MLflow and dependencies
- [ ] Create systemd unit file template for MLflow service
- [ ] Test that playbook runs idempotently
- [ ] Points: [5]
- Assigned to: [team member]

## Story 5: MLflow Testing and Verification
- [ ] Verify MLflow UI is accessible and shows registered model
- [ ] Verify curl health check passes
- [ ] Test that model can be loaded in Python
- [ ] Document findings in environment log
- [ ] Points: [3]
- Assigned to: [team member]
```

### Week 12 Backlog (FastAPI and Flask Integration)

Create a file `week-12/backlog.md`:

```markdown
# Week 12 Backlog

## Story 1: Build FastAPI Inference Endpoint
- [ ] Install FastAPI and uvicorn
- [ ] Create FastAPI app with inference endpoint
- [ ] Load registered model from MLflow
- [ ] Implement request validation (Pydantic models)
- [ ] Implement response with prediction and confidence
- [ ] Add health check endpoint
- [ ] Test endpoint locally with curl or httpx
- [ ] Points: [8]
- Assigned to: [team member]

## Story 2: Integrate FastAPI into Ansible Role
- [ ] Create FastAPI systemd unit file
- [ ] Add FastAPI service to MLflow Ansible role
- [ ] Test that playbook starts both MLflow and FastAPI
- [ ] Points: [5]
- Assigned to: [team member]

## Story 3: Flask Application Integration
- [ ] Add new endpoint to Flask app that calls FastAPI inference
- [ ] Handle FastAPI responses and display results
- [ ] Add error handling for inference failures
- [ ] Update Flask templates if UI updates are needed
- [ ] Points: [8]
- Assigned to: [team member]

## Story 4: End-to-End Testing
- [ ] Verify Flask app can call FastAPI endpoint
- [ ] Verify predictions appear in Flask UI
- [ ] Check MLflow UI shows new runs (if retraining)
- [ ] Test with multiple incident examples
- [ ] Points: [5]
- Assigned to: [team member]

## Story 5: Documentation and Demo Prep
- [ ] Document API contract for FastAPI endpoint
- [ ] Create demo script showing the full pipeline
- [ ] Capture screenshots of MLflow UI
- [ ] Update acceptance criteria
- [ ] Points: [3]
- Assigned to: [team member]
```

## Part 5: Populate Acceptance Criteria and Environment Log

Create stub files that will be filled in as weeks progress:

- [ ] `docs/week-10-acceptance-criteria.md` (template below)
- [ ] `docs/week-11-acceptance-criteria.md` (template below)
- [ ] `docs/week-12-acceptance-criteria.md` (template below)
- [ ] `docs/week-13-acceptance-criteria.md` (template below)
- [ ] `docs/week-14-acceptance-criteria.md` (template below)
- [ ] `docs/environment-log.md` (shared across all weeks)
- [ ] `docs/sprint-5-retrospective.md` (filled in after Week 10)
- [ ] `docs/sprint-6-retrospective.md` (filled in after Week 12)
- [ ] `docs/sprint-7-retrospective.md` (filled in after Week 14)

## Part 6: Create Ansible Directory Structure

Set up the Ansible role scaffold:

```bash
mkdir -p ansible/roles/mlflow
mkdir -p ansible/roles/mlflow/{defaults,handlers,tasks,templates,vars}
touch ansible/roles/mlflow/defaults/main.yml
touch ansible/roles/mlflow/handlers/main.yml
touch ansible/roles/mlflow/tasks/main.yml
touch ansible/roles/mlflow/templates/mlflow.service.j2
touch ansible/roles/mlflow/templates/fastapi.service.j2
touch ansible/roles/mlflow/vars/main.yml
```

The role will be developed in Weeks 11-12 but the structure is created now.

## Part 7: Commit and Record

Commit all Week 10 files to git:

```bash
cd track-04-machine-learning-and-ai
git add week-10/ ansible/ docs/
git commit -m "Week 10: Architecture decision, backlog, and role structure"
git push origin main
```

Record in your team's Google Doc:

- Architecture decision summary
- ML task choice and justification
- Feature set selected
- High-level backlog estimate for Weeks 11-12
- Any risks or assumptions

## Part 8: Fill Sprint 5 Retrospective

At the end of your Week 10 synchronous session, complete `docs/sprint-5-retrospective.md`:

- What did you contribute to the architecture decision?
- What is the most important aspect of the pipeline you designed?
- What would you change about your architecture if you started over?
- Notes for Sprint 6 (any unknowns or dependencies)?

## Deliverables Checklist

By end of Week 10, you must have:

- [ ] Architecture decision record completed and committed
- [ ] ML task chosen (severity classifier or time-to-resolution)
- [ ] Feature set defined from incidents table
- [ ] Week 11 backlog with estimated stories
- [ ] Week 12 backlog with estimated stories
- [ ] Ansible role directory structure created
- [ ] All acceptance criteria documents created (as stubs)
- [ ] Environment log template created
- [ ] Sprint 5 retrospective completed
- [ ] All files committed to git

## Verification

Run the Week 10 validation script (to be provided):

```bash
./scripts/check-week-10.sh
```

This will verify that all required files are present and properly structured.

## Next Steps

Week 11 begins the core build. Your tech lead and ML engineer will focus on:

1. Installing MLflow and starting the tracking server
2. Writing the model training pipeline
3. Logging the first trained model to MLflow
4. Starting the Ansible role implementation

Refer to `week-11/README.md` for detailed instructions.
