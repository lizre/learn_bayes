# setup and import data
here::here()
source("requirements.R")
demo_data <- readr::read_csv("data/demo_data.csv")

indep_ttest = read.csv("test.csv") # example independent groups t test data
# vignette(package = "brms")
# Main page https://github.com/paul-buerkner/brms
# The brms package provides an interface to fit Bayesian generalized (non-)linear multivariate multilevel models using Stan, which is a C++ package for performing full Bayesian inference

model = brm(price ~ place,
            data = apples)

bfInterval <- ttestBF(prepost_joined_nomissing$dass_stresssum_pre, prepost_joined_nomissing$dass_stresssum_post, nullInterval=c(-Inf,0)) 


# one sample t test -----

# Source
# How to compute Bayes factors using lm, lmer, BayesFactor, brms, and JAGS/stan/pymc3
# https://rpubs.com/lindeloev/bayes_factors
# across these methods, get diff BFs (range 3.7 to 14.1). these "small differences" are likely due to differences in priors. but "brms::hypothesis is erroneous".

# can model almost all (non-)linear models, including structural equation modeling

priors_intercept = c(set_prior('cauchy(0, 0.707)', 
                               class = 'Intercept'))  # JZS prior as the BayesFactor package, though without the Jeffreys prior on Sigma for simplicity.
full_brms = brm(score ~ 1, 
                data = intercept_data, 
                prior = priors_intercept, sample_prior = TRUE, iter = 10000)
BF_brms_savage = hypothesis(full_brms, 
                            hypothesis = 'Intercept = 0')
1 / BF_brms_savage$hypothesis$Evid.Ratio  # Inverse to make it in favor of the full model
# brms::hypothesis fails here because it relies on the Savage-Dickey density ratio between the prior and the posterior. This fails for priors that are hard to sample (Cauchy amd others): https://twitter.com/paulbuerkner/status/963585470482604033:
# The difference between brms::hypothesis and brms::bayes_factor is because it is very hard to sample from a cauchy distribution since it doesn't even have a mean or variance. Thus, please **do not** trust brms::hypothesis here, but use the brms::bayes_factor output. If you choose a more well behaving prior such as a normal distribution, both functions will yield highly similar results.

# Luckily, there’s a more general solution in brms::bayesfactor:
#  It mainly differs from brms::hypothesis in that you should fit the null model independently and change some arguments:
priors_intercept = c(set_prior('cauchy(0, 0.707)', 
                               class = 'Intercept'))  # JZS prior as the BayesFactor package, though without the Jeffreys prior on Sigma for simplicity.
full_brms = brm(score ~ 1, data = intercept_data, prior = priors_intercept, save_all_pars = TRUE, iter=10000)
null_brms = brm(score ~ 0, data = intercept_data, save_all_pars = TRUE, iter = 10000)
BF_brms_bridge = bayes_factor(full_brms, null_brms)
BF_brms_bridge$bf
# I’m told that you need a lot of samples to get accurate Bayes factors using brm, so be sure to do multiple runs to ensure convergence.



# independent samples t test -----
mod_eqvar_demo <- brm(
  continuous_var_num ~ group, 
  data = demo_data)

mod_eqvar_demo
# Population level effects
# "Estimate" = .11 = mean diff 
# intercept is 11.78, which is what mean would be for group 0, which we don't have. 

summary(mod_eqvar_demo)
# Rhat: how well the algorithm could estimate the posterior dist of this parameter. If considerably greater than 1, the algorithm has not yet converged and it is necessary to run more iterations and / or set stronger priors.
plot(mod_eqvar_demo) 
launch_shinystan(mod_eqvar_demo)
plot(brms::conditional_effects(mod_eqvar_demo))

mod_robust <- brm(
  bf(continuous_var_num ~ group, sigma ~ group),
  family=student,
  data = indep_ttest, 
  cores=4)
mod_robust
# sigma = shared standard deviation 


# links on using brms -----

# Corr in brms 	
# https://solomonkurz.netlify.com/post/bayesian-robust-correlations-with-brms-and-why-you-should-love-student-s-t/
  #https://solomonkurz.netlify.com/post/bayesian-correlations-let-s-talk-options/
  #https://bookdown.org/ajkurz/DBDA_recoded/bayesian-approaches-to-testing-a-point-null-hypothesis.html
#https://bookdown.org/ajkurz/Statistical_Rethinking_recoded/linear-models.html#adding-a-predictor
#Get bayes factors
# https://vuorre.netlify.com/post/2017/03/21/bayes-factors-with-brms/
  