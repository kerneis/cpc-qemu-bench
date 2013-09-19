#!/usr/bin/R --vanilla --slave -f

data <- read.csv("../data/microbench.csv")

# aggregate by backend
mean_agg <- aggregate(list(time = round(data$time * 1e9 / data$iterations)),
                      by=list(backend = sapply(data$backend, function(x) gsub("-nopool", "", x)),
                              pool = sapply(data$backend, function(x) toString(!grep("-nopool", x))),
                              test = data$test),
                      FUN="mean")
median_agg <- aggregate(list(time = round(data$time * 1e9 / data$iterations)),
                      by=list(backend = sapply(data$backend, function(x) gsub("-nopool", "", x)),
                              pool = sapply(data$backend, function(x) toString(!grep("-nopool", x))),
                              test = data$test),
                      FUN="median")

# sort

print("Mean time (over 10 runs)")
mean_agg[with(mean_agg, order(test, pool, time,backend)),]

print("Median time (over 10 runs)")
median_agg[with(mean_agg, order(test, pool, time,backend)),]
