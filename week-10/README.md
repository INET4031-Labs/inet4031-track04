---
**Week 1-9 Prerequisite**

Weeks 10-14 assume your completed Weeks 1-9 repositories are available as peer directories in `Student Repositories/`. This track's Ansible roles reference your prior work:
- `mlflow` role uses your Flask application from Week 2 (`../week-02/`)
- `mlflow` role connects to your PostgreSQL database from Week 4 (`../week-04/` or `../infrastructure/`)

Your track repo does NOT copy these — it integrates with them. Ensure your Week 1-9 work is complete and accessible before Week 11.

Note also that Weeks 1-9 leave you with **two** independently-running Flask stacks by Week 9: the Docker Compose stack at `localhost:8080` and the k3d-fronted stack at `localhost:8081`. This track's Flask integration (Weeks 11-12) targets the **Compose stack on port 8080** — that is the stack your `httpx` calls and demo script should point at.

---

## Week 10: Challenge Kickoff - Machine Learning and AI

**Sprint 5 Continuation | Synchronous**

### Overview

Week 10 is your challenge track kickoff. In this session, your team will ground your ML
task in the real incident schema, design the four-component pipeline (MLflow, model
training, FastAPI inference, Flask integration), record that design as an Architecture
Decision Record, and populate the backlog for Weeks 11 and 12. Unlike Weeks 1-9, this
track does not hand you a single prescribed path — your team chooses what to predict and
how, within the constraints of the data you actually have. By the end of this week, you
will have a documented, schema-grounded architecture decision, an estimated two-sprint
backlog, and a scaffolded Ansible role ready for implementation.

### Learning Objectives

- Inspect a production-style schema and identify what ML tasks it can and cannot support
- Design a four-component ML serving architecture and document it as an ADR
- Translate an architecture decision into a two-sprint backlog with estimated stories
- Confirm and extend an Ansible role scaffold that already contains a reference MLflow/FastAPI implementation
- Apply sprint-ceremony practices (kickoff, backlog grooming, retrospective) to a self-directed challenge track

### Prerequisites

- Completed Weeks 1-9, with the shared team container, PostgreSQL (`statustracker`
  database, `incidents` table, ~50,000 seeded rows), and Flask application running
- Access to both the Docker Compose Flask stack (`localhost:8080`) and the k3d-fronted
  stack (`localhost:8081`) — see the prerequisite note above
- Python 3.8+ and `pip` available in the container
- Your team's Week 9 sprint backlog and retrospective closed out

### Sprint 5 Kickoff (Track 4 Continuation)

This is a synchronous session — get your whole team in the same room (or call) before
starting. Track 4 hands you a framework, not a finished spec: the architecture decisions
you make this week shape everything you build through Week 14. Don't rush Part 1; a
model choice that doesn't fit the real schema will cost you far more time in Week 11
than it costs to double-check now.

---

### Part 1: Ground Your Architecture in the Real Schema

Before choosing an ML task, confirm what data you actually have to work with.

**Step 1.** Connect to your PostgreSQL database and inspect the `incidents` table directly — don't rely on memory or on what earlier course materials implied the schema might contain.

```bash
psql -U appuser -d statustracker -c "\d incidents"
psql -U appuser -d statustracker -c "SELECT status, COUNT(*) FROM incidents GROUP BY status;"
```

**Step 2.** Confirm the columns you see. The Week 1-9 baseline schema is: `id, title,
status, description, created_at`. There is **no** `severity`, `resolved_at`, or
`assigned_to` column. If your team has heard this track described elsewhere as building
a "severity classifier," that description does not match the data — there is nothing to
classify severity from. Don't design around a column that isn't there.

**Decide as a team:** what will your model predict from the incidents table? Some
concrete options, roughly in order of how directly the existing schema supports them:

- **Resolution-status classifier (recommended default):** predict `status`
  (open/resolved) from `title` and `description`. This maps directly onto an existing
  column and needs no extra data engineering.
- **A derived target you engineer yourselves:** for example, bucket `created_at` deltas
  within your dataset into a coarse "time since filed" signal, or add a lightweight
  labeling pass over a sample of incidents. If you go this route, document exactly how
  you derive the target column and be ready to defend it to QA — a derived label is
  only as credible as the method that produced it.

Whatever you pick, write down *why the schema supports it*. A plan that assumes a
`severity` or `resolved_at` field will not survive Week 11.

> **Enterprise Pattern:** Real ops teams rarely get the schema they wish they had.
> Production ML work usually starts with "what can I actually predict from what's
> already being collected," not "what would make the most interesting model." Treat
> this step as practice for that constraint, not a formality.

---

### Part 2: Architecture and Design

As a team, design (diagram or written description) the following components. Some
values below are already fixed by the Ansible role scaffold in this repo
(`ansible/roles/mlflow/`) — treat those as given. Where a component leaves you a real
choice, decide it now and record it in Part 3.

1. **MLflow Tracking Server** *(mostly fixed)*
   - Port **5001**, host `0.0.0.0` — pinned in `ansible/roles/mlflow/defaults/main.yml`
   - Data directory `/opt/mlflow`, artifact store `/opt/mlflow/artifacts` — pinned
   - **Open choice:** backend store. The scaffolded default is file-based
     (`file:/opt/mlflow`). You may switch to a PostgreSQL-backed store if your team
     wants queryable run metadata; document whichever you pick.

2. **Model Training Pipeline**
   - Input: `incidents` table via `appuser`/`changeme`@`localhost:5432`/`statustracker`
     (same credential pattern established in Week 2)
   - **Open choice:** feature engineering approach and model library/estimator
     (scikit-learn is required; which estimator — RandomForest, LogisticRegression,
     etc. — is yours to decide)
   - Output: trained model logged to MLflow with metrics

3. **FastAPI Inference Endpoint** *(port fixed, contract mostly open)*
   - Port **8000**, host `0.0.0.0`, deployed to `/opt/inference` — pinned
   - **Open choice:** exact request/response field names beyond the required
     `/health` and `/predict` endpoints (see Part 3 template)

4. **Flask Application Integration**
   - Target: the Compose Flask stack at `localhost:8080`
   - **Open choice:** which page/endpoint calls the inference service, and how (or
     whether) predictions are shown in the UI

5. **Ansible Role** *(scaffold already exists — extend, don't rebuild)*
   - `ansible/roles/mlflow/` already contains a working reference implementation:
     `tasks/main.yml`, `handlers/main.yml`, `defaults/main.yml`, `vars/main.yml`, and
     both systemd unit templates. Review it before Week 11 — you'll be extending this,
     not starting from a blank role.

**Data Flow Diagram**

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
                  +-> Flask App (localhost:8080) (calls endpoint, displays results)
```

---

### Part 3: Architecture Decision Record

Fill in `week-10/adr.md`, which is already scaffolded in this repo with the standard ADR
sections (Context, Decision, Options Considered, Rationale, Consequences, Ansible
Integration Plan). Make sure your **Decision** section states, explicitly:

- What your model predicts, and which real column(s) that target comes from
- The feature set (which `incidents` columns you'll use)
- Model library and estimator
- Metrics to track in MLflow
- MLflow backend-store choice (file-based, or PostgreSQL-backed)
- FastAPI request/response contract
- The Flask integration point (endpoint, UI behavior)

---

### Part 4: Populate the Backlog

Create `week-11/backlog.md` and `week-12/backlog.md`, breaking your Part 2/3 design into
stories with story points and an owner (or pair) per story. Use headings like "Set Up
MLflow Tracking Server," "Prepare Training Data," "Build and Train Model," "Ansible Role
for MLflow" for Week 11, and "Build FastAPI Inference Endpoint," "Integrate FastAPI into
Ansible Role," "Flask Application Integration," "End-to-End Testing" for Week 12. Assign
story points so each week totals roughly 20-30 points, and flag dependencies between
stories (e.g., the FastAPI story depends on a registered model existing).

---

### Part 5: Confirm the Ansible Scaffold

`ansible/roles/mlflow/` in this repo already has a full directory structure and a
working reference implementation (install tasks for both MLflow and FastAPI, directory
creation, systemd service deployment, handlers). Run through it now so Week 11 isn't the
first time you've seen it:

```bash
find ansible/roles/mlflow -type f
cat ansible/roles/mlflow/defaults/main.yml
```

Confirm the defaults (`mlflow_port: 5001`, `fastapi_port: 8000`,
`mlflow_data_dir: /opt/mlflow`, `fastapi_app_dir: /opt/inference`) match what you
documented in your ADR. If your team's design needs different values, override them in
`defaults/main.yml` now and note the change in your ADR.

---

### Part 6: Commit and Record

```bash
cd track-04-machine-learning-and-ai
git add week-10/ week-11/backlog.md week-12/backlog.md ansible/ docs/
git commit -m "Week 10: Architecture decision, backlog, and role scaffold review"
git push origin main
```

Record in your team's Google Doc: your architecture decision summary, ML task choice
and justification, feature set, high-level backlog estimate, and any risks or
assumptions.

---

### Validation Checks

**QA runs all validation checks.** Before your kickoff session ends, run the Week 10
validation script and fix anything it flags — don't carry missing scaffolding into
Week 11.

#### Validation Check: Architecture and Backlog Complete

```bash
./scripts/check-week-10.sh
```

Confirm against `docs/qa-report-10.md`: the ADR is filled in (no
remaining `**TODO**` markers), the ML task is stated and grounded in real schema
columns, both backlog files exist with estimated/assigned stories, and the Ansible role
directory structure is confirmed present.

---

### Deliverables

- [ ] `week-10/adr.md` completed — no TODO placeholders remaining
- [ ] ML task chosen and explicitly grounded in the real `incidents` schema (no
      references to a `severity` column)
- [ ] Feature set, model library, and metrics documented
- [ ] `week-11/backlog.md` and `week-12/backlog.md` created with estimated, assigned stories
- [ ] Ansible role scaffold reviewed and defaults confirmed or overridden
- [ ] `docs/sprint-10-retrospective.md` completed
- [ ] All files committed to git

### Sprint Backlog: Preparing for Week 11

Scrum Master, open these tickets before the async Week 11 sprint begins:

- **MLFLOW-1:** Stand up MLflow tracking server per the scaffolded Ansible role
- **MLFLOW-2:** Write `fetch-incidents.py` against the team's finalized feature set
- **MLFLOW-3:** Implement and log the training pipeline (`train-model.py`)
- **MLFLOW-4:** Verify the trained model is registered and visible in the MLflow UI
- **MLFLOW-5:** Extend `ansible/roles/mlflow/` for anything your ADR changed from the
  scaffolded defaults

---
