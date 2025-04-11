## README: Facebook Ad Experiment Simulation

### Overview

This project simulates a field experiment to assess the effectiveness of different Facebook ad strategies (reason-based and emotion-based) in increasing COVID-19 vaccine uptake and improving vaccine attitudes across the U.S.

The experiment simulates:
- A **baseline survey** (demographics, vaccine attitudes, vaccination status)
- **Random treatment assignment** (control group, reason ad, emotion ad)
- An **endline survey** post-treatment (attitudes and vaccination outcomes)
- Final **analysis and visualization** of experimental effects

The pipeline allows you to explore how different messaging strategies influence behavior and opinions in a realistic experimental framework.

---

### How to Run the Simulation

1. **Open R or RStudio**
2. **Load the script**: `simulation_and_analysis.R`
3. **Install required packages** (see Dependencies)
4. **Run the entire script**
   - This will generate all three datasets (baseline, treatment, endline)
   - Simulate treatment effects and behavior change
   - Produce plots comparing baseline and endline vaccination rates and attitudes

The plots will be displayed automatically and stored in memory for reporting.

---

### Dependencies

The following R package is required:

```r
install.packages("ggplot2")
```

---

### Methodology & Logic

#### 1. **Baseline Survey Simulation**
- 5,000 participants are generated with:
  - **Demographics**: Age (normal distribution, capped at 18–80), gender, education
  - **Baseline vaccine attitude**: 5-point categorical scale ("Terrible", "Bad", "Okay", "Good", "Excellent")
  - **Baseline vaccination status**: Random binary distribution (50/50), "Yes", "No"

#### 2. **Random Treatment Assignment**
- Participants are randomly assigned to:
  - `control group`
  - `reason` treatment
  - `emotions` treatment  
  with equal probability (1/3 each)

#### 3. **Endline Survey Simulation**
- 4,500 participants randomly retained (simulating real-world attrition)
- Treatment effects applied:
  - **Vaccination status** is updated based on group-specific probabilities:
    - `control group`: 30%
    - `reason`: 65%
    - `emotions`: 45%
  - **Attitude changes** are simulated using new distributions reflecting treatment influence

#### 4. **Analysis & Reporting**
- Datasets are merged for comparison
- Two main visualizations are produced:
  - **Vaccination status changes** by treatment group and time (baseline vs. endline)
  - **Vaccine attitude composition** by treatment group, shown side-by-side for each time point

#### 5. **Sanity Check**
- Ensures that no participant who was vaccinated at baseline is marked unvaccinated at endline

---

### Key Outputs

- **Plot 1**: Side-by-side bar chart of baseline vs. endline "Yes" responses per treatment group
- **Plot 2**: Stacked bar chart of vaccine attitudes by treatment group, faceted by survey (baseline/endline)

---

### File Structure

| File/Section              | Description                                      |
|---------------------------|--------------------------------------------------|
| `baseline`                | 5,000-person dataset with demographic + survey data |
| `random_assignment`       | Mapping of `id` to treatment group               |
| `endline`                 | Post-treatment outcomes for 4,500 participants   |
| `merged_dataset`          | Full dataset for analysis                        |
| `ggplot` plots            | Visualizations of behavior and attitude changes  |

---

### Notes & Assumptions

- Age distribution is drawn from `rnorm(5000, 40, 20)` and clipped to a realistic adult range (18–80)
- Attitude levels and treatment effects are assigned using `sample()` and `rbinom()` with custom probability weights
- Simulation uses fixed random seed (`set.seed(1)`) for reproducibility

---

### Limitations & Future Improvements

While the simulation provides a robust and insightful look into the impact of treatment strategies, there are several opportunities to increase realism and sophistication:

- **Dynamic Treatment Effects**: The current model assigns static probabilities for vaccination uptake by treatment group. A future version could vary treatment effectiveness based on individual characteristics such as baseline attitude or demographic traits, allowing for more nuanced behavioral modeling.

- **Non-Symmetric Dropout Modeling**: Currently, attrition is random. Future improvements could simulate non-random dropout patterns (e.g., lower response rates among those with negative baseline attitudes or lower education), which would better reflect common real-world survey behavior.

These extensions would enhance the realism of the simulation and enable more detailed policy or experimental insights.
