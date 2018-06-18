service_options <- c("youtu", "soundcloud", "bandcamp", "spotify", "mixcloud")

# The 2 lines of code below is run once to save your gs auth token in the app's working directory
# the app then uses this token to authenticate each time it is launched
#token <- gs_auth(cache = FALSE)
#saveRDS(token, file = "googlesheets_shiny_token.rds")

gs_auth(token = "googlesheets_shiny_token.rds")
sheet_key <- "1fXobkrovIjB1AgbP5TxzlFVztpJ9tTMQHb8-Js_KFoA"

# meta data scraping code courtesy of @hrbrmstr
# https://stackoverflow.com/questions/27863627/parsing-meta-name-content-using-xml-and-r

get_meta <- function(url) {

  pg <- read_html(url)

  all_meta_attrs <- unique(unlist(lapply(lapply(pg %>% html_nodes("meta"), html_attrs), names)))

  dat <- data.frame(lapply(all_meta_attrs, function(x) {
    pg %>% html_nodes("meta") %>% html_attr(x)
  }), stringsAsFactors = FALSE)

  colnames(dat) <- all_meta_attrs

  track <- filter_all(dat, any_vars(. == "og:title"))$content
  track <- ifelse(identical(track, character(0)), "", track)

  description <- filter_all(dat, any_vars(. == "og:description"))$content
  description <- ifelse(identical(description, character(0)), "", description)

  embed <- filter_all(dat, any_vars(. == "twitter:player"))$content
  embed <- ifelse(identical(embed, character(0)), "", embed)

  if (str_detect(url, "youtu")) {
    embed <- paste0(embed, "?autoplay=1")
  } else if (str_detect(embed, "soundcloud")) {
    embed <- str_replace(embed, "auto_play=false", "auto_play=true")
  } else if (str_detect(embed, "mixcloud")) {
    embed <- str_replace(embed, "feed=%2", "autoplay=1&feed=%2") %>% 
      str_replace("&amp;hide_cover=1&amp;hide_tracklist=1", "")
  }

  image <- filter_all(dat, any_vars(. == "twitter:image"))$content
  image <- ifelse(identical(image, character(0)), filter_all(dat, any_vars(. == "og:image"))$content, image)
  image <- ifelse(identical(image, character(0)), "", image)

  tibble(
    Added = Sys.time(),
    Track = track,
    Description = description,
    Link = url,
    Embed = embed,
    Artwork = sprintf("<img src='%s' title='%s'/>", image, str_replace_all(description, "'", "")),
    Image = image
  )

}

# Thanks to Dean Attali for the busy indicator code
# https://github.com/daattali/advanced-shiny/tree/master/busy-indicator

# Set up a button to have an animated loading indicator and a checkmark
# for better user experience
# Need to use with the corresponding `withBusyIndicator` server function
withBusyIndicatorUI <- function(button) {
  id <- button[['attribs']][['id']]
  div(style = "display: inline-block",
    `data-for-btn` = id,
    button,
    span(
      class = "btn-loading-container",
      hidden(
        img(src = "ajax-loader-bar.gif", class = "btn-loading-indicator"),
        icon("check", class = "btn-done-indicator")
      )
    ),
    hidden(
      div(class = "btn-err",
          div(icon("exclamation-circle"),
              tags$b("Error: "),
              span(class = "btn-err-msg")
          )
      )
    )
  )
}

# Call this function from the server with the button id that is clicked and the
# expression to run when the button is clicked
withBusyIndicatorServer <- function(buttonId, expr) {
  # UX stuff: show the "busy" message, hide the other messages, disable the button
  loadingEl <- sprintf("[data-for-btn=%s] .btn-loading-indicator", buttonId)
  doneEl <- sprintf("[data-for-btn=%s] .btn-done-indicator", buttonId)
  errEl <- sprintf("[data-for-btn=%s] .btn-err", buttonId)
  shinyjs::disable(buttonId)
  shinyjs::show(selector = loadingEl)
  shinyjs::hide(selector = doneEl)
  shinyjs::hide(selector = errEl)
  on.exit({
    shinyjs::enable(buttonId)
    shinyjs::hide(selector = loadingEl)
  })

  # Try to run the code when the button is clicked and show an error message if
  # an error occurs or a success message if it completes
  tryCatch({
    value <- expr
    shinyjs::show(selector = doneEl)
    shinyjs::delay(2000, shinyjs::hide(selector = doneEl, anim = TRUE, animType = "fade",
                                       time = 0.5))
    value
  }, error = function(err) { errorFunc(err, buttonId) })
}

# When an error happens after a button click, show the error
errorFunc <- function(err, buttonId) {
  errEl <- sprintf("[data-for-btn=%s] .btn-err", buttonId)
  errElMsg <- sprintf("[data-for-btn=%s] .btn-err-msg", buttonId)
  errMessage <- gsub("^ddpcr: (.*)", "\\1", err$message)
  shinyjs::html(html = errMessage, selector = errElMsg)
  shinyjs::show(selector = errEl, anim = TRUE, animType = "fade")
}
