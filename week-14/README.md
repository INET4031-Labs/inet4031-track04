## Week 14: Demo Day - Container Wipe and Playbook Rebuild

**Sprint 7 Continuation | Synchronous**

### Overview

Week 14 is Demo Day. Your team will wipe your container's ML pipeline state clean,
rebuild the entire environment from scratch using the Ansible playbook you've refined
since Week 11, retrain your model, and present the complete pipeline to your instructor.
This is the same capstone proof point that ran through Weeks 1-4 with OpenTofu,
Prometheus, and CI — infrastructure as code only counts if it can actually rebuild what
it claims to manage, on demand, from nothing.

By the end of this week, you will have:

1. Wiped the MLflow/FastAPI portion of the container environment completely
2. Rebuilt the entire stack (MLflow, FastAPI, and dependencies) via a single Ansible playbook run
3. Retrained and re-registered the model
4. Verified the complete pipeline end-to-end
5. Presented a successful demo to the instructor

### Learning Objectives

- Execute a destructive infrastructure operation (wipe) with a rehearsed, low-risk procedure
- Prove reproducibility by rebuilding a multi-service pipeline from a single playbook run
- Retrain and re-register a model as part of a rebuild, not just as a one-time setup step
- Deliver a timed technical demo under real conditions, including recovering from unexpected failures

### Prerequisites

- Week 13 deliverables complete: playbook verified, demo script rehearsed, edge cases handled
- All code committed to git with no uncommitted changes
- Ansible playbook runs successfully in production mode (not just check mode)
- Demo script ready for reference (printed or on a second screen)

### Demo Day

This is it — the capstone session for Track 4. Everything from Week 10's architecture
decision through Week 13's rehearsal converges here. Move through the wipe and rebuild
deliberately; there's no undo once you start Part 2.

---

### Part 1: Pre-Demo Verification

**Step 1.** Confirm every service is healthy one last time before wiping anything:

```bash
curl -s http://localhost:5001/health | python3 -m json.tool
curl -s http://localhost:8000/health | python3 -m json.tool
curl -s http://localhost:8080/ | head -20
```

**Step 2.** Confirm git is clean:

```bash
git status
```

If not, commit and push now — don't carry uncommitted changes into a wipe.

**Step 3.** Start `week-14/demo-day-log.md` and record pre-wipe status: services
running, playbook passing, git clean, demo script ready, team prepared.

---

### Part 2: Container Wipe Procedure

**CRITICAL: after this step, the current MLflow/FastAPI state is gone. There is no undo.**

Follow the procedure your team documented in `week-14/wipe-and-rebuild-procedure.md`
last week. It should cover, at minimum:

```bash
sudo systemctl stop mlflow
sudo systemctl stop fastapi

sudo rm -rf /opt/mlflow/*
sudo rm -rf /opt/inference/*
rm -rf ~/mlflow/ ~/.cache/mlflow/
```

Verify the wipe actually took — both health checks should now fail:

```bash
curl http://localhost:5001/health   # expect: connection refused
curl http://localhost:8000/health   # expect: connection refused
```

If either responds, a process wasn't actually stopped — find and kill it before
proceeding. Log the wipe phase (start/end time, steps completed) in
`week-14/demo-day-log.md`.

---

### Part 3: Rebuild via Ansible Playbook

Run the full playbook against the wiped container:

```bash
ansible-playbook -i ansible/inventory ansible/site.yml
```

Confirm the `PLAY RECAP` shows `unreachable=0` and `failed=0`.

> **Troubleshooting:** If the `k3d-setup` play hangs and `docker logs k3d-myapp-server-0`
> shows repeated `"too many open files"` / `"error creating fsnotify watcher"` errors,
> the host has run out of inotify watch instances — a common RHEL default
> (`fs.inotify.max_user_instances=128`) is too low for a fresh k3s cluster. Fix:
> `sudo sysctl -w fs.inotify.max_user_instances=1024`, then delete and re-create the
> cluster (`k3d cluster delete myapp` before re-running the playbook).

Then verify services came back up on their own, without any manual intervention:

```bash
sudo systemctl status mlflow
sudo systemctl status fastapi
curl -s http://localhost:5001/health | python3 -m json.tool
curl -s http://localhost:8000/health | python3 -m json.tool
```

Note: FastAPI's health check will report `model_loaded: false` (or fail to start
cleanly) until you retrain in Part 4 — the wipe removed the registered model along with
everything else in `/opt/mlflow`. Log rebuild timing and the `PLAY RECAP` numbers in
`week-14/demo-day-log.md`.

---

### Part 4: Retrain the Model

The wipe cleared MLflow's backend store, so the model registry is empty. Retrain:

```bash
cd week-11
python3 train-model.py
```

Confirm it logged a new run and registered a model matching what your team predicted
throughout the track:

```bash
mlflow models list
```

If training fails, check MLflow is up, PostgreSQL has data
(`psql -U appuser -d statustracker -c "SELECT COUNT(*) FROM incidents;"`), and your
Python environment has the required packages. Restart FastAPI after the model is
registered, if it didn't pick it up automatically:

```bash
sudo systemctl restart fastapi
```

Log training time, metrics, and registration status in `week-14/demo-day-log.md`.

---

### Part 5: End-to-End Pipeline Verification

Run your full test script and confirm all checks pass:

```bash
bash week-12/test-pipeline.sh
```

Do a manual pass too: open the MLflow UI and confirm the new experiment/run and
registered model are visible, send a `/predict` request directly, and exercise the
Flask integration endpoint. Log the results in `week-14/demo-day-log.md` — status
should read READY FOR DEMO before you move on.

---

### Part 6: Demo Execution

Set up your terminals/browser tabs (MLflow UI, Flask UI, a command line), have
`week-13/demo-script.md` ready for the narrator, and confirm roles: narrator,
demonstrator, backup. Follow the script you rehearsed in Week 13. Walk the instructor
through: the real incident data, the MLflow experiment and metrics, the FastAPI
prediction call, the Flask integration, and the Ansible playbook as your reproducibility
story — the rebuild you just performed *is* the proof for that last point.

If something breaks mid-demo, fall back to your Week 13 contingency plan: show
screenshots for a UI that won't load, show the systemd service status to prove
something is running even if a request times out, and keep narrating rather than going
silent while debugging.

---

### Storage Check

Before you start the wipe, confirm there's enough headroom for a full rebuild plus
retraining without a disk-space surprise mid-demo:

```bash
df -h
docker system df
```

---

### Validation Checks

**QA runs all validation checks.** Run this before you consider the environment
demo-ready, and again immediately after retraining in Part 4.

#### Validation Check: Post-Rebuild Pipeline Health

```bash
./scripts/check-week-14.sh
```

This confirms: `week-14/demo-day-log.md` and final documentation files exist, both
MLflow and FastAPI respond healthy, a model is registered in MLflow, the end-to-end
pipeline test passes, and git is clean. Cross-check anything it can't verify
automatically against `docs/qa-report-14.md` — in particular, that the
demo actually covered all five components and that instructor feedback got captured.

---

### Deliverables

- [ ] Container wiped clean (verified both services unreachable)
- [ ] Ansible playbook rebuilt the entire environment from scratch (`failed=0`, `unreachable=0`)
- [ ] Model retrained and re-registered post-rebuild
- [ ] End-to-end pipeline verified (`week-12/test-pipeline.sh` all green)
- [ ] Demo executed in front of the instructor
- [ ] `week-14/demo-day-log.md` completed with full timeline and instructor feedback
- [ ] `docs/sprint-14-retrospective.md` completed by the whole team
- [ ] All files committed and pushed; `git status` clean

---

### Track Wrap-Up

Track 4 is complete once Demo Day is done and documented. Before you close out:

- Finish the **Post-Track Reflection** in the Notes section of
  `docs/sprint-14-retrospective.md` — what worked, what you'd change, and total time
  invested per week — while it's still fresh.
- Confirm `docs/sprint-14-retrospective.md` captures each member's contribution across
  the final two weeks, not just a group summary.
- Do a final read-through of `docs/qa-report-10.md` through `docs/qa-report-14.md` and
  confirm anything still open that you can now confirm is done.
- If your team's ADR (`week-10/adr.md`) ended up diverging from what you actually
  shipped — a different model target, a different backend store, a different Flask UI
  approach — add a short note to the **Consequences** section explaining what changed
  and why. That record is more useful to future teams than a decision that reads as
  though it was never revisited.

There is no Week 15. This concludes Track 4: Machine Learning and AI.

---
