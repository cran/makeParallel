## ------------------------------------------------------------------------
d <- tempdir()
oldscript <- system.file("examples/mp_example.R", package = "makeParallel")
script <- file.path(d, "mp_example.R")
file.copy(oldscript, script)
list.files(d)

## ------------------------------------------------------------------------
library(makeParallel)

g <- makeParallel(script, file = TRUE)

## ------------------------------------------------------------------------
list.files(d)

## ---- echo = FALSE, results = "hide"-------------------------------------
stopifnot("gen_mp_example.R" %in% list.files(d))
unlink(d, recursive = TRUE)

## ------------------------------------------------------------------------
input <- parse(text = "
    x <- list(a = 1:10, beta = exp(-3:3), logic = c(TRUE,FALSE,FALSE,TRUE))
    m1 <- lapply(x, mean)
    m2 <- list()
    for(i in seq_along(x)) {
        m2[[i]] = mean(x[[i]])
    }
    ")

transformed <- makeParallel(input)

## ------------------------------------------------------------------------
input

## ------------------------------------------------------------------------
newcode <- writeCode(transformed)

newcode

## ------------------------------------------------------------------------
eval(newcode)
m2

## ------------------------------------------------------------------------
m2new <- m2
eval(input)
m2

stopifnot( all(as.numeric(m2) == as.numeric(m2new)) )

