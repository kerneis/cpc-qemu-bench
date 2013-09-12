#!/usr/bin/R --vanilla --slave -f

library(ggplot2)
library(reshape2)
library(plyr)

argv <- commandArgs(TRUE)

# First parameter is the column to plot
rw <- argv[1]
yvars <- argv[2:length(argv)]

# merge all input files together
files <- list.files(".", pattern=paste("^", rw, "-.*-guest\\.csv$", sep=""))
pool <- grep("nopool", files, invert=TRUE, value=TRUE)
nopool <- grep("nopool", files, value=TRUE)

read_data <- function(files) {
  datas <- lapply(files, read.csv)
  dat <- Reduce(rbind, datas)
  return(dat)
}

poold <- read_data(pool)
nopoold <- read_data(nopool)
#fulld <- read_data(files)

draw_graph <- function(rw, yvar, dat, nopool="") {
  png(filename=paste(rw, "-", yvar, nopool, ".png", sep=""), height=600, width=800)

  aggr <- aggregate(eval(substitute(
                    var ~ backend + numjobs , list(var = as.name(yvar)))),
                    FUN = "median", data = dat) 
  g <- ggplot(aggr, aes_string(x="numjobs", y=yvar, color="backend", shape="backend")) +
    geom_point() +
    geom_line()
    # + scale_y_log10(limits=c(1,max(aggr[[yvar]])))

  print(g)

  dev.off()
}

for (yvar in yvars) {
  #draw_graph(rw, yvar, fulld)
  draw_graph(rw, yvar, poold)
  draw_graph(rw, yvar, nopoold, "-nopool")
}
