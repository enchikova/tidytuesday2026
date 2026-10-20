# TidyTuesday 2026-10-20: College majors, AI exposure and starting salary
# Author: Ekaterina Enchikova
# Plot: faceted scatter by broad field - does the overall null result hold within fields?
#   x = AI exposure percentile, y = median starting salary, one dot per major

library(tidyverse)
library(ggrepel)
library(scales)

# ---- Data -------------------------------------------------------------------
base <- "https://raw.githubusercontent.com/rfordatascience/tidytuesday/main/data/2026/2026-10-20/"
d <- read_csv(paste0(base, "ai_salary_majors.csv"), show_col_types = FALSE)

# ---- Prep -------------------------------------------------------------------
# CIP has no single "Humanities" family, so this is my own grouping of the
# humanities-type families (flagged in the plot caption).
humanities <- c("English", "Foreign Languages", "Philosophy & Religion",
                "Theology & Religion", "History", "Area & Ethnic Studies",
                "Liberal Arts")

d <- d |>
  mutate(field = if_else(broad_field_short %in% humanities, "Humanities", broad_field_short))

min_n <- 8   # smaller fields give unstable correlations
panel_stats <- d |>
  filter(field != "Interdisciplinary") |>               # catch-all family, hard to interpret
  group_by(field) |>
  filter(n() >= min_n) |>
  summarise(n = n(),
            r = cor(ai_exposure_percentile, median_starting_salary),
            .groups = "drop") |>
  arrange(desc(r)) |>                                    # panels ordered by within-field r
  mutate(strip = fct_inorder(sprintf("%s\n(n = %d, r = %.2f)", field, n, r)))

plot_d <- d |> inner_join(panel_stats, by = "field")

# All majors, without the facet variable, so they appear in grey in every panel
bg <- d |> select(ai_exposure_percentile, median_starting_salary)

# Label the largest major (by graduates) in each panel
lab <- plot_d |>
  group_by(strip) |>
  slice_max(n_graduates, n = 1, with_ties = FALSE) |>
  ungroup() |>
  mutate(label = str_wrap(str_trunc(field_of_study, 30), 16))

# ---- Numbers behind the story ----------------------------------------------
r_all <- cor(d$ai_exposure_percentile, d$median_starting_salary)
m_pool <- lm(median_starting_salary ~ ai_exposure_percentile, data = d)
m_fe   <- lm(median_starting_salary ~ ai_exposure_percentile + factor(field), data = d)
ci <- function(m) round(10 * confint(m)["ai_exposure_percentile", ], 0)
cat(sprintf("Overall r = %.2f\n", r_all))
cat("Pooled slope per +10 percentile points (USD), 95% CI:", ci(m_pool), "\n")
cat("Within-field slope per +10 percentile points (USD), 95% CI:", ci(m_fe), "\n")

# ---- Plot -------------------------------------------------------------------
p <- ggplot(plot_d, aes(ai_exposure_percentile, median_starting_salary)) +
  geom_point(data = bg, colour = "grey82", size = 0.8) +
  geom_smooth(method = "lm", formula = y ~ x, se = TRUE,
              colour = "#B83232", fill = "#B83232", alpha = 0.12, linewidth = 0.8) +
  geom_point(aes(size = n_graduates), colour = "#1F4E79", alpha = 0.75) +
  geom_text_repel(data = lab, aes(label = label), size = 2.6, lineheight = 0.9,
                  min.segment.length = 0, box.padding = 0.4, max.overlaps = Inf,
                  segment.colour = "grey50", colour = "grey20") +
  facet_wrap(vars(strip), ncol = 5) +
  scale_x_continuous(breaks = c(0, 50, 100), limits = c(0, 100)) +
  scale_y_continuous(labels = label_dollar(scale = 1e-3, suffix = "k")) +
  scale_size_area(max_size = 6, labels = label_comma(), name = "Graduates") +
  labs(
    title = "Does the null result hold within fields?",
    subtitle = sprintf(
      "Across all 285 majors, exposure and starting salary are unrelated (r = %.2f); within fields the relationship is often strong, with differing signs",
      r_all),
    x = "AI exposure percentile (0 = least exposed major, 100 = most exposed)",
    y = "Median earnings 1 year after graduation (USD)",
    caption = paste0(
      "Blue = majors in the field; grey = all other majors; red line = linear fit with 95% CI. Panels ordered by r; small n, so treat r with caution.\n",
      "Fields with fewer than ", min_n, " majors and the catch-all 'Interdisciplinary' family omitted. 'Humanities' is my grouping of English, Foreign Languages, Philosophy, Theology, History and Area Studies.\n",
      "Source: College Scorecard, AIOE (Felten, Raj & Seamans 2021), NCES CIP-SOC crosswalk | #TidyTuesday 2026-W42"
    )
  ) +
  theme_minimal(base_size = 11) +
  theme(
    plot.title = element_text(face = "bold", size = 15),
    plot.title.position = "plot",
    plot.subtitle = element_text(size = 10),
    plot.caption = element_text(size = 7.5, hjust = 0, colour = "grey35"),
    plot.caption.position = "plot",
    strip.text = element_text(face = "bold", size = 8.5, lineheight = 1.0),
    panel.grid.minor = element_blank(),
    panel.spacing = unit(0.9, "lines"),
    legend.position = "bottom"
  )

ggsave("tt_2026_42_facets.png", p, width = 16, height = 8.5, dpi = 300, bg = "white")
p
