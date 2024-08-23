library(devtools)
breedR_repo <- "https://famuvie.github.io/breedR/"
devtools::install_github("famuvie/breedR", repos = breedR_repo)
devtools::install_github("OnofriAndreaPG/lmDiallel")

library(lmDiallel)
library(breedR)
library(ggplot2)
set.seed(123)

## Simulation parameters
n.parents <- c(male = 15L,
               female = 10L)
n.matings <- 100
n.replicates <- 40
mu = 10        # Intercept
sigma2_g <- 6  # Genetic variance of the base population
sigma2_s <- 1  # Variance of the SCA
sigma2_e <- 1  # Residual variance
## Generate all crosses and sample a subset
parents.codes <- list(male = seq.int(n.parents['male']),
                      female = n.parents['male'] + seq.int(n.parents['female']))
matings <- expand.grid(parents.codes)
matings <- matings[sample(prod(n.parents), n.matings),]
rownames(matings) <- with(matings, paste(male, female, sep = 'x'))

## Simulated values
GCA = sapply(do.call('c', parents.codes),
             function(x) rnorm(1, mean = 0, sd = sqrt(sigma2_g)))
SCA = sapply(rownames(matings),
             function(x) rnorm(1, mean = 0, sd = sqrt(sigma2_s)))

## Expected phenotype per family
eta.family <- mu + SCA + (GCA[matings$male] + GCA[matings$female])/2

## Realised Breeding Values in the progeny
## (intra-family variance = half genetic variance)
n.progeny <- n.replicates*n.matings
eta.realised <- eta.family + rnorm(n.progeny, sd = sqrt(sigma2_g/2))

dat <- data.frame(Id = max(sapply(parents.codes, max)) + seq.int(n.progeny),
                  rep = rep(seq.int(n.replicates), each = n.matings),
                  matings,
                  eta.realised,
                  y = eta.realised + rnorm(n.progeny, sd = sqrt(sigma2_e)))

## Define variable for the non-additive SCA
dat <- transform(dat,
                 SCA   = factor(paste(male, female, sep = 'x'),
                                levels = rownames(matings)))

## Printing simulated setting
print(table(dat[, c('male', 'female')]), zero.print = "")
str(dat)

# ---------------------------------
df <- read.csv("./data/Low_phosphate_group.csv", header = T)
str(df)
df$Geno <- as.factor(df$Geno)
df$Rep <- as.factor(df$Rep)


gcsres <- GCA(df[df$Rep == 1,][,-c(1,2)],df[df$Rep == 2,][,-c(1,2)])
class(gcsres)

write.table(gcsres, "./data/gcs.txt")

sink("./data/gcs_calc1.txt")
GCA(df[df$Rep == 1,][,-c(1,2)],df[df$Rep == 2,][,-c(1,2)])
sink()
plot(GCA(df[df$Rep == 1,][,-c(1,2)],df[df$Rep == 2,][,-c(1,2)]))
