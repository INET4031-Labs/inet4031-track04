## Week 13: Finalize and Prepare for Demo Day

**Sprint 7 | Synchronous**

### Overview

Week 13 is your final preparation sprint before Demo Day. Your focus shifts from new
implementation to hardening, verification, and rehearsal. As a synchronous session, get
the team together to run the Ansible playbook dry and for real, harden the Flask/FastAPI
integration against failure, rehearse the demo script, and close out documentation.
This week is lighter on new code but decides whether Week 14 goes smoothly.

By the end of this week, you will have:

1. Confirmed the Ansible playbook runs cleanly in both check mode and production mode, and is idempotent on a second run
2. A written, rehearsed demo script covering the full pipeline
3. Edge cases tested and handled (service down, invalid input, restart recovery)
4. All acceptance criteria and retrospective documentation current
5. A documented wipe-and-rebuild procedure ready for Week 14

### Learning Objectives

- Validate an Ansible playbook's idempotency and read a `PLAY RECAP` for signs of trouble
- Harden a service integration against dependency failure (timeouts, connection errors, malformed input)
- Write and rehearse a technical demo script under a time constraint
- Close out sprint documentation (retrospective, acceptance criteria) as a team practice, not an afterthought

### Prerequisites

- Week 12 deliverables complete: FastAPI and Flask integration working end to end
- `ansible/roles/mlflow/` included in `ansible/site.yml` and running successfully
- All Weeks 10-12 files committed to git
- Team members assigned to rehearsal roles (narrator, demonstrator, backup)

### Sprint 7 Ceremonies

This is a synchronous session. Sprint 7 has no new backlog stories beyond
hardening and rehearsal — treat this week as the team's dress rehearsal for Demo Day,
not a place to add scope.

---

### Part 1: Ansible Dry-Run and Verification

**Step 1.** Run the playbook in check mode first:

```bash
ansible-playbook -i ansible/inventory ansible/site.yml --check
```

Check mode reports what *would* change without applying it — use it to catch missing
variables, bad file paths, or permission issues before you touch a running service.

**Step 2.** Fix anything it flags. Common culprits: a variable missing from
`ansible/roles/mlflow/defaults/main.yml` or `vars/main.yml`, a `src:` path in a
`copy`/`template` task that doesn't match where your script actually lives, or a missing
`become: yes` on a task that needs root.

**Step 3.** Once check mode is clean, run it for real and verify all services:

```bash
ansible-playbook -i ansible/inventory ansible/site.yml

curl -s http://localhost:5001/health | python3 -m json.tool
curl -s http://localhost:8000/health | python3 -m json.tool
curl -s http://localhost:8080/ | head -10
```

**Step 4.** Run the playbook a second time and confirm idempotency — a healthy playbook
reports `changed=0` (or close to it) on the second pass, since everything it manages is
already in the desired state:

```bash
ansible-playbook -i ansible/inventory ansible/site.yml
```

Document the run in `docs/sprint-13-retrospective.md`: check-mode result, production-run
result, and the idempotency check (first-run vs. second-run `changed` counts).

---

### Part 2: Write and Rehearse the Demo Script

**Step 1.** Create `week-13/demo-script.md`. It must walk through all five components
your team built: the real incident data, the MLflow experiment/run, the FastAPI
prediction call, the Flask integration, and the Ansible playbook as the reproducibility
story. Structure it as a timed walkthrough (10-15 minutes total) with talking points for
each section, and a **Contingency** section covering what to do if MLflow, FastAPI, or
Flask isn't responding when you're on the spot.

Ground every claim in your script in what your pipeline actually predicts — if your
model classifies incident status (open/resolved), the script should say that, not
describe a severity prediction that doesn't exist in your data.

**Step 2.** Rehearse with the full team. Assign a narrator (explains what's happening),
a demonstrator (drives the terminals/UI), and a backup (ready to take over). Time the
run and iterate until it's a comfortable 10-15 minutes.

**Step 3.** Capture screenshots for reference: the MLflow experiment and run, the model
registry entry, a FastAPI prediction response, and the Flask UI showing a prediction (if
your team built UI display). Save these to `week-13/demo-screenshots/`.

---

### Part 3: Edge Cases and Robustness

Work through these scenarios as a team and fix anything that doesn't fail gracefully.

**Scenario 1 — MLflow/FastAPI unavailable.** Confirm your Flask integration already
returns a clean 503 rather than hanging or 500ing (built in Week 12). Test it:

```bash
pkill -f uvicorn
curl http://localhost:8080/incident/1/predict
# expect a 503, not a timeout or 500
python3 week-12/inference-server.py &
```

**Scenario 2 — invalid input to FastAPI.** Confirm Pydantic validation rejects bad
requests with 400/422, not a 500:

```bash
curl -X POST http://localhost:8000/predict -H "Content-Type: application/json" -d '{"title": ""}'
curl -X POST http://localhost:8000/predict -H "Content-Type: application/json" -d '{"description": "no title"}'
```

**Scenario 3 — service recovery after restart.** Stop everything, re-run the playbook,
and confirm services come back healthy and the registered model is still there.

Document PASS/FAIL for each scenario in `docs/sprint-13-retrospective.md`.

> **Enterprise Pattern:** The instinct to skip edge-case testing because "it worked in
> Week 12" is exactly what causes outages during real demos and real incidents alike.
> Budgeting explicit time for failure-mode testing, separate from feature work, is a
> standard on-call/SRE practice — this part of the week is that practice in miniature.

---

### Part 4: Complete Documentation

Fill in `docs/sprint-12-retrospective.md` (covering Weeks 11-12) as a team — every
team member answers the reflection questions,
not just whoever is typing. Then draft `week-14/wipe-and-rebuild-procedure.md`, covering:
stopping services, removing `/opt/mlflow` and `/opt/inference` contents, restarting the
container, re-running the playbook, retraining the model, and re-verifying the pipeline.
Base the expected timeline on what you actually observed in Part 1 and Part 3 this
week, not a guess.

---

### Storage Check

Before Demo Day, confirm you have headroom for a wipe-and-rebuild cycle plus a full
model retrain without running out of disk mid-demo:

```bash
df -h
docker system df
du -sh /opt/mlflow /opt/inference 2>/dev/null
```

---

### Validation Checks

**QA runs all validation checks.** Everything in this section should be green before
your team leaves the Week 13 session — Week 14 has no time to fix Week 13 gaps.

#### Validation Check: Playbook, Demo Script, and Edge Cases

```bash
./scripts/check-week-13.sh
git status   # should show "working tree clean"
```

Cross-check against `docs/qa-report-13.md`: check-mode and
production-mode runs both clean, second run idempotent, demo script covers all five
components and stays within 10-15 minutes, all three edge-case scenarios documented as
PASS, and `week-14/wipe-and-rebuild-procedure.md` exists.

---

### Deliverables

- [ ] Ansible playbook passes check mode and production mode without errors
- [ ] Second playbook run confirmed idempotent
- [ ] `week-13/demo-script.md` written, rehearsed, and timed at 10-15 minutes
- [ ] All three edge-case scenarios tested and documented
- [ ] Screenshots captured in `week-13/demo-screenshots/`
- [ ] `week-14/wipe-and-rebuild-procedure.md` documented
- [ ] `docs/sprint-12-retrospective.md` completed
- [ ] `git status` clean; all files committed and pushed

### Sprint Backlog: Preparing for Week 14

Scrum Master, open these tickets for Demo Day:

- **MLFLOW-16:** Assign Demo Day roles (narrator, demonstrator, backup) and confirm scheduling with the instructor
- **MLFLOW-17:** Do a final pre-wipe git status check the morning of Week 14
- **MLFLOW-18:** Time-box the wipe-and-rebuild rehearsal once more if the team has margin
- **MLFLOW-19:** Prepare `docs/sprint-14-retrospective.md` as a blank template ready to fill in after the demo

---
