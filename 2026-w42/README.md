# TidyTuesday 2026, week 42: AI exposure and starting pay

Which college majors are safest from AI, and do they pay? An interactive look at
AI exposure (AIOE index) against median starting salary for 285 US bachelor's majors.

**Live page:** https://enchikova.github.io/tidytuesday2026/2026-w42/

## Main finding
- Across all 285 majors, AI exposure percentile and starting salary are essentially unrelated (r = -0.03).
- Within eight broader groups of majors the sign differs (from r = +0.49 in Business to r = -0.63 in Education),
  but each group has only 12 to 71 majors, so the intervals are wide.
- Exposure is not automation: AIOE measures how much an occupation's tasks overlap with AI capabilities.

## Contents
| Path | What it is |
|---|---|
| `index.html` | Interactive faceted scatter (plain HTML, CSS and JavaScript; data embedded, no server needed) |
| `data/tt42_data.json` | The 285 majors with salary, three exposure percentiles and graduates |
| `R/tt_2026_42_export.R` | Builds the JSON from the TidyTuesday CSV |
| `R/tt_2026_42_facets.R` | Static ggplot2 faceted scatter |
| `R/tt_2026_42_scatter.R` | Static labelled scatter |

## Method notes
- Exposure percentile = rank of the major's mean AIOE score among all 285 majors (0 = least, 100 = most exposed).
- Majors are unweighted. Confidence intervals for r use the Fisher transformation.
- The eight groups are my own grouping of CIP fields (see the page footer).

## Data
College Scorecard, AIOE (Felten, Raj and Seamans 2021), NCES CIP-SOC crosswalk, via
[TidyTuesday](https://github.com/rfordatascience/tidytuesday) 2026-10-20.

Author: Ekaterina Enchikova, [ORCID 0000-0002-3919-2447](https://orcid.org/0000-0002-3919-2447)
