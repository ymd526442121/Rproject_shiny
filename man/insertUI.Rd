% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/insert-ui.R
\name{insertUI}
\alias{insertUI}
\title{Insert UI objects}
\usage{
insertUI(selector, multiple = FALSE, where = c("beforeBegin", "afterBegin",
  "beforeEnd", "afterEnd"), ui, immediate = FALSE, container = if (inline)
  "span" else "div", inline = FALSE, session = getDefaultReactiveDomain())
}
\arguments{
\item{selector}{A string that is accepted by jQuery's selector (i.e. the
string \code{s} to be placed in a \code{$(s)} jQuery call). This selector
will determine the element(s) relative to which you want to insert your
UI object.}

\item{multiple}{In case your selector matches more than one element,
\code{multiple} determines whether Shiny should insert the UI object
relative to all matched elements or just relative to the first
matched element (default).}

\item{where}{Where your UI object should go relative to the selector:
\describe{
  \item{\code{beforeBegin}}{Before the selector element itself}
  \item{\code{afterBegin}}{Just inside the selector element, before its
  first child}
  \item{\code{beforeEnd}}{Just inside the selector element, after its
  last child (default)}
  \item{\code{afterEnd}}{After the selector element itself}
}
Adapted from
\href{https://developer.mozilla.org/en-US/docs/Web/API/Element/insertAdjacentHTML}{here}.}

\item{ui}{The UI object you want to insert. This can be anything that
you usually put inside your apps's \code{ui} function.}

\item{immediate}{Whether the UI object should be immediately inserted into
the app when you call \code{insertUI}, or whether Shiny should wait until
all outputs have been updated and all observers have been run (default).}

\item{container}{A function to generate an HTML element to contain the UI
object.}

\item{inline}{Use an inline (\code{span()}) or block container (\code{div()},
default) for the output.}

\item{session}{The shiny session within which to call \code{insertUI}.}
}
\description{
Insert a UI object into the app.
}
\details{
This function allows you to dynamically add an arbitrarily large UI
object into your app, whenever you want, as many times as you want.
Unlike \code{\link{renderUI}}, the UI generated with \code{insertUI}
is not updatable as a whole: once it's created, it stays there. Each
new call to \code{insertUI} creates more UI objects, in addition to
the ones already there (all independent from one another). To
update a part of the UI (ex: an input object), you must use the
appropriate \code{render} function or a customized \code{reactive}
function. To remove any part of your UI, use \code{\link{removeUI}}.

Note that whatever UI object you pass through \code{ui}, it is always
wrapped in an extra \code{div} (or if \code{inline = TRUE}, a
\code{span}) before making its way into the DOM. This does not affect
what you mean to do, and it makes it easier to remove the whole UI
object using \code{\link{removeUI}} (if you wish to do so, of course).
}
\examples{
## Only run this example in interactive R sessions
if (interactive()) {
# Define UI
ui <- fluidPage(
  actionButton("add", "Add UI")
)

# Server logic
server <- function(input, output, session) {
  observeEvent(input$add, {
    insertUI(
      selector = "#add",
      where = "afterEnd",
      ui = textInput(paste0("txt", input$add),
                     "Insert some text")
    )
  })
}

# Complete app with UI and server components
shinyApp(ui, server)
}

}
\seealso{
\code{\link{removeUI}}
}

