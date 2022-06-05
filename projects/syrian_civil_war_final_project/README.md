# Syrian Civil War: a Refugee/Asylum geographical dispersion approach based on gender and group ages (2011-2021)

By [Lluis Badia Planes](https://github.com/lluis90badia/projects), 18/3/2022

<p align="center"><img src="https://github.com/lluis90badia/projects/blob/main/projects/syrian_civil_war_final_project/images/syrian_flag.jpg"  height="500"></p>

## Contents 

- [Purpose](https://github.com/lluis90badia/projects/tree/main/projects/syrian_civil_war_final_project#purpose)
- [Steps used for the project](https://github.com/lluis90badia/projects/tree/main/projects/syrian_civil_war_final_project#steps-used-for-the-project)
- [IDP based on Syrian Governorates](https://github.com/lluis90badia/projects/tree/main/projects/syrian_civil_war_final_project#idp-based-on-syrian-governorates)
- [Refugee dispersion demographics based on gender and group ages](https://github.com/lluis90badia/projects/tree/main/projects/syrian_civil_war_final_project#refugee-dispersion-demographics-based-on-gender-and-group-ages)
- [Top Asylum-Seeker/Applicant countries](https://github.com/lluis90badia/projects/tree/main/projects/syrian_civil_war_final_project#top-asylum-seekerapplicant-countries)
- [Conclusions](https://github.com/lluis90badia/projects/tree/main/projects/syrian_civil_war_final_project#top-asylum-seekerapplicant-countries)

## Purpose

The purpose of this project is to display and understand three aspects:

- IDP distribution in the fourteen Syrian Governorates during the available years.
- Which countries were the ones who received more Syrian refugees based on gender and group ages during 2011-2021.
- Which countries the Syrian population sought asylum or applied for during those years.

For a deeper understanding of the events, please see the attached [report](https://github.com/lluis90badia/projects/blob/main/projects/syrian_civil_war_final_project/syrian_civil_war_report.pdf).

## Steps used for the project

First of all, the search for the data has been focused, mostly, on international agencies such as the UNHCR (the United Nations High Comissioner for Refugees), particularly in the UN-OCHA (the Office for the Coordination of Human Affairs):

- Humanitarian Data Exchange (HDX)
- Relief Web
- Wikipedia has also been used to get some insights for the Data Explanation and the report.

Most of the files were in CSV format, which was quite handy for further [Data Cleaning](https://github.com/lluis90badia/projects/blob/main/projects/syrian_civil_war_final_project/Data_Cleaning.ipynb) and Data Extraction made in Pandas (Python), but there were also Excel and PDF files.
In addition, it was also used SQL (a [database](https://github.com/lluis90badia/projects/blob/main/projects/syria_final_project/tableau_data/sql_database.sql) was created along with several tables to load data from CSV files) to extract some queries and then exported them again to CSV format to proceed (along with the Data Extraction made with Python) to do Data Visualisation in [Tableau](https://public.tableau.com/app/profile/lluis6453/viz/Lluis_Badia-Syrian_Civil_War_Data_Visualisation/Asyl-Appdash?publish=yes).

On the one hand, the intention was to approach visualisations in a more geographical way using maps based on National or International perspectives during the years available.
On the other hand, bar and pie charts have been used to create 'race bars' or animated charts to have better visualisations and facilitate the analysis.

The key to creating the 'race bar' plots has been grouping the year columns with the 'pivot' option, so they were converted to rows and then placed in the 'pages' area. Whereas, for the map visualisations, multiple layers were created to display more than one kind of feature to get better analysis.


## IDP based on Syrian Governorates

This first part is focused on displaying the number of IDPs located in each of the fourteen Governorates that form the Syrian Arab Republic during the (available) years between 2011 and 2021.

At the first stages of the conflict, much of the IDPs were located in the central regions of the country. 

But as the conflict went by, the IDP's exodus was located increasingly in the NW regions, especially Aleppo and Idleb. However, the Aleppo Governorate suffered important damage when Russia entered in scene in October 2015 to back the government forces as a crucial turning point for the path of confronting the rebel factions (and also the Islamic State of Iraq and the Levant or ISIL in the East).

<p align="center"><img src="https://github.com/lluis90badia/projects/blob/main/projects/syrian_civil_war_final_project/images/idp_2014.PNG"  height="450"></p>
<p align="center">Number of IDPs per Governorate in 2014 (estimated IDP peak) and IDP timeline (2011-2021)</p>

That is why, the Idleb region has been resisting and continues to remain the main rebel stronghold. Therefore, it has become the main location for the majority of displaced people who still refuse to follow authoritarian rules, fear repression after returning to their home or have lost everything back home.

Since the increase in 2013 and its peak in 2014, the total number of IDPs has remained constant at around 6.5 million.


## Refugee dispersion demographics based on gender and group ages

The second part is focused on displaying the top countries that gather the majority of refugees based on gender and group ages from 2011 to 2021.

Regarding the refugee distribution based on group ages and gender, there is a clear difference between 2011 (data before the events started or the very early stages) and the following years.

The first one, the majority of the people were families with small children (0-4 years), and the countries that were heading were from the West. Therefore, it seems that they were looking for stability and a more level of future opportunities.

<p align="center"><img src="https://github.com/lluis90badia/projects/blob/main/projects/syrian_civil_war_final_project/images/ref_demographics.PNG"  height="500"></p>
<p align="center">Refugee demographics (2020-2021)</p>

However, after the early stages, the distribution got more uniform between the groups, although the adult one has been the top one. Regarding the countries in which they ended up, there was a clear change of tendency of western countries to closer countries with similar cultural and religious roots.

About the differences between gender, in general, the male population has been greater than the female. There are no major divergences between them, except that there is more presence of male refugees in Germany than in the female population, which reflects that it was more difficult for them to reach greater objectives for better prospects.


## Top Asylum-Seeker/Applicant countries

Finally, the last part is focused on displaying which countries had more applications from Syrian seeking-population to become a refugee and be able to receive benefits from the asylum state.

First of all, it is important to understand the difference between a refugee and an asylum-seeker/applicant:

- A refugee is a person who is fleeing armed conflicts or persecution and its situation is perilous that cross national borders to seek safety and access to assistance from another country. 

- Whereas an Asylum-Seeker is a person who claims to be a refugee but its application has not been evaluated yet. Until that person will not become a refugee, will be recognised as an Asylum-Seeker.

- On the other hand, the term Asylum-Applicant differs from Asylum-Seeker when the application has been already submitted. Therefore, the UNHCR distinguish the ones who are in process (Seeker) and the ones who have already a response (Applicant).

<p align="center"><img src="https://github.com/lluis90badia/projects/blob/main/projects/syrian_civil_war_final_project/images/seekers_applicants.PNG"  height="450"></p>
<p align="center">Top countries with more Asylum-Seekers/Asylum-Applicants (2011-2021)</p>

According to the UNHCR data, there are clear differences between the countries where the Syrian population wanted to apply (that does not mean they got accepted as a refugee) or were seeking asylum and the ones who ended up in closer countries as refugees.

Besides, there is a contrast between the Asylum-Seekers and the Asylum-Applicants. About the first ones, not only were seeking in European countries but countries such as the USA or Libya; whereas the latter ones were choosing mostly European countries which are members of the European Union.

## Conclusions

- Most of the data is based on estimations giving the difficulty to obtain reliable ground sources from a country which have been struggling for more than a decade without hopes of an imminent peace deal or an agreement to lay down arms between the contenders with opposing points of view.

- It would have been useful to have a more accurate age group distribution, particularly in the adult age, to check for patterns.

- For almost a decade, Syria is the country with the most number of IDPs (Internal Displaced People) followed by the Democratic Republic of the Congo (5.3 million) and Colombia (4.9 million).

- As the conflict progressed, the population fleeing the war has been concentrating in the areas of the northwest not controlled by the Syrian government (SDF - Syrian Democratic Forces and the Kurdish left-wing party PYD in the north).

- Turkey is, by far, the country with more Syrian refugee population; whereas Germany is, by far, the state with more asylum applications for a better future for them and their families.
