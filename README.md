# VaxAttitudeClass
Title: Vaccine Attitude Classifier

Brief Description: Classify attitude about COVID-19 vaccination from YouTube comment data

Overview: This model fits YouTube comment text data about COVID-19 vaccinations to a classification algorithm to determine user attitudes about vaccines before and after a specific event – President Biden’s YouTube Town Hall on COVID that occurred on May 24, 2021 on YouTube. Data are collected before and after the Town Hall broadcast to determine whether an association exists between the temporal relationship of the comments to the Town Hall and the level of support or opposition to vaccinations.

How to Install: All code in the model is built and implemented in R. Implementation of this code requires installation of the following packages into R:
•	Quanteda – an R package used for quantitative analysis of text data,
•	Quanteda.textmodels - a package adding text scaling models to quanteda,
•	Quanteda.textstats – a package that includes functions for characterizing and comparing text data
•	Quanteda.textplots – a package for developing plots and graphs out of text data,
•	Readtext – a package for importing various file formats,
•	Caret – a package that contains functions for classification and regression
The file name for the classification code is Harris_CINF624_VaxClass.R

How to Use: 
This code contains four main subtasks:
1.	Importing data
2.	Preprocessing data
3.	Feature selection
4.	Model training

Importing Data -
YouTube comment data are read in from a CSV file titled - CombinedComments.csv. This file contains over 104,000 comments. This file contains six columns of data – Comments, Likes, Published, Channel, BeforeAfter, and Label. Comments contain the text YouTube comments, Likes contains the number of likes corresponding with each comments, Published contains the date that comments were posted on, Channel contains the abbreviation for the YouTube Channel name, BeforeAfter contains a label indicating whether comments were posted before or after 5/24/2021, and Label contains a label for a subset of the data denoted “s” for supportive, “o” for opposing, or “n” for neutral on vaccinations.
 
Preprocessing Data -
Comment data is extracted from the Comment column of the CSV file and built into a corpus, and subcorpora of the labeled comment data are built. Comment data are tokenized a preprocessed to filter out stopwords, punctuation, and numbers. Tokens are lowercased and stemmed as well.

Feature Selection -
Tokens are built into a document feature matrix. In the DFM, comments (documents) are fixed as rows and tokens (features) are fixed as columns to associate specific values with certain features and to develop an objective method for analyzing and comparing the text data.

Model Training -
After comparing results from various algorithms, Naïve Bayes produced the most accurate results and the highest F1 score among several tested. 

File Manifest
•	CombinedComments.csv – comment data frame
•	Harris_CINF624_VaxClass.R – R code for classification

Known Issues
No known bugs

Credits
Quanteda provides tutorials on the use of their packages and functions at https://tutorials.quanteda.io/ 

author - Donald Harris
