library(parallel)
nworkers = 2
timeout = 600
cls = makeCluster(nworkers, "PSOCK")
workers = vector(nworkers, mode = "list")
close.NULL = function(...) NULL
connect = function(server, client, port, timeout, sleep = 0.1, ...) {
    if (ID == server) {
        con = socketConnection(port = port, server = TRUE, blocking = TRUE, open = "a+b", timeout = timeout, ...)
        workers[[client]] <<- con
    }
    if (ID == client) {
        Sys.sleep(sleep)
        con = socketConnection(port = port, server = FALSE, blocking = TRUE, open = "a+b", timeout = timeout, ...)
        workers[[server]] <<- con
    }
    NULL
}
environment(connect) = environment(close.NULL) = .GlobalEnv
clusterExport(cls, c("workers", "connect", "close.NULL"), envir = environment())
clusterMap(cls, assign, "ID", seq(nworkers), MoreArgs = list(envir = .GlobalEnv))
socket_map = read.csv(text = "\n\"server\",\"client\",\"port\"\n1,2,33000\n")
by(socket_map, seq(nrow(socket_map)), function(x) {
    clusterCall(cls, connect, x$server, x$client, x$port, timeout = timeout)
})
worker_code = c("if(ID != 1)\n    stop(sprintf(\"Worker is attempting to execute wrong code.\nThis code is for 1, but manager assigned ID %s\", ID))\n\na1 = 1\nb1 = a1 + 1\nb2 = a1 + 1\nb3 = a1 + 1\nb4 = a1 + 1\nserialize(b4, workers[[2]], xdr = FALSE)\nb7 = a1 + 1", "if(ID != 2)\n    stop(sprintf(\"Worker is attempting to execute wrong code.\nThis code is for 2, but manager assigned ID %s\", ID))\n\na2 = 2\nb5 = a2 + 2\nb4 <- unserialize(workers[[1]])\nb6 = a2 + b4 + b5\nwriteLines(as.character(b6), \"script7.R.log\")")
evalg = function(codestring) {
    code = parse(text = codestring)
    eval(code, .GlobalEnv)
    NULL
}
parLapply(cls, worker_code, evalg)
clusterEvalQ(cls, lapply(workers, close))
stopCluster(cls)
