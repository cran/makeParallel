## ----echo=FALSE, eval=FALSE, results='hide',message=FALSE----------------
#  
#      n = 1e6
#  
#      xfile = tempfile()
#      write.csv(data.frame(x = rnorm(n)), xfile, row.names = FALSE)
#  
#      yfile = tempfile()
#      write.csv(data.frame(y = rnorm(n)), yfile, row.names = FALSE)
#  

## ---- fig.width = 8, fig.height = 6, results = "hide"--------------------
library(makeParallel)

code = parse(text = "
    x = read.csv(xfile)
    y = read.csv(yfile)
    xy = sort(c(x[, 1], y[, 1]))
    ")

pcode = makeParallel(code, scheduler = scheduleTaskList
    , exprTime = c(1.25, 1.24, 0.2))

plot(schedule(pcode))

## ------------------------------------------------------------------------
writeCode(pcode)

## ------------------------------------------------------------------------
coresGenerate <- function(schedule, mc.cores = 2L, ...)
{
    # Rely on the method dispatch for the actual work.
    out <- generate(schedule, ...)

    # Construct an expression containing the desired code.
    setCores <- substitute(options(mc.cores = MC_CORES)
                          , list(MC_CORES = mc.cores))

    # Combine the newly constructed expression with what would have been
    # generated otherwise.
    out@code <- c(setCores, writeCode(out))
    out
}

## ------------------------------------------------------------------------
lapplyCode <- parse(text = "
    x <- list(a = 1:10, beta = exp(-3:3), logic = c(TRUE,FALSE,FALSE,TRUE))
    m1 <- lapply(x, mean)
")

transformed <- makeParallel(lapplyCode, generator = coresGenerate,
                            generatorArgs = list(mc.cores = 3L))

## ------------------------------------------------------------------------
writeCode(transformed)

## ---- echo = FALSE, results = "hide"-------------------------------------
# Testing, make sure the docs do what they say!
stopifnot(writeCode(transformed)[[1]] == quote(options(mc.cores = 3L)))

## ------------------------------------------------------------------------
setClass("WorkerMapSchedule", slots = c(mc.cores = "integer"), contains = "MapSchedule")

## ------------------------------------------------------------------------
workerMapSchedule = function(graph, mc.cores = 2L, ...)
{
    message(sprintf("User defined scheduler, mc.cores = %s", mc.cores))
    out = mapSchedule(graph, ...)
    new("WorkerMapSchedule", out, mc.cores = mc.cores)
}

## ------------------------------------------------------------------------
setMethod("generate", "WorkerMapSchedule", function(schedule, ...)
    coresGenerate(as(schedule, "MapSchedule"), mc.cores = schedule@mc.cores, ...)
)

## ------------------------------------------------------------------------
transformed <- makeParallel(code, scheduler = workerMapSchedule, mc.cores = 3L)

writeCode(transformed)

## ---- echo = FALSE, results = "hide"-------------------------------------
# Testing, make sure the docs do what they say!
stopifnot(writeCode(transformed)[[1]] == quote(options(mc.cores = 3L)))

