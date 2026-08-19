---
**Week 1-9 Prerequisite**

Weeks 10-14 assume your completed Weeks 1-9 repositories are available as peer directories in `Student Repositories/`. This track's Ansible roles reference your prior work:
- `mlflow` role uses your Flask application from Week 2 (`../week-02/`)
- `mlflow` role connects to your PostgreSQL database from Week 4 (`../week-04/` or `../infrastructure/`)

Your track repo does NOT copy these — it integrates with them. Ensure your Week 1-9 work is complete and accessible before Week 11.

---

# Week 11: Core Build - MLflow and Model Training

**Sprint 6 | Asynchronous**

## Overview

Week 11 is the core build phase. Your team will install MLflow, set up a tracking server,
write a data preparation and model training pipeline, and log your first trained model
to MLflow with full metrics and artifacts. The MLflow UI should display a complete run
with a registered model ready for serving in Week 12.

By the end of this week, you will have:

1. MLflow tracking server running and accessible at `http://localhost:5001`
2. A Python training pipeline that reads incidents from PostgreSQL (statustracker database)
3. A trained scikit-learn model logged to MLflow with metrics (incident status classifier)
4. A model registered in the MLflow Model Registry
5. The beginning of an Ansible role that installs MLflow

## Prerequisites

- Week 10 architecture decision and backlog completed
- Docker container with PostgreSQL running and incidents table populated (from Week 2)
- Flask application running (from Weeks 1-9)
- Python 3.8+ installed in container
- pip package manager available

## Part 1: Install MLflow (30 min)

### Step 1: Install MLflow and Dependencies

In your container, install MLflow and scikit-learn:

```bash
pip install mlflow scikit-learn pandas sqlalchemy psycopg2-binary
```

Verify installation:

```bash
mlflow --version
python3 -c "import mlflow; print('MLflow version:', mlflow.version.VERSION)"
python3 -c "import sklearn; print('scikit-learn version:', sklearn.__version__)"
```

### Step 2: Start MLflow Tracking Server

Launch the MLflow tracking server on port 5001:

```bash
mlflow server --host 0.0.0.0 --port 5001 --backend-store-uri file:./mlflow --default-artifact-root ./mlflow/artifacts
```

The command will display output like:

```
[YYYY-MM-DD HH:MM:SS +0000] [123456] [INFO] Starting gunicorn 20.x.x
[YYYY-MM-DD HH:MM:SS +0000] [123456] [INFO] Listening at: http://0.0.0.0:5001
```

### Step 3: Verify MLflow is Accessible

In another terminal, verify the server is running:

```bash
curl -s http://localhost:5001/health
```

Expected output:

```json
{"status":"ok"}
```

Or, open a browser and navigate to `http://localhost:5001/` to see the MLflow UI
(though you will see it is empty until you log experiments).

## Part 2: Prepare Training Data from PostgreSQL (45 min)

### Step 1: Write a Data Fetch Script

Create a file `week-11/fetch-incidents.py`:

```python
import pandas as pd
from sqlalchemy import create_engine

# Connect to PostgreSQL
# ASSUMPTION: PostgreSQL is running on localhost:5432
# Database: statustracker, User: appuser (established in Week 2)
engine = create_engine(
    "postgresql://appuser:changeme@localhost:5432/statustracker"
)

# Query incidents table
query = """
SELECT 
    id,
    title,
    description,
    status,
    created_at
FROM incidents
ORDER BY created_at
"""

df = pd.read_sql(query, con=engine)

print(f"Loaded {len(df)} incidents")
print(df.head())
print(df.info())

df.to_csv("incidents_data.csv", index=False)
print("Saved to incidents_data.csv")
```

ASSUMPTION: Your PostgreSQL database and user match the Week 2 baseline:
- Database: `statustracker` (established in Week 2)
- User: `appuser` (established in Week 2)
- Password: `changeme` (default; update if different)
- Host: `localhost`
- Port: `5432`

Note: The incidents table contains columns: id, title, description, status, created_at.
There are no severity, resolved_at, or assigned_to columns.

### Step 2: Test the Data Fetch

Run the script:

```bash
cd week-11
python3 fetch-incidents.py
```

Expected output:

```
Loaded 42 incidents
   id              title  ...          resolved_at  assigned_to
0   1  High CPU Usage  ...  2026-08-15 10:30:00  alice
...
```

If you see an error connecting to PostgreSQL, verify:

1. PostgreSQL container is running: `docker ps | grep postgres`
2. Connection string matches your setup
3. Incidents table exists and has data

Document any connection or data issues in `docs/environment-log.md`.

## Part 3: Build the Training Pipeline (1.5 hours)

### Step 1: Feature Engineering Script

Create a file `week-11/train-model.py` that:

1. Loads incidents data from PostgreSQL
2. Selects features based on your Week 10 architecture decision
3. Prepares labels (target variable)
4. Splits data into train/test sets
5. Trains a scikit-learn model
6. Logs to MLflow

Here is a template for an **incident status classifier** (predicts open vs. resolved):

```python
import pandas as pd
import numpy as np
from sqlalchemy import create_engine
from sklearn.model_selection import train_test_split
from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.ensemble import RandomForestClassifier
from sklearn.metrics import accuracy_score, precision_score, recall_score, f1_score
from sklearn.pipeline import Pipeline
import mlflow
import mlflow.sklearn

# Connect to PostgreSQL and fetch data
engine = create_engine(
    "postgresql://appuser:changeme@localhost:5432/statustracker"
)

query = """
SELECT title, description, status
FROM incidents
ORDER BY created_at
"""

df = pd.read_sql(query, con=engine)

print(f"Loaded {len(df)} incidents")
print(df['status'].value_counts())

# Feature engineering: combine title and description
df['text'] = df['title'] + ' ' + df['description'].fillna('')
X = df['text']
y = df['status']

# Train/test split
X_train, X_test, y_train, y_test = train_test_split(
    X, y, test_size=0.2, random_state=42, stratify=y
)

print(f"Train set: {len(X_train)}, Test set: {len(X_test)}")

# Set MLflow experiment
mlflow.set_experiment("incident-status-classifier")

# Start a new run
with mlflow.start_run() as run:
    # Log parameters
    mlflow.log_param("model_type", "RandomForest")
    mlflow.log_param("max_depth", 10)
    mlflow.log_param("n_estimators", 100)
    
    # Create pipeline with TF-IDF vectorizer and classifier
    pipeline = Pipeline([
        ('tfidf', TfidfVectorizer(max_features=100, ngram_range=(1, 2))),
        ('rf', RandomForestClassifier(max_depth=10, n_estimators=100, random_state=42))
    ])
    
    # Train model
    pipeline.fit(X_train, y_train)
    
    # Make predictions
    y_pred = pipeline.predict(X_test)
    
    # Compute metrics
    accuracy = accuracy_score(y_test, y_pred)
    precision = precision_score(y_test, y_pred, average='weighted', zero_division=0)
    recall = recall_score(y_test, y_pred, average='weighted', zero_division=0)
    f1 = f1_score(y_test, y_pred, average='weighted', zero_division=0)
    
    # Log metrics to MLflow
    mlflow.log_metric("accuracy", accuracy)
    mlflow.log_metric("precision", precision)
    mlflow.log_metric("recall", recall)
    mlflow.log_metric("f1", f1)
    
    # Log the model
    mlflow.sklearn.log_model(pipeline, "model")
    
    print(f"Run {run.info.run_id} logged:")
    print(f"  Accuracy: {accuracy:.4f}")
    print(f"  Precision: {precision:.4f}")
    print(f"  Recall: {recall:.4f}")
    print(f"  F1: {f1:.4f}")

# Register the model
model_uri = f"runs/{run.info.run_id}/model"
mlflow.register_model(model_uri, "incident-status-classifier")
print(f"Model registered as 'incident-status-classifier'")
```

NOTE: This model predicts incident status (open/resolved) based on the incident title and
description. The Week 1-9 baseline schema does not include severity, resolved_at, or
assigned_to columns, so severity classifiers and time-to-resolution predictors are not
feasible with the available data.

### Step 2: Run the Training Pipeline

Execute the training script:

```bash
python3 train-model.py
```

Expected output (status classifier):

```
Loaded 50000 incidents
resolved    12500
open        37500
Train set: 40000, Test set: 10000
Run abc123def456 logged:
  Accuracy: 0.7234
  Precision: 0.7156
  Recall: 0.7234
  F1: 0.7195
Model registered as 'incident-status-classifier'
```

If you see errors, check:

1. PostgreSQL is running and connection string is correct
2. Database is statustracker and user is appuser (from Week 2 setup)
3. Incidents table has data (50,000 rows from Week 9 seeding)
4. MLflow server is running on port 5001
5. All pip packages are installed

## Part 4: Verify Model in MLflow UI (15 min)

### Step 1: Access MLflow UI

Open a browser and navigate to `http://localhost:5001/`

You should see:

1. An experiment named `incident-status-classifier`
2. A run with your metrics displayed
3. An "Artifacts" tab showing the logged model artifacts

### Step 2: Register Model Version

In the MLflow UI, navigate to the "Models" tab in the left sidebar. You should see
your registered model `incident-status-classifier` with a model version.

If the model is not registered, register it manually from the CLI:

```bash
mlflow models list
mlflow models describe incident-status-classifier
```

## Part 5: Document in Environment Log

Update `docs/environment-log.md` with:

1. MLflow server version and host/port
2. Model name and version
3. Training script location and execution time
4. Metrics captured
5. Any data quality issues encountered
6. PostgreSQL connection details and row count

Template entry:

```markdown
### Week 11: MLflow and Model Training

**MLflow Tracking Server:**
- Version: [output of mlflow --version]
- Host: 0.0.0.0
- Port: 5001
- Backend: file:./mlflow
- Status: Running

**Model Training:**
- Model name: incident-status-classifier
- Training script: week-11/train-model.py
- Features: title and description (TF-IDF vectorized)
- Target: status (open or resolved)
- Data points: ~50,000 incidents
- Train/test split: 80/20
- Execution time: [minutes]

**Metrics:**
- Accuracy/MAE: [value]
- Precision/RMSE: [value]
- Recall/R2: [value]
- F1/Other: [value]

**Artifacts:**
- Model location: mlflow/artifacts/[run_id]/model
- Model type: scikit-learn pipeline
```

## Part 6: Implement Ansible Role for MLflow

### Step 1: Create Role Tasks

Create `ansible/roles/mlflow/tasks/main.yml`:

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
    state: present
  become: yes

- name: Create MLflow data directory
  file:
    path: /opt/mlflow
    state: directory
    owner: root
    group: root
    mode: '0755'
  become: yes

- name: Create MLflow artifacts directory
  file:
    path: /opt/mlflow/artifacts
    state: directory
    owner: root
    group: root
    mode: '0755'
  become: yes

- name: Deploy MLflow systemd service
  template:
    src: mlflow.service.j2
    dest: /etc/systemd/system/mlflow.service
    owner: root
    group: root
    mode: '0644'
  become: yes
  notify: Restart MLflow service

- name: Enable and start MLflow service
  systemd:
    name: mlflow
    enabled: yes
    state: started
    daemon_reload: yes
  become: yes
```

### Step 2: Create Handler

Create `ansible/roles/mlflow/handlers/main.yml`:

```yaml
---
- name: Restart MLflow service
  systemd:
    name: mlflow
    state: restarted
  become: yes
```

### Step 3: Create Service Template

Create `ansible/roles/mlflow/templates/mlflow.service.j2`:

```ini
[Unit]
Description=MLflow Tracking Server
After=network.target

[Service]
Type=simple
User=root
WorkingDirectory=/opt/mlflow
ExecStart=/usr/bin/python3 -m mlflow server \
  --host 0.0.0.0 \
  --port 5001 \
  --backend-store-uri file:/opt/mlflow \
  --default-artifact-root /opt/mlflow/artifacts
Restart=on-failure
RestartSec=10

[Install]
WantedBy=multi-user.target
```

### Step 4: Create Defaults and Vars

Create `ansible/roles/mlflow/defaults/main.yml`:

```yaml
---
mlflow_host: 0.0.0.0
mlflow_port: 5001
mlflow_data_dir: /opt/mlflow
mlflow_artifacts_dir: /opt/mlflow/artifacts
```

Create `ansible/roles/mlflow/vars/main.yml`:

```yaml
---
# Variables specific to MLflow role (can be overridden)
mlflow_packages:
  - mlflow
  - scikit-learn
  - pandas
  - sqlalchemy
  - psycopg2-binary
```

## Part 7: Test Ansible Role

Add the MLflow role to your site.yml (if not already present):

In `ansible/site.yml`, ensure the mlflow role is included:

```yaml
---
- hosts: all
  roles:
    # ... other roles from Weeks 1-9 ...
    - mlflow
```

Test the playbook in dry-run mode:

```bash
ansible-playbook -i ansible/inventory ansible/site.yml --check
```

Then run it for real:

```bash
ansible-playbook -i ansible/inventory ansible/site.yml
```

Verify MLflow is running after the playbook:

```bash
curl -s http://localhost:5001/health
```

## Part 8: Commit and Verify

Commit all Week 11 work:

```bash
git add week-11/ ansible/ docs/
git commit -m "Week 11: MLflow server, model training, Ansible role"
git push origin main
```

Run the Week 11 validation script:

```bash
./scripts/check-week-11.sh
```

## Deliverables Checklist

By end of Week 11, you must have:

- [ ] MLflow tracking server running on port 5001
- [ ] Data fetch script (`fetch-incidents.py`) that reads from statustracker database with appuser
- [ ] Training script (`train-model.py`) that builds incident status classifier
- [ ] Model trained and logged to MLflow with accuracy/precision/recall/f1 metrics
- [ ] Model registered in MLflow Model Registry as `incident-status-classifier`
- [ ] MLflow UI showing the run with metrics and artifacts
- [ ] Ansible role (`ansible/roles/mlflow/`) created with full tasks
- [ ] Ansible playbook includes mlflow role and runs without error
- [ ] `scripts/check-week-11.sh` passes
- [ ] `docs/week-11-acceptance-criteria.md` completed
- [ ] `docs/environment-log.md` updated with MLflow and database details
- [ ] All files committed to git

## Verification Command

```bash
curl -s http://localhost:5001/health 2>/dev/null && echo "MLflow up" || echo "FAIL"
```

Expected output: `MLflow up`

## Next Steps

Week 12 continues with:

1. Building a FastAPI inference endpoint that loads the registered model
2. Adding a Flask integration that calls the inference endpoint
3. Testing end-to-end and capturing MLflow UI screenshots

Refer to `week-12/README.md` for detailed instructions.
