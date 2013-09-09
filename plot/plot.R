#!/usr/bin/R --vanilla --slave -f
exit_usage <- function() {
    print("usage: --arg (file | folder) [(file | folder) ...]")
    q()
}

compute_data <- function(csvFile) {
    document_name = basename(sub(".csv$", "", csvFile))

    csvData <- (read.table(csvFile, header=TRUE, sep=";"))[c("time", "rcvBytes", "sndBytes")]
	timeDiff <- diff(csvData[,"time"], differences=1)
#	csvData["time"] <- csvData[,"time"] - csvData[1,"time"]
	csvData <- data.frame(time=csvData[2:nrow(csvData),"time"],
		rcvThroughput=c(1000000 * diff(csvData[,"rcvBytes"], differences=1) / timeDiff),
		sndThroughput=c(1000000 * diff(csvData[,"sndBytes"], differences=1) / timeDiff))

    list(name = document_name,
         data = csvData)
}

# Draw axis and sub-graduations by hand.
draw_axis <- function(i, color = "black") {
    axis_labels = axis(i, col = color)
    len = length(axis_labels)
    maxVal = axis_labels[len] * 2
    by_step = axis_labels[len] - axis_labels[len - 1]
    axis(i, at = seq(from = 0, to = maxVal, by = by_step),
         tcl = -.75, col = color)
    axis(i, at = seq(from = 0, to = maxVal, by = by_step/2),
         tcl = -.5 , col = color, labels = FALSE)
    axis(i, at = seq(from = 0, to = maxVal, by = by_step/4),
         tcl = -.25, col = color, labels = FALSE)
}

draw_legend <- function(names, col, lty) {
    legend("topleft", legend = names,
           col=col,
           ncol=1, cex = 1,
           lwd = 1, lty = lty, pch=-1,
           inset = 0, bg = "white", x.intersp = 1)
    mtext(txt_time, 1, line = 2, las = 0)
    mtext(txt_throughput, 2, line = 2, las = 0)
}

open_device <- function(filename, type) {
    filename <- sub(paste(".", type, "$", sep=""), "", filename)
    filename = paste(filename, type, sep=".");
    print(paste("drawing:", filename))
    if(Sys.info()[["sysname"]] == "Darwin") {
        # On MacOS, the best is to use quartz.
        quartz(file = filename, width = flag_width,
               height = flag_height, type = type, dpi=300)
    } else {
        # Works on Linux:
        f_pixels <- function() {
            do.call(type, list(file = filename, width = flag_width,
                    height = flag_height, units = "in", res = 300))
        }
        f_other <- function() {
            do.call(type, list(file = filename, width = flag_width,
                    height = flag_height))
        }
        tryCatch(f_pixels(), error = function(e) {f_other()})
    }
}

draw_graph <- function(csvFiles) {
    data <- list()
    argc <- length(csvFiles)
    tmax = Inf
    tmin = 0
    ymax = 0
    for(i in 1:argc) {
        if(length(grep(".csv$", csvFiles[i])) == 0) {
            print(paste("Invalid file:", csvFiles[i]))
            exit_usage()
        } else {
            print(paste("compute", csvFiles[i]))
            tmp <- compute_data(csvFiles[i])
            tmax <- min(tmax, max(tmp$data[,"time"]))
            tmin <- max(tmin, min(tmp$data[,"time"]))
            data[[i]] <- tmp
        }
    }

    for(i in 1:argc) {
		data[[i]]$data <- subset(data[[i]]$data, tmin < time)
		data[[i]]$data <- subset(data[[i]]$data, time < tmax)
		data[[i]]$data["time"] <- (data[[i]]$data["time"] - tmin) / 1000000000
		ymax <- max(ymax, max(data[[i]]$data["rcvThroughput"]))
    }

    # set output
    open_device(flag_filename, flag_output_type)
    par(mar = c(3,4,0,0) + 0.1)
    plot(0, type="n", xlab="", ylab="", main="", axes = FALSE) # create empty graph.
    foo <- par(no.readonly = TRUE)
    rm(foo)

    # fix scales
	xmax <- (tmax - tmin) / 1000000000
    xlim <- c(0, xmax)
    ylim <- c(0, ymax)

    # Set palette
    palette(colors()[c(11, 24, 28, 35, 44, 51, 77, 84, 93)])

    # plot requests
    print(paste(sep="", "xmax = ", xmax))
    print(paste(sep="", "ymax = ", ymax))
    line_type <- 2
    color <- 1
    legend_names <- c()
    legend_col   <- c()
    legend_lty   <- c()
    box(bty="o")
    for(i in 1:argc) {
        tmpDat <- data[[i]]$data
        par(new = TRUE)
        plot(tmpDat$time,
             tmpDat$rcvThroughput,
             xlim = xlim, ylim = ylim,
             xlab = "", ylab = "",
             pch = 1, col = color, cex = 1,
             bty = "o", type = "o",
             axes = FALSE, lty = line_type)
        legend_names <- c(legend_names, data[[i]]$name)
        legend_col   <- c(legend_col, color)
        legend_lty   <- c(legend_lty, line_type)
        color <- color + 1
        line_type <- (line_type %% 6) + 1
    }
    draw_axis(1)
    draw_axis(2)

    draw_legend(legend_names, legend_col, legend_lty) 

    rc <- dev.off()
}


# program begins
argv <- commandArgs(TRUE)
argc <- length(argv)
if(argc <= 0)
    exit_usage()

# parse options
flag_xmax <- Inf
flag_ymax <- Inf
flag_lang <- "en"
flag_width <- 12.8
flag_height <- 8
flag_filename <- "graph"
flag_output_type <- "png"
recurse <- TRUE

i <- 1
while(1) {
    if(argv[i] == "--xmax") {
        flag_xmax <- as.numeric(argv[i+1])
    } else if(argv[i] == "--ymax") {
        flag_ymax <- as.numeric(argv[i+1])
    } else if(argv[i] == "--lang") {
        flag_lang <- argv[i+1]
    } else if(argv[i] == "--width") {
        flag_width <- as.numeric(argv[i+1])
    } else if(argv[i] == "--height") {
        flag_height <- as.numeric(argv[i+1])
    } else if(argv[i] == "--out") {
        flag_filename <- paste(getwd(), sep="/", argv[i+1])
    } else if(argv[i] == "--out-type") {
        flag_output_type <- argv[i+1]
    } else { # 1 argument cases
        if(argv[i] == "--no-recurse") {
            recurse <- FALSE
        } else {
            break   # quit loop
        }
        i <- i + 1  # skip 1 argument
        next
    }
    i <- i + 2      # skip 2 arguments
}
argv <- argv[i:argc]
argc <- argc - i + 1

# set languages considerations
if(flag_lang == "fr") {
    txt_time <- "Temps de l'expérience (s)"
    txt_throughput  <- "Débit (Ko/s)"
} else {
    txt_time <- "Time of experiment (s)"
    txt_throughput  <- "Throughput (Ko/s)"
}

# draw a graph with csvFiles given in command line
csvFiles <- argv[grep("[.]csv$", argv)]
if(length(csvFiles) != 0)
    draw_graph(csvFiles)

# draw a graph per subdirectories given in command line
absolutePath <- getwd()
for(arg in argv) {
    if(!file.exists(arg)) {
        print(paste("file does not exists:", arg))
        q()
    }
    if(file.info(arg)$isdir) {
        if(recurse) {
            tmp <- arg
            arg <- list.dirs(tmp, recursive=TRUE)
            rm(tmp)
        }
        for(argdir in arg) {
            setwd(paste(absolutePath, argdir, sep="/"))
            csvFiles <- list.files(".", pattern="[.]csv", recursive=FALSE)
            if(length(csvFiles) > 0)
                draw_graph(csvFiles)
        }
    }
}

print("finished")

