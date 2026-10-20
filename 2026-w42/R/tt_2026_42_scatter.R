# TidyTuesday 2026-10-20: College majors, AI exposure and starting salary
# Author: Ekaterina Enchikova
# Plot: one dot per major; x = AI exposure (percentile), y = median starting salary

library(tidyverse)
library(ggrepel)
library(scales)

# ---- Data -------------------------------------------------------------------
base <- "https://raw.githubusercontent.com/rfordatascience/tidytuesday/main/data/2026/2026-10-20/"
d <- read_csv(paste0(base, "ai_salary_majors.csv"), show_col_types = FALSE)

# ---- Prep -------------------------------------------------------------------
# Keep the 6 most common broad fields (by number of majors), lump the rest
d <- d |>
  mutate(field_grp = fct_lump_n(broad_field_short, n = 6, other_level = "Other"))

x_mid <- 50                                   # percentile midpoint
y_mid <- median(d$median_starting_salary)     # median salary across majors

# Label extremes: top/bottom salary and most/least exposed, plus a few of interest
interest <- c("Education", "Psychology", "Health Professions")
labels_df <- d |>
  mutate(label = str_trunc(field_of_study, 32)) |>
  filter(
    rank(-median_starting_salary) <= 6 |
      rank(median_starting_salary) <= 6 |
      rank(-ai_exposure_percentile, ties.method = "first") <= 4 |
      rank(ai_exposure_percentile, ties.method = "first") <= 4 |
      str_detect(field_of_study, regex("^Registered Nursing|^Elementary Education|^Psychology, General",
                                       ignore_case = TRUE))
  )

r <- cor(d$ai_exposure_percentile, d$median_starting_salary, use = "complete.obs")

# ---- Plot -------------------------------------------------------------------
p <- ggplot(d, aes(ai_exposure_percentile, median_starting_salary)) +
  geom_vline(xintercept = x_mid, linetype = "dashed", colour = "grey60") +
  geom_hline(yintercept = y_mid, linetype = "dashed", colour = "grey60") +
  geom_smooth(method = "lm", se = TRUE, colour = "grey30", fill = "grey85", linewidth = 0.6) +
  geom_point(aes(colour = field_grp, size = n_graduates), alpha = 0.7) +
  geom_text_repel(
    data = labels_df, aes(label = label),
    size = 3, min.segment.length = 0, max.overlaps = Inf,
    box.padding = 0.4, segment.colour = "grey50"
  ) +
  annotate("text", x = 2,   y = Inf, label = "Safer from AI,\nhigher paid",  hjust = 0, vjust = 1.3, fontface = "bold", colour = "grey35", size = 3.5) +
  annotate("text", x = 98,  y = Inf, label = "More exposed,\nhigher paid",   hjust = 1, vjust = 1.3, fontface = "bold", colour = "grey35", size = 3.5) +
  annotate("text", x = 2,   y = -Inf, label = "Safer from AI,\nlower paid",  hjust = 0, vjust = -0.5, fontface = "bold", colour = "grey35", size = 3.5) +
  annotate("text", x = 98,  y = -Inf, label = "More exposed,\nlower paid",   hjust = 1, vjust = -0.5, fontface = "bold", colour = "grey35", size = 3.5) +
  scale_x_continuous(breaks = seq(0, 100, 25), limits = c(0, 100)) +
  scale_y_continuous(labels = label_dollar()) +
  scale_size_area(max_size = 9, labels = label_comma(), name = "Graduates") +
  scale_colour_brewer(palette = "Dark2", name = "Broad field") +
  labs(
    title = "Is a safe-from-AI major a well-paid major?",
    subtitle = sprintf("285 US bachelor's majors. Exposure and starting salary are essentially unrelated (r = %.2f).", r),
    x = "AI exposure percentile (0 = least exposed major, 100 = most exposed)",
    y = "Median earnings 1 year after graduation (USD)",
    caption = "Source: College Scorecard, AIOE (Felten, Raj & Seamans 2021), NCES CIP-SOC crosswalk | #TidyTuesday 2026-W42"
  ) +
  theme_minimal(base_size = 12) +
  theme(
    plot.title = element_text(face = "bold", size = 15),
    plot.title.position = "plot",
    legend.position = "right",
    panel.grid.minor = element_blank()
  )

ggsave("tt_2026_42_scatter.png", p, width = 11, height = 7.5, dpi = 300, bg = "white")
p
