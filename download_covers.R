library(tidyverse)
library(httr2)

# Read the Taylor Swift album list
albums <- read_csv("data/taylor_swift_albums.csv", show_col_types = FALSE)

# Download each album cover from Cover Art Archive
walk2(albums$id, albums$title, \(id, title) {
  # Clean filename so it saves smoothly
  safe_name <- str_replace_all(title, "[^A-Za-z0-9 ]", "")
  dest <- file.path("covers", paste0(safe_name, ".jpg"))
  
  # Only download if missing or empty
  if (!file.exists(dest) || file.size(dest) == 0) {
    message("Downloading: ", title)
    url <- paste0("https://coverartarchive.org/release-group/", id, "/front")
    tryCatch({
      request(url) |>
        req_retry(max_tries = 3) |>
        req_perform(path = dest)
    }, error = \(e) {
      if (file.exists(dest)) unlink(dest)
      message("  Failed: ", title, " - ", conditionMessage(e))
    })
    Sys.sleep(0.5) # Pause briefly between requests
  }
})
