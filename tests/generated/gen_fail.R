library(parallel)
nworkers = 2
cls = makeCluster(nworkers, "PSOCK")
clusterMap(cls, assign, "ID", seq(nworkers), MoreArgs = list(envir = .GlobalEnv))
worker_code = c("if(ID != 1)\n    stop(sprintf(\"Worker is attempting to execute wrong code.\nThis code is for 1, but manager assigned ID %s\", ID))\n\nab = \"a\" + \"b\"", "if(ID != 2)\n    stop(sprintf(\"Worker is attempting to execute wrong code.\nThis code is for 2, but manager assigned ID %s\", ID))\n\nprint(\"If this line prints then execution proceeded after the error. Fix it.\")")
evalg = function(codestring) {
    code = parse(text = codestring)
    eval(code, .GlobalEnv)
    NULL
}
parLapply(cls, worker_code, evalg)
stopCluster(cls)
