context("RSS feed")

## store the GITHUB_PAT
old_pat <- Sys.getenv("GITHUB_PAT")
Sys.setenv(GITHUB_PAT = "")
test_that("feed can be returned when user does NOT have a valid GITHUB_PAT set",
          expect_error(obtain_feed())
)

## use the bundled pat to at least retrieve something
bundled <- paste0("b2b7441d",
                  "aeeb010b",
                  "1df26f1f6",
                  "0a7f1ed",
                  "c485e443")
Sys.setenv(GITHUB_PAT=bundled)
test_that("feed can be returned when a user DOES have a valid GITHUB_PAT set", {
          expect_warning(obtain_feed(password = ""))
          expect_equivalent(suppressWarnings(is.null(obtain_feed(password = "")[[2]])), TRUE)
})

## return the GITHUB_PAT to normal
Sys.setenv(GITHUB_PAT=old_pat)
