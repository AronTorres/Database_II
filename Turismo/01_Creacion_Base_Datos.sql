
/*
Base Datos para sector Turismo
------------------------------
Incluye Reservas, Clientes, Empleados, Transporte, Hospedaje
Lugares Turisticos, Proveedores ect.
Adaptacion personal: TXZ
*/

-- USA BASE MODELO
USE master;
GO

-- Validar existencia base de datos
IF DB_ID(N'Turismo_TXZ') IS NULL
BEGIN
    CREATE DATABASE Turismo_TXZ;
    PRINT 'Se ha creado la base de datos Turismo_TXZ';
END
ELSE
BEGIN
    PRINT 'La base de datos Turismo_TXZ existe';
END
GO

-- Usar la base de datos creada
USE Turismo_TXZ;
PRINT 'Usando Turismo_TXZ';
GO

-- Crear esquema

IF SCHEMA_ID(N'RRHH') IS NULL
BEGIN
    EXEC (N'CREATE SCHEMA RRHH AUTHORIZATION dbo;');
    PRINT 'Esquema RRHH Creado';
END
ELSE
BEGIN
    PRINT 'Esquema RRHH existe';
END;
GO

IF SCHEMA_ID(N'Compras') IS NULL
BEGIN
    EXEC (N'CREATE SCHEMA Compras AUTHORIZATION dbo;');
    PRINT 'Esquema Compras Creado';
END
ELSE
BEGIN
    PRINT 'Esquema Compras existe';
END;
GO

IF SCHEMA_ID(N'Ventas') IS NULL
BEGIN
    EXEC (N'CREATE SCHEMA Ventas AUTHORIZATION dbo;');
    PRINT 'Esquema Ventas Creado';
END
ELSE
BEGIN
    PRINT 'Esquema Ventas existe';
END;
GO

IF SCHEMA_ID(N'UNC') IS NULL
BEGIN
    EXEC (N'CREATE SCHEMA UNC AUTHORIZATION dbo;');
    PRINT 'Esquema UNC Creado';
END
ELSE
BEGIN
    PRINT 'Esquema UNC existe';
END;
GO

IF SCHEMA_ID(N'TXZ') IS NULL
BEGIN
    EXEC (N'CREATE SCHEMA TXZ AUTHORIZATION dbo;');
    PRINT 'Esquema TXZ Creado';
END
ELSE
BEGIN
    PRINT 'Esquema TXZ existe';
END;
GO

/*
Creacion de Tablas
Validar Existencia
Crear la Tabla
*/

-- Crear Tabla Pais

IF OBJECT_ID(N'TXZ.Pais', N'U') IS NULL
BEGIN
    CREATE TABLE TXZ.Pais (
        -- primera forma poner PK
        idpais int primary key identity(1,1),
        nombrepais varchar(40) not null,
        codigoiso varchar(3) not null, --PER, ARG, CHL, COL
        constraint UQ_nombrepais
        UNIQUE (nombrepais),
        constraint UQ_codigoiso
        UNIQUE (codigoiso)
    );

    PRINT 'La tabla TXZ.Pais creada';
END
ELSE
BEGIN
    PRINT 'La tabla TXZ.Pais existe';
END
GO

-- Crear tabla nacionalidad

IF OBJECT_ID(N'TXZ.Nacionalidad', N'U') IS NULL
BEGIN
    CREATE TABLE TXZ.Nacionalidad (
        idnacionalidad int identity(1,1),
        nomnacionalidad varchar(80) not null,
        idpais int not null,
        constraint PK_nacionalidad
        primary key (idnacionalidad),
        constraint UQ_nacionalidad
        UNIQUE (nomnacionalidad),
        constraint FK_pais_nacionalidad
        foreign key (idpais) References TXZ.Pais (idpais)
    );

    PRINT 'Tabla Nacionalidad Creada';
END
ELSE
BEGIN
    PRINT 'La tabla TXZ.Nacionalidad existe';
END
GO

-- Crear tabla region (Departamento)

IF OBJECT_ID(N'TXZ.Region', N'U') IS NULL
BEGIN
    CREATE TABLE TXZ.Region (
        idregion int identity (1,1),
        nomregion varchar (80) not null,
        codigoubigeo varchar(3) not null,--CAJ, LIM, CUS
        idpais int not null,
        constraint PK_region primary key (idregion),
        constraint UQ_nomregion UNIQUE (nomregion),
        constraint FK_region_pais
        foreign key (idpais) References TXZ.Pais (idpais)
    );

    PRINT 'Tabla Region Creada';
END
ELSE
BEGIN
    PRINT 'La tabla TXZ.Region existe';
END
GO

-- Crear tabla subregion (Provincia)

IF OBJECT_ID(N'TXZ.Subregion', N'U') IS NULL
BEGIN
    CREATE TABLE TXZ.Subregion (
        idsubregion int identity(1,1),
        nomsubregion nvarchar(100) not null,
        codigo_ubigeo varchar(4) not null,
        idregion int not null,
        constraint PK_subregion primary key (idsubregion),
        constraint FK_subregion_region
        foreign key (idregion)
        references TXZ.Region (idregion)
    );

    PRINT 'Tabla Subregion creada';
END
ELSE
BEGIN
    PRINT 'La tabla TXZ.Subregion existe';
END
GO

-- Crear tabla ciudad o distrito

IF OBJECT_ID(N'TXZ.Ciudad', N'U') IS NULL
BEGIN
    CREATE TABLE TXZ.Ciudad (
        idciudad int identity(1,1),
        nomciudad varchar(80) not null,
        codigo_ubigeo varchar(6),
        idsubregion int not null,
        constraint PK_ciudad primary key (idciudad),
        constraint FK_ciudad_subregion
        foreign key (idsubregion)
        References TXZ.Subregion (idsubregion)
    );

    PRINT 'Tabla Ciudad creada';
END
ELSE
BEGIN
    PRINT 'La tabla TXZ.Ciudad existe';
END
GO

-- Crear tabla Tipo_documento

IF OBJECT_ID(N'RRHH.TipoDocumento', N'U') IS NULL
BEGIN
    CREATE TABLE RRHH.TipoDocumento(
        idtipodocumento int identity(1,1),
        nombredoc varchar(50) not null,
        abreviatura char(10) not null,
        constraint PK_tipodocumento
        primary key (idtipodocumento),
        constraint UQ_nombredoc UNIQUE (nombredoc),
        constraint UQ_abreviatura UNIQUE (abreviatura)
    );

    PRINT 'Tabla TipoDocumento Creado';
END
ELSE
BEGIN
    PRINT 'La tabla RRHH.TipoDocumento existe';
END
GO

-- Crear tabla Persona

IF OBJECT_ID(N'RRHH.Persona', N'U') IS NULL
BEGIN
    CREATE TABLE RRHH.Persona (
        idpersona int identity(1,1),
        tipo_persona char(1) not null --N: Natural,J:Juridica
        constraint CHK_tipo_persona
        CHECK (tipo_persona in ('N', 'J')),

        nombres varchar(100),
        apaterno varchar(100),
        amaterno varchar(100),

        razon_social varchar (200) not null,
        nombre_comercial varchar(200),

        idtipodocumento int not null,
        numero_documento varchar(20) not null,

        telefono varchar(20)
        constraint CHK_numero_telefono
        CHECK (LEN(Ltrim(RTRIM(telefono))) between 12 and 20
        and telefono not like '%[^0-9+()]%'),

        --+51987654321, (+51)987654321, (01) 654321

        email varchar(150),
        idnacionalidad int not null,

        estado varchar(20) default 'Activo'
        constraint CHK_estado
        CHECK (estado in ('Activo', 'Inactivo')),

        constraint PK_persona primary key (idpersona),
        constraint UQ_persona_documento
        UNIQUE (idtipodocumento, numero_documento),

        constraint FK_Persona_tipodocumento
        foreign key (idtipodocumento)
        References RRHH.TipoDocumento (idtipodocumento),

        constraint FK_persona_nacionalidad
        foreign key (idnacionalidad)
        References TXZ.Nacionalidad (idnacionalidad)
    );

    PRINT 'Tabla Persona Creada';
END
ELSE
BEGIN
    PRINT 'La tabla RRHH.Persona existe';
END
GO

-- Crear tabla Cargo

IF OBJECT_ID(N'RRHH.Cargo', N'U') IS NULL
BEGIN
    CREATE TABLE RRHH.Cargo (
        idcargo int identity(1,1),
        nomcargo varchar(50) not null,
        descripcion varchar(max),
        salario_base decimal(10,2) not null,
        constraint PK_cargo Primary key (idcargo)
    );

    PRINT 'Tabla Cargo Creada';
END
ELSE
BEGIN
    PRINT 'La tabla RRHH.Cargo existe';
END
GO

PRINT 'Proceso de creacion finalizado';
GO
