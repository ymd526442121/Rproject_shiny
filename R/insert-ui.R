#' Insert UI objects
#'
#' Insert a UI object into the app.
#'
#' This function allows you to dynamically add an arbitrarily large UI
#' object into your app, whenever you want, as many times as you want.
#' Unlike \code{\link{renderUI}}, the UI generated with \code{insertUI}
#' is not updatable as a whole: once it's created, it stays there. Each
#' new call to \code{insertUI} creates more UI objects, in addition to
#' the ones already there (all independent from one another). To
#' update a part of the UI (ex: an input object), you must use the
#' appropriate \code{render} function or a customized \code{reactive}
#' function. To remove any part of your UI, use \code{\link{removeUI}}.
#'
#' Note that whatever UI object you pass through \code{ui}, it is always
#' wrapped in an extra \code{div} (or if \code{inline = TRUE}, a
#' \code{span}) before making its way into the DOM. This does not affect
#' what you mean to do, and it makes it easier to remove the whole UI
#' object using \code{\link{removeUI}} (if you wish to do so, of course).
#'
#' @param selector A string that is accepted by jQuery's selector (i.e. the
#' string \code{s} to be placed in a \code{$(s)} jQuery call). This selector
#' will determine the element(s) relative to which you want to insert your
#' UI object.
#'
#' @param multiple In case your selector matches more than one element,
#' \code{multiple} determines whether Shiny should insert the UI object
#' relative to all matched elements or just relative to the first
#' matched element (default).
#'
#' @param where Where your UI object should go relative to the selector:
#' \describe{
#'   \item{\code{beforeBegin}}{Before the selector element itself}
#'   \item{\code{afterBegin}}{Just inside the selector element, before its
#'   first child}
#'   \item{\code{beforeEnd}}{Just inside the selector element, after its
#'   last child (default)}
#'   \item{\code{afterEnd}}{After the selector element itself}
#' }
#' Adapted from
#' \href{https://developer.mozilla.org/en-US/docs/Web/API/Element/insertAdjacentHTML}{here}.
#'
#' @param ui The UI object you want to insert. This can be anything that
#' you usually put inside your apps's \code{ui} function.
#'
#' @param immediate Whether the UI object should be immediately inserted into
#' the app when you call \code{insertUI}, or whether Shiny should wait until
#' all outputs have been updated and all observers have been run (default).
#'
#' @param container A function to generate an HTML element to contain the UI
#' object.
#'
#' @param inline Use an inline (\code{span()}) or block container (\code{div()},
#' default) for the output.
#'
#' @param session The shiny session within which to call \code{insertUI}.
#'
#' @seealso \code{\link{removeUI}}
#'
#' @examples
#' ## Only run this example in interactive R sessions
#' if (interactive()) {
#' # Define UI
#' ui <- fluidPage(
#'   actionButton("add", "Add UI")
#' )
#'
#' # Server logic
#' server <- function(input, output, session) {
#'   observeEvent(input$add, {
#'     insertUI(
#'       selector = "#add",
#'       where = "afterEnd",
#'       ui = textInput(paste0("txt", input$add),
#'                      "Insert some text")
#'     )
#'   })
#' }
#'
#' # Complete app with UI and server components
#' shinyApp(ui, server)
#' }
#'
#' @export
insertUI <- function(selector,
  multiple = FALSE,
  where = c("beforeBegin", "afterBegin", "beforeEnd", "afterEnd"),
  ui,
  immediate = FALSE,
  container = if (inline) "span" else "div",
  inline = FALSE,
  session = getDefaultReactiveDomain()) {

  force(selector)
  force(ui)
  force(session)
  force(multiple)
  force(container)
  if (missing(where)) where <- "beforeEnd"
  where <- match.arg(where)

  callback <- function() {
    session$sendInsertUI(selector = selector,
                         multiple = multiple,
                         where = where,
                         content = processDeps(ui, session),
                         container = container)
  }

  if (!immediate) session$onFlushed(callback, once = TRUE)
  else callback()
}


#' Remove UI objects
#'
#' Remove a UI object from the app.
#'
#' This function allows you to remove any part of your UI. Once \code{removeUI}
#' is executed on some element, it is gone forever.
#'
#' While it may be a particularly useful pattern to pair this with
#' \code{\link{insertUI}} (to remove some UI you had previously inserted),
#' there is no restriction on what you can use \code{removeUI} on. Any
#' element that can be selected through a jQuery selector can be removed
#' through this function.
#'
#' @param selector A string that is accepted by jQuery's selector (i.e. the
#' string \code{s} to be placed in a \code{$(s)} jQuery call). This selector
#' will determine the element(s) to be removed. If you want to remove a
#' Shiny input or output, note that many of these are wrapped in \code{div}s,
#' so you may need to use a somewhat complex selector (see the Examples below).
#'
#' @param multiple In case your selector matches more than one element,
#' \code{multiple} determines whether Shiny should remove all the matched
#' elements or just the first matched element (default).
#'
#' @param immediate Whether the element(s) should be immediately removed from
#' the app when you call \code{removeUI}, or whether Shiny should wait until
#' all outputs have been updated and all observers have been run (default).
#'
#' @param session The shiny session within which to call \code{removeUI}.
#'
#' @seealso \code{\link{insertUI}}
#'
#' @examples
#' ## Only run this example in interactive R sessions
#' if (interactive()) {
#' # Define UI
#' ui <- fluidPage(
#'   actionButton("rmv", "Remove UI"),
#'   textInput("txt", "This is no longer useful")
#' )
#'
#' # Server logic
#' server <- function(input, output, session) {
#'   observeEvent(input$rmv, {
#'     removeUI(
#'       selector = "div:has(> #txt)"
#'     )
#'   })
#' }
#'
#' # Complete app with UI and server components
#' shinyApp(ui, server)
#' }
#'
#' @export
removeUI <- function(selector,
  multiple = FALSE,
  immediate = FALSE,
  session = getDefaultReactiveDomain()) {

  force(selector)
  force(multiple)
  force(session)

  callback <- function() {
    session$sendRemoveUI(selector = selector,
                         multiple = multiple)
  }

  if (!immediate) session$onFlushed(callback, once = TRUE)
  else callback()
}
