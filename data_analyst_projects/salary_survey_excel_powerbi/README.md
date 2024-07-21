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
  
2. Data Cleaning & Exploratory Data Analysis (EDA) in Excel:
- Header simplification:<br>Clarified headers for better readability and identification.
- Initial Data Overview:<br>Created a pivot table and charts for an initial context overview.
- Noise Reduction and Standardisation:<br>Developed formulas (IF, OR, AND, ISNUMBER, SEARCH functions) to group dimensions based on variables such as Industry, Race, Gender, and Position Level (refer to the attached TXT file for detailed formulas).
- Salary Data Standardisation:<br>Converted the “Annual Salary” column from general to Currency (€) format, applying specific conversion rates for other currencies. In addition, the “Other” currency category excluded rows without specified salaries.
- Salary Interval Analysis:<br>Utilised FREQUENCY and PERCENTILE functions to analyse salary data with the knowledge gained by searching for information about average salary data and position levels across Europe.
- Bonus Variable Standardisation:<br>Added a binary column for the “bonus” variable, indicating “YES” if the value is greater than 0, and “NO” if the cell is blank or 0.
- Data Segregation:<br>Segregated columns into sheets based on Demography, Salary, Location, and Job data to facilitate the creation of a data model in Power BI.

3. Data Preparation & Visualisation in Power BI:

- Data Import and Preparation: Refined the sheets in Power Query by removing unnecessary columns and adjusting data types to enable chart creation. After that, Imported the Excel file containing the segregated sheets to build a data model based on respondent IDs.
- Measure Creation:<br>
&emsp;- Developed measures to calculate:<br>
&emsp;&emsp;1. Percentages of total respondents for dimensions such as Gender and Race (formulas available in the [TXT file]() attached<br>



## Contenido

- [Finalidad](https://github.com/lluis90badia/projects/blob/main/projects/proyecto_SQL_concesionario/README.md#finalidad)
- [Pasos realizados](https://github.com/lluis90badia/projects/blob/main/projects/proyecto_SQL_concesionario/README.md#pasos-realizados)
- [Esquema E/R](https://github.com/lluis90badia/projects/blob/main/projects/proyecto_SQL_concesionario/README.md#esquema-er)
- [Modelo Relacional](https://github.com/lluis90badia/projects/blob/main/projects/proyecto_SQL_concesionario/README.md#modelo-relacional)
- [Relaciones entre tablas](https://github.com/lluis90badia/projects/blob/main/projects/proyecto_SQL_concesionario/README.md#relaciones)

## Finalidad

Uno de los socios capitalistas ha pedido una lista completa de los coches que se han vendido durante los últimos meses con sus características.

Por esta razón, además de la lista que contiene los coches vendidos y en stock, se ha aprovechado este requerimiento para actualizar los datos de la empresa a lo que se refiere a empleados y clientes.

## Pasos realizados

Esta es la información que se ha recopilado para cada entidad ([archivos CSV](https://github.com/lluis90badia/projects/tree/main/projects/proyecto_SQL_concesionario/archivos_csv)):
- Para la generación de los nombres y apellidos, se han obtenido mediante el portal web [Generate Data](https://generatedata.com/).
- Para los [clientes](https://github.com/lluis90badia/projects/blob/main/projects/proyecto_SQL_concesionario/archivos_csv/clientes.csv), se han utilizado varias funciones en excel para formar aleatoriamente el DNI, el muncipio, el email y el teléfono. Hay una explicación más detallada en el apartado 7 del archivo [PDF](https://github.com/lluis90badia/projects/blob/main/projects/proyecto_SQL_concesionario/Proyecto_SQL_concesionario.pdf).
- Para los [empleados](https://github.com/lluis90badia/projects/blob/main/projects/proyecto_SQL_concesionario/archivos_csv/empleados.csv), se han usado los mismos métodos para obtener el DNI, el email, teléfono y municipio.
- Para las [provincias](https://github.com/lluis90badia/projects/blob/main/projects/proyecto_SQL_concesionario/archivos_csv/provincias.csv), se han listado las 52 provincias españolas con sus respectivos identificadores obtenidos des del portal web [INE](https://ine.es/).
- Para los [municipios](https://github.com/lluis90badia/projects/blob/main/projects/proyecto_SQL_concesionario/archivos_csv/municipios.csv), no se ha podido usar como identificador el código postal porque no concuerdan los códigos postales del INE con los reales; por eso se ha empleado un identificador auto-incrementable.
- Para los [modelos](https://github.com/lluis90badia/projects/blob/main/projects/proyecto_SQL_concesionario/archivos_csv/modelos.csv), se han designado los nombres de los modelos a partir de asignar aleatóriamente la marca del [coche](https://github.com/lluis90badia/projects/blob/main/projects/proyecto_SQL_concesionario/archivos_csv/coches.csv).
- Para las [características](https://github.com/lluis90badia/projects/blob/main/projects/proyecto_SQL_concesionario/archivos_csv/caracteristicas.csv), se ha utilizado la función 'RANDBETWEEN' para las columnas 'id_mod', 'plazas', 'puertas', 'motor' y 'kilometraje' empleando unos parámetros diferentes acorde al tipo de característica. Para el resto de columnas, se ha usado la función 'INDEX' juntamente con 'RANDBETWEEN' y 'COUNTA'. 
- Para las [ventas](https://github.com/lluis90badia/projects/blob/main/projects/proyecto_SQL_concesionario/archivos_csv/ventas.csv), se ha multiplicado por 1,05 el precio perteneciente a la tabla coches para sumar el margen que se lleva el concesionario. Además, se han asignado aleatoriamente los DNIs de los empleados y clientes. Para la columna 'f_venta' se ha escogido hacer un 'CONCAT' incluyendo tres 'RANDBETWEEN' para determinar los días, meses y años (separados por guiones).  

## Esquema E/R

<p align="center"><img src="https://github.com/lluis90badia/projects/blob/main/projects/proyecto_SQL_concesionario/imagenes_modelos/entidad_relacion.PNG"  height="400"></p>

En la anterior imagen se desarrolan las relaciones entre entidades para poder hacer consultas en las diferentes tablas importadas de los archivos CSV dentro de la base de datos creada a partir del archivo [SQL](https://github.com/lluis90badia/projects/blob/main/projects/proyecto_SQL_concesionario/concesionario.sql).

## Modelo Relacional

<p align="center"><img src="https://github.com/lluis90badia/projects/blob/main/projects/proyecto_SQL_concesionario/imagenes_modelos/modelo_relacional.PNG"  height="500"></p>

La imagen anterior desarrollada en MySQL Workbench corresponde a la transformación al modelo relacional a partir del esquema E/R. En los apartados 4 y 5 del archivo [PDF](https://github.com/lluis90badia/projects/blob/main/projects/proyecto_SQL_concesionario/Proyecto_SQL_concesionario.pdf) hay la descripción de las entidades y sus atributos.

## Relaciones

En este último apartado, se han efectuado una serie de consultas para comprobar las [relaciones](https://github.com/lluis90badia/projects/blob/main/projects/proyecto_SQL_concesionario/comprov_relaciones_tablas.txt) entre las entidades que agrupa el modelo.
