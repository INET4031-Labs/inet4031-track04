# Week 13 Acceptance Criteria

This document tracks the requirements for Week 13 completion. Week 13 is the final preparation sprint before Demo Day.

## Ansible Playbook Verification

- [ ] Playbook runs in check mode without errors: `ansible-playbook -i ansible/inventory ansible/site.yml --check`
- [ ] All tasks report no failures or unreachable hosts
- [ ] Playbook runs in production mode without errors
- [ ] All services start automatically after playbook runs
- [ ] Second playbook run shows idempotency:
  - [ ] Most tasks report `changed=0`
  - [ ] Idempotent tasks don't report spurious changes
- [ ] MLflow role included in site.yml
- [ ] FastAPI role (or MLflow role) includes FastAPI service
- [ ] Playbook execution time documented (typically 5-10 minutes)

## Service Verification

- [ ] MLflow service running after playbook: `sudo systemctl status mlflow`
- [ ] FastAPI service running after playbook: `sudo systemctl status fastapi`
- [ ] Flask application running or startable
- [ ] MLflow health check passes: `curl http://localhost:5001/health`
- [ ] FastAPI health check passes: `curl http://localhost:8000/health`
- [ ] Services remain stable for 30+ minutes (no restarts)
- [ ] No errors in systemd logs: `sudo journalctl -u mlflow` and `sudo journalctl -u fastapi`

## Demo Script and Rehearsal

- [ ] Demo script created: `week-13/demo-script.md`
- [ ] Script includes all five components:
  - [ ] Show incident data (PostgreSQL query)
  - [ ] Show MLflow experiment and metrics
  - [ ] Show FastAPI prediction endpoint (curl test)
  - [ ] Show Flask UI integration
  - [ ] Show Ansible playbook (highlight role structure)
- [ ] Script includes contingency plans for common failures
- [ ] Script timing: 10-15 minutes total
- [ ] Full team rehearsed the demo:
  - [ ] Narrator role assigned and practiced
  - [ ] Demonstrator role assigned and practiced
  - [ ] Backup demonstrator identified and ready
- [ ] All commands in demo script tested and verified
- [ ] Rehearsal completed without critical issues
- [ ] Screenshots captured for reference during demo

## Edge Case Testing

- [ ] **Test 1: MLflow Down / FastAPI Graceful Failure**
  - [ ] Stop MLflow: `pkill -f "mlflow server"`
  - [ ] Call Flask endpoint expecting 503
  - [ ] Restart MLflow and verify recovery
  - Status: PASS / FAIL (document)

- [ ] **Test 2: Invalid Input to FastAPI**
  - [ ] Send empty title: `{"title":""}`
  - [ ] Send missing field
  - [ ] Send very long text (10K+ characters)
  - [ ] Verify 400/422 error responses
  - Status: PASS / FAIL (document)

- [ ] **Test 3: Service Recovery After Restart**
  - [ ] Stop all services
  - [ ] Run playbook again
  - [ ] Verify services start and are healthy
  - [ ] Verify data persistence (model still registered)
  - Status: PASS / FAIL (document)

- [ ] **Test 4: Concurrent Requests (Basic Load)**
  - [ ] Send 5 concurrent requests to FastAPI
  - [ ] Send 5 concurrent requests to Flask endpoint
  - [ ] All requests should complete successfully
  - [ ] No 500 errors or timeouts
  - Status: PASS / FAIL (document)

- [ ] All edge case results documented in `docs/environment-log.md`

## Documentation Completion

- [ ] `docs/sprint-6-retrospective.md` filled in completely:
  - [ ] Sprint completion items listed
  - [ ] All team members' contributions documented
  - [ ] Reflection questions answered
  - [ ] Handoff notes for Sprint 7 included
- [ ] `docs/week-13-acceptance-criteria.md` filled in (this file)
- [ ] `docs/environment-log.md` updated with Week 13 section
- [ ] `docs/qa-report-6.md` template created (or per track naming)
- [ ] `week-13/demo-script.md` complete with full walkthrough
- [ ] `week-14/wipe-and-rebuild-procedure.md` documented
- [ ] All documentation committed to git

## Git Repository Status

- [ ] All Week 13 files committed
- [ ] All uncommitted changes from Weeks 10-12 committed
- [ ] `git status` shows "working tree clean"
- [ ] No untracked files (except .gitignore'd items)
- [ ] Repository ready for clean checkout on Demo Day
- [ ] Commit history available: `git log --oneline | head -20`

## Container and Environment

- [ ] Container running and accessible
- [ ] PostgreSQL accessible and incidents table populated
- [ ] Flask application running or easily startable
- [ ] All required ports available:
  - [ ] 5001 (MLflow)
  - [ ] 8000 (FastAPI)
  - [ ] 5000 (Flask)
  - [ ] 5432 (PostgreSQL)
- [ ] Disk space sufficient for MLflow artifacts and Python packages
- [ ] No obvious performance issues or warnings

## Team Readiness

- [ ] All team members understand the complete pipeline
- [ ] Narrator can explain the architecture and design choices
- [ ] Demonstrator can navigate MLflow UI, Flask UI, and run curl commands
- [ ] Backup demonstrator can take over mid-demo
- [ ] Contingency plan exists if technology fails (manual explanation backup)
- [ ] Team has practiced transitions between demo sections
- [ ] Questions and answers prepared for likely instructor questions

## Verification Commands

**Playbook readiness:**
```bash
ansible-playbook -i ansible/inventory ansible/site.yml --check
# Output: PLAY RECAP should show 0 failed
```

**Services running:**
```bash
curl http://localhost:5001/health && echo "MLflow OK"
curl http://localhost:8000/health && echo "FastAPI OK"
curl http://localhost:8080/ && echo "Flask OK"
```

**Git ready:**
```bash
git status
# Output: "working tree clean"
```

**Demo script executable:**
```bash
bash week-13/demo-script.md
# All commands should work
```

## Sign-Off

- [ ] Tech Lead: Playbook verified, infrastructure ready
- [ ] Backend Lead: FastAPI and Flask integration verified
- [ ] QA Lead: All tests passing, edge cases handled
- [ ] ML Engineer: Model and pipeline verified
- [ ] Narrator: Demo script memorized or notes ready
- [ ] Demonstrator: All commands and UI navigation practiced

## Final Checklist Before Demo Day

- [ ] All code committed and pushed
- [ ] Repository clean (no uncommitted changes)
- [ ] Playbook runs successfully in production
- [ ] All services healthy and responsive
- [ ] Model registered and serving predictions
- [ ] Demo script rehearsed with full team
- [ ] Screenshots and reference materials prepared
- [ ] Contingency plans documented
- [ ] Team roles assigned and practiced

## Notes

[Document any issues resolved, workarounds applied, or special circumstances]

## Transition to Week 14

**Ready for Demo Day if:**
- Ansible playbook verified and working
- All edge cases tested and handled
- Demo script ready and rehearsed
- Git repository clean
- All documentation complete
- Team confident in presentation

**Week 14 will:**
- Wipe the container completely
- Rebuild environment using Ansible playbook
- Retrain model from scratch
- Verify complete pipeline
- Execute demo for instructor and class
