# this R script filters out the puzzles by level
# download the db from:
# https://database.lichess.org/lichess_db_puzzle.csv.zst
# and uncompress with:
# zstd -d lichess_db_puzzle.csv.zst


# Sys.setenv(PKG_CXXFLAGS = "-I/Library/Developer/CommandLineTools/SDKs/MacOSX.sdk/usr/include/c++/v1")
# install.packages("dplyr")
library(dplyr)


# load the source db
db <- read.csv("~/Downloads/lichess_db_puzzle.csv")
db <- db %>%
  filter(Rating >= 500 & Popularity < 70 & Rating < 2100)
# remove cols that we don't need
db$RatingDeviation <- NULL
db$NbPlays <- NULL
db$GameUrl <- NULL
db$OpeningTags <- NULL

# order by rating and popularity
db <- db[order(db$Rating, -db$Popularity), ]

# create a column with the level, for easy filtering
db$Level <- (db$Rating %/% 100) * 100

# get the top 1000 from each level
db <- db %>%
    group_by(Level) %>%
    arrange(desc(Popularity), .by_group = TRUE) %>%
    slice_head(n = 5000)

# split by levels
split_db <- db %>%
  group_split(Level)


# save each data frame into a separate CSV file
for (df in split_db) {
  level <- df$Level[1]  # Extract the level value
  file_name <- paste0("level_", level, ".csv")  # Create the file name
  write.table(df, file_name, row.names = FALSE, col.names = FALSE, quote = FALSE, sep = ",")
  cat("Saved:", file_name, "\n")  # Print confirmation
}
