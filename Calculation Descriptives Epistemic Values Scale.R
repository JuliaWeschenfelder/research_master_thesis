# --- Packages
library(readxl)
library(dplyr)
library(tidyr)
library(knitr)
library(kableExtra)

# base path for data
data_path <- "data_epistemic_values_scale.xlsx"

# Load data
dat <- readxl::read_excel(data_path)

# Identify item columns
item_cols <- grep("^Item\\d+", names(dat), value = TRUE)

# Make to numeric
dat[item_cols] <- lapply(dat[item_cols], function(x) {
  x <- trimws(as.character(x))
  x[x %in% c("", "NA", "N/A", "NaN", "na")] <- NA
  suppressWarnings(as.numeric(x))
})

# Item order and labels
item_info <- tibble::tribble(
  ~`Item Number`, ~`Item Content`, ~Subscale,
  # Reliability and Truth
  "Item23","I want my research to represent the truth as accurately as possible.","Reliability and Truth",
  "Item40","I want my research to serve as reliable evidence.","Reliability and Truth",
  "Item26","I want others to rely on my research because of its methodological rigor.","Reliability and Truth",
  "Item35","I want to communicate my research truthfully to others.","Reliability and Truth",
  "Item36","I believe it’s acceptable to sometimes prioritize speed over thoroughness in research.","Reliability and Truth", # *
  # Cumulative Collective Knowledge
  "Item20","I want my research to contribute reliable evidence to the literature that other researchers can build upon.","Cumulative Collective Knowledge",
  "Item27","I want my research to contribute to resolving long-standing research questions.","Cumulative Collective Knowledge",
  "Item22","I want my research to be relevant and useful for other researchers.","Cumulative Collective Knowledge",
  "Item38","I want my research to remain valuable to the field in the future.","Cumulative Collective Knowledge",
  "Item32","I want my research to be updated or corrected by the scientific community.","Cumulative Collective Knowledge",
  "Item30","I prefer developing new ideas over engaging with existing research.","Cumulative Collective Knowledge", # *
  "Item28","I believe that building on existing literature can constrain originality in research.","Cumulative Collective Knowledge", # *
  "Item34","I want my research to be distinct from the existing body of research.","Cumulative Collective Knowledge", # *
  # Criticism and Error Correction
  "Item37","I aim to identify errors in published research through careful reanalysis.","Criticism and Error Correction",
  "Item29","I want my research to challenge and potentially falsify existing findings.","Criticism and Error Correction",
  "Item21","I aim to critically examine and expose the limitations of existing research.","Criticism and Error Correction",
  "Item39","I prioritize original contributions over correcting the published work of other researchers.","Criticism and Error Correction", # *
  "Item25","I see it as my responsibility to help correct inaccuracies in the scientific record.","Criticism and Error Correction",
  "Item33","Once research has passed peer review, I generally assume it's reliable.","Criticism and Error Correction", # *
  "Item24","I believe it's often unproductive to reevaluate accepted findings.","Criticism and Error Correction", # *
  "Item31","No study is perfect.","Criticism and Error Correction"
)

# Reverse-code items (1–7 scale): recode as 8 - x
reverse_items <- c("Item36","Item30","Item28","Item34","Item39","Item33","Item24")

dat_scored <- dat
for (col in intersect(reverse_items, names(dat_scored))) {
  dat_scored[[col]] <- ifelse(is.na(dat_scored[[col]]), NA, 8 - dat_scored[[col]])
}

# --- Item-level descriptive stats (mean, sd, min, max), using scored data
item_stats <- dat_scored %>%
  summarise(across(all_of(item_cols),
                   list(mean = ~mean(.x, na.rm = TRUE),
                        sd   = ~sd(.x,   na.rm = TRUE),
                        min  = ~min(.x,  na.rm = TRUE),
                        max  = ~max(.x,  na.rm = TRUE)),
                   .names = "{.col}_{.fn}")) %>%
  pivot_longer(everything(),
               names_to = c("Item Number", ".value"),
               names_sep = "_")

# Merge to preserve order as specified above
item_summary <- item_info %>%
  left_join(item_stats, by = "Item Number") %>%
  arrange(factor(`Item Number`, levels = item_info$`Item Number`))

# Subscales (means across items per participant; after reverse-coding)
subscale_map <- list(
  `Reliability and Truth` = c("Item23","Item40","Item26","Item35","Item36"),
  `Cumulative Collective Knowledge` = c("Item20","Item27","Item22","Item38","Item32","Item30","Item28","Item34"),
  `Criticism and Error Correction`  = c("Item37","Item29","Item21","Item39","Item25","Item33","Item24","Item31")
)

subscale_scores <- lapply(subscale_map, function(items) {
  rowMeans(dat_scored[items], na.rm = TRUE)
}) |> as.data.frame()

subscale_stats <- subscale_scores %>%
  summarise(across(everything(),
                   list(mean = ~mean(.x, na.rm = TRUE),
                        sd   = ~sd(.x,   na.rm = TRUE),
                        min  = ~min(.x,  na.rm = TRUE),
                        max  = ~max(.x,  na.rm = TRUE)),
                   .names = "{.col}_{.fn}")) %>%
  pivot_longer(everything(),
               names_to = c("Subscale", ".value"),
               names_sep = "_") %>%
  mutate(Subscale = factor(Subscale,
                           levels = c("Reliability and Truth",
                                      "Cumulative Collective Knowledge",
                                      "Criticism and Error Correction"))) %>%
  arrange(Subscale)

# Print tables
item_table <- item_summary %>%
  select(`Item Number`, `Item Content`, Subscale, mean, sd, min, max)

print(
  kable(item_table,
        format = "pipe",
        digits = 2,
        caption = "Epistemic Values: Item-level Descriptive Statistics (Mean, SD, Min, Max) — reverse-coded items already scored")
)

subscale_table <- subscale_stats %>%
  select(Subscale, mean, sd, min, max)

print(
  kable(subscale_table,
        format = "pipe",
        digits = 2,
        caption = "Epistemic Values: Subscale-level Descriptive Statistics (Mean, SD, Min, Max)")
)

# Save CSVs
write.csv(item_table, "epistemic_item_summary.csv", row.names = FALSE)
write.csv(subscale_table, "epistemic_subscale_summary.csv", row.names = FALSE)


