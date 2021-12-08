install.packages("quanteda")
install.packages("quanteda.textmodels")
install.packages("quanteda.textstats")
install.packages("quanteda.textplots")
install.packages("readtext")
install.packages("caret")

#read comment data and assign to variable
dat_YTcomment <- read.csv(paste0("CombinedComments.csv"))

#build corpus of Comment data
corpus_YTC <- corpus(dat_YTcomment, text_field = "Comment")

#build subset corpus of labeled comment data
corpus_LabComm <- corpus_subset(corpus_YTC, Label %in% c("s", "o"))

#build randomized (604 of 863) training set from subset of 70% of labeled data
set.seed(2)
id_train <- sample(1:863, 604, replace = FALSE)

# create docvar with ID
corpus_LabComm$id_numeric <- 1:ndoc(corpus_LabComm)

#tokenize texts, remove punctuation, remove numbers, lower case, remove stopwords, 
#conduct stemming
toks_LabComm <- tokens(corpus_LabComm, remove_punct = TRUE, remove_number = TRUE) %>% 
  tokens_remove(c(stopwords("english"), "got", "get", "like", "vacc*")) %>%
  tokens_tolower() %>%
  tokens_wordstem()

#build document-feature matrix of Comment corpus
dfm_YTC <- dfm(toks_LabComm)

# get training set
dfm_train <- dfm_subset(dfm_YTC, id_numeric %in% id_train)
# get test set (documents not in id_train)
dfm_test <- dfm_subset(dfm_YTC, !id_numeric %in% id_train)

#train Naive Bayes classifier with the train dfm
tmod_nb <- textmodel_nb(dfm_train, dfm_train$Label)

#ensure that the test and train matrices match for comparison
dfm_matched <- dfm_match(dfm_test, features = featnames(dfm_train))

#evaluate the classification model
actual_class <- dfm_matched$Label
predicted_class <- predict(tmod_nb, newdata = dfm_matched)
tab_class <- table(actual_class, predicted_class)
tab_class

#All must be labeled to do a confusion matrix
confusionMatrix(tab_class, mode = "everything")

##END NB CLASSIFIER CODE##
##PREDICTIONS ON NEW DATA WITH TRAINED MODEL##

#build subset corpus of unlabeled comment data
corpus_unlabeled <- corpus_subset(corpus_YTC, Label %in% c("unlabeled"))

corpus_unl_B <- corpus_subset(corpus_unlabeled, BeforeAfter %in% c("Before"))
corpus_unl_A <- corpus_subset(corpus_unlabeled, BeforeAfter %in% c("After"))

# create docvar with ID for both subcorpora
corpus_unl_B$id_numeric <- 1:ndoc(corpus_unl_B)
corpus_unl_A$id_numeric <- 1:ndoc(corpus_unl_A)

#tokenize texts, remove punctuation, remove numbers, lower case, remove stopwords, conduct stemming
toks_unl_B <- tokens(corpus_unl_B, remove_punct = TRUE, remove_number = TRUE) %>% 
  tokens_remove(c(stopwords("english"), "got", "get", "like", "vacc*")) %>%
  tokens_tolower() %>%
  tokens_wordstem()
toks_unl_A <- tokens(corpus_unl_A, remove_punct = TRUE, remove_number = TRUE) %>% 
  tokens_remove(c(stopwords("english"), "got", "get", "like", "vacc*")) %>%
  tokens_tolower() %>%
  tokens_wordstem()

#build document-feature matrix of both labeled comment corpora
dfm_unl_B <- dfm(toks_unl_B)
dfm_unl_A <- dfm(toks_unl_A)

#build a tfidf of comment dfm
dfm_unl_B <- dfm_tfidf(dfm_unl_B, scheme_tf = "prop") %>% round(digits = 2)
dfm_unl_A <- dfm_tfidf(dfm_unl_A, scheme_tf = "prop") %>% round(digits = 2)

write.csv(predict(tmod_nb, dfm_unl_B, type = c("class"), force = T), file="C:/Users/harri/OneDrive/Documents/THPredictBefore.csv", row.names = T)
write.csv(predict(tmod_nb, dfm_unl_A, type = c("class"), force = T), file="C:/Users/harri/OneDrive/Documents/THPredictAfter.csv", row.names = T)
##END PREDICTIONS##

###Subset for Before/After Comparison Cloud###
corpus_subset(corpus_YTC, Channel %in% c("BW", "JA", "MM")) %>%
  tokens(remove_punct = TRUE, remove_symbols = TRUE , remove_number = TRUE) %>%
  tokens_remove(stopwords("english")) %>%
  tokens_remove(c("00*", "fe*", "0f*", "u", "r", "$", "<", ">", "+")) %>%
  dfm() %>%
  dfm_group(groups = Channel) %>%
  dfm_trim(min_termfreq = 300, verbose = FALSE) %>%
  textplot_wordcloud(color = c("red", "blue", "brown"), comparison = TRUE)

#############Subset for Frequency Graph of Full Data Set #######

#tokenize texts, remove punctuation, remove numbers, lower case, remove stopwords, conduct stemming
toks_YTC_freq <- tokens(corpus_YTC, remove_punct = TRUE, remove_number = TRUE) %>% 
  tokens_remove(c(stopwords("english"), "$", "got", "get", "like", "vacc*")) %>%
  tokens_tolower() %>%
  tokens_wordstem()

#build document-feature matrix of Comment corpus
dfm_YTC <- dfm(toks_YTC_freq)

features_dfm_YTC <- textstat_frequency(dfm_YTC, n = 50)

# Sort by reverse frequency order
features_dfm_YTC$feature <- with(features_dfm_YTC, reorder(feature, -frequency))

ggplot(features_dfm_YTC, aes(x = feature, y = frequency)) +
  geom_point() + 
  theme(axis.text.x = element_text(angle = 90, hjust = 1))

#############Subset for Frequency Graph for Before and After#######

dfm_weight_BA <- corpus_YTC %>%
  corpus_subset(BeforeAfter %in% c("Before", "After")) %>%
  tokens(remove_punct = TRUE) %>%
  tokens_remove(c(stopwords("english"), "$", "got", "get", "like", "vacc*")) %>%
  dfm() %>%
  dfm_weight(scheme = "prop")

# Calculate relative frequency by president
freq_weight_BA <- textstat_frequency(dfm_weight_BA, n = 10, 
                                  groups = dfm_weight_BA$BeforeAfter)

ggplot(data = freq_weight_BA, aes(x = nrow(freq_weight_BA):1, y = frequency)) +
  geom_point() +
  facet_wrap(~ group, scales = "free") +
  coord_flip() +
  scale_x_continuous(breaks = nrow(freq_weight_BA):1,
                     labels = freq_weight_BA$feature) +
  labs(x = NULL, y = "Relative frequency")

#############Subset for Frequency Graph for Before/After-suppos/oppos#######

dfm_weight_SO <- corpus_YTC %>%
  corpus_subset(Label %in% c("s", "o")) %>%
  tokens(remove_punct = TRUE) %>%
  tokens_remove(c(stopwords("english"), "$", "got", "get", "like", "vacc*")) %>%
  dfm() %>%
  dfm_weight(scheme = "prop")


freq_weight_SO <- textstat_frequency(dfm_weight_SO, n = 10, 
                                     groups = dfm_weight_SO$Label)

ggplot(data = freq_weight_SO, aes(x = nrow(freq_weight_SO):1, y = frequency)) +
  geom_point() +
  facet_wrap(~ group, scales = "free") +
  coord_flip() +
  scale_x_continuous(breaks = nrow(freq_weight_SO):1,
                     labels = freq_weight_SO$feature) +
  labs(x = NULL, y = "Relative frequency")

#############Subset for Comparative Keyness Frequency#######
corp_YTC_BA <- corpus_subset(corpus_YTC, BeforeAfter %in% c("Before", "After"))

# Create a dfm grouped by 
dfm_YTC_BA <- tokens(corp_YTC_BA, remove_punct = TRUE) %>%
  tokens_remove(c(stopwords("english"), "$", "got", "get", "like", "vacc*")) %>%
  tokens_group(groups = BeforeAfter) %>%
  dfm()

# Calculate keyness and determine Trump as target group
result_keyness <- textstat_keyness(dfm_YTC_BA, target = "Before")

# Plot estimated word keyness
textplot_keyness(result_keyness) 

#############Subset for Single Keyness Frequency#######
corp_YTC_SO <- corpus_subset(corpus_YTC, Label %in% c("s", "o"))
corp_YTC_BA <- corpus_subset(corpus_YTC, BeforeAfter %in% c("Before", "After"))

# Create a dfm grouped by president
dfm_YTC_SO <- tokens(corp_YTC_SO, remove_punct = TRUE) %>%
  tokens_remove(c(stopwords("english"), "$", "got", "get", "like", "vacc*")) %>%
  tokens_group(groups = Label) %>%
  dfm()

dfm_YTC_BA <- tokens(corp_YTC_BA, remove_punct = TRUE) %>%
  tokens_remove(c(stopwords("english"), "$", "got", "get", "like", "vacc*")) %>%
  tokens_group(groups = BeforeAfter) %>%
  dfm()

# Calculate keyness and determine Trump as target group
result_keyness <- textstat_keyness(dfm_YTC_SO, target = "s")
result_keyness <- textstat_keyness(dfm_YTC_BA, target = "Before")

# Plot estimated word keyness
textplot_keyness(result_keyness, show_reference = FALSE)
