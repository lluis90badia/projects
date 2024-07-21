# Salary Survey

Author: [Lluis Badia Planes](https://github.com/lluis90badia/projects)

<p align="center"><img src="https://site.surveysparrow.com/wp-content/uploads/2021/05/decide-on-the-right-time-to-conduct-a-survey-768x410.png" height="400"></p>

## Content

- [Objectives]()
- [Actions Taken]()
- [Conclusions]()

## Objectives

- Understand, clean and process the selected database using Microsoft Excel.
- Import the processed file into Power BI to amend the sheets in Power Query, and to visualise the data through charts.
- Analyse whether the survey data realistically reflects the current European labour market context.

## Actions Taken

### 1. Survey Completion and Data Collection:
- Introduced our job position details.
- Downloaded the dataset in an Excel file for further analysis.
  
### 2. Data Cleaning & Exploratory Data Analysis (EDA) in Excel:
- Header simplification:<br>Clarified headers for better readability and identification.
- Initial Data Overview:<br>Created a pivot table and charts for an initial context overview.
- Noise Reduction and Standardisation:<br>Developed formulas (IF, OR, AND, ISNUMBER, SEARCH functions) to group dimensions based on variables such as Industry, Race, Gender, and Position Level (refer to the attached TXT file for detailed formulas).
- Salary Data Standardisation:<br>Converted the “Annual Salary” column from general to Currency (€) format, applying specific conversion rates for other currencies. In addition, the “Other” currency category excluded rows without specified salaries.
- Salary Interval Analysis:<br>Utilised FREQUENCY and PERCENTILE functions to analyse salary data with the knowledge gained by searching for information about average salary data and position levels across Europe.
- Bonus Variable Standardisation:<br>Added a binary column for the “bonus” variable, indicating “YES” if the value is greater than 0, and “NO” if the cell is blank or 0.
- Data Segregation:<br>Segregated columns into sheets based on Demography, Salary, Location, and Job data to facilitate the creation of a data model in Power BI.

### 3. Data Preparation & Visualisation in Power BI:

- Data Import and Preparation:<br>Refined the sheets in Power Query by removing unnecessary columns and adjusting data types to enable chart creation. After that, Imported the Excel file containing the segregated sheets to build a data model based on respondent IDs.
- Measure Creation:<br>
&emsp;- Developed measures to calculate:<br>
&emsp;&emsp;1. Percentages of total respondents for dimensions such as Gender and Race (formulas available in the [TXT file]() attached).<br>
&emsp;&emsp;2. Average salary.<br>
&emsp;&emsp;3. A card on the “Demography” tab to display selected industries or “All” if all are selected.<br><br>
&emsp;- Interactive Features:<br>
&emsp;&emsp;1. Added a moving filter bar on the “Demography” tab, toggled by a filter icon (using bookmarks) and a hide icon (left-pointing arrow in a circle).<br>
&emsp;&emsp;2. Created a “Clear Filters” action on all tabs except “Summary” to reset filters on the page.<br>

