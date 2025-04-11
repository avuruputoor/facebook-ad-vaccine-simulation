library(ggplot2)

#Sets the seed in order for results to be reproducible
set.seed(1)

#1) Baseline Survey Dataset

#Creates 5000 unique identifiers
id <- c(1:5000)

#Creates a normal distribution of 5000 age values with a mean of 40 years and 
#a standard deviation of 20 years
age <- rnorm(5000, 40, 20)

#Creates a categorical distribution of gender
gender <- sample(c("Male", "Female", "Non-binary"), 5000, TRUE, 
                 c(0.48, 0.48, 0.4))
#Creates a categorical distribution of different levels of education status
education <- sample(c("High School", "Associate Degree", "Bachelor's Degree", 
                      "Graduate Degree"), 5000, TRUE, c(0.2, 0.3, 0.3, 0.2))

#Creates a categorical distribution different attitudes of vaccination
baseline_vaccine_attitude <- sample(c("Terrible", "Bad", "Okay", "Good", 
                                      "Excellent"), 5000, TRUE, c(0.15, 0.2, 0.3
                                                                  , 0.2, 0.15))

#Creates a binary categorical distribution of vaccination status
baseline_vaccination_status <- sample(c("Yes", "No"), 5000, TRUE, c(0.5, 0.5))

#Creates a baseline dataset with 5000 observations and columns for unique 
#identifiers, and the basic demographic information from the vectors we created
#above
baseline <- data.frame(id, age, gender, education, baseline_vaccine_attitude, 
                       baseline_vaccination_status)

#Sets minimum age to 18 and maximum age to 80, changing all values in the age 
#column that apply
baseline$age <- ifelse(baseline$age <= 18, 18, baseline$age)
baseline$age <- ifelse(baseline$age >= 80, 80, baseline$age)

#Rounds all ages to whole numbers to maintain consistency and proper format
baseline$age <- round(baseline$age, 0)

#2) Random Assignment

#Assigns 1/3 of participants to each treatment group through random assignment
treatment <- sample(c("reason", "emotions", "control group"), 5000, TRUE, 
                    c((1/3), (1/3), (1/3)))

#Creates a dataset that contains the information on random assignment (id's and
#their corresponding treatment groups)
random_assignment <- data.frame(id, treatment)


#3) Endline Survey Dataset
set.seed(1)
#Identifies 4500 id's to keep for the endline survey dataset that survived "attrition"
endline_treated <- sample(c(id),4500, FALSE)

#Creates a subset of the baseline survey dataset that keeps only the id's that 
#were previously identified to survive "attrition"
endline <- subset(baseline, id %in% endline_treated)

#Changes vaccine_attitude column name to reflect endline behavioral & 
#vaccination status change
colnames(endline)[5] <- "endline_vaccine_attitude"
colnames(endline)[6] <- "endline_vaccination_status"

#Merges the endline dataset with the random assignment dataset to make it easier 
#to simulate treatment effects
endline <- merge(endline, random_assignment, by = 1)

#Calculates probability for treatment effect depending on treatment group and 
#stores in a variable p
p <- ifelse(endline$treatment == "control group", 0.3, 
       ifelse(endline$treatment == "reason", 0.65, 0.45))

#Generates total number of individuals who are in the endline dataset and are 
#not vaccinated
not_vaccinated_sum <- sum(endline$endline_vaccination_status == "No")

#Creates a vector of the indices where "No" values are TRUE and "Yes" are FALSE
not_vaccinated_indices <- endline$endline_vaccination_status == "No"

#Creates a vector that assigns new vaccination_status for the endline survey 
#setting previous baseline "No" values to 0 if they stayed the same and 1 if 
#they changed to "Yes"
vaccination_pt_update <- rbinom(not_vaccinated_sum, 1, p[not_vaccinated_indices])

#Replaces the 0s with "No" and 1s with "Yes"
endline$endline_vaccination_status[not_vaccinated_indices] <- ifelse( 
                                        vaccination_pt_update == 1, "Yes", "No")

#Generates total number of individuals who are in each of the treatment groups
control_sum <- sum(endline$treatment == "control group")
reason_sum <- sum(endline$treatment == "reason")
emotions_sum <- sum(endline$treatment == "emotions")

#Creates a new treatment distribution for the control group (this is the same 
#because we assume that the distribution doesn't change if they weren't treated)
control_va_treatment <- sample(c("Terrible", "Bad", "Okay", "Good", "Excellent"), 
                               control_sum, TRUE, c(0.15, 0.2, 0.3, 0.2, 0.15))

#Creates a new treatment distribution for the reason group (this shifts some of 
#probability from the "Okay" responses towards "Good" and "Excellent")
reason_va_treatment <- sample(c("Terrible", "Bad", "Okay", "Good", "Excellent"), 
                              reason_sum, TRUE, c(0.15, 0.2, 0.2, 0.25, 0.2))

#Creates a new treatment distribution for the emotions group (this shifts some of 
#probability form the "Okay" responses towards the "Terrible", "Good" and 
#"Excellent" responses)
emotions_va_treatment <- sample(c("Terrible", "Bad", "Okay", "Good", "Excellent"), 
                            emotions_sum, TRUE, c(0.2, 0.2, 0.1, 0.25, 0.25))

#Assigns the new treatment vaccine_attitude values to each of the respective 
#treatment groups
endline$endline_vaccine_attitude[endline$treatment == 
                                   "control group"] <- control_va_treatment
endline$endline_vaccine_attitude[endline$treatment == 
                                   "reason"] <- reason_va_treatment
endline$endline_vaccine_attitude[endline$treatment == 
                                   "emotions"] <- emotions_va_treatment


#4) Analysis and Reporting

#Merges the baseline and endline datasets by the first four columns (id, age, 
#gender, education)
merged_dataset <- merge(baseline, endline, c(1, 2, 3, 4))

#Sanity check to make sure individuals with a vaccination status of "Yes" at 
#baseline do not have a change in status to "No" in endline
print("No" %in% merged_dataset$endline_vaccination_status
      [merged_dataset$baseline_vaccination_status == "Yes"])

#Plots appear in a new external window
windows()

#Plot 1

#Stores the indices of the baseline and endline vaccinated individuals
baseline_yes_indices <- merged_dataset$baseline_vaccination_status == "Yes"
endline_yes_indices <- merged_dataset$endline_vaccination_status == "Yes"

#Stores the indices of each of the treatment groups
control_indices <- merged_dataset$treatment == "control group"
emotions_indices <- merged_dataset$treatment == "emotions"
reason_indices <- merged_dataset$treatment == "reason"

#Creates tables for baseline and endline surveys which stores treatment group, 
#and total count of "Yes" responses
baseline_yes_dat <- as.data.frame(table(merged_dataset$treatment[
  baseline_yes_indices]))
endline_yes_dat <- as.data.frame(table(merged_dataset$treatment[
  endline_yes_indices]))

#Renames columns with their respective names
names(baseline_yes_dat) <- c("treatment_group", "count")
names(endline_yes_dat) <- c("treatment_group", "count")

#Adds baseline and endline survey columns to identify the survey post merge
baseline_yes_dat$survey <- "baseline"
endline_yes_dat$survey <- "endline"

#Uses rbind to merge both baseline & endline dataframes into a single dataframe 
#with "Yes" counts per treatment group and with their respective survery
yes_counts_dat <- rbind(baseline_yes_dat, endline_yes_dat)

#Generates a side by side bar plot which compares the number of vaccinated 
#individuals ("Yes" responses) for each treatment group and by survey
ggplot(yes_counts_dat, aes(x = treatment_group, y = count, fill = survey)) +
  geom_bar(stat = "identity", position = "dodge") +
  labs(title = "Vaccinated Indiviuals by Treatment Group and Survey",
       x = "Treatment Group",
       y = "Number of 'Yes' Responses",
       fill = "Survey") +
  theme_minimal()

#The plots shows a" general increase in the number of "Yes" responses from baseline
#to endline. Additionally, the treatment group with the greatest increase was the 
#"reason" treatment group and it finished with the most "Yes" responses in the endline 
#survey. While the people randomly sampled into emotions group had the most "Yes" 
#responses for vaccination status going in the baseline we can see that the 
#"reason" group was the most effective, though both treatments were successful 
#at getting people vaccinated. It is interesting to note that the control group 
#also had an increase in vaccinations. This could be due to the increasing 
#necessity to get a vaccination during COVID, including vaccine mandates, etc...

#Plot 2

#Creates tables for baseline and endline surveys which stores the vaccine attitude
#treatment group, and total counts
baseline_attitude_dat <- as.data.frame(
  table(merged_dataset$baseline_vaccine_attitude, merged_dataset$treatment))
endline_attitude_dat <- as.data.frame(
  table(merged_dataset$endline_vaccine_attitude, merged_dataset$treatment))


#Renames columns with their respective names
names(baseline_attitude_dat) <- c("vaccine_attitude", "treatment", "count")
names(endline_attitude_dat) <- c("vaccine_attitude", "treatment", "count")

#Adds baseline and endline survey columns to identify the survey post merge
baseline_attitude_dat$survey <- "baseline"
endline_attitude_dat$survey <- "endline"

#Uses rbind to merge both baseline & endline dataframes into a single dataframe 
#with vaccine attitude counts counts per treatment group and with their respective survey
attitude_dat <- rbind(baseline_attitude_dat, endline_attitude_dat)

#Generates a stacked side-by-side barplot that shows how vaccine attitudes changed 
#across survey group and the composition of each attitude by treatment group
ggplot(attitude_dat, aes(x = vaccine_attitude, y = count, fill = treatment)) +
  geom_bar(stat = "identity", position = "stack") +
  facet_wrap(~ survey) +
  scale_fill_manual(values = c("navy", "gold", "red")) +
  labs(
    title = "Vaccine Attitudes by Treatment Group (Baseline vs. Endline)",
    x = "Vaccine Attitude",
    y = "Number of Participants",
    fill = "Treatment Group"
  ) +
  theme_minimal()

#We can see immediately that "Okay" was the vaccine attitude with the highest
#of participants in the baseline and that all of the responses were composed
#of each treatment group roughly equally. In the endline, while there was a slight
#increase in participants with a "Terrible" and "Bad" vaccine attitude but most 
#of the attitudes had shifted from "Okay" towards "good" and "Excellent" as there
#was a notable increase in participants with these vaccine attitudes from baseline
#to endline. Overall we can conclude that the program was effective at shifting
#people's attitudes of vaccines in a positive direction.

#Exports datasets as .csv files
#write.csv(baseline, "C:\\Users\\avuru\\OneDrive\\Desktop\\RA Data Tasks\\Professor Song Data Task AV\\baseline.csv", row.names = FALSE)
#write.csv(random_assignment, "C:\\Users\\avuru\\OneDrive\\Desktop\\RA Data Tasks\\Professor Song Data Task AV\\random_assignment.csv", row.names = FALSE)
#write.csv(endline, "C:\\Users\\avuru\\OneDrive\\Desktop\\RA Data Tasks\\Professor Song Data Task AV\\endline.csv", row.names = FALSE)

#Exports plots as png
#ggsave("C:\\Users\\avuru\\OneDrive\\Desktop\\RA Data Tasks\\Professor Song Data Task AV\\vaccine_attitudes_plot.png", plot = last_plot(), width = 8, height = 5)
#ggsave("C:\\Users\\avuru\\OneDrive\\Desktop\\RA Data Tasks\\Professor Song Data Task AV\\vaccined_counts_plot.png", plot = last_plot(), width = 8, height = 5)