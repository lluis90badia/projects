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
  - Developed measures to calculate:<br>
    - Percentages of total respondents for dimensions such as Gender and Race (formulas available in the [TXT file]() attached).<br>
    - Average salary.<br>
    - A card on the “Demography” tab to display selected industries or “All” if all are selected.<br>
  - Interactive Features:<br>
    - Added a moving filter bar on the “Demography” tab, toggled by a filter icon (using bookmarks) and a hide icon (left-pointing arrow in a circle).<br>
    - Created a “Clear Filters” action on all tabs except “Summary” to reset filters on the page.<br>
  - Chart Creation:
    - Developed various charts to analyse respondent data. The conclusions are presented in the next section.

## Conclusions

- Summary:<br>The survey indicates a predominant profile: a white, college-educated woman in her late twenties to early thirties, based in the USA, working in IT or education at a mid-level position, with over a decade of experience, and earning an annual salary of €40-60K.

- Demography:<br>
  - Gender: 76% of respondents are women, yet they have the lowest average earnings, except in India and remote positions.
  - Race: “White” respondents comprise 83% but do not have the highest average salaries due to their majority representation.
  - Education & Age: Higher education levels and older age groups report higher salaries, following logical trends.

- Industry & Position Level:<br>
  - There is generally no correlation between reported position levels and actual salaries, categorised by European salary intervals.
  - Filters reveal most junior respondents, particularly from the USA (85%), should be promoted to mid-level positions due to higher salaries compared to European counterparts.
  - In the “Industry” dimension, most hospitality workers should be at the intermediate level, while IT workers should hold better positions based on European salary context.
  - More respondents reported not receiving bonuses (54%). Bonus-receiving industries include consulting, engineering, finance, insurance, technology, and marketing, known for their results-oriented performance, market competitiveness, and business models based on commissions and incentives.

- Position Level – Reported vs. Actual:<br>
Significant discrepancies exist between reported position levels and those inferred from salaries. While 61% of reported positions are mid-level and 28% senior management, the actual distribution (based on European context) would be more balanced with 32% at the intermediate level. The Law and Veterinary sectors exhibit the most notable discrepancies.
