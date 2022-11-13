# Final Project
# Where in the world is arabica coffee?

# Data exploration and statistical analysis

## Load Libraries
library(dplyr)
library(tidyr)
library(rcompanion)
library(ggplot2)
library(tidyverse)
library(car)
library(mvnormtest)
library(ggplot2)
library(writexl)

## Load coffee2.csv dataset

## Column Counts
view(table(coffee2$Country.of.Origin))
view(table(coffee2$Processing.Method))
view(table(coffee2$Region.Name))
## Processing Method of Washed/Wet accounts for 73% of method used
## Coffee from Mexico accounts for 22% country of origin

#*****************************************************************************************************************************

# Does coffee country of origin and processing method affect total cup points?

## Remove unnecessary columns & rows for analysis
### Remove Columns
coffee3 <- subset(coffee2, select = -c(X, Country.of.OriginR, RegionR, Processing.MethodR))

### Remove Rows with only 1 instance of Country.of.Origin
coffee3 <- coffee3[-c(37, 80, 204, 303, 415, 624, 910), ]
view(coffee3)

## Export coffee3 csv for later use
write_csv(coffee3, "C:\\Users\\timca\\Desktop\\coffee3.csv")

## Find the mean & standard deviation of total cup points for for each country/processing group & region/processing group.

### mean & stdev of Total Cup Points grouped by Country of Origin & Processing Method
view(coffee3 %>% group_by(Country.of.Origin, Processing.Method) %>%
  summarize(count = n(),
            mean = mean(Total.Cup.Points),
            sd = sd(Total.Cup.Points)))
### Of the 10 highest count by processing method, 7 are washed/wet, which is in line with 73% of that method being used in general 
### with this data.  Columbia washed/wet has the highest mean total cup score of 83.58 from the top 10 by count.  Columbia natural/dry
### has the lowest standard deviation at 1.075, with 24 samples.  Honduras washed/wet has the biggest stdev spread at 4.08 with 33
### total count.


### Fit Country.of.Origin & Processing.Method with a 2-way ANOVA against Total.Cup.Points

model1 <- aov(Total.Cup.Points ~ Country.of.Origin * Processing.Method, data = coffee3)
summary(model1)
#### Country.of.Origin is significant with p value < .05
#### Processing.Method is not significant
#### Country.of.Origin:Processing.Method is significant p < .05


### Check Model1 for normality assumption creating histogram of residuals

resid1 <- model1$residuals
hist(resid1, main = "Histogram of Residuals", xlab = "Residuals", col = "green")
#### Residuals are roughly normally distributed with a slight negative skew, normality assumption is met


### Conduct Levene's test for assumption on homogeneity of variances
### Load library(car)

leveneTest(Total.Cup.Points ~ Country.of.Origin * Processing.Method, data = coffee3)
#### Failed homogeneity of variance with P value < .05


### Correct for violating assumption of homogeneity of variance

ANOVA <- lm(Total.Cup.Points ~ Country.of.Origin * Processing.Method, data = coffee3)
Anova(ANOVA, Type="II", white.adjust=TRUE)
#### Unable to correct violation of homogeneity of variance
#### Will not be moving forward as there is little significance of country and processing method affecting total cup points

#*****************************************************************************************************************************

### mean & stdev of Total Cup Points grouped by Country Region & Processing Method

view(coffee3 %>% group_by(Region.Name, Processing.Method) %>%
  summarize(count = n(),
            mean = mean(Total.Cup.Points),
            sd = sd(Total.Cup.Points)))
### Of the top 5 highest count, processing method washed/wet is 4 of 5.  South America washed/wet has the highest mean of 83.42 in
### top 5 in count.  S America natural/dry has the lowest stdev at 1.38 in top 5 and 2nd lowest overall within a group with significant
### count.  


### Check Model1 for normality assumption creating histogram of residuals

resid2 <- model2$residuals
hist(resid2, main = "Histogram of Residuals", xlab = "Residuals", col = "green")
#### Residuals are roughly normally distributed with a slight negative skew, normality assumption is met


### Fit Country Region & Processing.Method with a 2-way ANOVA against Total.Cup.Points

model2 <- aov(Total.Cup.Points ~ Region.Name * Processing.Method, data = coffee3)
summary(model2)
#### Region.Name is significant with p value < .05
#### Processing.Method is not significant
#### Region.Name:Processing.Method is significant p < .05

## Will not move forward with Region and Processing Method as prediction of Total Cup Points

#*****************************************************************************************************************************

# What is the affect of country on total cup points?

### mean & stdev of Total Cup Points grouped by Country of Origin
view(coffee3 %>% group_by(Country.of.Origin) %>%
       summarize(count = n(),
                 mean = mean(Total.Cup.Points),
                 sd = sd(Total.Cup.Points)))

## Run ANOVA since IV is categorical and DV is continuous

## Test Normality
plotNormalHistogram(coffee3$Total.Cup.Points)
### Assumption of Normality is passed

## Homogeneity of Variance
bartlett.test(Total.Cup.Points ~ Country.of.Origin, data = coffee3)
fligner.test(Total.Cup.Points ~ Country.of.Origin, data = coffee3)
### violated the assumption of homogeneity of variance p value < .05 for bartlett & fligner

## Correct for violated homogeneity of variance using Welch's One-way test
ANOVA <- lm(Total.Cup.Points ~ Country.of.Origin, data=coffee3)
Anova(ANOVA, Type="II", white.adjust=TRUE)
### p value < .01 so there is significant difference in Total Cup Points between all the countries somewhere

## Computing Post Hocs with violated homogeneity of variance
view(pairwise.t.test(coffee3$Total.Cup.Points, coffee3$Country.of.Origin, p.adjust="bonferroni", pool.sd = FALSE))
### There is significance between certain countries with the biggest difference between Colombia and Mexico  This has to do
### with Mexico and Colombia have 2 of 3 largest sample sizes

## Determine Means and draw conclusions
view(coffee3 %>% group_by(Country.of.Origin) %>%
       summarize(count = n(),
                 mean = mean(Total.Cup.Points)))

## Conclusion of Country of Origin to Total Cup Points
### Since assumption of homogeneity of variance wasn't met, post hocs show little difference between total cup point means, but  
### partially due to the sample of size of each individual coffee.  There could be enough difference to sway how you go about 
### trying coffee in the future


#*****************************************************************************************************************************

# What is the affect of world region on total cup points?

### mean & stdev of Total Cup Points grouped by Country of Origin
view(coffee3 %>% group_by(Region.Name) %>%
       summarize(count = n(),
                 mean = mean(Total.Cup.Points),
                 sd = sd(Total.Cup.Points)))

## Run ANOVA since IV is categorical and DV is continuous

## Test Normality
plotNormalHistogram(coffee3$Total.Cup.Points)
### Assumption of Normality is passed

## Homogeneity of Variance
bartlett.test(Total.Cup.Points ~ Region.Name, data = coffee3)
fligner.test(Total.Cup.Points ~ Region.Name, data = coffee3)
### violated the assumption of homogeneity of variance p value < .05 for bartlett & fligner

## Correct for violated homogeneity of variance using Welch's One-way test
ANOVA <- lm(Total.Cup.Points ~ Region.Name, data=coffee3)
Anova(ANOVA, Type="II", white.adjust=TRUE)
### p value < .01 so there is significant difference in Total Cup Points between the country regions somewhere

## Computing Post Hocs with violated homogeneity of variance
pairwise.t.test(coffee3$Total.Cup.Points, coffee3$Region.Name, p.adjust="bonferroni", pool.sd = FALSE)
### There is significance between Africa - Asia, C America and S America; Asia - Mexico and S America; C America - S America
### Mexico - S America

## Determine Means and draw conclusions
coffee3 %>% group_by(Region.Name) %>%
  summarize(mean = mean(Total.Cup.Points))

## Conclusion of World Region to Total Cup Points
### Since assumption of homogeneity of variance wasn't met, post hocs show little difference between total cup point means, but 
### there could be enough of a difference to sway what region you prefer or want to purchase from 

#******************************************************************************************************************

# Does Processing Method affect Acidity and Aftertaste?
# Run a MANOVA since IV is categorical and have 2 continuous DV

## Subset DVs to run a matrix using keeps
keeps <- c("Acidity", "Aftertaste")
coffee4 <- coffee3[keeps]

## Format coffee4 as matrix
coffee5 <- as.matrix(coffee4)

## Test Assumptions ##
## Multivariate Normality - Wilkes-Shapiro test

mshapiro.test(t(coffee5))
### Violated the assumption of multivariate normality with p value < .05
### THE DATA DOES NOT MEET THE ASSUMPTION FOR MANOVAs, WILL NOT BE PROCEEDING

#*******************************************************************************************************************

# Does Altitude affect Total Cup Points
# Run a simple linear regression since IV and DV are continuous

## Run Pearson correlation test
cor.test(coffee3$altitude_mean_meters, coffee3$Total.Cup.Points, method = "pearson", use = "complete.obs")
### p value is < .05 so there is significance, but the correlation is fairly low at .188

## Run Linear regression
lin_reg <- lm(Total.Cup.Points ~ altitude_mean_meters, coffee3)
print(lin_reg)
### y = .00113x + 80.6312

## Summary Linear Regression
summary(lin_reg)
### Overall Model Significance
### p value for t-test is significant at < .05 as well as the p value overall.  But altitude is able explain about 3% of the 
### factors that go into total cup points 

## Plot altitude against total cup points
ggplot(coffee3, aes(x = altitude_mean_meters, y = Total.Cup.Points)) + geom_point() + geom_smooth(method=lm)
### There is a positive correlation between altitude & total cup points, with the bulk between 1100 - 1800m altitude

# Overall, Altitude can impact Total Cup Points, but there are many other variables involved in Total Cup Points

#**************************************************************************************************************

# Stepwise Regression - What scoring categories affect the Cupper.Points?

## Backward Elimination

FitAll = lm(Cupper.Points ~ Aroma + Flavor + Aftertaste + Acidity + Body + Balance + Uniformity + Clean.Cup + Sweetness, data = coffee3)
summary(FitAll)

step(FitAll, direction = 'backward')
fitsome = lm(Cupper.Points ~ Flavor + Aftertaste + Acidity + 
               Body + Balance + Clean.Cup, data = coffee3)
summary(fitsome)


## Forward Selection

FitStart = lm(Cupper.Points ~ 1, data = coffee3)
summary(FitStart)

step(FitStart, direction = 'forward', scope = (formula(FitAll)))
fitsome2 = lm(Cupper.Points ~ Flavor + Aftertaste + Balance + 
                Acidity + Body + Clean.Cup, data = coffee3)
summary(fitsome2)


## Hybrid Stepwise

step(FitStart, direction = "both", scope = formula(FitAll))
fitsome3 = lm(Cupper.Points ~ Flavor + Aftertaste + Balance + 
                Acidity + Body + Clean.Cup, data = coffee3)
summary(fitsome3)

### The best model for Cupper.Points is Flavor, Aftertaste, Balance, Acidity, Body & Clean.Cup.  Flavor, Aftertaste & Balance are
### the most significant in determining Cupper.Points.  Clean.Cup is not significant at all, but combined with the other 5 scoring
### categories, gives the best result.

#***************************************************************************************************************

