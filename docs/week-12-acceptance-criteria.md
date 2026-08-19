# Week 12 Acceptance Criteria

This document tracks the requirements for Week 12 completion. Each item below must be verified before moving to Week 13.

## FastAPI Inference Endpoint

- [ ] FastAPI application created (`week-12/inference-server.py`)
- [ ] FastAPI imports MLflow and scikit-learn modules
- [ ] Startup event loads model from MLflow registry:
  - [ ] Model loaded via `mlflow.sklearn.load_model()`
  - [ ] Model is the correct registered version
- [ ] Root endpoint (`/`) responds with service information
- [ ] Health check endpoint (`/health`) responds with `{"status":"ok"}`
- [ ] Health check includes `"model_loaded":true`
- [ ] Prediction endpoint (`/predict`) accepts POST requests
- [ ] Prediction request validates input (Pydantic model)
- [ ] Prediction returns JSON response:
  - [ ] Contains `"prediction"` field
  - [ ] Contains `"confidence"` field (0.0 to 1.0)
  - [ ] Contains `"model"` field with model name
- [ ] FastAPI documentation available at `/docs` (Swagger)
- [ ] Error responses are clear and informative (400, 422, 503)
- [ ] Service runs without errors: `python3 week-12/inference-server.py`
- [ ] Service accessible at `http://localhost:8000`

## Flask Integration

- [ ] Flask application has new endpoint calling FastAPI
- [ ] Endpoint accepts incident data (title, description)
- [ ] Endpoint makes HTTP POST request to FastAPI endpoint
- [ ] Flask parses JSON response from FastAPI
- [ ] Flask returns prediction to user/client
- [ ] Error handling for FastAPI unavailability:
  - [ ] Returns graceful error message
  - [ ] HTTP 503 (Service Unavailable)
  - [ ] Fallback value or empty result
- [ ] Flask integrated with httpx or requests library
- [ ] Connection timeout configured (5 seconds recommended)
- [ ] Tested with curl and/or browser navigation
- [ ] Multiple incidents tested to verify consistency

## Ansible Role Updates

- [ ] Ansible role includes FastAPI and uvicorn installation
- [ ] Ansible role installs all Python dependencies:
  - [ ] fastapi
  - [ ] uvicorn
  - [ ] httpx
  - [ ] pydantic
- [ ] Role creates directory for inference server (`/opt/inference`)
- [ ] Role copies inference server script to target directory
- [ ] FastAPI systemd service template created:
  - [ ] File: `ansible/roles/mlflow/templates/fastapi.service.j2`
  - [ ] ExecStart uses uvicorn with correct module
  - [ ] Port set to 8000
  - [ ] After clause includes mlflow.service dependency
- [ ] Service task deploys template and enables service
- [ ] Handler created for restarting FastAPI service
- [ ] Playbook runs without errors: `ansible-playbook -i ansible/inventory ansible/site.yml`
- [ ] Both MLflow and FastAPI services start after playbook

## End-to-End Pipeline Testing

- [ ] MLflow health check passes: `curl http://localhost:5001/health`
- [ ] FastAPI health check passes: `curl http://localhost:8000/health`
- [ ] FastAPI prediction endpoint responds to test requests
- [ ] Flask endpoint successfully calls FastAPI
- [ ] Flask displays or logs predictions appropriately
- [ ] Tested with multiple incident examples
- [ ] No service errors in logs during testing
- [ ] Predictions have expected format and reasonable values
- [ ] Test script `week-12/test-pipeline.sh` created and passes

## Performance and Reliability

- [ ] FastAPI response time acceptable (< 500 ms)
- [ ] FastAPI handles concurrent requests gracefully
- [ ] Model loading on startup completes quickly (< 10 seconds)
- [ ] Graceful shutdown and restart (no connection errors)
- [ ] Flask timeout handling prevents hanging requests
- [ ] No memory leaks after extended operation

## Documentation

- [ ] `docs/environment-log.md` updated with Week 12 section
- [ ] FastAPI version documented
- [ ] Request/response examples documented
- [ ] Flask integration details documented
- [ ] Performance metrics documented
- [ ] Any issues and resolutions documented
- [ ] `docs/week-12-acceptance-criteria.md` completed (this file)
- [ ] API contract documented (request/response format)

## Verification Script

- [ ] `./scripts/check-week-12.sh` created and executable
- [ ] Script verifies MLflow health
- [ ] Script verifies FastAPI health
- [ ] Script tests prediction endpoint
- [ ] Script tests Flask integration (if possible)
- [ ] All checks pass: `./scripts/check-week-12.sh`

## MLflow UI and Screenshots

- [ ] MLflow UI accessible at `http://localhost:5001/`
- [ ] Experiment visible in left sidebar
- [ ] Training run clickable and shows metrics
- [ ] Artifacts tab displays model directory
- [ ] Model Registry shows registered model
- [ ] Screenshots captured for documentation/demo

## Git Commits

- [ ] All Week 12 files committed to git
- [ ] FastAPI server script committed
- [ ] Updated Ansible role tasks committed
- [ ] Service templates committed
- [ ] Test script committed
- [ ] Commit messages are descriptive
- [ ] No uncommitted changes remain

## Team Artifacts

- [ ] Week 12 backlog stories updated with actual time/points
- [ ] Completed stories marked as Done
- [ ] Incomplete items documented with reasons
- [ ] Knowledge shared (code review, pair programming, or docs)

## Sign-Off

- [ ] Backend Engineer: FastAPI and Flask integration verified
- [ ] Infrastructure Lead: Ansible role verified
- [ ] QA Lead: End-to-end pipeline verified
- [ ] All acceptance criteria signed off
- [ ] No blockers preventing Week 13 start

## Notes

[Document any deviations, workarounds, limitations, or special circumstances]

## Rollover to Week 13

**Assumptions for Week 13:**

- MLflow is running with a trained model
- FastAPI is serving predictions successfully
- Flask can call FastAPI and display results
- Ansible playbook includes both MLflow and FastAPI roles
- PostgreSQL and Flask app are operational

**Deliverables passed to Week 13:**

- Complete ML inference pipeline (data → model → predictions)
- FastAPI endpoint ready for production use
- Flask integration ready for demo
- Ansible playbook ready for dry-run testing and rehearsal
