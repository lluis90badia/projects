drop database if exists concesionario;
create database concesionario;
use concesionario;

create table provincias (
    id_prov int not null auto_increment,
    nombre varchar(40),
    primary key (id_prov)
) engine=innodb default charset=utf8;

create table municipios (
    id_mun int not null auto_increment,
    nombre varchar(70),
    id_prov int,
    primary key (id_mun),
    foreign key (id_prov) references provincias (id_prov)
) engine=innodb default charset=utf8;

create table clientes (
    dni_clie char(9) not null,
    nombre varchar(25),
    apellido1 varchar(30),
    apellido2 varchar(30),
    telefono char(9),
    municipio int,
    email varchar(40),
    primary key (dni_clie),
    foreign key (municipio) references municipios (id_mun)
) engine=innodb default charset=utf8;

create table empleados (
    dni_emp char(9) not null,
    nombre varchar(25),
    apellido1 varchar(30),
    apellido2 varchar(30),
    cargo varchar(20),
    telefono char(9),
    municipio int,
    email varchar(40),
    primary key (dni_emp),
    foreign key (municipio) references municipios (id_mun)
) engine=innodb default charset=utf8;

create table marcas (
    id_mar int not null auto_increment,
    nombre varchar(40),
    primary key (id_mar)
) engine=innodb default charset=utf8;

create table modelos (
    id_mod int not null auto_increment,
    id_mar int,
    nombre varchar(70),
    primary key (id_mod),
    foreign key (id_mar) references marcas (id_mar)
) engine=innodb default charset=utf8;

create table caracteristicas (
    id_carac int not null auto_increment,
    id_mod int,
    tipo varchar(30),
    plazas char(2),
    color varchar(15),
    puertas tinyint(1),
    motor char(5),
    combustible enum('Gasolina','Gasoil','Híbrido','Eléctrico') default 'Gasolina',
    kilometraje varchar(10),
    primary key (id_carac),
    foreign key (id_mod) references modelos (id_mod)
) engine=innodb default charset=utf8;

create table coches (
    matricula char(7) not null,
    id_mod int,
    precio decimal(8,2),
    año_fab char(4),
    primary key (matricula),
    foreign key (id_mod) references modelos (id_mod)
) engine=innodb default charset=utf8;

create table ventas (
    matricula char(7) not null,
    dni_clie char(9),
    dni_emp char(9),
    f_venta date,
    p_venta decimal(8,2),
    primary key (matricula,dni_clie),
    foreign key (dni_emp) references empleados (dni_emp),
    foreign key (matricula) references coches (matricula),
    foreign key (dni_clie) references clientes (dni_clie)
) engine=innodb default charset=utf8;

load data local infile '~/Documentos/concesionario/provincias.csv' into table provincias fields terminated by ',' lines terminated by '\n' ignore 1 lines;

load data local infile '~/Documentos/concesionario/municipios.csv' into table municipios fields terminated by ',' lines terminated by '\n' ignore 1 lines;

load data local infile '~/Documentos/concesionario/clientes.csv' into table clientes fields terminated by ',' lines terminated by '\n' ignore 1 lines;

load data local infile '~/Documentos/concesionario/empleados.csv' into table empleados fields terminated by ',' lines terminated by '\n' ignore 1 lines;

load data local infile '~/Documentos/concesionario/marcas.csv' into table marcas fields terminated by ',' lines terminated by '\n' ignore 1 lines;

load data local infile '~/Documentos/concesionario/modelos.csv' into table modelos fields terminated by ',' lines terminated by '\n' ignore 1 lines;

load data local infile '~/Documentos/concesionario/coches.csv' into table coches fields terminated by ',' lines terminated by '\n' ignore 1 lines;

load data local infile '~/Documentos/concesionario/ventas.csv' into table ventas fields terminated by ',' lines terminated by '\n' ignore 1 lines (@col1,@col2,@col3,@col4,@col5) set matricula=@col1,dni_clie=@col2,dni_emp=@col3,f_venta=str_to_date(@col4,'%d-%m-%Y'),p_venta=@col5;

load data local infile '~/Documentos/concesionario/caracteristicas.csv' into table caracteristicas fields terminated by ',' lines terminated by '\n' ignore 1 lines;
