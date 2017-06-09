#' Obtain RSS feed URL
#'
#' @param username GitHub username. If missing, will attempt to use GITHUB_PAT to determine it.
#' @param password GitHub password. If missing, will be prompted to enter is securely.
#'
#' @return a two-element list containing the username and RSS atom feed URL
#' @export
obtain_feed <- function(username, password) {

    ## see if the user already has a GITHUB_PAT set
    ## if so, take the username from that
    user <- github_GET("/user")
    if (is.null(user$login) && missing(username)) stop("Requires a username")

    ## get the list of user items from api.github.com/feeds
    ## ask the user for their password, securely
    feeds <- httr::GET("https://api.github.com/feeds",
                       httr::authenticate(user = user$login,
                                          password = ifelse(missing(password),
                                                            getPass::getPass("Please enter your Github password"),
                                                            password
                                          )))

    if (identical(httr::status_code(feeds), 200L)) {
        return(list(user = user$login,
                    feed = httr::content(feeds)$current_user_url)
        )
    } else {
        message(httr::warn_for_status(feeds))
        return(list(user = NULL,
                    feed = NULL)
        )
    }
}


github_auth <- function(token) {
    if (is.null(token)) {
        NULL
    } else {
        httr::authenticate(token, "x-oauth-basic", "basic")
    }
}

github_response <- function(req) {
    text <- httr::content(req, as = "text")
    parsed <- jsonlite::fromJSON(text, simplifyVector = FALSE)

    if (httr::status_code(req) >= 400) {
        stop(github_error(req))
    }

    parsed
}

github_error <- function(req) {
    text <- httr::content(req, as = "text", encoding = "UTF-8")
    parsed <- tryCatch(jsonlite::fromJSON(text, simplifyVector = FALSE),
                       error = function(e) {
                           list(message = text)
                       })
    errors <- vapply(parsed$errors, `[[`, "message", FUN.VALUE = character(1))

    structure(
        list(
            call = sys.call(-1),
            message = paste0(parsed$message, " (", httr::status_code(req), ")\n",
                             if (length(errors) > 0) {
                                 paste("* ", errors, collapse = "\n")
                             })
        ), class = c("condition", "error", "github_error"))
}

## stolen from hadley/devtools/github.R
github_GET <- function(path, ..., pat = github_pat(),
                       host = "https://api.github.com") {

    url <- httr::parse_url(host)
    url$path <- paste(url$path, path, sep = "/")
    ## May remove line below at release of httr > 1.1.0
    url$path <- gsub("^/", "", url$path)
    ##
    req <- httr::GET(url, github_auth(pat), ...)
    github_response(req)
}

github_pat <- function(quiet = FALSE) {
    pat <- Sys.getenv("GITHUB_PAT")
    if (nzchar(pat)) {
        if (!quiet) {
            message("Using GitHub PAT from envvar GITHUB_PAT")
        }
        return(pat)
    }
    message("No GITHUB_PAT environment variable set.\nConsider setting one?\nInstructions: https://itsalocke.com/using-travis-make-sure-use-github-pat/")
    return(NULL)
}

in_ci <- function() {
    nzchar(Sys.getenv("CI"))
}
