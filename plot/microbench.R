#!/usr/bin/R --vanilla --slave -f

data <- read.csv("../data/microbench.csv")

# aggregate by backend
mean_agg <- aggregate(time ~ backend, FUN="mean", data=data)
median_agg <- aggregate(time ~ backend, FUN="median", data=data)

# sort

print("Mean time (over 10 runs)")
mean_agg[with(mean_agg, order(time,backend)),]

print("Median time (over 10 runs)")
median_agg[with(median_agg, order(time,backend)),]
