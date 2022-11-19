data <- read.csv("C:\\Users\\berx\\Downloads\\punkte.txt", header=TRUE)
head(data)

sgalm <- lm(sga ~cpu , data=data)
summary(sgalm)

data$sga_calc <- 112.25 + 44.5 * data$cpu
data$sga_calc <- summary(sgalm)$coefficients["(Intercept)", "Estimate"] + summary(sgalm)$coefficients["cpu", "Estimate"] * data$cpu

head(data)
plot(data$cpu, data$sga/1024, xlab="cpu_count", ylab="minimum SGA required (GB)")
plot(data$cpu, data$sga_calc)

data$diff <- data$sga - data$sga_calc

plot(data$cpu, data$diff, xlab="cpu_count", ylab="residuals (MB)")
abline(v=4, col="red")
abline(v=32, col="blue")
abline(v=112, col="black")

