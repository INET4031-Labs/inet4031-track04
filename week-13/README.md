# Week 13: Finalize and Prepare for Demo Day

**Sprint 7 | Synchronous**

## Overview

Week 13 is your final preparation sprint before Demo Day. Your focus shifts from new
implementation to hardening, verification, and rehearsal. In this week, your team will:

1. Run the Ansible playbook in dry-run mode to identify and fix any issues
2. Test the complete environment rebuild from scratch
3. Write and rehearse the demo script
4. Complete all documentation (acceptance criteria, retrospectives, environment logs)
5. Handle edge cases and ensure robustness

This week is lighter in new code but critical for Demo Day success.

## Prerequisites

- Week 12 deliverables complete (FastAPI and Flask integration working)
- Ansible playbook includes the mlflow role and runs successfully
- All Weeks 10-12 files committed to git
- Team members assigned to rehearsal roles

## Part 1: Ansible Dry-Run and Verification (1 hour)

### Step 1: Run Playbook in Check Mode

Run your Ansible playbook in dry-run (check mode) to identify any issues before
Demo Day:

```bash
cd /path/to/track-04-machine-learning-and-ai
ansible-playbook -i ansible/inventory ansible/site.yml --check
```

Expected output will show:

```
PLAY [all] **********************
TASK [mlflow : Install MLflow and dependencies] ****
changed: [localhost]
TASK [mlflow : Create MLflow data directory] ****
changed: [localhost]
...
PLAY RECAP **********************
localhost : ok=X changed=Y unreachable=0 failed=0
```

**Important:** In check mode, Ansible will report changes but won't actually apply
them. This is good for validation.

### Step 2: Review and Fix Errors

If you see any errors or failures, review them:

1. **Missing variables:** Check `ansible/roles/mlflow/defaults/main.yml` and
   `ansible/roles/mlflow/vars/main.yml`
2. **File paths:** Ensure all `src` paths in copy/template tasks are correct
3. **Permissions:** Verify the Ansible user has sudo access
4. **Idempotency:** Check that tasks use `state:` parameters correctly

Example common issues:

- **Error: "Could not find src file"**
  - Solution: Verify file paths are relative to the playbook or use absolute paths

- **Error: "Permission denied"**
  - Solution: Add `become: yes` to the task and ensure sudo is configured

- **Error: "Module not found"**
  - Solution: Ensure the Ansible module is available (e.g., `systemd`, `pip`, `template`)

### Step 3: Run for Real (if no errors)

Once check mode passes, run the playbook for real:

```bash
ansible-playbook -i ansible/inventory ansible/site.yml
```

After the playbook completes, verify all services are running:

```bash
# MLflow
curl -s http://localhost:5001/health | python3 -m json.tool
# FastAPI
curl -s http://localhost:8000/health | python3 -m json.tool
# Flask (or your health endpoint)
curl -s http://localhost:8080/ | head -10
```

### Step 4: Document Playbook Status

Update `docs/environment-log.md` with playbook execution details:

```markdown
### Week 13: Ansible Playbook Verification

**Playbook Execution:**
- Date: [today]
- Check mode: PASS
- Full run: PASS
- Execution time: [X minutes]

**Services Started:**
- MLflow: Running on port 5001
- FastAPI: Running on port 8000
- Flask: Running on port 5000

**Idempotency Check:**
- First run: ok=[X] changed=[Y]
- Second run: ok=[X] changed=0 (idempotent)

**Issues Resolved:**
- [Issue 1]: [Resolution]
```

## Part 2: Write and Rehearse Demo Script (1.5 hours)

### Step 1: Create Demo Script

Create a file `week-13/demo-script.md` that walks through the entire pipeline:

```markdown
# Demo Script: Machine Learning and AI Track

## Demo Setup (5 min before start)

1. **Verify all services are running:**
   ```bash
   curl -s http://localhost:5001/health && curl -s http://localhost:8000/health && echo "All services up"
   ```

2. **Open browsers/terminals:**
   - Terminal 1: MLflow UI (`http://localhost:5001/`)
   - Terminal 2: Flask UI (`http://localhost:8080/`)
   - Terminal 3: Testing queries

## Demo Walkthrough (10-15 min)

### Part 1: Show the Data (2 min)

**What we're demonstrating:** The incident data in PostgreSQL that fuels the ML pipeline.

1. In Terminal 3, query the incidents table:
   ```bash
   psql -U appuser -d statustracker -c "SELECT id, title, status, created_at FROM incidents LIMIT 5;"
   ```

2. **Talking points:**
   - "This is the incident data from Weeks 1-2"
   - "We have [X] incidents with various severity levels"
   - "This data trained our ML model"

### Part 2: Show the MLflow Experiment (2 min)

**What we're demonstrating:** Model training history and metrics.

1. In Terminal 1, navigate to MLflow UI (`http://localhost:5001/`)

2. **Show:**
   - The experiment: `incident-status-classifier` (or `incident-resolution-predictor`)
   - The training run with timestamp
   - Metrics: accuracy, precision, recall, F1 (or MAE, RMSE, R2)
   - Artifacts: the trained model

3. **Talking points:**
   - "MLflow tracks every experiment run"
   - "Our model achieved [X]% accuracy on the test set"
   - "This is the exact model we're serving via FastAPI right now"

### Part 3: Show the FastAPI Service (2 min)

**What we're demonstrating:** The inference endpoint serving the model.

1. In Terminal 3, make a prediction request:
   ```bash
   curl -X POST http://localhost:8000/predict \
     -H "Content-Type: application/json" \
     -d '{"title": "Database Connection Timeout", "description": "Cannot connect to PostgreSQL after 30 seconds"}' | \
     python3 -m json.tool
   ```

2. **Show:**
   - The HTTP request with incident text
   - The JSON response with prediction and confidence

3. **Talking points:**
   - "FastAPI loads the MLflow model and serves predictions in real time"
   - "Latency is [X] milliseconds"
   - "The model predicted severity '[prediction]' with [confidence]% confidence"

### Part 4: Show Flask Integration (3 min)

**What we're demonstrating:** Real incidents getting predictions from the Flask UI.

1. In Terminal 2, navigate to Flask UI (`http://localhost:8080/`)

2. **Show an incident detail page:**
   - Click on an incident or navigate to `/incident/1` (or similar)
   - Click the "Get AI Suggestion" button (or similar)

3. **Show:**
   - The Flask UI calling FastAPI in the background
   - The predicted severity appearing in the UI
   - The confidence score

4. **Talking points:**
   - "This is where end-users interact with the ML model"
   - "The Flask app automatically calls the FastAPI inference endpoint"
   - "No manual steps—fully integrated"

### Part 5: Show Ansible Playbook (2-3 min)

**What we're demonstrating:** Infrastructure as Code for reproducibility.

1. In Terminal 3, show the Ansible role:
   ```bash
   ls -la ansible/roles/mlflow/
   cat ansible/roles/mlflow/tasks/main.yml | head -30
   ```

2. **Show:**
   - The mlflow role directory structure
   - Key tasks: install packages, create directories, deploy services

3. **Talking points:**
   - "Everything is automated via Ansible"
   - "This is how we'll rebuild everything in Week 14 from a blank container"
   - "The playbook is idempotent—run it multiple times, same result"

## Demo Conclusion (1 min)

**Summary:**

"We've built a complete ML pipeline for incident prediction:

1. Data: PostgreSQL incidents table with [X] records
2. Model: Trained via scikit-learn, tracked in MLflow
3. Serving: FastAPI endpoint returns predictions in milliseconds
4. Integration: Flask UI calls the endpoint seamlessly
5. Reproducibility: Ansible ensures the same setup every time

This is production-ready infrastructure for ML."

## Contingency: If Something Breaks

- **MLflow unavailable:** Fall back to showing the metrics from logs
- **FastAPI down:** Show the curl request and expected response
- **Flask unavailable:** Demonstrate the FastAPI endpoint directly
- **Ansible dry-run failed:** Explain the issue and show manual fixes applied
```

### Step 2: Rehearse with Full Team

Schedule a rehearsal with all team members:

1. **Assign roles:**
   - **Narrator (1 person):** Explains what's happening
   - **Demonstrator (1-2 people):** Operates the terminals/UI
   - **Backup (1 person):** Ready to take over if technical issues occur

2. **Run through the script:**
   - Time the demo (should be 10-15 minutes)
   - Practice transitions between sections
   - Prepare answers to likely questions

3. **Test all commands:**
   - Run each curl command, PostgreSQL query, and UI navigation
   - Ensure all responses match expectations
   - Document any differences

### Step 3: Capture Screenshots

For reference during the demo, capture:

1. MLflow UI showing the experiment and run
2. MLflow Model Registry showing the registered model
3. FastAPI prediction response (curl output)
4. Flask UI showing an incident with prediction

Save these to `week-13/demo-screenshots/` for reference.

## Part 3: Edge Cases and Robustness (1 hour)

### Test Scenario 1: What if MLflow is Down?

Update Flask integration to handle gracefully:

```python
@app.route("/incident/<int:incident_id>/suggest-severity", methods=["GET"])
def suggest_severity(incident_id):
    try:
        # ... existing code ...
        response = httpx.post(
            INFERENCE_URL,
            json={"title": incident.title, "description": incident.description or ""},
            timeout=5.0
        )
        response.raise_for_status()
        # ... return prediction ...
    
    except httpx.ConnectError:
        # Graceful fallback: return cached prediction or default
        return jsonify({
            "warning": "Inference service unavailable",
            "suggested_severity": "medium",  # Default value
            "confidence": 0.0
        }), 503
    
    except httpx.TimeoutException:
        return jsonify({"error": "Inference service timeout"}), 504
```

Test this behavior:

1. Stop FastAPI: `pkill -f uvicorn`
2. Call Flask endpoint: `curl http://localhost:8080/incident/1/suggest-severity`
3. Verify graceful 503 response
4. Restart FastAPI: `python3 week-12/inference-server.py`

### Test Scenario 2: Invalid Input to Inference

Test what happens with bad data:

```bash
# Empty title
curl -X POST http://localhost:8000/predict \
  -H "Content-Type: application/json" \
  -d '{"title": "", "description": "test"}'

# Missing required field
curl -X POST http://localhost:8000/predict \
  -H "Content-Type: application/json" \
  -d '{"description": "test"}'

# Very long input
curl -X POST http://localhost:8000/predict \
  -H "Content-Type: application/json" \
  -d '{"title": "'$(python3 -c "print(\"x\" * 10000)')'", "description": "test"}'
```

FastAPI should return 422 or 400 errors with clear messages.

### Test Scenario 3: Model Switching

If you want to test swapping to a different model version:

```bash
# In Python, force load a specific model version
import mlflow.sklearn
model = mlflow.sklearn.load_model("models:/incident-status-classifier/2")
```

Document any edge case behaviors in `docs/environment-log.md`.

## Part 4: Complete All Acceptance Criteria

### Fill in Week 13 Acceptance Criteria

Create or update `docs/week-13-acceptance-criteria.md`:

```markdown
# Week 13 Acceptance Criteria

## Ansible Playbook

- [ ] Playbook runs in check mode without errors
- [ ] Playbook runs for real without errors
- [ ] All services start correctly after playbook runs
- [ ] Second playbook run is idempotent (changed=0)
- [ ] MLflow role is included in site.yml
- [ ] All Ansible templates and tasks are properly formatted

## Demo Script and Rehearsal

- [ ] Demo script created and documented (`week-13/demo-script.md`)
- [ ] Demo script covers all components: data, MLflow, FastAPI, Flask, Ansible
- [ ] Team rehearsed the demo script
- [ ] Demo timing: 10-15 minutes
- [ ] All commands in demo script tested and verified
- [ ] Screenshots captured for reference

## Edge Case Testing

- [ ] Tested: FastAPI unavailable, Flask fails gracefully
- [ ] Tested: Invalid input to FastAPI (returns 400/422)
- [ ] Tested: Service recovery after restart
- [ ] Tested: Concurrent requests (basic load)
- [ ] All edge cases documented

## Documentation Complete

- [ ] `docs/sprint-6-retrospective.md` filled in
- [ ] `docs/sprint-6-acceptance-criteria.md` completed
- [ ] `docs/environment-log.md` complete and current
- [ ] `docs/qa-report-6.md` template created

## Service Verification

- [ ] MLflow health check passes
- [ ] FastAPI health check passes
- [ ] Flask endpoint works and calls FastAPI
- [ ] All three services can be started via Ansible playbook

## Git Status

- [ ] All Week 13 files committed
- [ ] All uncommitted changes from Weeks 10-12 committed
- [ ] No untracked files except .gitignore'd items
- [ ] Ready for clean checkout on Demo Day
```

### Complete Sprint 6 Retrospective

Fill in `docs/sprint-6-retrospective.md` (covers Weeks 11-12):

```markdown
# Sprint 6 Retrospective

**Sprint Dates:** [Week 11 start] to [Week 12 end]

## Sprint Close: What Was Completed

**Completed Items:**

- MLflow tracking server installed and running
- Model trained (severity classifier/resolution predictor) and registered
- FastAPI inference endpoint built and tested
- Flask application integrated with FastAPI
- End-to-end pipeline tested successfully
- Ansible role for MLflow created and tested

**Incomplete Items:**

- [List any items that did not finish, with one-sentence notes]

## Team Reflection Questions

### 1. What did you contribute to Sprint 6?

Each team member:
- **[Team Member 1]:** [contributions to MLflow/training pipeline]
- **[Team Member 2]:** [contributions to FastAPI/inference]
- **[Team Member 3]:** [contributions to Flask integration]
- **[Team Member 4]:** [contributions to Ansible/testing]

### 2. What is the most important thing the team shipped?

[Team consensus: e.g., "A fully integrated ML pipeline that serves real-time
predictions from incident data to end users via the Flask UI."]

### 3. What would you do differently if Sprint 6 started again?

[Team reflection: e.g., "We would have defined the Flask API contract earlier
to reduce integration friction."]

## Lessons Learned

- **Data quality:** [Any insights from training on incident data]
- **Model performance:** [Accuracy, latency, edge cases]
- **Deployment:** [Lessons from Ansible automation]
- **Integration:** [Challenges and solutions in Flask/FastAPI handoff]

## Notes for Sprint 7

[Handoff information for demo prep:
- Demo script is ready
- Playbook runs idempotently
- Known limitations or assumptions for Demo Day
]
```

## Part 5: Prepare Container Wipe Procedure (30 min)

Document the procedure for Week 14's container wipe and rebuild:

Create `week-14/wipe-and-rebuild-procedure.md`:

```markdown
# Week 14: Container Wipe and Rebuild Procedure

## Pre-Wipe Checklist

- [ ] All code is committed to git
- [ ] Git remote is up-to-date (push all branches)
- [ ] Backup important data (if any external data sources)
- [ ] Verify Ansible playbook runs without errors

## Wipe Procedure

1. **Stop all services:**
   ```bash
   systemctl stop mlflow
   systemctl stop fastapi
   docker stop <container-name>  # Or k3d
   ```

2. **Remove volume data:**
   ```bash
   rm -rf /opt/mlflow/*
   rm -rf /opt/inference/
   ```

3. **Clean up any ML artifacts:**
   ```bash
   rm -rf ~/mlflow/
   rm -rf ~/.cache/mlflow/
   ```

## Rebuild Procedure

1. **Restart container:**
   ```bash
   docker start <container-name>  # Or k3d
   ```

2. **Run full Ansible playbook:**
   ```bash
   ansible-playbook -i ansible/inventory ansible/site.yml
   ```

3. **Verify all services:**
   ```bash
   curl http://localhost:5001/health
   curl http://localhost:8000/health
   curl http://localhost:8080/  # Flask
   ```

4. **Retrain model (if needed):**
   ```bash
   cd week-11
   python3 train-model.py
   ```

5. **Verify MLflow UI:**
   - Navigate to `http://localhost:5001/`
   - Confirm experiment and model are present

6. **Demo readiness check:**
   ```bash
   bash week-12/test-pipeline.sh
   ```

## Expected Timeline

- Wipe and container restart: 5 minutes
- Ansible playbook run: 3-5 minutes
- Model retraining (if needed): 2-3 minutes
- Verification: 2 minutes
- **Total: 10-15 minutes**

## Troubleshooting

- **Playbook fails:** Check Ansible log and refer to Week 13 documentation
- **MLflow not starting:** Verify /opt/mlflow directory exists and has permissions
- **Model not found:** Retrain using `python3 week-11/train-model.py`
```

## Part 6: Commit and Final Verification

### Commit Week 13 Work

```bash
cd track-04-machine-learning-and-ai
git add week-13/ docs/
git commit -m "Week 13: Demo script, rehearsal, edge case testing, documentation"
git push origin main
```

### Run Final Validation

```bash
./scripts/check-week-13.sh
```

### Verify Git Status

```bash
git status  # Should show "working tree clean"
git log --oneline -5  # Verify recent commits
```

## Deliverables Checklist

By end of Week 13, you must have:

- [ ] Ansible playbook runs in check mode without errors
- [ ] Ansible playbook runs for real and starts all services
- [ ] Demo script created and rehearsed with full team
- [ ] All demo commands tested and working
- [ ] Edge cases tested (service failures, invalid input, etc.)
- [ ] Screenshots captured for reference
- [ ] `docs/sprint-6-retrospective.md` completed
- [ ] `docs/week-13-acceptance-criteria.md` completed
- [ ] `docs/environment-log.md` fully updated
- [ ] Week 14 wipe-and-rebuild procedure documented
- [ ] All files committed to git
- [ ] `./scripts/check-week-13.sh` passes
- [ ] Container can run services without manual intervention

## Verification Commands

**Playbook check mode:**
```bash
ansible-playbook -i ansible/inventory ansible/site.yml --check
```

**All services up:**
```bash
curl -s http://localhost:5001/health && \
curl -s http://localhost:8000/health && \
echo "All services ready for demo"
```

**Git ready for Demo Day:**
```bash
git status
# Output: "On branch main, nothing to commit, working tree clean"
```

## Next Steps

Week 14 is Demo Day:

1. Wipe the container clean
2. Run Ansible playbook from scratch
3. Verify complete pipeline
4. Present to instructor and class

Refer to `week-14/README.md` for Demo Day instructions.
