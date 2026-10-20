# TidyTuesday 2026-10-20: export data for the interactive faceted scatter
# Author: Ekaterina Enchikova
library(tidyverse)

base <- "https://raw.githubusercontent.com/rfordatascience/tidytuesday/main/data/2026/2026-10-20/"
d <- read_csv(paste0(base, "ai_salary_majors.csv"), show_col_types = FALSE)

pct <- function(x) round(100 * (rank(x, ties.method = "average") - 1) / (length(x) - 1), 1)
humanities <- c("English", "Foreign Languages", "Philosophy & Religion", "Theology & Religion",
                "History", "Area & Ethnic Studies", "Liberal Arts")

out <- d |>
  mutate(field = if_else(broad_field_short %in% humanities, "Humanities", broad_field_short),
         p_overall = pct(ai_exposure), p_language = pct(ai_exposure_language), p_image = pct(ai_exposure_image),
         name = str_squish(field_of_study)) |>
  transmute(id = row_number(), name, field, sal = median_starting_salary,
            po = p_overall, pl = p_language, pi = p_image,
            g = coalesce(n_graduates, 0))

# write JSON by hand (no jsonlite dependency)
esc <- function(x) gsub('"', '\\\\"', x)
rows <- pmap_chr(out, function(id, name, field, sal, po, pl, pi, g)
  sprintf('{"id":%d,"n":"%s","f":"%s","s":%d,"o":%s,"l":%s,"i":%s,"g":%d}',
          id, esc(name), esc(field), as.integer(round(sal)), po, pl, pi, as.integer(g)))
writeLines(paste0("[", paste(rows, collapse = ",\n"), "]"), "data/tt42_data.json")  # run from the week folder
cat(nrow(out), "rows\n")
print(count(out, field, sort = TRUE), n = Inf)
