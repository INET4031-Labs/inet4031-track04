# Week 12: Challenge Build Continued - FastAPI Endpoint and Flask Integration

**Sprint 6 Continuation | Asynchronous**

## Overview

Week 12 builds on Week 11's MLflow foundation. Your team will create a FastAPI
inference endpoint that loads and serves the trained model, integrate it into your
Flask application so that users can request predictions on incident data, and verify
the complete pipeline end-to-end. By Demo Day (Week 14), this pipeline will be
rebuilt from a wiped container via Ansible.

By the end of this week, you will have:

1. FastAPI inference endpoint running and serving predictions
2. Flask application calling the FastAPI endpoint with incident data
3. Predictions displayed in the Flask UI (or logged for verification)
4. End-to-end testing showing the complete pipeline
5. Ansible role updated to include FastAPI service

## Prerequisites

- Week 11 deliverables complete (MLflow server running, model trained and registered)
- FastAPI and uvicorn installed (`pip install fastapi uvicorn httpx`)
- Flask application running (from Weeks 1-9)
- Ability to modify Flask application code

## Part 1: Build FastAPI Inference Endpoint (1.5 hours)

### Step 1: Create FastAPI Application

Create a file `week-12/inference-server.py`:

```python
from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
from typing import Optional
import mlflow
import mlflow.sklearn
import numpy as np
import logging

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# Initialize FastAPI app
app = FastAPI(title="Incident Inference Service", version="1.0.0")

# Global model variable
loaded_model = None

class PredictionRequest(BaseModel):
    """Request model for severity classifier"""
    title: str
    description: Optional[str] = None

class ResolutionPredictionRequest(BaseModel):
    """Request model for resolution time predictor"""
    title: str
    description: Optional[str] = None
    severity: Optional[str] = None

class PredictionResponse(BaseModel):
    """Response model for predictions"""
    prediction: str
    confidence: float
    model: str
    run_id: str

class ResolutionPredictionResponse(BaseModel):
    """Response model for time predictions"""
    predicted_hours: float
    confidence: float
    model: str
    run_id: str

@app.on_event("startup")
async def load_model():
    """Load model from MLflow on startup"""
    global loaded_model
    try:
        # Load the latest version of the registered model
        model_name = "incident-status-classifier"  # Change if using resolution predictor
        model = mlflow.sklearn.load_model(f"models:/{model_name}/latest")
        loaded_model = model
        logger.info(f"Loaded model: {model_name}")
    except Exception as e:
        logger.error(f"Failed to load model: {e}")
        raise

@app.get("/health")
async def health_check():
    """Health check endpoint"""
    if loaded_model is None:
        raise HTTPException(status_code=503, detail="Model not loaded")
    return {"status": "ok", "model_loaded": True}

@app.post("/predict", response_model=PredictionResponse)
async def predict(request: PredictionRequest):
    """
    Predict severity for an incident.
    
    For severity classifier:
    - Input: title and description
    - Output: predicted severity (critical/high/medium/low)
    """
    if loaded_model is None:
        raise HTTPException(status_code=503, detail="Model not loaded")
    
    try:
        # Combine title and description (same as training pipeline)
        text_input = request.title + " " + (request.description or "")
        
        # Make prediction
        prediction = loaded_model.predict([text_input])[0]
        
        # Get prediction probabilities for confidence
        if hasattr(loaded_model, 'predict_proba'):
            proba = loaded_model.predict_proba([text_input])[0]
            confidence = float(np.max(proba))
        else:
            confidence = 1.0
        
        return PredictionResponse(
            prediction=prediction,
            confidence=confidence,
            model="incident-status-classifier",
            run_id="see MLflow UI"
        )
    except Exception as e:
        logger.error(f"Prediction error: {e}")
        raise HTTPException(status_code=400, detail=str(e))

@app.post("/predict-resolution", response_model=ResolutionPredictionResponse)
async def predict_resolution(request: ResolutionPredictionRequest):
    """
    Predict time-to-resolution for an incident.
    
    For resolution time predictor:
    - Input: title, description, severity
    - Output: predicted resolution time in hours
    """
    if loaded_model is None:
        raise HTTPException(status_code=503, detail="Model not loaded")
    
    try:
        # This is a simplified example; real implementation would match training pipeline
        text_input = request.title + " " + (request.description or "")
        severity_map = {'critical': 3, 'high': 2, 'medium': 1, 'low': 0}
        severity_code = severity_map.get(request.severity or 'medium', 1)
        
        # For now, assume the model expects the same input as training
        # In production, ensure consistent feature preprocessing
        prediction = loaded_model.predict([[severity_code]])[0]  # Simplified
        
        return ResolutionPredictionResponse(
            predicted_hours=float(prediction),
            confidence=0.8,  # Placeholder
            model="incident-resolution-predictor",
            run_id="see MLflow UI"
        )
    except Exception as e:
        logger.error(f"Prediction error: {e}")
        raise HTTPException(status_code=400, detail=str(e))

@app.get("/")
async def root():
    """Root endpoint with documentation"""
    return {
        "service": "Incident Inference Service",
        "version": "1.0.0",
        "endpoints": {
            "health": "/health",
            "predict": "/predict (POST)",
            "docs": "/docs"
        }
    }

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000, log_level="info")
```

### Step 2: Test FastAPI Locally

Run the inference server:

```bash
cd week-12
python3 inference-server.py
```

Expected output:

```
INFO:     Uvicorn running on http://0.0.0.0:8000 (Press CTRL+C to quit)
INFO:     Loaded model: incident-status-classifier
```

### Step 3: Test Endpoints with curl

In another terminal, test the endpoints:

**Health check:**

```bash
curl -s http://localhost:8000/health | python3 -m json.tool
```

Expected response:

```json
{"status":"ok","model_loaded":true}
```

**Prediction endpoint (severity classifier):**

```bash
curl -s -X POST http://localhost:8000/predict \
  -H "Content-Type: application/json" \
  -d '{"title": "High CPU Usage", "description": "System experiencing 100% CPU"}' | \
  python3 -m json.tool
```

Expected response:

```json
{
  "prediction": "critical",
  "confidence": 0.92,
  "model": "incident-status-classifier",
  "run_id": "see MLflow UI"
}
```

If you encounter errors:

1. **"Model not loaded"**: Verify MLflow is running and model is registered
   ```bash
   curl http://localhost:5001/health
   mlflow models list
   ```

2. **"ModuleNotFoundError"**: Install missing packages
   ```bash
   pip install fastapi uvicorn pydantic
   ```

3. **Connection refused**: Verify FastAPI is listening on port 8000
   ```bash
   netstat -tlnp | grep 8000
   ```

Document any issues in `docs/environment-log.md`.

## Part 2: Integrate FastAPI into Flask Application (1.5 hours)

### Step 1: Add Inference Route to Flask

Modify your Flask application to call the inference endpoint. For example, add to your
Flask app (typically in `app.py` or a views file):

```python
from flask import render_template, request, jsonify
import httpx

# Inference endpoint URL
INFERENCE_URL = "http://localhost:8000/predict"

@app.route("/incident/predict", methods=["POST"])
def predict_incident_severity():
    """
    Endpoint to predict incident severity.
    Expects JSON: {"title": "...", "description": "..."}
    """
    try:
        data = request.get_json()
        
        # Call FastAPI inference endpoint
        response = httpx.post(
            INFERENCE_URL,
            json={"title": data.get("title"), "description": data.get("description")},
            timeout=5.0
        )
        response.raise_for_status()
        
        prediction = response.json()
        return jsonify({
            "success": True,
            "prediction": prediction["prediction"],
            "confidence": prediction["confidence"]
        })
    
    except httpx.ConnectError:
        return jsonify({"success": False, "error": "Inference service unavailable"}), 503
    except Exception as e:
        return jsonify({"success": False, "error": str(e)}), 400

@app.route("/incident/<int:incident_id>/suggest-severity", methods=["GET"])
def suggest_severity(incident_id):
    """
    GET endpoint to get severity suggestion for an incident from the database.
    """
    try:
        # Query incident from database (example using SQLAlchemy)
        incident = Incident.query.get(incident_id)
        if not incident:
            return jsonify({"error": "Incident not found"}), 404
        
        # Call inference endpoint
        response = httpx.post(
            INFERENCE_URL,
            json={"title": incident.title, "description": incident.description or ""},
            timeout=5.0
        )
        response.raise_for_status()
        
        prediction = response.json()
        return jsonify({
            "incident_id": incident_id,
            "suggested_severity": prediction["prediction"],
            "confidence": prediction["confidence"]
        })
    
    except httpx.ConnectError:
        return jsonify({"error": "Inference service unavailable"}), 503
    except Exception as e:
        return jsonify({"error": str(e)}), 400
```

Ensure `httpx` is installed:

```bash
pip install httpx
```

### Step 2: Update Flask Template (Optional)

If you want to show predictions in the UI, add a form to your incident detail page:

```html
<!-- In your incident detail template (e.g., incident.html) -->
<div class="card">
  <div class="card-header">Severity Suggestion</div>
  <div class="card-body">
    <button id="suggest-btn" class="btn btn-primary">Get AI Suggestion</button>
    <div id="suggestion-result" style="margin-top: 10px;"></div>
  </div>
</div>

<script>
document.getElementById('suggest-btn').addEventListener('click', async () => {
  const incidentId = {{ incident.id }};
  try {
    const response = await fetch(`/incident/${incidentId}/suggest-severity`);
    const data = await response.json();
    if (response.ok) {
      document.getElementById('suggestion-result').innerHTML = `
        <div class="alert alert-info">
          Suggested Severity: <strong>${data.suggested_severity}</strong>
          (Confidence: ${(data.confidence * 100).toFixed(1)}%)
        </div>
      `;
    } else {
      document.getElementById('suggestion-result').innerHTML = `
        <div class="alert alert-danger">Error: ${data.error}</div>
      `;
    }
  } catch (error) {
    document.getElementById('suggestion-result').innerHTML = `
      <div class="alert alert-danger">Error: ${error.message}</div>
    `;
  }
});
</script>
```

### Step 3: Test Flask Integration

1. Verify Flask application is running:
   ```bash
   python3 app.py  # or however you start your Flask app
   ```

2. Verify FastAPI inference server is running (in a separate terminal):
   ```bash
   cd week-12
   python3 inference-server.py
   ```

3. Make a request to your Flask predict endpoint:
   ```bash
   curl -X POST http://localhost:8080/incident/predict \
     -H "Content-Type: application/json" \
     -d '{"title": "Database Connection Error", "description": "Cannot connect to PostgreSQL"}'
   ```

4. Or navigate to an incident detail page and click the "Get AI Suggestion" button.

Document the Flask integration details in `docs/environment-log.md`.

## Part 3: Update Ansible Role for FastAPI (45 min)

### Step 1: Add FastAPI to Role Tasks

Update `ansible/roles/mlflow/tasks/main.yml` to include FastAPI:

```yaml
---
- name: Install MLflow and dependencies
  pip:
    name:
      - mlflow
      - scikit-learn
      - pandas
      - sqlalchemy
      - psycopg2-binary
      - fastapi
      - uvicorn
      - httpx
      - pydantic
    state: present
  become: yes

# ... existing MLflow tasks ...

- name: Deploy FastAPI systemd service
  template:
    src: fastapi.service.j2
    dest: /etc/systemd/system/fastapi.service
    owner: root
    group: root
    mode: '0644'
  become: yes
  notify: Restart FastAPI service

- name: Enable and start FastAPI service
  systemd:
    name: fastapi
    enabled: yes
    state: started
    daemon_reload: yes
  become: yes
```

### Step 2: Add FastAPI Service Template

Create `ansible/roles/mlflow/templates/fastapi.service.j2`:

```ini
[Unit]
Description=FastAPI Inference Server
After=network.target mlflow.service

[Service]
Type=simple
User=root
WorkingDirectory=/opt/inference
ExecStart=/usr/bin/python3 -m uvicorn inference-server:app \
  --host 0.0.0.0 \
  --port 8000
Restart=on-failure
RestartSec=10

[Install]
WantedBy=multi-user.target
```

### Step 3: Copy Inference Script via Ansible

Add a task to deploy the inference script:

```yaml
- name: Create inference app directory
  file:
    path: /opt/inference
    state: directory
    owner: root
    group: root
    mode: '0755'
  become: yes

- name: Deploy inference server script
  copy:
    src: ../../../week-12/inference-server.py  # Adjust path as needed
    dest: /opt/inference/inference-server.py
    owner: root
    group: root
    mode: '0644'
  become: yes
  notify: Restart FastAPI service
```

### Step 4: Add Handler for FastAPI

Update `ansible/roles/mlflow/handlers/main.yml`:

```yaml
---
- name: Restart MLflow service
  systemd:
    name: mlflow
    state: restarted
  become: yes

- name: Restart FastAPI service
  systemd:
    name: fastapi
    state: restarted
  become: yes
```

## Part 4: End-to-End Testing (1 hour)

### Step 1: Verify All Services

Ensure all three services are running:

```bash
# MLflow
curl -s http://localhost:5001/health | python3 -m json.tool

# FastAPI
curl -s http://localhost:8000/health | python3 -m json.tool

# Flask (if it has a health endpoint)
curl -s http://localhost:8080/ | head -20
```

### Step 2: Test Complete Pipeline

Perform an end-to-end test:

1. **Incident selection**: Use a real incident from your PostgreSQL database
2. **Inference call**: Call `/incident/<id>/suggest-severity` from Flask
3. **Result verification**: Confirm the prediction appears in the Flask UI
4. **MLflow check**: Open MLflow UI and verify the run is logged (if you log each call)

Example script (`week-12/test-pipeline.sh`):

```bash
#!/bin/bash

echo "Testing ML Pipeline..."

# 1. Check MLflow
echo "1. Checking MLflow..."
curl -s http://localhost:5001/health | grep -q "ok" && echo "  MLflow: OK" || echo "  MLflow: FAIL"

# 2. Check FastAPI
echo "2. Checking FastAPI..."
curl -s http://localhost:8000/health | grep -q "ok" && echo "  FastAPI: OK" || echo "  FastAPI: FAIL"

# 3. Test prediction
echo "3. Testing prediction..."
PRED=$(curl -s -X POST http://localhost:8000/predict \
  -H "Content-Type: application/json" \
  -d '{"title": "Test Incident", "description": "A test"}')
echo "  Response: $PRED"

# 4. Test Flask integration
echo "4. Testing Flask integration..."
FLASK=$(curl -s http://localhost:8080/incident/1/suggest-severity)
echo "  Response: $FLASK"

echo "Done."
```

Run the test:

```bash
chmod +x week-12/test-pipeline.sh
./week-12/test-pipeline.sh
```

### Step 3: Screenshot MLflow UI

Navigate to `http://localhost:5001/` and capture screenshots of:

1. The experiment showing your training run
2. The model registry showing the registered model
3. Metrics and artifacts for the run

Save these to your documentation for Demo Day.

## Part 5: Document in Acceptance Criteria and Environment Log

### Update Acceptance Criteria

Fill in `docs/week-12-acceptance-criteria.md`:

```markdown
# Week 12 Acceptance Criteria

## FastAPI Inference Endpoint

- [ ] FastAPI application created (`week-12/inference-server.py`)
- [ ] FastAPI imports and loads registered model from MLflow
- [ ] Health check endpoint (`/health`) responds with `{"status":"ok"}`
- [ ] Prediction endpoint (`/predict`) accepts incident text and returns prediction
- [ ] Prediction includes confidence score
- [ ] FastAPI runs without errors: `python3 week-12/inference-server.py`
- [ ] Endpoint is accessible at `http://localhost:8000`

## Flask Integration

- [ ] Flask app has new endpoint calling FastAPI inference
- [ ] Flask endpoint accepts incident data and returns prediction
- [ ] Error handling: graceful failure if inference service is down
- [ ] Flask UI displays prediction results (or logged appropriately)
- [ ] Tested with curl and/or browser

## Ansible Role Updates

- [ ] Ansible role includes FastAPI installation tasks
- [ ] Ansible role includes FastAPI systemd service template
- [ ] Service template file created: `ansible/roles/mlflow/templates/fastapi.service.j2`
- [ ] Playbook runs without errors: `ansible-playbook -i ansible/inventory ansible/site.yml`
- [ ] Both MLflow and FastAPI services start after playbook runs

## End-to-End Testing

- [ ] All three services running: MLflow, FastAPI, Flask
- [ ] MLflow health check passes
- [ ] FastAPI health check passes
- [ ] Flask can call FastAPI and return predictions
- [ ] Predictions are reasonable (correct format, sensible values)

## Documentation

- [ ] `docs/environment-log.md` updated with FastAPI details
- [ ] FastAPI request/response examples documented
- [ ] Any integration issues noted and resolved
- [ ] Screenshots of MLflow UI with registered model captured

## Verification

- [ ] `./scripts/check-week-12.sh` passes
```

### Update Environment Log

Add a Week 12 section to `docs/environment-log.md`:

```markdown
### Week 12: FastAPI Endpoint and Flask Integration

**FastAPI Inference Server:**
- Version: [output of pip show fastapi]
- Host: 0.0.0.0
- Port: 8000
- Model loaded: incident-status-classifier
- Status: Running

**Flask Integration:**
- Endpoint: /incident/<id>/suggest-severity
- Response time: [measured time]
- Error handling: graceful with 503 when inference service down
- UI updates: Yes/No

**Testing Results:**
- End-to-end test: [PASS/FAIL]
- Sample predictions: [2-3 examples with actual output]
- MLflow logging: Yes/No

**Issues Encountered:**
- [Issue 1]: [Resolution]
```

## Part 6: Commit and Verify

Commit all Week 12 work:

```bash
git add week-12/ ansible/ docs/
git commit -m "Week 12: FastAPI endpoint, Flask integration, end-to-end testing"
git push origin main
```

Run the Week 12 validation script:

```bash
./scripts/check-week-12.sh
```

## Deliverables Checklist

By end of Week 12, you must have:

- [ ] FastAPI inference server running on port 8000
- [ ] FastAPI loads and serves registered MLflow model
- [ ] FastAPI `/health` and `/predict` endpoints working
- [ ] Flask application integrated with FastAPI inference call
- [ ] Flask calls inference endpoint and displays/logs results
- [ ] Ansible role updated with FastAPI installation and service
- [ ] Ansible playbook runs successfully (playbook now starts both MLflow and FastAPI)
- [ ] End-to-end pipeline tested and verified
- [ ] MLflow UI screenshots captured
- [ ] `docs/week-12-acceptance-criteria.md` completed
- [ ] `docs/environment-log.md` updated
- [ ] `./scripts/check-week-12.sh` passes
- [ ] All files committed to git

## Verification Commands

**MLflow health:**
```bash
curl -s http://localhost:5001/health 2>/dev/null && echo "MLflow up" || echo "FAIL"
```

**FastAPI health:**
```bash
curl -s http://localhost:8000/health 2>/dev/null && echo "FastAPI up" || echo "FAIL"
```

**Full pipeline:**
```bash
bash week-12/test-pipeline.sh
```

## Next Steps

Week 13 transitions to synchronous sprint ceremonies and preparation for Demo Day:

1. Ansible playbook dry-run and fixes
2. Demo script rehearsal
3. Edge-case handling and robustness
4. Sprint 6 retrospective completion

Refer to `week-13/README.md` for detailed instructions.
