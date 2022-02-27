library(tidyverse)
library(ggplot2)


uber <- read_csv("uber.csv", na = ".")

new_uber <- uber %>%
  separate('Date/Time', into = c("date", "time"), sep = " ") %>%
  mutate(date = mdy(date))

# write_csv(new_uber, "uber.csv")
