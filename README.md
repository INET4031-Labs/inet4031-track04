# INET 4031: Track 4 - Machine Learning and AI

**Challenge Track | Weeks 10-14**

This repository contains the challenge track scaffold for Track 4: Machine Learning and
AI. This track builds an ML model serving pipeline integrated with the incident data,
using MLflow for experiment tracking and FastAPI for model inference.

## Important: Framework Status and Container Architecture Assumption

Weeks 10-14 were flagged in the source lab directions as needing re-evaluation with the
professor before being finalized. What you find here is a framework for this challenge
track, not a finished deliverable. Specific deliverables and integration points may
still change. Confirm with your instructor before starting.

Additionally, the university's container platform runs Docker containers in privileged
mode (`--privileged` flag). This has been confirmed by the professor, and the team
container model described in this course functions as designed starting Week 3.

## Challenge Track Goal

Build an ML model serving pipeline integrated with the incident-tracking application.
Deploy MLflow for experiment tracking and model registry, train a model on seeded
incident data, and serve the model behind a FastAPI inference endpoint. The
`incidents` table only has `id, title, status, description, created_at` — there is no
`severity` column, so your team decides what to predict from the columns that
actually exist (a status classifier is the straightforward default; derive your own
target if you want something else). Demonstrate integration by calling the inference
endpoint from the Flask application and showing the complete pipeline (training run,
registered model, and live predictions) in the MLflow UI.

## Weekly Structure

| Week | Sprint | Type | Focus |
|---|---|---|---|
| [Week 10](week-10/) | Sprint 5 (cont.) | Synchronous | Challenge kickoff, architecture decision, backlog |
| [Week 11](week-11/) | Sprint 6 | Asynchronous | Core build: MLflow server and model training |
| [Week 12](week-12/) | Sprint 6 (cont.) | Asynchronous | FastAPI inference endpoint and Flask integration |
| [Week 13](week-13/) | Sprint 7 | Synchronous | Ansible dry run, demo rehearsal, edge-case hardening |
| [Week 14](week-14/) | Sprint 7 (cont.) | Synchronous | Demo Day: container wipe and playbook rebuild |

## Directory Structure

```
README.md                 - this file
ansible/                  - Ansible role for MLflow installation and management
docs/                     - sprint retrospectives, QA reports
scripts/                  - validation and verification scripts
week-10/                  - Week 10 (architecture and planning)
week-11/                  - Week 11 (MLflow server and model training)
week-12/                  - Week 12 (FastAPI endpoint and Flask integration)
week-13/                  - Week 13 (Ansible dry run and demo prep)
week-14/                  - Week 14 (Demo Day rebuild)
.gitignore                - standard git ignores for Python, ML artifacts, secrets
```

## Role Assignments and Prerequisites

This challenge track is part of your team's Week 9+ continuation. Refer to your
team-charter.md for the active sprint rotation schedule. Track 4 works best with:

- **Tech Lead / Infrastructure:** Oversees MLflow deployment and Ansible integration
- **Backend Engineer:** Builds FastAPI inference endpoint and Flask app integration
- **Data Specialist / ML Engineer:** Trains and validates ML model
- **QA/Operations:** Verifies the pipeline end-to-end, performs the Demo Day rebuild

However, roles can overlap; all team members should be able to navigate the entire
pipeline.

## Core Deliverables at a Glance

**Week 11:**
- MLflow tracking server running and accessible
- Trained model logged with metrics (named for what it actually predicts — see Week 10's
  ADR, not a "severity classifier" since no severity column exists)
- Model registered in MLflow model registry

**Week 12:**
- FastAPI inference endpoint serving the registered model
- Flask application calling the inference endpoint with live incident data
- MLflow UI showing the complete training run and registered model

**Week 13:**
- Ansible playbook includes MLflow role and can run without error (dry run)
- All four role-artifact documents filled in and reviewed
- Demo script written and rehearsed

**Week 14:**
- Container wiped clean
- Playbook runs from scratch to restore the entire environment
- Full pipeline verified end-to-end in front of instructor (Demo Day)

## Ansible Capstone Integration

The MLflow role you build in Weeks 11-12 becomes part of your team's growing
`ansible/site.yml` playbook. By Demo Day (Week 14), the playbook must be able to
wipe the container and rebuild the entire environment—including MLflow and the ML
pipeline—in a single idempotent run. This is the same accumulating-playbook pattern
that ran through Weeks 1-4 with OpenTofu, Prometheus, GitHub Actions, and other
tooling.

## Verification and Sign-Off

Each week has specific acceptance criteria and a QA report. Before moving to the next
week, verify that your deliverables meet the stated requirements:

- Week 10: Architecture decision documented, backlog populated, roles assigned
- Week 11: MLflow server health check passes, model trained and logged
- Week 12: FastAPI endpoint responds, Flask calls it, MLflow UI shows the run
- Week 13: Ansible playbook runs dry run without error, demo script ready
- Week 14: Container rebuild complete, end-to-end pipeline verified

See `docs/qa-report-10.md` through `docs/qa-report-14.md` for the full sign-off
checklists.

## Running Validation Scripts

Each week includes a validation script in `scripts/check-week-0N.sh`. Run it from the
repo root:

```bash
./scripts/check-week-10.sh
./scripts/check-week-11.sh
./scripts/check-week-12.sh
./scripts/check-week-13.sh
./scripts/check-week-14.sh
```

## Getting Started

1. Read the Week 10 README completely before your kickoff synchronous session.
2. Follow the architecture decision and backlog planning steps in Part 1.
3. Divide the backlog into team assignments and estimate story points.
4. As each week begins, read its README and follow the step-by-step lab directions.
5. Before submitting each week, run the corresponding validation script and fill in
   the acceptance criteria checklist.
6. Update the sprint retrospective at the end of the sprint (Sprint 5 close on Week 10,
   Sprint 6 close after Week 12, Sprint 7 close after Week 14).

## Questions or Issues

1. Check the troubleshooting section in each week's lab directions.
2. Review the acceptance criteria and QA report for that week.
3. Consult with your team's Tech Lead and QA roles.
4. Contact the course instructor if blocked.

## Team and Track Information

**Team Name:** [To be filled in]

**Track Number:** 4

**Track Name:** Machine Learning and AI

**Core Tooling:** MLflow, scikit-learn, FastAPI

**Seeded Data Source:** Incident table (PostgreSQL, pre-populated in Week 2)

**ML Task:** Team's choice, grounded in the real `incidents` schema (`id, title, status,
description, created_at` — no `severity` or `resolved_at` column). A status
(open/resolved) classifier is the recommended default; see `week-10/adr.md` for your
team's actual decision.

**Verification Command:**
```bash
curl -s http://localhost:5001/health 2>/dev/null && echo "MLflow up" || echo "FAIL"
```
