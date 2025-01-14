# setup and import data
source("requirements.R")
here::here()
demo_data <- readr::read_csv("data/demo_data.csv")

# BayesFactor indep t test -----
demo_ttest <- ttestBF(x = demo_data %>% filter(group=="1") %>% dplyr::select(continuous_var_num) %>% unlist(), 
                      y = demo_data %>% filter(group=="2") %>% dplyr::select(continuous_var_num) %>% unlist(),
                      paired=FALSE, 
                      # posterior = TRUE, iterations = 1000,
                      rscale=.707)
    # ttestBF() function documentation at https://www.rdocumentation.org/packages/BayesFactor/versions/0.9.12-4.2/topics/ttestBF
demo_ttest
exp(demo_ttest@bayesFactor$bf)  # non-log Bayes factor
median(demo_ttest[,4]) # median of posterior

# same:
summary(demo_ttest[,"mu"])
summary(demo_ttest[,4])
summary(demo_ttest)
median(demo_ttest[,"mu"], 4)


# sample from the posterior distribution
chains = posterior(demo_ttest, iterations = 10000)
# The posterior function returns a object of type BFmcmc, which inherits 
# the methods of the mcmc class from the coda package
summary(chains) # median delta = -.321, same as JASP
# median beta (x - y) is also mean diff?? = -.22
plot(chains[,2]) # beta, x-y
plot(chains[,4]) # trace plot of mean diff, delta (effect size)
plot(density(chains[,4])) # density plot of mean diff, delta
plot(chains[,1:2])



# BayesFactor paired t test -----

bayesttest <- BayesFactor::ttestBF(demo_data_prepost$pre, 
                                   demo_data$post,  
                                   paired=TRUE, posterior = TRUE, iterations = 1000)
median(bayesttest[,4]) # median of posterior
plot(bayesttest[,"mu"])

# one-sample t test -----
BF = ttestBF(demo_data$continuous_var_num, rscale = 0.707)
exp(BF@bayesFactor$bf)  # non-log Bayes factor
# Higher r values mean a wider distribution.

# sample from the posterior distribution for the numerator model
chains = posterior(BF, iterations = 10000)
plot(chains[,2])


# links on using BayesFactor -----

#BayesFactor
#Using the 'BayesFactor' package 
#https://richarddmorey.github.io/BayesFactor/
#  correlationBF function
#https://rpubs.com/lindeloev/bayes_factors
#https://twitter.com/jonaslindeloev/status/963577225546223616
