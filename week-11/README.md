---
**Week 1-9 Prerequisite**

Weeks 10-14 assume your completed Weeks 1-9 repositories are available as peer directories in `Student Repositories/`. This track's Ansible roles reference your prior work:
- `mlflow` role uses your Flask application from Week 2 (`../week-02/`)
- `mlflow` role connects to your PostgreSQL database from Week 4 (`../week-04/` or `../infrastructure/`)

Your track repo does NOT copy these — it integrates with them. Ensure your Week 1-9 work is complete and accessible before Week 11.

---

## Week 11: Core Build - MLflow and Model Training

**Sprint 6 | Asynchronous**

### Overview

Week 11 is the core build phase. Working async this week, your team will install
MLflow, stand up the tracking server, build a data-preparation and training pipeline
against the real `incidents` table, and log your first trained model with metrics and
artifacts. By the end of this week, the MLflow UI should show a complete run with a
registered model, and your Ansible role should be able to reproduce the MLflow server
from a clean container.

By the end of this week, you will have:

1. MLflow tracking server running and accessible at `http://localhost:5001`
2. A Python training pipeline that reads incidents from PostgreSQL (`statustracker` database)
3. A trained scikit-learn model logged to MLflow with metrics, matching the target you chose in your Week 10 ADR
4. A model registered in the MLflow Model Registry
5. `ansible/roles/mlflow/` verified end-to-end for the MLflow half of the pipeline

### Learning Objectives

- Stand up an MLflow tracking server with a file-based backend store
- Build a data pipeline that queries PostgreSQL and prepares features for scikit-learn
- Train, evaluate, and log a model run to MLflow with metrics and artifacts
- Register a model in the MLflow Model Registry and load it back programmatically
- Extend an Ansible role so a systemd-managed service survives a container rebuild

### Prerequisites

- Week 10 architecture decision (`week-10/adr.md`) and backlog (`week-11/backlog.md`) completed
- Docker container with PostgreSQL running and `incidents` table populated (from Week 2/Week 9 seeding, ~50,000 rows)
- Flask application running on the Compose stack (`localhost:8080`)
- Python 3.8+ and `pip` available in the container

### Async Sprint Work

This is an asynchronous sprint week — coordinate through your backlog and check in with
your team async (chat, PR reviews, standup notes) rather than a single synchronous
block. Work through the parts below in order; each depends on the previous one
producing a running service or a working script.

---

### Part 1: Install and Start MLflow

**Step 1.** Install MLflow and its dependencies in your container.

```bash
pip install mlflow scikit-learn pandas sqlalchemy psycopg2-binary
```

Verify:

```bash
mlflow --version
python3 -c "import mlflow; print('MLflow version:', mlflow.version.VERSION)"
python3 -c "import sklearn; print('scikit-learn version:', sklearn.__version__)"
```

**Step 2.** Start the MLflow tracking server on the pinned port (**5001**), with a
file-based backend store unless your ADR called for PostgreSQL-backed storage:

```bash
mlflow server --host 0.0.0.0 --port 5001 --backend-store-uri file:./mlflow --default-artifact-root ./mlflow/artifacts
```

**Step 3.** Verify the server is reachable:

```bash
curl -s http://localhost:5001/health
```

Expected: `{"status":"ok"}`. Open `http://localhost:5001/` in a browser — it will be
empty until you log your first run.

---

### Part 2: Prepare Training Data from PostgreSQL

**Step 1.** Write `week-11/fetch-incidents.py` to pull the real `incidents` table and
confirm the data matches what your ADR assumed. Use the established connection pattern:

```python
import pandas as pd
from sqlalchemy import create_engine

# Database, user, and password follow the Week 2 baseline (appuser/changeme)
engine = create_engine("postgresql://appuser:changeme@localhost:5432/statustracker")

query = """
SELECT id, title, description, status, created_at
FROM incidents
ORDER BY created_at
"""

df = pd.read_sql(query, con=engine)
print(f"Loaded {len(df)} incidents")
print(df['status'].value_counts())
df.to_csv("incidents_data.csv", index=False)
```

Remember: the table has `id, title, description, status, created_at` and nothing else —
no `severity`, `resolved_at`, or `assigned_to`. If your training pipeline needs a
different target column, this is where you build/derive it, exactly as you specified in
your ADR.

**Step 2.** Run it and confirm row counts and a sane class balance for whatever target
you chose:

```bash
cd week-11
python3 fetch-incidents.py
```

If the connection fails, check that PostgreSQL is running, the connection string matches
your setup, and the `incidents` table has data. Document any issues in
`docs/sprint-11-retrospective.md`.

---

### Part 3: Build the Training Pipeline

Build `week-11/train-model.py`: load data, engineer features per your ADR, split
train/test, train a scikit-learn model, and log everything to MLflow.

If your team went with the recommended default (resolution-status classifier), the
shape of the pipeline looks like this — adapt the feature engineering, estimator, and
hyperparameters to your own design rather than copying this verbatim:

```python
import pandas as pd
from sqlalchemy import create_engine
from sklearn.model_selection import train_test_split
from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.ensemble import RandomForestClassifier
from sklearn.metrics import accuracy_score, precision_score, recall_score, f1_score
from sklearn.pipeline import Pipeline
import mlflow
import mlflow.sklearn

engine = create_engine("postgresql://appuser:changeme@localhost:5432/statustracker")
df = pd.read_sql("SELECT title, description, status FROM incidents ORDER BY created_at", con=engine)

df['text'] = df['title'] + ' ' + df['description'].fillna('')
X, y = df['text'], df['status']

X_train, X_test, y_train, y_test = train_test_split(
    X, y, test_size=0.2, random_state=42, stratify=y
)

mlflow.set_experiment("incident-status-classifier")

with mlflow.start_run() as run:
    mlflow.log_param("model_type", "RandomForest")
    mlflow.log_param("max_depth", 10)
    mlflow.log_param("n_estimators", 100)

    pipeline = Pipeline([
        ('tfidf', TfidfVectorizer(max_features=100, ngram_range=(1, 2))),
        ('rf', RandomForestClassifier(max_depth=10, n_estimators=100, random_state=42))
    ])
    pipeline.fit(X_train, y_train)
    y_pred = pipeline.predict(X_test)

    mlflow.log_metric("accuracy", accuracy_score(y_test, y_pred))
    mlflow.log_metric("precision", precision_score(y_test, y_pred, average='weighted', zero_division=0))
    mlflow.log_metric("recall", recall_score(y_test, y_pred, average='weighted', zero_division=0))
    mlflow.log_metric("f1", f1_score(y_test, y_pred, average='weighted', zero_division=0))

    mlflow.sklearn.log_model(pipeline, "model")

model_uri = f"runs/{run.info.run_id}/model"
mlflow.register_model(model_uri, "incident-status-classifier")
```

**If your team chose a different target** (a derived label rather than `status`),
substitute your own feature/label construction here, but keep the same MLflow logging
shape: `mlflow.set_experiment(...)`, `mlflow.start_run()`, `log_param`/`log_metric`,
`mlflow.sklearn.log_model(...)`, and `mlflow.register_model(...)`. Name your experiment
and registered model to match what you predict — don't call it a "severity classifier"
if there's no severity label backing it.

Run it:

```bash
python3 train-model.py
```

If you hit errors, check PostgreSQL connectivity, the database/user match Week 2 setup,
the `incidents` table has data, MLflow is running on 5001, and all pip packages are
installed.

---

### Part 4: Verify the Model in the MLflow UI

Open `http://localhost:5001/` and confirm:

1. Your experiment appears with a run showing your logged metrics
2. The "Artifacts" tab shows the logged model
3. The "Models" tab shows your registered model with a version

If the model isn't registered, check from the CLI:

```bash
mlflow models list
mlflow models describe <your-model-name>
```

---

### Part 5: Extend the Ansible Role for MLflow

`ansible/roles/mlflow/` already contains a working reference implementation covering
both MLflow and FastAPI (tasks, handlers, defaults, vars, and both systemd templates).
For this week, confirm the MLflow half works end-to-end:

```bash
ansible-playbook -i ansible/inventory ansible/site.yml --check
ansible-playbook -i ansible/inventory ansible/site.yml
curl -s http://localhost:5001/health
```

If your ADR changed anything from the scaffolded defaults (backend store type, ports,
directories), update `ansible/roles/mlflow/defaults/main.yml` and re-run to confirm the
change took effect.

> **Enterprise Pattern:** Notice the role already installs FastAPI's dependencies
> alongside MLflow's, even though you won't build the FastAPI service until Week 12.
> Real infra teams commonly provision dependencies for a service ahead of the service
> itself, so a later rollout is a config change rather than a fresh install.

---

### Storage Check

MLflow, scikit-learn, and their dependencies add real disk usage, and every training
run writes new artifacts. Check your headroom before and after your first run:

```bash
df -h
docker system df
du -sh /opt/mlflow 2>/dev/null || du -sh ./mlflow
```

---

### Validation Checks

**QA runs all validation checks.** Before marking Week 11 stories done in your backlog,
run the validation script and cross-check against `docs/qa-report-11.md`.

#### Validation Check: MLflow Server and Training Pipeline

```bash
./scripts/check-week-11.sh
```

This confirms: `week-11/fetch-incidents.py` and `week-11/train-model.py` exist, the
MLflow health check passes, the Ansible role's tasks file references `mlflow`, and
`ansible/site.yml` includes the `mlflow` role. Manually confirm what the script can't:
the registered model name matches your ADR's stated target, and the metrics logged are
the ones you committed to tracking.

---

### Deliverables

- [ ] MLflow tracking server running on port 5001
- [ ] `week-11/fetch-incidents.py` reads from `statustracker` with `appuser`
- [ ] `week-11/train-model.py` trains and logs a model matching your Week 10 ADR target
- [ ] Model registered in the MLflow Model Registry with metrics visible in the UI
- [ ] `ansible/roles/mlflow/` verified to bring MLflow up from a clean run
- [ ] `scripts/check-week-11.sh` passes
- [ ] All files committed to git

### Sprint Backlog: Preparing for Week 12

Scrum Master, open these tickets to continue Sprint 6:

- **MLFLOW-6:** Build `week-12/inference-server.py` (FastAPI) loading the registered model
- **MLFLOW-7:** Add FastAPI systemd service to `ansible/roles/mlflow/`
- **MLFLOW-8:** Wire a Flask endpoint (Compose stack, `localhost:8080`) to call FastAPI
- **MLFLOW-9:** Write `week-12/test-pipeline.sh` for end-to-end verification
- **MLFLOW-10:** Capture MLflow UI screenshots for Demo Day reference material

---
