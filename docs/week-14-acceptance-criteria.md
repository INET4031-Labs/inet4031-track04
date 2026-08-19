# Week 14 Acceptance Criteria - Demo Day

This document tracks the requirements for Week 14 completion and Demo Day success. Demo Day tests the complete pipeline in front of the instructor after a container wipe and Ansible rebuild.

## Pre-Demo Verification (Before Demo Starts)

- [ ] All services running before wipe: MLflow, FastAPI, Flask, PostgreSQL
- [ ] Git repository clean: `git status` shows "working tree clean"
- [ ] All code committed and pushed to origin
- [ ] Demo script (`week-13/demo-script.md`) reviewed and finalized
- [ ] Screenshots and reference materials printed or accessible
- [ ] All team members present and roles assigned
- [ ] Time slot confirmed with instructor (typically 10-15 minutes)

## Container Wipe Phase

- [ ] MLflow service stopped: `sudo systemctl stop mlflow`
- [ ] FastAPI service stopped: `sudo systemctl stop fastapi`
- [ ] MLflow data directory cleaned: `sudo rm -rf /opt/mlflow/*`
- [ ] Inference server directory cleaned: `sudo rm -rf /opt/inference/*`
- [ ] Local cache cleaned: `rm -rf ~/mlflow/` and `rm -rf ~/.cache/mlflow/`
- [ ] Verification: All services unreachable after wipe
- [ ] Wipe time documented

## Ansible Rebuild Phase

- [ ] Ansible playbook run started from clean state
- [ ] Full playbook executed without interruption: `ansible-playbook -i ansible/inventory ansible/site.yml`
- [ ] Playbook completed successfully:
  - [ ] PLAY RECAP shows `failed=0`
  - [ ] PLAY RECAP shows `unreachable=0`
  - [ ] No critical errors in output
- [ ] Rebuild time documented (typically 5-10 minutes)
- [ ] Services started automatically by playbook:
  - [ ] MLflow systemd service active
  - [ ] FastAPI systemd service active
  - [ ] Flask application running

## Service Verification Post-Rebuild

- [ ] MLflow health check passes: `curl http://localhost:5001/health`
- [ ] FastAPI health check passes: `curl http://localhost:8000/health`
- [ ] Flask accessible: `curl http://localhost:8080/`
- [ ] PostgreSQL accessible with incidents data
- [ ] All services stable (no restart loops)
- [ ] System logs show no critical errors

## Model Restoration

- [ ] Model training script executed: `cd week-11 && python3 train-model.py`
- [ ] Training completes successfully without errors
- [ ] Model registered in MLflow: `mlflow models list` shows model
- [ ] Model version accessible and loadable
- [ ] Training time documented (typically 2-3 minutes)
- [ ] Model metrics comparable to Week 11 results

## End-to-End Pipeline Verification

- [ ] Test script passes: `bash week-12/test-pipeline.sh`
  - [ ] MLflow: OK
  - [ ] FastAPI: OK
  - [ ] Prediction: OK
  - [ ] Flask integration: OK
- [ ] Manual tests performed:
  - [ ] MLflow UI accessible and shows experiment
  - [ ] FastAPI prediction endpoint responds
  - [ ] Flask endpoint returns predictions
- [ ] No errors in logs or system output
- [ ] Full pipeline verified end-to-end
- [ ] Time to full readiness after wipe: documented (typically 15-20 minutes)

## Demo Execution

### Demo Start

- [ ] All services healthy before demo begins
- [ ] Demo script available to narrator
- [ ] Terminals/browsers positioned for visibility
- [ ] Time tracking started
- [ ] Instructor and audience ready

### Demo Content - Each Component Demonstrated

- [ ] **Component 1: Incident Data (PostgreSQL)**
  - [ ] Query executed and results shown
  - [ ] Number of incidents confirmed
  - [ ] Data quality assessed
  - Time spent: [X] minutes

- [ ] **Component 2: MLflow Experiment and Model**
  - [ ] Experiment visible in MLflow UI
  - [ ] Training run clickable and metrics shown
  - [ ] Model metrics (accuracy/MAE/RMSE) displayed
  - [ ] Model Registry shows registered model
  - Time spent: [X] minutes

- [ ] **Component 3: FastAPI Inference Endpoint**
  - [ ] Curl request sent to `/predict` endpoint
  - [ ] Request shows incident text input
  - [ ] Response shows prediction and confidence
  - [ ] Endpoint demonstrates real-time inference capability
  - Time spent: [X] minutes

- [ ] **Component 4: Flask UI Integration**
  - [ ] Flask page/endpoint navigated to
  - [ ] Prediction call triggered (button click or manual request)
  - [ ] Result displayed in Flask UI or verified in response
  - [ ] Integration shows end-user experience
  - Time spent: [X] minutes

- [ ] **Component 5: Ansible Playbook (Reproducibility)**
  - [ ] Playbook role structure shown
  - [ ] Key tasks highlighted (installation, service setup)
  - [ ] Explained as infrastructure-as-code
  - [ ] Connects to the just-executed rebuild
  - Time spent: [X] minutes

### Demo Conclusion

- [ ] Summary statement delivered by narrator
- [ ] Key achievements highlighted
- [ ] Acknowledgment of team effort
- [ ] Total demo time: [X] minutes (should be 10-15)

## Handling Demo Failures (If Services Fail)

- [ ] **MLflow unavailable during demo:**
  - [ ] Gracefully transition to FastAPI demo
  - [ ] Show MLflow from previous screenshots
  - [ ] Explain: "MLflow tracks experiments and models"

- [ ] **FastAPI times out:**
  - [ ] Show expected curl response from printed reference
  - [ ] Call to reload/restart service
  - [ ] Proceed to Flask UI demo

- [ ] **Flask fails to call inference:**
  - [ ] Demonstrate FastAPI directly
  - [ ] Explain Flask integration architecture
  - [ ] Show code to audience

- [ ] **Complete service failure:**
  - [ ] Present slides or documentation instead
  - [ ] Explain architecture and design
  - [ ] Discuss how system would be restored

**Contingency documented:** YES / NO

## Post-Demo Documentation

- [ ] Demo execution time recorded (total minutes)
- [ ] Instructor feedback captured (notes, verbatim if possible)
- [ ] Any technical issues encountered and resolutions documented
- [ ] Questions asked by instructor and answers provided
- [ ] Strengths highlighted by instructor noted
- [ ] Suggestions for improvement captured

## Sprint 7 Retrospective Completion

- [ ] `docs/sprint-7-retrospective.md` fully filled in
- [ ] All team members contributed to retrospective
- [ ] Final reflection questions answered:
  - [ ] Contributions of each member documented
  - [ ] Most important achievement identified
  - [ ] Lessons learned captured
  - [ ] Advice for future teams recorded
- [ ] Team signature/approval of retrospective

## Final Documentation

- [ ] `week-14/demo-day-log.md` completed:
  - [ ] Demo date and time
  - [ ] Attendees listed
  - [ ] All components demonstrated confirmed
  - [ ] Feedback recorded
  - [ ] Grade/approval captured
- [ ] `docs/environment-log.md` final section completed:
  - [ ] Demo results documented
  - [ ] Post-rebuild metrics recorded
  - [ ] Any issues and resolutions noted
- [ ] All documentation spell-checked and proofread
- [ ] No placeholder text remaining (all fields filled in)

## Git Final Status

- [ ] All Week 14 files committed
- [ ] Demo day log committed
- [ ] Final retrospectives committed
- [ ] Final environment log updates committed
- [ ] `git status` shows "working tree clean"
- [ ] All commits pushed to origin
- [ ] Repository ready for instructor review

## Track Completion Metrics

- [ ] **Code quality:** All code follows team standards, no warnings
- [ ] **Documentation:** Complete, clear, and accurate
- [ ] **Testing:** End-to-end pipeline verified multiple times
- [ ] **Reproducibility:** Ansible playbook verified from scratch
- [ ] **Team collaboration:** All members contributed meaningfully
- [ ] **Technical achievement:** ML pipeline working as designed
- [ ] **Presentation:** Demo clear and professional

## Final Sign-Off

- [ ] **Tech Lead:** Infrastructure and Ansible verified ___________
- [ ] **Backend Engineer:** FastAPI and Flask integration verified ___________
- [ ] **ML Engineer / Data Specialist:** Model and pipeline verified ___________
- [ ] **QA Lead:** All tests passing, demo successful ___________
- [ ] **Instructor:** Demo accepted and approved ___________

## Track 4 Completion Status

- [ ] Week 10: COMPLETE
- [ ] Week 11: COMPLETE
- [ ] Week 12: COMPLETE
- [ ] Week 13: COMPLETE
- [ ] Week 14: COMPLETE
- [ ] **Overall Track Status:** SUCCESSFUL / WITH ISSUES / INCOMPLETE

## Grade and Feedback

**Instructor Grade:** [To be filled by instructor]

**Strengths:**
- [Point 1]
- [Point 2]

**Areas for Improvement:**
- [Point 1]
- [Point 2]

**Comments:**
[Instructor remarks]

## Final Reflection

**What this track taught us:**

- About machine learning: [Insight]
- About deployment: [Insight]
- About teamwork: [Insight]
- For future projects: [Insight]

**Would we use these tools in production?**

- MLflow: YES / NO / MAYBE (comment)
- FastAPI: YES / NO / MAYBE (comment)
- Ansible: YES / NO / MAYBE (comment)

---

**Track 4 - Machine Learning and AI: COMPLETE**

All deliverables met. Team ready for submission and instructor feedback.
