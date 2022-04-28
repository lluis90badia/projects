# Proyecto SQL - Estudio de caso: Concesionario

Elaborado por [Lluis Badia Planes](https://github.com/lluis90badia/lbadialabwork)

<p align="center"><img src="https://www.lawdonut.co.uk/business/sites/lawdonut-business/files/usedcardealer1_0.jpg" height="400"></p>

## Contenido

- [Finalidad](https://github.com/lluis90badia/projects/blob/main/proyecto_SQL_concesionario/README.md#finalidad)
- [Pasos realizados](https://github.com/lluis90badia/projects/blob/main/proyecto_SQL_concesionario/README.md#pasos-realizados)
- [Esquema E/R]()
- [Modelo Relacional]()
- [Relaciones entre tablas](https://github.com/lluis90badia/projects/blob/main/proyecto_SQL_concesionario/README.md#relaciones)

## Finalidad

Uno de los socios capitalistas ha pedido una lista completa de los coches que se han vendido durante los últimos meses con sus características.

Por esta razón, además de la lista que contiene los coches vendidos y en stock, se ha aprovechado este requerimiento para actualizar los datos de la empresa a lo que se refiere a empleados y clientes.

## Pasos realizados

Esta es la información que se ha recopilado para cada entidad ([archivos CSV](https://github.com/lluis90badia/projects/tree/main/proyecto_SQL_concesionario/archivos_csv)):
- Para la generación de los nombres y apellidos, se han obtenido mediante el portal web [Generate Data](https://generatedata.com/).
- Para los [clientes](https://github.com/lluis90badia/projects/blob/main/proyecto_SQL_concesionario/archivos_csv/clientes.csv), se han utilizado varias funciones en excel para formar aleatoriamente el DNI, el muncipio, el email y el teléfono. Hay una explicación más detallada en el apartado 7 del archivo [PDF](https://github.com/lluis90badia/projects/blob/main/proyecto_SQL_concesionario/Proyecto_SQL_concesionario.pdf).
- Para los [empleados](https://github.com/lluis90badia/projects/blob/main/proyecto_SQL_concesionario/archivos_csv/empleados.csv), se han usado los mismos métodos para obtener el DNI, el email .
- 

## Esquema E/R

<p align="center"><img src="https://github.com/lluis90badia/projects/blob/main/proyecto_SQL_concesionario/imagenes_modelos/entidad_relacion.PNG"  height="400"></p>

## Modelo Relacional

<p align="center"><img src="https://github.com/lluis90badia/projects/blob/main/proyecto_SQL_concesionario/imagenes_modelos/modelo_relacional.PNG"  height="500"></p>

## Relaciones

En este último apartado, se han efectuado una serie de consultas para comprobar las [relaciones](https://github.com/lluis90badia/projects/blob/main/proyecto_SQL_concesionario/comprov_relaciones_tablas.txt) entre las entidades que agrupa el modelo.

[SQL](https://github.com/lluis90badia/projects/blob/main/proyecto_SQL_concesionario/concesionario.sql)
[PDF](https://github.com/lluis90badia/projects/blob/main/proyecto_SQL_concesionario/Proyecto_SQL_concesionario.pdf)
