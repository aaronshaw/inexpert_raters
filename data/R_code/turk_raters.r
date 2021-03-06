# R code for AMT analysis
# Shaw, Horton, Chen - 2010
#
# Created: Monday, June 14, 2010
# 
# Last Revised: 12/6/2010

# preliminaries:

rm(list = ls() )

library(foreign)
library(ggplot2)
library(Hmisc)
require(stats)
require(graphics)

# the package multtest requires Biobase, which is not available
# through the CRAN repository. To install Biobase, uncomment
# the next two lines:
#source("http://www.bioconductor.org/biocLite.R")
#biocLite("Biobase")   
library(multtest)

# get the data:

d <- read.csv("~/Dropbox/turk_raters/AMT-data/Turk_raters_data_2010-0614.csv")# alter location accordingly

## Tests to see if the randomization worked

rando <- lm(as.numeric(condition) ~ hhsize + female + country, data=d)
summary(rando)
# correct for multiplpe comparisons.
rando.model <- summary(rando)
pvals.rando <- rando.model$coefficients[,4]
adjp.rando <- mt.rawp2adjp(pvals.rando, "Bonferroni")
adjp.rando
# none are significant.


#subset the data to remove demographic control for analysis of the outcomes:
dsub <- subset(d, condition != "Demog only")


# remove the missing level & order remaining levels to make life easier
ordlevs <- levels(dsub$condition)[c(5,15,4,3,12,13,10,11,14,9,7,16,2,8,1)]

dsub$condition <- factor(dsub$condition, levels= ordlevs)


# looking at reults & models for the individual questions
avatartab <- table(dsub$avatars)
avatartab

model.avatars <- lm(avatars ~ condition, data = dsub)
summary(model.avatars)

contenttab <- table(dsub$contentrank)
contenttab

model.content <- lm(contentrank ~ condition, data = dsub)
summary(model.content)

userstab <- table(dsub$usersrank)
userstab

model.users <- lm(usersrank ~ condition, data = dsub)
summary(model.users)

revtab <- table(dsub$revenue)
revtab

model.rev <- lm(revenue ~ condition, data = dsub)
summary(model.rev)

sntab <- table(dsub$socnetwork)
sntab

model.sn <- lm(socnetwork ~ condition, data = dsub)
summary(model.sn)


# tests for each result to see whether workers did better
# than chance:
# for each - p == vector of probabilities for responses...

p.av <- c(.75, .25)
p.content <- c(.8,.2)
p.users <- c(.8,.2)
p.rev <- c(.5, .5)
p.sn <- c(.5, .5)

c(avatartab[1]/sum(avatartab),avatartab[2]/sum(avatartab))
c(contenttab[1]/sum(contenttab),contenttab[2]/sum(contenttab))
c(userstab[1]/sum(userstab),userstab[2]/sum(userstab))
c(revtab[1]/sum(revtab),revtab[2]/sum(revtab)) 
c(sntab[1]/sum(sntab),sntab[2]/sum(sntab))

chisq.test(avatartab, p=p.av)
chisq.test(contenttab, p=p.content)
chisq.test(userstab, p=p.users)
chisq.test(revtab, p=p.rev)
chisq.test(sntab, p=p.sn)
# all tests are significant, suggesting that the actual distributions are
# different from the theoretical distributions predicted by guessing
# answers randomly for each question.
# note, this means that the revenue responses were in fact worse than
# chance


 

###
#
# Describing Worker Performance on the aggregated outcome
# the key outcome variable is agg.nopriv


# Now, a few models looking at the aggregated outcome.

# first, check out the distribution of outcomes
qplot(dsub$agg.nopriv, fill="blue", binwidth=.35, )

# The alternative version (no sn) this distribution's a little bit fat
qplot(dsub$agg.noprivsn)

# ggplot object version
aggd <- dsub[,c(3,12)]

names(aggd) <- c("condition","score")

aggplot <- ggplot(aggd, aes(score))


# This plot captures the outcome distribution per treatment condition)
aggplot1 <- aggplot + geom_bar(binwidth=.5, fill="#0571B0") + scale_x_continuous(name="\nCorrect answers\n(population mean highlited)", limits=c(-.5, 5), breaks=c(-.25,.75,1.75,2.75,3.75,4.75), labels=c(0:5)) + facet_wrap(~ condition, nrow=3) + scale_y_continuous(name="Numbrer of workers\n") + opts(title="Worker performance distributions\n(per condition)\n") + geom_vline(xintercept=(mean(aggd$score)-.25), colour="darkred", alpha=.5, linetype=2)


aggplot1 


# This plot captures the outcome distribution - aggregate)
aggplot2 <- aggplot + theme_bw() + geom_bar(binwidth=.5, fill="#0571B0") + scale_x_continuous(name="\nCorrect answers", limits=c(-.5, 5), breaks=c(-.25,.75,1.75,2.75,3.75,4.75), labels=c(0:5)) + scale_y_continuous(name="Number of workers\n") + geom_vline(xintercept=(mean(aggd$score)-.25), colour="black", linetype=2)+ geom_text(aes(x=mean(aggd$score-.25), y=450, label="mean = 2.38"), size = 6, hjust = 0, vjust = -.45, angle = 270, colour="black") + opts(axis.title.x = theme_text(size=24), axis.title.y = theme_text(size=24, angle=90), axis.text.x=theme_text(size=18, vjust=1.5), axis.text.y=theme_text(size=18, hjust=1.5))

aggplot2



# + opts(title="Worker performance distributions for all conditions\n")

postscript("../images/AggPerf.eps", title=NULL, horizontal=FALSE, pointsize=40, width=9, height=8)
aggplot2
dev.off()


# MODEL 1
# This first model would calculate aggregated results for all questions
# no need to run it, b/c one of the questions (privacy) was pre-treatment)
# model.agg1 <- lm(agg.result ~ condition, data = dsub)
# summary(model.agg1)


# MODEL 2 - this is the one I think we should use in the paper
# agg.nopriv removes privacy results to calculate performance w.out that one


model.agg2 <- lm(agg.nopriv ~ condition, data = dsub)
summary(model.agg2)


# MODEL 3 -
# agg.noprivsn removes sn too since the contingency table of results suggests no significant differences across treatments
model.agg3 <- lm(agg.noprivsn ~ condition, data = dsub)
summary(model.agg3)



####
# ADJUSTMENTS FOR MULTIPLE TESTS:
#
# calculate adjusted p values using the second model (no privacy q)
tests <- c("Bonferroni","Holm", "Hochberg")

m2 <- summary(model.agg2)
pvals.m2 <- m2$coefficients[2:15,4]
adjp.m2 <- mt.rawp2adjp(pvals.m2, tests)

adjp.m2

# and again for the third model (no sn q, since no sig variation)
m3 <- summary(model.agg3)
pvals.m3 <- m3$coefficients[2:15,4]
adjp.m3 <- mt.rawp2adjp(pvals.m3, tests)
adjp.m3



# significant after corrections:
# BTS, Punishment-agreement, Betting
# reward-agmt, promise opp.
# solidarity was weakly sig...

# summary of the 2nd version of the  model suggests:
# avg respondent in control got ~ 2.1 questions correct
# BTS caused an improvement of .6 over control
# Punishment-agmt caused .5
# betting caused .47
# reward agmt .39
# promise opp. .41
# solidarity .33 (weak sig)


# add attrition info for calculating ITT - note, still no demog. here

attrit <- c(3,5,7,9,9,5,7,5,8,7,7,4,9,6,8)
attrit <- as.data.frame(attrit)
rownames(attrit) <- names(table(dsub$condition))

# the total # of subjects assigned to each treatment
attrit$total <- rep(0, length(attrit[,1]))

for(i in 1:length(attrit[,1])){
  attrit$total[i] <- table(dsub$condition)[i] + attrit$attrit[i]
}

# And the full set of attrition information for testing whether or not it
# was random...

attrit.d <- read.csv("~/Dropbox/turk_raters/AMT-data/amt_attrition_data.csv")

chisq.test(as.matrix(attrit.d))
#
#####


# Now, back to calculating ate/itt estimators:
# This calculates mean outcome (using the itt estimator)
attrit$sum.score <- tapply(dsub$agg.nopriv, dsub$condition, sum, na.rm=TRUE)

for(i in 1:length(attrit$attrit)){
  attrit$mean.score[i] <- attrit$sum.score[i]/attrit$total[i]
}

attrit$itt.d <- rep(0, length(attrit$attrit))
attrit$itt.d <- apply(as.matrix(attrit$mean.score), 1, function(x)x-attrit$mean.score[1])


# var of ITT (sample variance in treatment/ total treated) + (sample variance in control/ total control)

# for each row in attrit I need:
# sample var(T)
# total treated
# sample var(C)
# total control

attrit$sample.var <- tapply(dsub$agg.nopriv, dsub$condition, var, na.rm=TRUE)

var.c <- attrit$sample.var[1]
n.c <- attrit$total[1]

for(i in 1:length(attrit$attrit)){
  attrit$itt.var[i] <- (attrit$sample.var[i]/attrit$total[i]) + (var.c/n.c)
  attrit$itt.stderr[i] <- sqrt(attrit$itt.var[i])
  attrit$itt.teststat[i] <- abs(attrit$itt.d[i])/attrit$itt.stderr[i]
}

attrit[1,c(7:9)] <- NA


# Note: a reasonable est. of the deg. of freedom for the corresponding t-tests:
# df <- (attrit$total[i]-1) + (attrit$total[1]-1)
# in general, this works out to be ~= 250 for each...



# creating full samples & ITT estimators...
# Note: I insert 0 values for NA's because in this case they serve the
# same function for calculating the mean treatment effects and T-tests
# using ITT

agg.control <- c(dsub$agg.nopriv[dsub$condition == "Control"], rep(0, attrit$attrit[1]))

ncond <- length(attrit$attrit)

pv <- rep(NA, ncond)

# and adjusted p-values for the ITT estimators...
for(i in 2:(ncond)){
  agg.total <- c(dsub$agg.nopriv[dsub$condition == rownames(attrit)[i]], rep(0, attrit$attrit[i]))
  t.result <- t.test(agg.total, agg.control)
  print(t.result) # comment this out for a quieter loop)
  pv[i] <- t.result$p.value
}

adjp.itt <- mt.rawp2adjp(pv, tests)

adjp.itt
names(table(dsub$condition))[2:15]


# rename some stuff to make life easier to read:

names(attrit) <- c("attriters", "total.assigned", "sum.score", "itt", "diff.means.itt", "sample.var", "itt.var", "itt.t.stat","itt.stderr")


# and construct a new data frame to hold full ITT results:

ITT.results <- attrit[,c(4,5,7:9)]

ITT.results$raw.p.val <- pv

bonf.index <- adjp.itt$index
bonf.vals <- adjp.itt$adjp[,2]


ITT.results$bonferroni <- bonf.vals[order(bonf.index)]
# Use this set - ITT.results - to produce our
# final visualization of the results...



#################
#
# Running a model to test for significant effects of demographic controls:

# covariates are:
# age, edu, hhsize, female, notenglish, hhemploy, employed.f, country,
# feeds, tabs


# creating a model:
model.controls <- lm(agg.nopriv ~ condition + age + edu + hhsize + female + notenglish + hhemploy + employed.f + country + feeds + tabs, data=dsub)
summary(model.controls)

# looks like the only potentially significant stuff (other than conditions)
# were: tabs & hhsize

model.control2 <- lm(agg.nopriv ~ condition + tabs + hhsize, data=dsub)
summary(model.control2)

# need to recode tabs to make it numeric.

tabnames <- levels(dsub$tabs)
tablevs <- c(5,4,2,1,3)
tabs.tmp <- as.character(dsub$tabs)

for(i in 1:length(tabnames)){
  tabs.tmp[tabs.tmp == tabnames[i]] <- tablevs[i]
}
tabs.tmp <- as.numeric(tabs.tmp)

dsub$tabs.num <- tabs.tmp

# now a new model:
model.control3 <-  lm(agg.nopriv ~ condition + tabs.num + hhsize, data=dsub)
summary(model.control3)

# Summary of these results:
# This model suggests that two of our demographic controls may have
# had modest, significant effects despite the randomization:
# household size and web skills. Larger household size and
# reduced web skills were both  associated with
# reduced performance and were significant after correcting for
# multiple comparisons.
#
# No other covariates produced a significant effect in a full OLS
# model.
# 
# At the same time, including these covariates in the model hardly altered
# the point estimates for the effects of our treatment conditions.
# This suggests that the estimated effects for the treatment conditions
# (at least the significant ones) were robust.


# one more model w. US & IN indicators:

dsub$countryUS <- grepl("US", dsub$country)

dsub$countryIN <- grepl("IN", dsub$country)


model.control4 <- lm(agg.nopriv ~ condition + tabs.num + hhsize + countryUS + countryIN, data=dsub)
summary(model.control4)

### THIS model
# reported in table 3 of the
# final paper.
model.control5 <- lm(agg.nopriv ~ condition + tabs.num + hhsize + countryIN, data=dsub)
summary(model.control5)

mc5 <- summary(model.control5)
pvals.mc5 <- mc5$coefficients[,4]
adjp.mc5 <- mt.rawp2adjp(pvals.mc5, tests)
adjp.mc5


##################

# Plot of correct answers to each question across treatments:
# x axis: treatment condition
# y axis: percent correct per outcome
# points: print numerical outcomes
# misc: grey horizontal bar at level = % correct by chance
# 

#create a data set to use w. ggplot2 - this entails all otucomes:
plotd <- dsub[,c(3,5:10)]

names(plotd) <- c("condition", "privacy policy", "avatars", "rank content", "rank users", "soc. network features", "revenue streams")


gplotd <- ddply(plotd, c("condition"), function(df)
                data.frame(
                           privacy=(sum(df[,2], na.rm=TRUE)/length(df[,2])),
                           avatars=(sum(df[,3], na.rm=TRUE)/length(df[,3])),
                           contentrank=(sum(df[,4], na.rm=TRUE)/length(df[,4])),
                           usersrank=(sum(df[,5], na.rm=TRUE)/length(df[,5])),
                           socnetwork=(sum(df[,6], na.rm=TRUE)/length(df[,6])),
                           revenue=(sum(df[,7], na.rm=TRUE)/length(df[,7]))
                 ))

tablelist <- NULL

# This list stores tables and chi.square tests for all individual outcomes...
for(i in (1:6)){
  tablelist[[i]] <- table(plotd[,1], plotd[,i+1])
  tablelist[[6+i]] <- chisq.test(tablelist[[i]])
}


# re-name the question labels for melting...
question.names <- c("privacy", "avatars", "rank\ncontent", "rank\nusers", "soc. network\nfeat.", "revenue")

names(gplotd)[2:7] <- question.names

# melt the data to facilitate faceting later on...
gplotm <- melt(gplotd, id=c("condition"))
names(gplotm) <- c("Condition", "Question", "Correct")


# plot away!

p <- ggplot(gplotm, aes(x=Condition, y=Correct, label=signif(Correct, 2))) # add label=Correct for text...

condition.names <- names(table(dsub$condition))

condition.names[c(2,3,4,5,6,7,8,10,14)] <- c("Tournament",
                                             "Cheap surveillance",
                                             "Cheap norm. incentive",
                                             "Reward accuracy",
                                             "Reward agmt",
                                             "Punish accuracy",
                                             "Punish agmt",
                                             "Promise opport.", "Norm prime")

# condition.names <- as.character(c(1:15))

pa <- p + geom_bar(stat="identity", aes(fill=Question)) +
  facet_grid(Question~.) + scale_fill_brewer(palette="Dark2") +
  scale_y_continuous(name="\nPercent Correct (per question)",
                     formatter="percent") + opts(legend.position =
  "none") + scale_x_discrete(name="Condition",
  labels=(condition.names), breaks=levels(gplotm$Condition))
                  
# title="Histograms of treatment outcomes per information seeking question\n",

pa


pa2 <- pa + opts(axis.title.x = theme_text(size=24), axis.title.y = theme_text(size=24, angle=270), axis.text.x=theme_text(hjust=0, size=14, angle=270, colour="grey40"))

pa2
# axis.text.y=theme_text(size=16, hjust=1.5)

pa3 <- pa2 + theme_bw() + opts(axis.title.x = theme_text(size=24), axis.title.y = theme_text(size=24, angle=270), axis.text.x=theme_text(hjust=0, size=16, angle=270), legend.position="none")

pa3

postscript("../../images/per_q.eps", title=NULL, width=11, height=8.5)
pa3
dev.off()



# another set to illustrate the ate on aggregated outcomes

# dsub$agg.nopriv is the outcome I want...see attrit


#check this indexing...
aggmeans <- attrit[ ,c(3,6)]
aggmeans$condition <- condition.names

aggmeans$meanoutcome <- as.numeric(aggmeans$mean.outcome)

g <- ggplot(aggmeans, aes(x=condition, y=mean.outcome, label=signif(mean.outcome,2)))

g1 <- g + geom_text(aes(colour=condition)) + scale_y_continuous(name="Total Correct", limits=c(3,3.8)) + scale_x_discrete(name="\n\nCondition") + opts(legend.position="none") + scale_colour_hue("clarity")

g1


h <- ggplot(aggmeans, aes(y=signif(meanoutcome, 3))) 

h1 <- g + geom_bar(stat="identity", aes(fill=condition), position="dodge") + scale_y_continuous(name="Avg. Total Correct\n") + scale_x_discrete(name="\n\nCondition") + opts(legend.position="none") + scale_colour_hue("clarity")

h1


# full results (not agg)
pa


# full results (agg - bar)
h1

# full results (text)
g1


