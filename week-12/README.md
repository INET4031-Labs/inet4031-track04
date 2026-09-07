## Week 12: Challenge Build Continued - FastAPI Endpoint and Flask Integration

**Sprint 6 Continuation | Asynchronous**

### Overview

Week 12 builds on Week 11's MLflow foundation. Your team will build a FastAPI inference
endpoint that loads and serves your registered model, wire it into the Flask
application (the Compose stack at `localhost:8080`) so real incident data can be sent
for predictions, and verify the pipeline end to end. By Demo Day, this pipeline gets
rebuilt from a wiped container via Ansible — so anything you hardcode outside the role
now becomes a Week 14 problem.

By the end of this week, you will have:

1. FastAPI inference endpoint running and serving predictions on port 8000
2. Flask application calling the FastAPI endpoint with real incident data
3. Predictions displayed in the Flask UI (or logged/returned for verification)
4. End-to-end testing showing the complete pipeline
5. `ansible/roles/mlflow/` extended to also manage the FastAPI service

### Learning Objectives

- Build a FastAPI service that loads a model from the MLflow Model Registry on startup
- Design a request/response contract for a model-serving endpoint, including validation and error responses
- Integrate a microservice call into an existing Flask application with graceful failure handling
- Extend an Ansible role to manage a second systemd-backed service alongside the first
- Produce a repeatable end-to-end test that exercises the whole pipeline in one script

### Prerequisites

- Week 11 deliverables complete: MLflow server running, model trained and registered
- FastAPI and uvicorn installed (`pip install fastapi uvicorn httpx`)
- Flask application running on the Compose stack (`localhost:8080`)
- Ability to modify Flask application code

### Async Sprint Work

This continues Sprint 6 asynchronously. The FastAPI contract you settle on in Part 1
becomes the interface Flask, your test script, and (eventually) your demo script all
depend on — get your team to agree on the exact request/response shape before anyone
starts wiring Flask to it.

---

### Part 1: Build the FastAPI Inference Endpoint

**Step 1.** Create `week-12/inference-server.py`. The endpoint must expose `/health`
(returning `{"status":"ok","model_loaded":true}` once the model is loaded) and `/predict`
(accepting incident text and returning a prediction with a confidence score). Beyond
that shared contract, the exact request/response field names are your team's call —
document them in your ADR if you haven't already.

The skeleton below matches the recommended default from Week 11 (a resolution-status
classifier trained on `title`/`description`, predicting `status`). If your team is
serving a different target, keep the same structure — startup model load, `/health`,
`/predict` with Pydantic validation, model/run metadata in the response — but adjust
the field names and prediction values to match what your model actually outputs. Don't
label a `status` prediction as a "severity" — there is no severity label anywhere in
this pipeline.

```python
from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
from typing import Optional
import mlflow
import mlflow.sklearn
import numpy as np
import logging

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

app = FastAPI(title="Incident Inference Service", version="1.0.0")
loaded_model = None
MODEL_NAME = "incident-status-classifier"  # match the name you registered in Week 11

class PredictionRequest(BaseModel):
    title: str
    description: Optional[str] = None

class PredictionResponse(BaseModel):
    prediction: str          # e.g. "open" / "resolved" for the status classifier
    confidence: float
    model: str
    run_id: str

@app.on_event("startup")
async def load_model():
    global loaded_model
    try:
        loaded_model = mlflow.sklearn.load_model(f"models:/{MODEL_NAME}/latest")
        logger.info(f"Loaded model: {MODEL_NAME}")
    except Exception as e:
        logger.error(f"Failed to load model: {e}")
        raise

@app.get("/health")
async def health_check():
    if loaded_model is None:
        raise HTTPException(status_code=503, detail="Model not loaded")
    return {"status": "ok", "model_loaded": True}

@app.post("/predict", response_model=PredictionResponse)
async def predict(request: PredictionRequest):
    if loaded_model is None:
        raise HTTPException(status_code=503, detail="Model not loaded")
    try:
        text_input = request.title + " " + (request.description or "")
        prediction = loaded_model.predict([text_input])[0]
        if hasattr(loaded_model, 'predict_proba'):
            confidence = float(np.max(loaded_model.predict_proba([text_input])[0]))
        else:
            confidence = 1.0
        return PredictionResponse(
            prediction=prediction,
            confidence=confidence,
            model=MODEL_NAME,
            run_id="see MLflow UI"
        )
    except Exception as e:
        logger.error(f"Prediction error: {e}")
        raise HTTPException(status_code=400, detail=str(e))

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000, log_level="info")
```

**Step 2.** Run it and test both endpoints:

```bash
cd week-12
python3 inference-server.py
```

```bash
curl -s http://localhost:8000/health | python3 -m json.tool

curl -s -X POST http://localhost:8000/predict \
  -H "Content-Type: application/json" \
  -d '{"title": "Database Connection Timeout", "description": "Cannot reach PostgreSQL after 30s"}' | \
  python3 -m json.tool
```

Common failure modes: "Model not loaded" (check `curl http://localhost:5001/health` and
`mlflow models list`), `ModuleNotFoundError` (install missing packages), connection
refused (confirm uvicorn is bound to port 8000). Document anything unexpected in
`docs/sprint-12-retrospective.md`.

---

### Part 2: Integrate FastAPI into the Flask Application

**Step 1.** Add a route to your Flask app (the Compose stack, `localhost:8080`) that
calls the FastAPI `/predict` endpoint and handles the case where inference is
unavailable:

```python
from flask import request, jsonify
import httpx

INFERENCE_URL = "http://localhost:8000/predict"

@app.route("/incident/<int:incident_id>/predict", methods=["GET"])
def predict_for_incident(incident_id):
    incident = Incident.query.get(incident_id)
    if not incident:
        return jsonify({"error": "Incident not found"}), 404
    try:
        response = httpx.post(
            INFERENCE_URL,
            json={"title": incident.title, "description": incident.description or ""},
            timeout=5.0
        )
        response.raise_for_status()
        prediction = response.json()
        return jsonify({
            "incident_id": incident_id,
            "prediction": prediction["prediction"],
            "confidence": prediction["confidence"]
        })
    except httpx.ConnectError:
        return jsonify({"error": "Inference service unavailable"}), 503
    except Exception as e:
        return jsonify({"error": str(e)}), 400
```

Install `httpx` if you haven't: `pip install httpx`.

**Step 2 (optional).** Decide as a team whether and how to surface predictions in the
Flask UI. A minimal option is returning JSON only (fine for a curl-driven demo); a
richer option adds a button and result panel to the incident detail template. Either is
acceptable — document which you chose.

**Step 3.** Test the integration:

```bash
curl http://localhost:8080/incident/1/predict
```

Or exercise it through the UI if you built one. Document the integration in
`docs/sprint-12-retrospective.md`.

---

### Part 3: Extend the Ansible Role for FastAPI

`ansible/roles/mlflow/` already includes FastAPI installation, a directory task for
`/opt/inference`, a `fastapi.service.j2` template, and a restart handler — this was
scaffolded alongside the MLflow tasks in Week 10/11. Your job this week is to point it
at your actual inference script and confirm it comes up correctly:

```bash
ansible-playbook -i ansible/inventory ansible/site.yml --check
ansible-playbook -i ansible/inventory ansible/site.yml
curl -s http://localhost:8000/health
```

If the `copy` task's `src` path doesn't match where you put `inference-server.py`,
fix the path in `ansible/roles/mlflow/tasks/main.yml` rather than moving your script to
match the scaffold.

> **Enterprise Pattern:** The FastAPI systemd unit's `After=network.target
> mlflow.service` ordering means FastAPI won't start trying to load a model before
> MLflow is even up. This kind of explicit dependency ordering is exactly what
> production teams rely on instead of retry loops and hope.

---

### Part 4: End-to-End Testing

**Step 1.** Confirm all three services respond:

```bash
curl -s http://localhost:5001/health | python3 -m json.tool
curl -s http://localhost:8000/health | python3 -m json.tool
curl -s http://localhost:8080/ | head -20
```

**Step 2.** Write `week-12/test-pipeline.sh` that exercises the full chain — MLflow
health, FastAPI health, a prediction call, and the Flask integration call:

```bash
#!/bin/bash
echo "Testing ML Pipeline..."

curl -s http://localhost:5001/health | grep -q "ok" && echo "  MLflow: OK" || echo "  MLflow: FAIL"
curl -s http://localhost:8000/health | grep -q "ok" && echo "  FastAPI: OK" || echo "  FastAPI: FAIL"

PRED=$(curl -s -X POST http://localhost:8000/predict \
  -H "Content-Type: application/json" \
  -d '{"title": "Test Incident", "description": "A test"}')
echo "  Prediction response: $PRED"

FLASK=$(curl -s http://localhost:8080/incident/1/predict)
echo "  Flask response: $FLASK"
echo "Done."
```

```bash
chmod +x week-12/test-pipeline.sh
./week-12/test-pipeline.sh
```

**Step 3.** Capture MLflow UI screenshots (experiment, run metrics, registered model)
for Demo Day reference material.

---

### Validation Checks

**QA runs all validation checks.** Cross-check against
`docs/qa-report-12.md` before closing out Week 12 stories.

#### Validation Check: FastAPI and Flask Integration

Manually confirm what a script can't fully cover: `/predict` returns a `prediction` and
`confidence` field with sensible values for your chosen target, the Flask endpoint
returns a 503 (not a 500 or a hang) when FastAPI is stopped, and the field names in your
FastAPI response match what your Flask integration expects.

```bash
./scripts/check-week-12.sh
bash week-12/test-pipeline.sh
```

---

### Deliverables

- [ ] `week-12/inference-server.py` running on port 8000, loading the registered model
- [ ] `/health` and `/predict` endpoints working with documented request/response shape
- [ ] Flask endpoint calling FastAPI, with graceful 503 handling when it's down
- [ ] `ansible/roles/mlflow/` extended so the playbook starts both MLflow and FastAPI
- [ ] `week-12/test-pipeline.sh` created and passing
- [ ] MLflow UI screenshots captured
- [ ] All files committed to git

### Sprint Backlog: Preparing for Week 13

Scrum Master, open these tickets to close out Sprint 6 and open Sprint 7:

- **MLFLOW-11:** Run the full Ansible playbook in check mode and log any failures
- **MLFLOW-12:** Draft `week-13/demo-script.md` covering all five pipeline components
- **MLFLOW-13:** Identify edge cases to test (service down, bad input, restart recovery)
- **MLFLOW-14:** Schedule the Sprint 7 demo rehearsal with the full team
- **MLFLOW-15:** Complete `docs/sprint-12-retrospective.md`

---
