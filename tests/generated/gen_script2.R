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
worker_code = c("if(ID != 1)\n    stop(sprintf(\"Worker is attempting to execute wrong code.\nThis code is for 1, but manager assigned ID %s\", ID))\n\na = 7\nb = a + 4\ny <- unserialize(workers[[2]])\nc = b + y\nserialize(c, workers[[2]], xdr = FALSE)", "if(ID != 2)\n    stop(sprintf(\"Worker is attempting to execute wrong code.\nThis code is for 2, but manager assigned ID %s\", ID))\n\nx = 1\ny = x + 2\nserialize(y, workers[[1]], xdr = FALSE)\nc <- unserialize(workers[[1]])\noutput = c(\"got:\", c * x * y, \"expected:\", (7 + 4 + 1 + 2) * 1 * (1 + 2))\nwriteLines(output, \"script2.R.log\")")
evalg = function(codestring) {
    code = parse(text = codestring)
    eval(code, .GlobalEnv)
    NULL
}
parLapply(cls, worker_code, evalg)
clusterEvalQ(cls, lapply(workers, close))
stopCluster(cls)
