# run.R - DESC
# /run.R

# Copyright European Union, 2017
# Author: Iago Mosqueira (EC JRC) <iago.mosqueira@ec.europa.eu>
#
# Distributed under the terms of the European Union Public Licence (EUPL) V.1.1.

# nameGrid {{{
#' nameGrid
#'
#' Creates folder names from a 'grid' df of scenarios
#'
nameGrid <- function(df, dir, from=1) {
	df$number <- seq(from=from, length=nrow(df))
	df$id <- paste(df$number, apply(df, 1, function(x)
		paste0(gsub(" ", "", paste0(names(x), as.character(x))), collapse="_")), sep="-")
	return(df)
}
# }}}

# rungrid {{{
runss3grid <- function(grid, dir=paste0('grid', format(Sys.time(), "%Y%m%d")),
  logfile=paste0(dir, '/run_grid_log'),
	options="") {
	
	cat("START: ", date(), "\n", file=logfile)

  # FIND ss3 in pkg
	if (.Platform$OS.type == "unix") {
    ss3path <- system.file("bin/linux/", package="ss3om")
    sep <- ":"
    exe <- "ss3"
	} else if (.Platform$OS.type == "windows") {
    ss3path <- system.file("bin/windows/", package="ss3om")
    sep <- ";"
    exe <- "ss3.exe"
  }

  # SET $PATH
  path <- paste0(ss3path, sep, Sys.getenv("PATH"))
  Sys.setenv(PATH=path)

	foreach (i=grid$number, .errorhandling = "remove") %dopar% {
    
    row <- which(grid$number == i)
		dirname <- paste(dir, grid[row, "id"], sep="/")
		
    cat("[", i, "]\n")
    cat(grid[row,'id'], ": ", date(), "\n", file=logfile, append=TRUE)

		# SS3!
		workdir <- getwd()
		setwd(dirname)
		system(paste(exe, options), ignore.stdout = TRUE, ignore.stderr = TRUE)
		setwd(workdir)

		cat("DONE ", grid[row,'id'], ": ", date(), "\n", file=logfile, append=TRUE)
	}

	cat("END: ", date(), "\n", file=logfile, append=TRUE)

	invisible(0)
} # }}}