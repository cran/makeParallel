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
worker_code = c("if(ID != 1)\n    stop(sprintf(\"Worker is attempting to execute wrong code.\nThis code is for 1, but manager assigned ID %s\", ID))\n\nv1 = \"foo1\"\nx <- paste0(v1, v1)\ny <- unserialize(workers[[2]])\nxy <- paste0(x, y)\nwriteLines(xy, \"script1.R.log\")", "if(ID != 2)\n    stop(sprintf(\"Worker is attempting to execute wrong code.\nThis code is for 2, but manager assigned ID %s\", ID))\n\nv2 = \"foo2\"\ny <- paste0(v2, v2)\nserialize(y, workers[[1]], xdr = FALSE)")
evalg = function(codestring) {
    code = parse(text = codestring)
    eval(code, .GlobalEnv)
    NULL
}
parLapply(cls, worker_code, evalg)
clusterEvalQ(cls, lapply(workers, close))
stopCluster(cls)
