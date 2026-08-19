# Week 14: Demo Day - Container Wipe and Playbook Rebuild

**Sprint 7 Continuation | Synchronous**

## Overview

Week 14 is Demo Day. Your team will demonstrate the complete ML pipeline in front of the
instructor and class. Before the demo, you will wipe the container clean and rebuild the
entire environment from scratch using the Ansible playbook you've been refining since
Week 11. This final rebuild proves that your infrastructure is reproducible and
production-ready.

By the end of this week, you will have:

1. Wiped the container environment completely
2. Rebuilt the entire stack (including MLflow, FastAPI, Flask, and all dependencies) via
   Ansible playbook in a single run
3. Retrained or restored the ML model
4. Verified the complete pipeline end-to-end
5. Presented a successful demo to the instructor

## Prerequisites

- Week 13 deliverables complete (playbook tested, demo script rehearsed)
- All code committed to git with no uncommitted changes
- Ansible playbook runs successfully in production mode (not just check mode)
- Demo script is memorized or printed for reference

## Part 1: Pre-Demo Verification (30 min)

### Step 1: Confirm All Services Are Running

Before wiping, verify everything works one last time:

```bash
# MLflow
curl -s http://localhost:5001/health | python3 -m json.tool
# FastAPI
curl -s http://localhost:8000/health | python3 -m json.tool
# Flask
curl -s http://localhost:8080/ | head -20
```

All three should respond successfully.

### Step 2: Verify Git Status

Ensure no uncommitted changes:

```bash
cd /path/to/track-04-machine-learning-and-ai
git status
```

Expected output:

```
On branch main
nothing to commit, working tree clean
```

If you see uncommitted changes, commit them now:

```bash
git add .
git commit -m "Final pre-demo commit"
git push origin main
```

### Step 3: Document Current State

In `week-14/demo-day-log.md`, record the current state:

```markdown
# Demo Day Log

**Date:** [Today's date]
**Time:** [Current time]

## Pre-Wipe Status

- All services running: YES
- Ansible playbook passing: YES
- Git status: clean
- Demo script: ready
- Team prepared: YES

[Continue with wipe and rebuild details below]
```

## Part 2: Container Wipe Procedure (10-15 min)

**CRITICAL: After this step, your current environment is gone. You cannot undo this.**

### Step 1: Stop All Services

```bash
# Stop systemd services (if running)
sudo systemctl stop mlflow
sudo systemctl stop fastapi

# Or, if using manual processes, kill them
pkill -f "mlflow server"
pkill -f "uvicorn"
```

### Step 2: Remove MLflow Data and Artifacts

```bash
# Remove MLflow tracking data
sudo rm -rf /opt/mlflow/*

# Remove inference server directory (if created)
sudo rm -rf /opt/inference/*

# Remove local MLflow cache
rm -rf ~/mlflow/
rm -rf ~/.cache/mlflow/
```

### Step 3: Clean Git Artifacts (if any)

```bash
# Remove any uncommitted artifacts
git clean -fd

# Verify nothing is removed except build artifacts
git status  # Should show "clean working tree"
```

### Step 4: Verify Wipe Was Successful

```bash
# All three should fail (connection refused or not found)
curl http://localhost:5001/health  # FAIL: cannot connect
curl http://localhost:8000/health  # FAIL: cannot connect

# If they don't fail, services weren't stopped
ps aux | grep mlflow
ps aux | grep uvicorn
# Kill any remaining processes manually
```

Update demo log:

```markdown
## Wipe Phase

**Time Started:** [timestamp]
**Steps Completed:**
- [ ] Services stopped
- [ ] /opt/mlflow cleaned
- [ ] /opt/inference cleaned
- [ ] Local cache cleaned
- [ ] Verification: services unreachable

**Time Completed:** [timestamp]
```

## Part 3: Rebuild via Ansible Playbook (5-10 min)

### Step 1: Run Ansible Playbook

Run the full playbook to rebuild everything:

```bash
cd /path/to/track-04-machine-learning-and-ai
ansible-playbook -i ansible/inventory ansible/site.yml
```

Expected output (abridged):

```
PLAY [all] **********************

TASK [setup] **********************
ok: [localhost]

TASK [mlflow : Install MLflow and dependencies] ****
changed: [localhost]

TASK [mlflow : Create MLflow data directory] ****
changed: [localhost]

... [more tasks] ...

PLAY RECAP **********************
localhost : ok=XX changed=YY unreachable=0 failed=0
```

**Key metrics:**
- `unreachable=0` and `failed=0` mean success
- `changed=YY` is expected on first run (services not yet running)

### Step 2: Verify Services Started

After playbook completes, check that services are running:

```bash
# Check systemd services
sudo systemctl status mlflow
sudo systemctl status fastapi

# Or check processes
ps aux | grep mlflow
ps aux | grep uvicorn
```

Expected output:

```
mlflow.service - MLflow Tracking Server
   Loaded: loaded (/etc/systemd/system/mlflow.service; enabled; vendor preset: enabled)
   Active: active (running) since [date] [time] ago
```

### Step 3: Health Checks

Verify all services are healthy:

```bash
# MLflow
curl -s http://localhost:5001/health | python3 -m json.tool
# Expected: {"status":"ok"}

# FastAPI
curl -s http://localhost:8000/health | python3 -m json.tool
# Expected: {"status":"ok","model_loaded":true}

# Flask
curl -s http://localhost:8080/ | head -20
# Should show HTML content
```

If any health check fails, see **Troubleshooting** section below.

Update demo log:

```markdown
## Rebuild Phase

**Time Started:** [timestamp]

**Ansible Playbook Output:**
- Changed: [XX]
- Ok: [YY]
- Failed: [0]
- Unreachable: [0]

**Services Verified:**
- [ ] MLflow healthy
- [ ] FastAPI healthy
- [ ] Flask responding

**Time Completed:** [timestamp]
```

## Part 4: Retrain Model (5 min)

The container rebuild cleared MLflow's data. You need to retrain (or restore) the model.

### Option A: Quick Retrain

Run the training script to recreate the model:

```bash
cd week-11
python3 train-model.py
```

Expected output:

```
Loaded 42 incidents with severity labels
Train set: 33, Test set: 9
Run abc123def456 logged:
  Accuracy: 0.8889
  Precision: 0.8852
  Recall: 0.8889
  F1: 0.8869
Model registered as 'incident-status-classifier'
```

If this fails:

1. **Verify MLflow is running:** `curl http://localhost:5001/health`
2. **Verify PostgreSQL has data:** `psql -U appuser -d statustracker -c "SELECT COUNT(*) FROM incidents;"`
3. **Check Python imports:** `python3 -c "import mlflow, sklearn; print('OK')"`

### Option B: Pre-Build and Snapshot

Alternatively, if training is time-consuming, you could:

1. Export the model from the current environment
2. Include it as an artifact in the repo
3. Load it during the playbook run

This is more advanced but faster for demos. For now, Option A (retrain) is recommended.

Update demo log:

```markdown
## Model Restoration Phase

**Time Started:** [timestamp]
**Method:** Quick retrain
**Training Script:** week-11/train-model.py

**Training Output:**
- Incidents loaded: [X]
- Training samples: [Y]
- Test samples: [Z]
- Accuracy: [0.XX]
- Model registered: YES

**Time Completed:** [timestamp]
```

## Part 5: End-to-End Pipeline Verification (10 min)

### Step 1: Run Full Test Suite

```bash
bash week-12/test-pipeline.sh
```

Expected output:

```
Testing ML Pipeline...
1. Checking MLflow...
  MLflow: OK
2. Checking FastAPI...
  FastAPI: OK
3. Testing prediction...
  Response: {"prediction":"critical","confidence":0.92,"model":"incident-status-classifier","run_id":"see MLflow UI"}
4. Testing Flask integration...
  Response: {"incident_id":1,"suggested_severity":"high","confidence":0.85}
Done.
```

All four checks must pass.

### Step 2: Manual Verification

Do a quick manual walkthrough:

```bash
# 1. Check MLflow UI
echo "Open http://localhost:5001/ in your browser"
echo "Expected: Experiment and run visible, model registered"

# 2. Test FastAPI directly
curl -X POST http://localhost:8000/predict \
  -H "Content-Type: application/json" \
  -d '{"title":"Test","description":"Test incident"}' | python3 -m json.tool

# 3. Test Flask endpoint
curl http://localhost:8080/incident/1/suggest-severity | python3 -m json.tool
```

### Step 3: Load Test (Optional)

If time permits, test concurrent requests:

```bash
# Send 5 concurrent requests
for i in {1..5}; do
  curl -X POST http://localhost:8000/predict \
    -H "Content-Type: application/json" \
    -d '{"title":"Test '$i'","description":"Test incident"}' &
done
wait
echo "All requests completed"
```

All should succeed without errors.

Update demo log:

```markdown
## End-to-End Verification Phase

**Test Results:**
- MLflow: PASS
- FastAPI: PASS
- Flask integration: PASS
- Load test (5 concurrent): PASS

**Issues Found and Resolved:**
- [Issue 1]: [How resolved]

**Status:** READY FOR DEMO
```

## Part 6: Demo Day Execution (10-15 min)

### Demo Setup

1. **Open three terminals/windows:**
   - Terminal 1: MLflow UI browser tab (`http://localhost:5001/`)
   - Terminal 2: Flask UI browser tab (`http://localhost:8080/`)
   - Terminal 3: Command line for testing

2. **Have demo script ready:**
   - Print `week-13/demo-script.md` or open it on a second screen
   - Verify all commands match your environment

3. **Assigned roles:**
   - Narrator: Explains what's happening
   - Demonstrator: Operates the terminals/UI
   - Backup: Ready if something breaks

### Demo Execution

Follow `week-13/demo-script.md` exactly. Key points:

1. **Introduce the challenge:** "We built an ML pipeline for incident severity prediction"
2. **Show the data:** PostgreSQL incidents (Week 1-2)
3. **Show the model:** MLflow experiment with metrics
4. **Show the service:** FastAPI inference endpoint (curl test)
5. **Show the integration:** Flask UI calling FastAPI
6. **Show reproducibility:** Ansible playbook automated everything

Total time: 10-15 minutes.

### Handling Interruptions

- **If MLflow UI won't load:** Show MLflow logs and explain the service is running
- **If FastAPI times out:** Show the systemd service status to prove it's running
- **If a curl command fails:** Retry; transient errors can happen
- **If Flask integration fails:** Explain the intended flow and show the code

### Q&A

Be prepared to answer:

1. "Why MLflow?" -- Tracks experiments, versioning, reproducibility
2. "Why FastAPI?" -- Fast, modern, easy to integrate with Flask
3. "What happens if the model predicts incorrectly?" -- Retrain with more data
4. "Can this scale to production?" -- Yes, with load balancing and monitoring
5. "How long to rebuild from scratch?" -- 10-15 minutes via Ansible

## Part 7: Post-Demo Documentation

### Update Demo Day Log

Complete the log:

```markdown
# Demo Day Log

**Date:** [Date]
**Instructor:** [Instructor name]
**Attendees:** [Team members and instructor]

## Demo Execution

**Time Started:** [timestamp]
**Time Ended:** [timestamp]
**Duration:** [X] minutes

**Components Demonstrated:**
- [ ] PostgreSQL incident data
- [ ] MLflow experiment and metrics
- [ ] FastAPI inference endpoint
- [ ] Flask integration
- [ ] Ansible playbook rebuild
- [ ] Complete end-to-end pipeline

**Feedback from Instructor:**
[Notes on feedback, questions asked, suggestions]

**Grade:** [To be provided by instructor]

## Reflection

### What went well:
- [Point 1]
- [Point 2]

### What could be improved:
- [Point 1]
- [Point 2]

### Final notes:
[Any final thoughts on the track]
```

### Complete Sprint 7 Retrospective

Fill in `docs/sprint-7-retrospective.md`:

```markdown
# Sprint 7 Retrospective

**Sprint Dates:** [Week 13 start] to [Week 14 end]

## Sprint Close: What Was Completed

**Completed Items:**

- Ansible playbook verified in check and production modes
- Demo script created and rehearsed
- Edge case testing and fixes applied
- Container wiped and rebuilt successfully
- Model retrained successfully
- Complete pipeline verified end-to-end
- Demo Day executed successfully

**Incomplete Items:**

- [None expected; this is the final sprint]

## Team Reflection Questions

### 1. What did you contribute to the final two weeks?

Each team member:
- **[Team Member 1]:** [Contributions to demo prep/rehearsal]
- **[Team Member 2]:** [Contributions to edge case testing/fixes]
- **[Team Member 3]:** [Contributions to Ansible verification]
- **[Team Member 4]:** [Contributions to demo execution]

### 2. What is the most important achievement of this track?

[Team consensus: e.g., "Building a fully reproducible ML pipeline that can be
stood up from scratch in 10 minutes via Ansible."]

### 3. What would you do differently if you started the track over?

[Reflections on process, architecture decisions, tool choices]

## Course Reflection

### MLflow and Experiment Tracking
- How useful was MLflow for managing experiments?
- What alternatives would you consider?

### FastAPI and Microservices
- How easy was it to integrate FastAPI with Flask?
- What about latency and performance?

### Ansible and Reproducibility
- How confident are you in the playbook?
- What would make it even more robust?

### Overall Track Experience
- Was this the right level of difficulty?
- Would you use these tools in a real project?

## Lessons for Future Teams

[Advice to future students taking Track 4:
- Start with a simple model first, then iterate
- Test the FastAPI integration early
- Don't underestimate the time for Ansible debugging
- Keep demo script simple and rehearsed
]

## Final Status

**Track Completion:** 100%
**Confidence in Pipeline:** High / Medium / Low
**Ready for Production:** Yes / With caveats / No
```

### Commit Final Files

```bash
git add week-14/ docs/
git commit -m "Week 14: Demo Day execution, final documentation"
git push origin main
```

## Deliverables Checklist

By end of Week 14 (Demo Day), you must have:

- [ ] Container wiped clean (no services running)
- [ ] Ansible playbook rebuilt entire environment from scratch
- [ ] MLflow service started automatically
- [ ] FastAPI service started automatically
- [ ] Flask application running
- [ ] Model retrained and registered
- [ ] End-to-end pipeline verified (all tests passing)
- [ ] Demo executed successfully in front of instructor
- [ ] `week-14/demo-day-log.md` completed with demo results
- [ ] `docs/sprint-7-retrospective.md` completed
- [ ] All files committed to git
- [ ] Repository clean and ready for submission

## Verification Commands

**Complete rebuild readiness:**

```bash
# Wipe
sudo rm -rf /opt/mlflow/* /opt/inference/*

# Rebuild
ansible-playbook -i ansible/inventory ansible/site.yml

# Verify
curl -s http://localhost:5001/health | grep -q ok && \
curl -s http://localhost:8000/health | grep -q ok && \
echo "READY FOR DEMO"
```

**Demo execution:**

```bash
bash week-12/test-pipeline.sh
# All four checks must show: OK
```

## Appendix: Troubleshooting Demo Day

### Issue: MLflow Service Won't Start

**Symptoms:** `curl http://localhost:5001/health` fails

**Diagnosis:**

```bash
sudo systemctl status mlflow
sudo journalctl -u mlflow -n 20
```

**Common causes:**

1. **Port 5001 already in use:**
   ```bash
   lsof -i :5001
   # Kill process or change port in template
   ```

2. **/opt/mlflow directory doesn't exist:**
   ```bash
   sudo mkdir -p /opt/mlflow
   sudo chmod 755 /opt/mlflow
   sudo systemctl restart mlflow
   ```

3. **Permissions issue:**
   ```bash
   sudo chown root:root /opt/mlflow
   sudo chmod 755 /opt/mlflow
   ```

### Issue: FastAPI Service Won't Start

**Symptoms:** `curl http://localhost:8000/health` fails

**Diagnosis:**

```bash
sudo systemctl status fastapi
sudo journalctl -u fastapi -n 20
```

**Common causes:**

1. **Model not found:** MLflow needs to have a trained model registered
   ```bash
   cd week-11
   python3 train-model.py
   ```

2. **Port 8000 already in use:**
   ```bash
   lsof -i :8000
   ```

3. **Python module not installed:**
   ```bash
   pip install fastapi uvicorn mlflow scikit-learn
   ```

### Issue: Model Training Fails

**Symptoms:** `python3 week-11/train-model.py` errors

**Diagnosis:**

```bash
# Check PostgreSQL
psql -U appuser -d statustracker -c "SELECT COUNT(*) FROM incidents;"
# Should return a number > 0

# Check Python environment
python3 -c "import mlflow, sklearn, pandas; print('OK')"
```

**Common causes:**

1. **PostgreSQL not running:**
   ```bash
   docker ps | grep postgres
   # If not running, restart container
   ```

2. **Connection string wrong:** Update in `train-model.py`

3. **Dependencies missing:**
   ```bash
   pip install mlflow scikit-learn pandas sqlalchemy psycopg2-binary
   ```

### Issue: Concurrent Requests Fail

**Symptoms:** Multiple curl requests to FastAPI return 503 or 500

**Diagnosis:** FastAPI may be overloaded or MLflow connection pooling issue

**Solution:** Increase gunicorn workers in MLflow service template:

```ini
ExecStart=/usr/bin/python3 -m mlflow server \
  --host 0.0.0.0 \
  --port 5001 \
  --backend-store-uri file:/opt/mlflow \
  --default-artifact-root /opt/mlflow/artifacts \
  --workers 4
```

Restart MLflow:

```bash
sudo systemctl restart mlflow
```

## Final Checklist Before Demo

- [ ] Container wiped
- [ ] Ansible playbook completed successfully
- [ ] All services running and responding to health checks
- [ ] Model trained and registered
- [ ] Demo script printed or on reference screen
- [ ] All team members know their roles
- [ ] Backup demonstrator ready
- [ ] Contingency plan if services fail
- [ ] Screenshots ready for reference
- [ ] Timer set for 10-15 minute demo

You're ready for Demo Day!
