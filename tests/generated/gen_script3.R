library(parallel)
nworkers = 2
cls = makeCluster(nworkers, "PSOCK")
clusterMap(cls, assign, "ID", seq(nworkers), MoreArgs = list(envir = .GlobalEnv))
worker_code = c("if(ID != 1)\n    stop(sprintf(\"Worker is attempting to execute wrong code.\nThis code is for 1, but manager assigned ID %s\", ID))\n\na1 = 1\na2 = a1 + 1\na3 = a2 + 1\na4 = a3 + 1", "if(ID != 2)\n    stop(sprintf(\"Worker is attempting to execute wrong code.\nThis code is for 2, but manager assigned ID %s\", ID))\n\nb1 = 1\nc1 = 1\nc2 = c1 + 1\nb2 = b1 + 1\nb3 = b2 + 1\nb4 = b3 + 1\nc3 = c2 + 1\nwriteLines(as.character(c3), \"script3.R.log\")")
evalg = function(codestring) {
    code = parse(text = codestring)
    eval(code, .GlobalEnv)
    NULL
}
parLapply(cls, worker_code, evalg)
stopCluster(cls)
