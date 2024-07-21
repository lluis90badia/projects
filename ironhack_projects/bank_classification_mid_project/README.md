# JAL Data Solutions - Bank Classification Study Case :credit_card: :moneybag: :currency_exchange:

Authors: [Josep Trota](https://www.linkedin.com/in/josep-trota-ochoa-de-eribe-ba01b055/), [Agustín Carcelén](https://www.linkedin.com/in/agustin-carcelen-chicote-b70048231/), [Lluis Badia](https://github.com/lluis90badia/projects) 


## Contents

- [Briefing](https://github.com/JosepTrota/JAL-repo/blob/main/README.md#briefing-mag_right)
- [Data Exploration](https://github.com/JosepTrota/JAL-repo/blob/main/README.md#data-exploration-microscope)
- [Feature engineering](https://github.com/JosepTrota/JAL-repo/blob/main/README.md#feature-engineering-recycle)
- [Models and their insights](https://github.com/JosepTrota/JAL-repo/blob/main/README.md#models-and-their-insights-chart)
- [Visualizations](https://github.com/JosepTrota/JAL-repo/blob/main/README.md#visualizations)
- [Final insights](https://github.com/JosepTrota/JAL-repo/blob/main/README.md#final-insights)

## Briefing :mag_right:

The bank needs us as risk analysts to read into a specifically designed 18000 clients database to:
* PRIMARY OBJECTIVE: Understand demographics and other characteristics of both customers that accept the offer and not.
* SECONDARY: More insights are also highly valued.

What to do :question:
* Understand the data and variables
* Research, explore and compare important issues related to them
* Feature engineer our way into a good enough model
* Make helpful conclusions that can lead to decisions


## Data Exploration :microscope:

Exploring the DataFrame, we had to deal with some null values that had been removed because of the small proportion compared to the total (practically no difference whether we include them or not). Besides, we encountered two outliers in the column 'household size' that had also been removed for the same reason. Further conclusions or details in the [notebook](https://github.com/JosepTrota/JAL-repo/blob/main/Code/Case%20Studio%20Bank%20Final.ipynb) ("Deal with Outliers", section 3.2.5, in [23]).

Based on what we have seen in the columns from a general perspective, on the one side, some patterns follow a uniform tendency when we talk about the majority ('income level', 'nº bank accounts open', among others). On the other side, other variables such as 'reward' or 'average_balance' follow a different pattern depending on whether the client accepts or not the offer. More information is in the column analysis report (in this SQL report [file](https://github.com/JosepTrota/JAL-repo/blob/main/MySql/Profiles%20and%20patterns.pdf)).

However, there is no correlation between the variables except for the balance quarters and average balance.

<p align="center"> We could also begin showing some graphic insights on the target we have in our hands</p>
<p align="center"><img src="https://user-images.githubusercontent.com/96822258/154541671-856745dd-941b-4c9d-9702-1797873e5155.png"  height="400">


## Feature engineering :recycle:
  
In the histogram for average balance three distinct “normal bells” can be seen, so we decided to split them onto groups as seen in the area chart. That had a part into the profiling, which combined values of the new groups, credit rating and income level in order to identify people who had high to low values on each of them.
*	There is a large chunk of the data (almost 1/5) that has a different value in each one of the profiling variables (one high, one medium, one low). Thus the creation of the non profilable class.

<p align="center"><img src="https://github.com/JosepTrota/JAL-repo/blob/main/Images/Profiling.png?raw=true"  height="400">
<p align="center"> We can already see some interesting trends. The higher the profile, the least likely they are to take the offer or get overdraft protection</p>

*	In further models we dropped every variable except profile, average balance, household size, offer accepted, mailer type, credit cards held, bank account open, due to insights gained by applying the random forest model as seen in the [code](https://github.com/JosepTrota/JAL-repo/blob/main/Code/Case%20Studio%20Bank%20Final.ipynb) ("Looking for the best feature importance scores", section 4.4.2, in [62]).


## Models and their insights :chart:

We have used 3 different models to evaluate our case study: Regression Logistic, Knn, Random Forest<BR>
  
- **Original Data:** In the first place we have analyzed the original database, applying the three aforementioned models to it. We have used different scalers and samples to try to improve our predictions, we have also used improvement techniques such as looking for the best value of K for the Knn model or looking for the best features for the Random Forest model. You can see it in the [code](https://github.com/JosepTrota/JAL-repo/blob/main/Code/Case%20Studio%20Bank%20Final.ipynb) ("Looking for the best k", section 4, in [54]).<BR>
  
  * Our best result has been applying the Logistic Regression model, and afterwards applying SMOTE oversampler.
  
- **Profiled Data:** After doing feature engineering, we have created a new database that we have used to do a second analysis. Here we have applied all available scaling methods, sampling methods and enhancement techniques to our model to find the best prediction. You can see it in the [code](https://github.com/JosepTrota/JAL-repo/blob/main/Code/Case%20Studio%20Bank%20Final.ipynb) ("Looking for the best feature importance scores", section 5, in [62]).
  
  * In this case, our best result has been applying the random forest model with SMOTE oversampling.
  
  ---
## Visualizations
  If you wish to further investigate all our visualization efforts you can look up our [Tableau](https://public.tableau.com/app/profile/josep.trota.ochoa.de.eribe/viz/JAL_16448750609760/Whatkindofclientsacceptedtheoffer?publish=yes) and the [Presentation](http://slides.com/agustincarcelenchicote/deck) ;)
  
  ---
  
## Final insights 

### Conclusions :memo:
  
* The target variable is highly imbalanced; therefore, it affected our results.

* After applying the three predictive models, we concluded to make feature engineering to create a new (and shorter) Data Frame based on the profiles extracted from some important variables and the ones which are more related to the target variable.

* The best model prediction is the random forest combined with the SMOTE oversampler implemented on our profile Data Frame because it returns more 'yes' values than the rest of the models in both datasets.

### Recommendations :heavy_check_mark:
  
* The bank could be more interested in rewarding the clients who do not accept the offer with an alternative reward instead of a credit card to achieve more benefits.
* Further discussion on our proposed profiles is encouraged.
    * Which kind of client does the bank want to encourage the most?
    * Are there any other variables that seem important?
    * Do we already have this data? If not, is there an easy way to get it? 
  
### Proposals :briefcase:

* Include a Date-Time variable.
* Replace the mailing system with email.

