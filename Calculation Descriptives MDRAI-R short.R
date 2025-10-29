# Packages
library(readxl)
library(dplyr)
library(tidyr)

# base path for data
data_path <- "data_MDRAI-R_short.xlsx"

# Load data
dat <- readxl::read_excel(data_path)

# Identify item columns
item_cols <- grep("^Item\\d+", names(dat), value = TRUE)

# Make to numeric
dat[item_cols] <- lapply(dat[item_cols], function(x) {
  x <- trimws(as.character(x))
  x[x %in% c("", "NA", "N/A", "NaN", "na")] <- NA
  suppressWarnings(as.numeric(x))   # convert; non-numeric -> NA
})

# Item order + labels
item_info <- tibble::tribble(
  ~`Item Number`, ~`Item Content`, ~Subscale,
  "Item11","Being a highly regarded expert is one of my career goals.","Scientific Ambition",
  "Item2","I aim to be recognized by my peers.","Scientific Ambition",
  "Item17","I am constantly striving to publish new papers.","Scientific Ambition",
  "Item15","I would be interested in pursuing research in other fields.","Divergence",
  "Item8","I enjoy multidisciplinary research more than single-disciplinary research.","Divergence",
  "Item10","My publications are enhanced by collaboration with other authors.","Collaboration",
  "Item4","I enjoy conducting collaborative research with my peers.","Collaboration",
  "Item18","I am often invited to collaborate with my peers.","Collaboration",
  "Item13","Part of my work is largely due to my former PhD mentor’s ideas.","Mentor Influence",
  "Item6","My research choices are highly influenced by my former PhD mentor’s ideas.","Mentor Influence",
  "Item14","Limited funding does not constrain my choice of topic.","Tolerance of Low Funding",
  "Item1","I am not discouraged by the lack of funding on a certain topic.","Tolerance of Low Funding",
  "Item3","I would rather conduct revolutionary research with little chance of success than replicate research with a high probability of success.","Discovery",
  "Item5","I am driven by innovative research.","Discovery",
  "Item7","I often decide my research agenda in collaboration with my field community.","Academia Driven",
  "Item9","I adjust my research agenda based on my institution’s demands.","Academia Driven",
  "Item19","My research agenda is aligned with my institution’s research strategies.","Academia Driven",
  "Item16","Societal challenges drive my research choices.","Society Driven",
  "Item12","I consider the opinions of my nonacademic peers when I choose my research topics.","Society Driven"
)

# Item-level descriptive stats (mean, sd, min, max)
item_stats <- dat %>%
  summarise(across(all_of(item_cols),
                   list(mean = ~mean(.x, na.rm = TRUE),
                        sd   = ~sd(.x,   na.rm = TRUE),
                        min  = ~min(.x,  na.rm = TRUE),
                        max  = ~max(.x,  na.rm = TRUE)),
                   .names = "{.col}_{.fn}")) %>%
  pivot_longer(everything(),
               names_to = c("Item Number", ".value"),
               names_sep = "_")

# Merge to keep order
item_summary <- item_info %>%
  left_join(item_stats, by = "Item Number")

# --- Subscales (means across items per participant)
subscale_map <- list(
  `Scientific Ambition`      = c("Item11","Item2","Item17"),
  `Divergence`               = c("Item15","Item8"),
  `Collaboration`            = c("Item10","Item4","Item18"),
  `Mentor Influence`         = c("Item13","Item6"),
  `Tolerance of Low Funding` = c("Item14","Item1"),
  `Discovery`                = c("Item3","Item5"),
  `Academia Driven`          = c("Item7","Item9","Item19"),
  `Society Driven`           = c("Item16","Item12")
)

subscale_scores <- lapply(subscale_map, function(items) {
  rowMeans(dat[items], na.rm = TRUE)
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
               names_sep = "_")

# Results
item_summary     # stats for each item
subscale_stats   # stats for each subscale

library(knitr)
library(kableExtra)

# 1. Item-level summary table
item_table <- item_summary %>%
  select(`Item Number`, `Item Content`, Subscale,
         mean, sd, min, max) %>%
  arrange(factor(`Item Number`,
                 levels = item_info$`Item Number`))

print(
  kable(item_table,
        format = "pipe",
        digits = 2,
        caption = "Item-level Descriptive Statistics (Mean, SD, Min, Max)")
)

# 2. Subscale-level summary table
subscale_table <- subscale_stats %>%
  select(Subscale, mean, sd, min, max)

print(
  kable(subscale_table,
        format = "pipe",
        digits = 2,
        caption = "Subscale-level Descriptive Statistics (Mean, SD, Min, Max)")
)

write.csv(item_table, "item_summary.csv", row.names = FALSE)
write.csv(subscale_table, "subscale_summary.csv", row.names = FALSE)

