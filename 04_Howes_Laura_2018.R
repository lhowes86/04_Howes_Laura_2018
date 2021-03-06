#'----------------------
#'
#' Homework week 04
#' 
#' @Date 2018-10-07
#' 
#' @author Laura Howes
#' 
#' ---------------------
#' 

library(dplyr)
library(ggplot2)
library(tidyr)

#---
# Problem 1
#---

###W&S Chapter 6 questions 15, 21, and 29

###15: null hypotheses

####15a: There is no difference in mean femur lengths between Pygmy Mammoths and Continental mammoths.

####15b: Patients who take phentermien and topiramate lose weight as the same rate as control patients who don't take them.

####15c: Patients who take phentermien and topiramate have the same proportions of babies born with cleft palates as control patients who don't take them.

####15d: Shoppers buy the same amount of Candy while Christmas music is playing as shoppers who listen to the usual type of music do.

####15e: Male white-collared manakins dance the same amount of time when females are present and when females are absent.

###21:

####21a: A study has more power if the sample size is large, so the 60-participant study has more of a likelihood of committing a Type II error because is has a lower power than the 100 sample size.

####21b: The study with the 100 sample size has higher power. 

####21c: Type I errors are controlled by the size of alpha, so unless the studies use two different alphas (which they do not), than they have an equal chance of committing a Type I error.

####21d: The test should be two-tailed because there are two effects that could happen, cardiac arrest could increase or decrease.

###29:

####29a: The alpha value is also the P value, so the the probability the researchers would reject none of them is 5%.

####29b: 5 tests on average are expected to reject the null hypothesis if all null hypotheses were true.

#---
# Problem 2
#---

###22: Use R to calculate a p-value

pbinom(6101, size=9821, prob= 0.5, lower.tail= FALSE)
####P = 3.207137e-129 (very small)

####22a: Calculate the 95% CI interval

binom.test(6101, 9821, conf.level = 0.95)

####number of successes = 6101, number of trials = 9821, p-value < 2.2e-16 alternative hypothesis: true probability of success is not equal to 0.5.
####95 percent confidence interval: 0.6115404-0.6308273

####22b: Since the P value is very small, it is not plausible for a 50:50 chance the toast landing butter side-up or butter side-down.

#---
# Problem 3
#---

###3: From the Lab: Many SDs and Alphas. What sample size do we need to achieve a power of 0.8?

####3.1: Start up your simulation. Multiple sample sizes: from 1-20, with 500 simulations per sample size
####multiple SD values, from 3 through 10 (just 3:10, no need for non-integer values)
####You're going to want crossing with your intitial data frame of just sample sizes and a 
####vector of sd values to start. Then generate samples from the appropriate random normal distribution.

Sim <- data.frame(samp_size = rep(1:20, 500))
####1 though 20, repeated 500 timess
SD_values <- c(3:10)
Sim <- crossing(Sim, SD_values)

Sim <- Sim %>% 
  group_by(1:n()) %>% #1 though 10, repeated 500 timess
  mutate(sample_mean= mean(rnorm(samp_size, 85, SD_values))) %>%
  ungroup()

####3.2: Z! 

Sim <- Sim %>% 
  mutate(sigma_ybar= SD_values/(sqrt(samp_size))) %>%  
  mutate(Z_score= (sample_mean - 80)/sigma_ybar) %>%
  mutate(p_val= pnorm(abs(Z_score), lower.tail = FALSE))%>% 
  ungroup()

Sim_plot <- ggplot(data= Sim, mapping = aes(x= samp_size, y= p_val)) + 
  geom_jitter() +
  facet_wrap(~SD_values)

Sim_plot

####3.3: P and Power

Sim_power <- Sim %>%
  group_by(SD_values, samp_size) %>%
  summarize(power= 1-sum(p_val>0.05)/n()) %>%
  ungroup()

Sim_power_plot <- ggplot(data= Sim_power, mapping= aes(x= samp_size, y= power, group= SD_values, color= factor(SD_values))) +
  geom_line() +
  geom_hline(yintercept = 0.8)

Sim_power_plot

####3.4: Many alphas

Sim_alphas <- Sim %>% 
  crossing(alpha= seq(0.01, 0.1, .01)) %>%
  group_by(samp_size, SD_values, alpha) %>%
  summarize(power= 1- sum(p_val > alpha)/n()) %>%
  ungroup()

Sim_alphas_plot <- ggplot(data = Sim_alphas, mapping= aes(x= samp_size, y= power, color= factor(alpha))) +
  geom_line() +
  facet_wrap(~SD_values)

Sim_alphas_plot

####3.5: What does it all mean? What do you learn about how alpha and SD affect power?

#####If you make alpha bigger it gives greater power, but then you have a greater probability of rejecting 
#####the null hypothesis falsely. you need a high  SD value in order to get the needed power of at least 0.8.

####3.6 How do you think that changing the effect size would affect power?

#####I think a bigger effect size would increase the power.

  