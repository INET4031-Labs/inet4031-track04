# Demo Plan: Machine Learning and AI Track

**Demo Date:** [Insert date]  
**Demo Duration:** [XX minutes]  
**Audience:** [Faculty, peers, stakeholders]  
**Location/Format:** [In-person / Virtual / Hybrid]

---

## 1. Demo Sequence

**Step-by-step walkthrough with timing:**

| Time | Step | Description | Owner |
|------|------|-------------|-------|
| 0:00 | Introduction | Brief overview of track objectives | [Name] |
| 0:30 | Component 1 | [Description with specific actions] | [Name] |
| 2:00 | Component 2 | [Description with specific actions] | [Name] |
| 4:00 | Component 3 | [Description with specific actions] | [Name] |
| 5:30 | Results/Analysis | [Description of outputs demonstrated] | [Name] |
| 6:30 | Q&A | Questions from audience | All |

**Total: XX minutes**

### Detailed Walkthrough

**TODO:** Provide step-by-step instructions for each demo component
- Which models/notebooks to run?
- What predictions/inferences to show?
- What MLflow experiments to display?
- Where are potential failure points?

---

## 2. Success Criteria

**What must work for the demo to succeed:**

- [ ] ML models load and initialize correctly
- [ ] Data pipeline executes without errors
- [ ] Model training/inference runs successfully
- [ ] MLflow server displays experiments and metrics
- [ ] Visualizations/dashboards render correctly
- [ ] All predictions/outputs appear as expected
- [ ] Network/connectivity is stable (if applicable)
- [ ] Audio/video working (if virtual)
- [ ] Timing is within target duration
- [ ] [Additional track-specific criteria]

---

## 3. Risk Assessment

**What could go wrong:**

| Risk | Likelihood | Impact | Mitigation |
|------|-----------|--------|-----------|
| Model inference too slow | Medium | High | Use smaller batch; pre-compute results |
| MLflow server crashes | Low | High | Pre-start server; have backup results |
| Data loading fails | Medium | High | Cache data locally; use sample subset |
| GPU/CUDA issues | Low | High | Use CPU mode; pre-test GPU beforehand |
| Visualization rendering slow | Medium | Medium | Pre-load plots; use screenshots if needed |
| Network bandwidth insufficient | Medium | Medium | Download models locally; cache data |

---

## 4. Recovery Plans

**How to handle each risk:**

### Slow Inference
- **Plan A:** Use smaller batch size or dataset
- **Plan B:** Show pre-computed predictions and metrics
- **Plan C:** Play pre-recorded model run with explanations

### MLflow Issues
- **Plan A:** Restart MLflow server
- **Plan B:** Display screenshots of typical experiment runs
- **Plan C:** Use alternative visualization (CSV export, Jupyter)

### Data Loading Failures
- **Plan A:** Use local cached data
- **Plan B:** Use sample/synthetic dataset
- **Plan C:** Show data loading code and explain process verbally

### GPU/CUDA Problems
- **Plan A:** Switch to CPU mode
- **Plan B:** Use pre-trained model (skip training demo)
- **Plan C:** Show inference code and results separately

---

## 5. Key Talking Points

**What to explain to the audience:**

- **Problem Definition:** What prediction/classification task are we solving?
- **Model Architecture:** What type of model and why?
- **Training Process:** How was the model trained? What data?
- **Performance Metrics:** Accuracy, precision, recall, F1, AUC, etc.
- **MLflow Experiment Tracking:** How we manage experiments and reproducibility
- **Real-world Applications:** How would this model be used in production?
- **Challenges & Solutions:** What was hard? What worked well?
- **Future Improvements:** Model enhancements, data collection, deployment

### Sample Talking Points
- [Point 1 - TODO: Fill in]
- [Point 2 - TODO: Fill in]
- [Point 3 - TODO: Fill in]

---

## 6. Contingencies

**Backup plan if primary demo fails:**

### Pre-recorded Model Run
- Location: `week-12/backup/model-run-recording.mp4`
- Duration: [XX minutes]
- Setup instructions: [Specify how to play]

### Screenshot Fallback
- Location: `week-12/backup/screenshots/`
- Contents:
  - [ ] Screenshot 1: [MLflow dashboard]
  - [ ] Screenshot 2: [Model metrics/performance]
  - [ ] Screenshot 3: [Prediction output]

### Printed Handout
- Location: `week-12/backup/demo-handout.pdf`
- Contents: Model architecture diagram, performance metrics table, sample predictions

### Live Code Walk-Through Alternative
- **Scenario:** If systems unavailable, team can:
  1. Walk through training notebook code
  2. Explain model architecture and hyperparameters
  3. Show actual model weights/parameters
  4. Display performance curves and confusion matrices

---

## Pre-Demo Checklist

**Day Before:**
- [ ] Test entire ML pipeline end-to-end
- [ ] Verify all systems accessible (MLflow, GPU/CPU, data sources)
- [ ] Check network/internet connectivity
- [ ] Download/cache all models and data locally
- [ ] Pre-run inference to verify results
- [ ] Record backup video (if using)
- [ ] Prepare printed handouts with metrics
- [ ] Brief all team members on their roles
- [ ] Run through demo once, timing it

**Morning Of:**
- [ ] Restart MLflow server
- [ ] Verify GPU/CUDA available (if using)
- [ ] Load models into memory
- [ ] Open Jupyter notebook and verify connectivity
- [ ] Test microphone/audio (if virtual)
- [ ] Verify projection/screen sharing
- [ ] Have backup devices/networks ready
- [ ] Review talking points one more time

---

## Demo Success Log

**After demo, complete the following:**

- [ ] Demo completed successfully?
  - [ ] Yes - Note what worked well
  - [ ] Partial - Note what failed and recovery used
  - [ ] No - Document what went wrong

- [ ] Audience feedback: [Brief notes]
- [ ] Lessons learned: [What to improve next time]
- [ ] Follow-up actions: [Any questions to address]

---

**Demo Rehearsal Completed:** [Date]  
**Final Approval:** [Name/Date]
