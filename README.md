# Research Master Thesis

This repository contains the R scripts and research materials for the study
**Choosing What to Study: Researchers' Motivations, Epistemic Values, and Reflections on Research Practice**.

---

## Project Description

This study investigates how researchers’ motivations and epistemic values influence their project choices.  
It combines quantitative and qualitative data, including:

- Two questionnaires:
  - **Multidimensional Research Agendas Inventory – Revised (MDRAI-R, short version)**
  - **Epistemic Values Scale (EVS)**
- **Semi-structured interviews** exploring motivations, values, and research context
- **Python code** for automated transcription using OpenAI Whisper

The repository includes reproducible R scripts for descriptive analyses of both questionnaires.

---

## Analysis Overview

**R Scripts:**
- `Calculation Descriptives MDRAI-R short.R`  
  → Computes descriptive statistics for the MDRAI-R (short) used in the study.
  *Note:* For participant ID01, the complete MDRAI-R questionnaire was administered.  
  However, for consistency in descriptive calculations, only the items included for all other participants were used.

- `Epistemic_Values_analysis.R`  
  → Computes descriptive statistics for the Epistemic Values Scale.

Both scripts produce:
- Item-level statistics (mean, SD, min, max)
- Subscale-level statistics (mean, SD, min, max)
- CSV output files

---

## Questionnaires

- **MDRAI-R short version:** Assesses non-epistemic motivations in research (e.g., ambition, collaboration, discovery).  
- **Epistemic Values Scale:** Measures epistemic motivations and values (e.g., truth, cumulative knowledge, error correction).

---

## Interview Materials

- **Interview_preparation_potential_subquestions.pdf** — preparatory subquestions to guide interviews.  
- **Research_Master_Thesis_Appendices.pdf** — includes all questionnaires, descriptive tables, interview questions, and ethical documentation.  
- **Python_code_for_transcription_with_whisper.pdf** — code used for generating transcripts from recorded interviews.

---

## Licenses

- **Code (R, Python)** MIT License
- **Questionnaires, data, and written materials**: CC BY 4.0 License

---

## Software Requirements

- R ≥ 4.0  
- Packages: `readxl`, `dplyr`, `tidyr`, `knitr`, `kableExtra`  
- Optional: Python ≥ 3.10 with `openai-whisper` for transcription

---

