#' Create a shinydashboard of the recent activity
#'
#' @inheritParams obtain_feed
#' @param feed (optionally) a GitHub RSS feed URL (with token) to use
#' @return produces a shinydashboard of recent activity.
#' @export
starryeyes <- function(username, password, feedURL) {

    # loadNamespace("shiny")
    # loadNamespace("DT")
    # loadNamespace("shinydashboard")

    if (!missing(feedURL)) {
        my_feed_list <- list(user = "",
                             feed = feedURL)
    } else {
        my_feed_list <- obtain_feed(username, password)
    }
    my_table <- extract_feed(my_feed_list$feed)
    my_table$thumb <- paste0("<img src=\"", sub("^(.*)\\?.*$", "\\1", my_table$thumb), "\" height = \"60\"></img>")
    my_table$links <- paste0("<a href=", my_table$links, ">", my_table$target, "</a>")
    my_table$published <- paste(format(Sys.time() - as.POSIXct(my_table$published, format = "%Y-%m-%dT%TZ"), digits = 3), "ago")

    ui <- shinydashboard::dashboardPage(
        shinydashboard::dashboardHeader(title = my_feed_list$user),
        shinydashboard::dashboardSidebar(disable = TRUE),
        shinydashboard::dashboardBody(
            shiny::fluidRow(
                shinydashboard::box(DT::dataTableOutput("table1"), width = 12)
            )
        )
    )

    server <- function(input, output) {
        output$table1 <- DT::renderDataTable({
            DT::datatable(my_table[ , c("thumb", "user", "action", "target", "published", "links")],
                          escape = FALSE,
                          options = list(pageLength = 100))
        })
    }

    shiny::shinyApp(ui, server)

}
