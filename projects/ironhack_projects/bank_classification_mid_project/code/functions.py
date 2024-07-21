
import pandas as pd 
import numpy as np

#%matplotlib inline


######################################################################################################################
##################################       different methods to scale our numerical values        ######################
######################################################################################################################

##Normally X = X_num
#receives a database with the numerical values
#returns the same database with the values scaled according to the selected method

def maxmin_scaler (X):
    from sklearn.preprocessing import MinMaxScaler
    df = MinMaxScaler().fit(X).transform(X)
    df = pd.DataFrame(df, index=X.index, columns=X.columns)
    return df


def abs_scaler (X):
    from sklearn.preprocessing import MaxAbsScaler
    df = MaxAbsScaler().fit(X).transform(X)
    df = pd.DataFrame(df, index=X.index, columns=X.columns)
    return df


def st_scaler (X):
    from sklearn.preprocessing import StandardScaler
    df = StandardScaler().fit(X).transform(X)
    df = pd.DataFrame(df, index=X.index, columns=X.columns)
    return df


def rob_scaler (X):
    from sklearn.preprocessing import RobustScaler
    df = RobustScaler().fit(X).transform(X)
    df = pd.DataFrame(df, index=X.index, columns=X.columns)
    return df


def nor_scaler (X):
    from sklearn.preprocessing import Normalizer
    df = Normalizer().fit(X).transform(X)
    df = pd.DataFrame(df, index=X.index, columns=X.columns)
    return df


def trans_sclaer (X):
    from sklearn.preprocessing import QuantileTransformer
    df = QuantileTransformer().fit(X).transform(X)
    df = pd.DataFrame(df, index=X.index, columns=X.columns)
    return df


def pow_scaler (X):
    from sklearn.preprocessing import PowerTransformer
    df = PowerTransformer().fit(X).transform(X)
    df = pd.DataFrame(df, index=X.index, columns=X.columns)
    return df

#Return a database list with all the values scaled
def all_scalers (X):

    return [maxmin_scaler (X),abs_scaler (X),st_scaler (X),rob_scaler (X),nor_scaler (X),trans_sclaer (X),pow_scaler (X)]
    
    
######################################################################################################################
######################################################################################################################
######################################################################################################################



######################################################################################################################
################################       different methods to sample our numerical values        #######################
######################################################################################################################

##Normally X = X_full (data before train)
##Normally y = Goal
#receives a database
#returns the same database with the values sampled according to the selected method

def smote_sample (X,y):
    from imblearn.over_sampling import SMOTE 
    sampler = SMOTE()
    X_smote,y_smote = sampler.fit_resample(X,y)
    return X_smote,y_smote

def tomek_sample (X,y):
    from imblearn.under_sampling import TomekLinks 
    sampler= TomekLinks()
    X_tomek,y_tomek = sampler.fit_resample(X,y)
    return X_tomek,y_tomek

def randomunder_sample (X,y):
    from imblearn.under_sampling import RandomUnderSampler 
    sampler= RandomUnderSampler()
    X_rus,y_rus=sampler.fit_resample(X,y)
    return X_rus,y_rus

def randomover_sample (X,y):
    from imblearn.over_sampling import RandomOverSampler 
    sampler=RandomOverSampler()
    X_ros,y_ros=sampler.fit_resample(X,y)
    return X_ros,y_ros



######################################################################################################################
######################################################################################################################
######################################################################################################################



######################################################################################################################
#################################     different methods to train your model          #################################
######################################################################################################################

##Normally X = X_full (data before train)
##Normally y = Goal
#control = (1, 0) if 1: change y column from Yes,No to 1,0
#receives a database
#returns accuracy of model, confusion matrix plot, roc_curve plot


def logistic_regresion_train (X,y,control):
    from sklearn.model_selection import train_test_split 
    from sklearn.linear_model import LogisticRegression
    from sklearn.metrics import accuracy_score 
    #split our data
    X_train,X_test,y_train,y_test=train_test_split(X,y,test_size=0.30,random_state=40)
    #apply and train logistic regresion
    model=LogisticRegression(max_iter=500)
    model.fit(X_train,y_train)
    #calculate accuracy
    y_test_pred=model.predict(X_test)
    accuracy = accuracy_score(y_test, y_test_pred)
    print("Accuracy of LogisticRegresion:",accuracy)
    
    from sklearn.metrics import confusion_matrix, ConfusionMatrixDisplay
    import matplotlib.pyplot as plt 
    import seaborn as sns
    from sklearn.metrics import roc_auc_score, roc_curve
    #calculate confusion matrix and plot
    fig, (ax) = plt.subplots(3,1, figsize=(15, 20))
    cmx=confusion_matrix(y_test,y_test_pred)
    disp=ConfusionMatrixDisplay(confusion_matrix=cmx)
    disp.plot(ax=ax[0]);
    #confusion matrix heatmap
    sns.heatmap(cmx/np.sum(cmx), annot=True, fmt='.2%',cmap='Blues', ax=ax[1]);    
    #transform y_test from Yes/No to 1/0 it is necessary
    if control == True:
        def yes_no_to_0_1(x):
            if 'Yes' in x:
                return 1
            else: 
                return 0
        y_test = y_test.apply(yes_no_to_0_1)
    else:
        y_test = y_test
    
    y_pred_probs=model.predict_proba(X_test)[::,1]
    #roc_curve plot
    fpr,tpr, _ = roc_curve(y_test,y_pred_probs)
    auc=roc_auc_score(y_test,y_pred_probs)
    ax[2].plot(fpr,tpr,label='roc model,auc='+str(auc))
    ax[2].legend(loc=4)
    plt.show()
    return accuracy,auc

#---------------------------------------------------------------------------------------------------
##Normally X = X_full (data before train)
##Normally y = Goal
#control = (1, 0) if 1: change y column from Yes,No to 1,0
#neighboors = number of neighbors
#receives a database
#shows accuracy of model, confusion matrix plot, roc_curve plot
#returns accuracy,roc_score

def knn_train (X,y,control,neighbors):
    from sklearn.model_selection import train_test_split 
    from sklearn.neighbors import KNeighborsClassifier
    from sklearn.metrics import accuracy_score 
    #split our data
    X_train,X_test,y_train,y_test=train_test_split(X,y,test_size=0.30,random_state=40)
    #apply and train logistic regresion
    model=KNeighborsClassifier(n_neighbors = neighbors)
    model.fit(X_train,y_train)
    #calculate accuracy
    y_test_pred=model.predict(X_test)
    accuracy = accuracy_score(y_test, y_test_pred)
    print("Accuracy of LogisticRegresion:",accuracy)
    
    from sklearn.metrics import confusion_matrix, ConfusionMatrixDisplay
    import matplotlib.pyplot as plt 
    import seaborn as sns
    from sklearn.metrics import roc_auc_score, roc_curve
    #calculate confusion matrix and plot
    fig, (ax) = plt.subplots(3,1, figsize=(15, 20))
    cmx=confusion_matrix(y_test,y_test_pred)
    disp=ConfusionMatrixDisplay(confusion_matrix=cmx)
    disp.plot(ax=ax[0]);
    #confusion matrix heatmap
    sns.heatmap(cmx/np.sum(cmx), annot=True, fmt='.2%',cmap='Blues', ax=ax[1]);    
    #transform y_test from Yes/No to 1/0 it is necessary
    if control == True:
        def yes_no_to_0_1(x):
            if 'Yes' in x:
                return 1
            else: 
                return 0
        y_test = y_test.apply(yes_no_to_0_1)
    else:
        y_test = y_test
    
    y_pred_probs=model.predict_proba(X_test)[::,1]
    #roc_curve plot
    fpr,tpr, _ = roc_curve(y_test,y_pred_probs)
    auc=roc_auc_score(y_test,y_pred_probs)
    ax[2].plot(fpr,tpr,label='roc model,auc='+str(auc))
    ax[2].legend(loc=4)
    plt.show()
    return accuracy, auc

#---------------------------------------------------------------------------------------------------
##Normally X = X_full (data before train)
##Normally y = Goal
#control = (1, 0) if 1: change y column from Yes,No to 1,0
#receives a database
#shows accuracy of model, confusion matrix plot, roc_curve plot
#returns accuracy,roc_score

def random_forest_train (X,y,control):
    from sklearn.model_selection import train_test_split 
    from sklearn.ensemble import RandomForestClassifier
    from sklearn.metrics import accuracy_score 
    #split our data
    X_train,X_test,y_train,y_test=train_test_split(X,y,test_size=0.30,random_state=40)
    #apply and train logistic regresion
    model=RandomForestClassifier(n_estimators=100)
    model.fit(X_train,y_train)
    #calculate accuracy
    y_test_pred=model.predict(X_test)
    accuracy = accuracy_score(y_test, y_test_pred)
    print("Accuracy of RandomForest:",accuracy)
    
    from sklearn.metrics import confusion_matrix, ConfusionMatrixDisplay
    import matplotlib.pyplot as plt 
    import seaborn as sns
    from sklearn.metrics import roc_auc_score, roc_curve
    #calculate confusion matrix and plot
    fig, (ax) = plt.subplots(3,1, figsize=(15, 20))
    cmx=confusion_matrix(y_test,y_test_pred)
    disp=ConfusionMatrixDisplay(confusion_matrix=cmx)
    disp.plot(ax=ax[0]);
    #confusion matrix heatmap
    sns.heatmap(cmx/np.sum(cmx), annot=True, fmt='.2%',cmap='Blues', ax=ax[1]);    
    #transform y_test from Yes/No to 1/0 it is necessary
    if control == True:
        def yes_no_to_0_1(x):
            if 'Yes' in x:
                return 1
            else: 
                return 0
        y_test = y_test.apply(yes_no_to_0_1)
    else:
        y_test = y_test
    
    y_pred_probs=model.predict_proba(X_test)[::,1]
    #roc_curve plot
    fpr,tpr, _ = roc_curve(y_test,y_pred_probs)
    auc=roc_auc_score(y_test,y_pred_probs)
    ax[2].plot(fpr,tpr,label='roc model,auc='+str(auc))
    ax[2].legend(loc=4)
    plt.show()
    return model,accuracy,auc

#---------------------------------------------------------------------------------------------------
##Normally X = X_full (data before train)
##Normally y = Goal
#control = (1, 0) if 1: change y column from Yes,No to 1,0
#receives a list database
#shows accuracy, confusion matrix plot, roc_curve plot for each
#returns a database with scaler,accuracy,roc_score

def logistic_regresion_full (X,y,control):
    #we create a list with the names of the scaled values
    names = ['MinMaxScaler','MaxAbsScaler','StandardScaler','RobustScaler','Normalizer','QuantileTransformer','PowerTransformer']
    #we create a empty list to store accuracy of each scaled values
    accuracy = []
    #we create a empty list to store score of each scaled values
    score = []
    ##we create a empty list to store the results
    result = pd.DataFrame(columns = ['Scaler','Accuracy', 'Rock Auc Score'])
    #This for, call the function -logistic_regresion_train- to test each scaled value for the regression model
    for i in range(len(X)):  
        print("Numerical values sampled with: " + names[i])
        print(X[i])
        acu,roc = logistic_regresion_train (X[i],y,control)
        accuracy.append(acu)
        score.append(roc)
        result = result.append({'Scaler' : names[i] , 'Accuracy' : accuracy[i], 'Rock Auc Score' : score[i]}, ignore_index=True)
        print("")
    return result

######################################################################################################################
######################################################################################################################
######################################################################################################################



######################################################################################################################
##################################################     usefl functions          ######################################
######################################################################################################################

#Receive a column from pandas with Yes and No and return the same with 1 and 0
def yes_no_to_0_1 (data):
    if data in ['No', 'NO']:
        return 0
    else: 
        return 1
    
#Recive a database and show all Value_counts()
def show_values (data):
    import matplotlib.pyplot as plt
    import seaborn as sns
    for column in data:    
        #used to underline the text
        print("\033[4m" + data[column].name + "\033[0m")
        print(data[column].value_counts())
        fig, (ax) = plt.subplots(1,1, figsize=(5, 5))
        sns.histplot(data[column], ax=ax)
        print("")
        print("")
        
#Recive a database and show a correlation matrix plot
def matrix_correlation (data):
    import matplotlib.pyplot as plt
    import seaborn as sns
    corr_matrix=data.corr(method='pearson')
    mask=np.zeros_like(corr_matrix)
    mask[np.triu_indices_from(mask)]=True
    fig,ax = plt.subplots(figsize=(10,8))
    ax=sns.heatmap(corr_matrix, mask=mask, center=0, cmap=sns.diverging_palette(220, 20, as_cmap=True), annot=True)


######################################################################################################################
######################################################################################################################
######################################################################################################################
























