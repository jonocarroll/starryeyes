#' Extract GitHub RSS feed
#'
#' @param feed a list containing two elements: a username and a RSS atom link
#'
#' @return a data.frame of the RSS feed contents
#' @export
extract_feed <- function(feed) {

    entries <- httr::GET(feed) %>%
        xml2::read_html() %>%
        rvest::html_nodes("entry")

    id <- rvest::html_nodes(entries, "id") %>%
        rvest::html_text() %>%
        gsub("^.*:", "", x = .) %>%
        gsub("Event.*$", "", x = .)
    title <- rvest::html_nodes(entries, "title") %>%
        rvest::html_text()
    user <- sub("^(.*?) .*", "\\1", title)
    action <- sub("^(.*?) (.*) .*$", "\\2", title)
    target <- sub("^.* (.*?)$", "\\1", title)
    published <- rvest::html_nodes(entries, "published") %>%
        rvest::html_text()
    links <- rvest::html_nodes(entries, "link") %>%
        rvest::html_attr("href")
    thumb <- rvest::html_nodes(entries, "thumbnail") %>%
        rvest::html_attr("url")

    tidyfeed <- data.frame(
        thumb, user, action, target, published, id, links, stringsAsFactors = FALSE
    )

    return(tidyfeed)

}

#' Pipe operator
#'
#' @name %>%
#' @rdname pipe
#' @keywords internal
#' @export
#' @importFrom magrittr %>%
#' @usage lhs \%>\% rhs
NULL

globalVariables(".")
