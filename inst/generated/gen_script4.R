library(parallel)
nworkers = 2
timeout = 600
cls = makeCluster(nworkers, "PSOCK")
workers = vector(nworkers, mode = "list")
close.NULL = function(...) NULL
connect = function(server, client, port, sleep = 0.1, ...) {
    if (ID == server) {
        con = socketConnection(port = port, server = TRUE, blocking = TRUE, open = "a+b", ...)
        workers[[client]] <<- con
    }
    if (ID == client) {
        Sys.sleep(sleep)
        con = socketConnection(port = port, server = FALSE, blocking = TRUE, open = "a+b", ...)
        workers[[server]] <<- con
    }
    NULL
}
clusterExport(cls, c("workers", "connect", "close.NULL"))
clusterMap(cls, assign, "ID", seq(nworkers), MoreArgs = list(envir = .GlobalEnv))
socket_map = read.csv(text = "\n\"server\",\"client\",\"port\"\n1,2,33000\n")
by(socket_map, seq(nrow(socket_map)), function(x) {
    clusterCall(cls, connect, x$server, x$client, x$port, timeout = timeout)
})
worker_code = c("if(ID != 1)\n    stop(sprintf(\"Worker is attempting to execute wrong code.\nThis code is for 1, but manager assigned ID %s\", ID))\n\na1 = 1\na2 = 2\nb2 <- unserialize(workers[[2]])\na3 = a1 + a2 + b2\nserialize(a2, workers[[2]], xdr = FALSE)\nb3 <- unserialize(workers[[2]])\na4 = a2 + a3 + b3\nserialize(a3, workers[[2]], xdr = FALSE)\nb4 <- unserialize(workers[[2]])\na5 = a3 + a4 + b4\nserialize(a4, workers[[2]], xdr = FALSE)", "if(ID != 2)\n    stop(sprintf(\"Worker is attempting to execute wrong code.\nThis code is for 2, but manager assigned ID %s\", ID))\n\nb1 = 1\nb2 = 2\nserialize(b2, workers[[1]], xdr = FALSE)\na2 <- unserialize(workers[[1]])\nb3 = b1 + b2 + a2\nserialize(b3, workers[[1]], xdr = FALSE)\na3 <- unserialize(workers[[1]])\nb4 = b2 + b3 + a3\nserialize(b4, workers[[1]], xdr = FALSE)\na4 <- unserialize(workers[[1]])\nb5 = b3 + b4 + a4\nwriteLines(as.character(b5), \"script4.R.log\")")
evalg = function(codestring) {
    code = parse(text = codestring)
    eval(code, .GlobalEnv)
    NULL
}
parLapply(cls, worker_code, evalg)
clusterEvalQ(cls, lapply(workers, close))
stopCluster(cls)
