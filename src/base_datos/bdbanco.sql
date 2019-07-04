
CREATE TABLE TIPO_CLIENTE (
    id                      SERIAL              PRIMARY KEY,
    descripcion             VARCHAR(50)         NOT NULL
);

CREATE TABLE TIPO_MONEDA (
    id                      SERIAL              PRIMARY KEY, 
    codigo                  CHAR(3)             NOT NULL, 
    descripcion             VARCHAR(50)         NOT NULL
);

CREATE TABLE TIPO_TARJETA (
    id                      SERIAL              PRIMARY KEY, 
    descripcion             VARCHAR(50)         NOT NULL
);

CREATE TABLE TIPO_MOVIMIENTO (
    id                      SERIAL              PRIMARY KEY, 
    descripcion             VARCHAR(50)         NOT NULL
);

CREATE TABLE CANAL (
    id                      SERIAL              PRIMARY KEY, 
    descripcion             VARCHAR(50)         NOT NULL
);

CREATE TABLE TIPO_PRESTAMO (
    id                      SERIAL              PRIMARY KEY, 
    descripcion             VARCHAR(50)         NOT NULL
);

CREATE TABLE MARCA (
    id                      SERIAL              PRIMARY KEY,
    descripcion             VARCHAR(30)         NOT NULL
);

CREATE TABLE UBIGEO (
    id                      CHAR(6)             PRIMARY KEY,
    departamento            VARCHAR(25)                 NOT NULL REFERENCES DEPARTAMENTO,
    provincia               VARCHAR(25)                 NOT NULL REFERENCES PROVINCIA,
    distrito                VARCHAR(60)         NOT NULL
);

CREATE TABLE SUCURSAL (
    id                      SERIAL              PRIMARY KEY,
    ubigeo_id               CHAR(6)             NOT NULL REFERENCES UBIGEO,
    descripcion             VARCHAR(100)        NOT NULL,
    direccion               VARCHAR(200)        NOT NULL,
    telefono                VARCHAR(14)         NOT NULL
);

CREATE TABLE EMPLEADO (
    id                      SERIAL              PRIMARY KEY,
    numero_documento        CHAR(8)             NOT NULL,
    nombres                 VARCHAR(100)        NOT NULL,
    apellido_paterno        VARCHAR(100)        NOT NULL,
    apellido_materno        VARCHAR(100)        NOT NULL,
    fecha_nacimiento        DATE                NOT NULL CHECK (AGE(fecha_nacimiento) >= '20 years'),
    direccion               VARCHAR(200)        NOT NULL,
    correo                  VARCHAR(50)         NOT NULL,
    telefono                VARCHAR(20)         NOT NULL,
    estado                  BOOLEAN             NOT NULL
);

CREATE TABLE CLIENTE (
    id                      SERIAL              PRIMARY KEY,
    tipo_cliente_id         INT                 NOT NULL REFERENCES TIPO_CLIENTE,
    numero_documento        VARCHAR(11)         NOT NULL,
    nombres                 VARCHAR(100)        NOT NULL,
    apellido_paterno        VARCHAR(100)        NULL,
    apellido_materno        VARCHAR(100)        NULL,
    fecha_nacimiento        DATE                NOT NULL,
    direccion               VARCHAR(200)        NOT NULL,
    correo                  VARCHAR(50)         NOT NULL,
    telefono                VARCHAR(20)         NULL,
    estado                  BOOLEAN             NOT NULL,

    CONSTRAINT chk_fecha_nacimiento_cliente
        CHECK (
            (LENGTH(numero_documento) = 8 AND AGE(fecha_nacimiento) >= '18 years') OR
            (LENGTH(numero_documento) = 11 AND AGE(fecha_nacimiento) >= '0 days')
        )
);

CREATE TABLE SERVICIO (
    id                      SERIAL              PRIMARY KEY,
    cliente_id              INT                 NOT NULL REFERENCES CLIENTE,
    descripcion             VARCHAR(40)         NOT NULL
);

CREATE TABLE SERVICIO_BRINDADO (
    id                      SERIAL              PRIMARY KEY,
    servicio_id             INT                 NOT NULL REFERENCES SERVICIO,
    usuario                 VARCHAR(9)          NOT NULL,
    costo                   MONEY               NOT NULL,
    fecha_facturacion       DATE                NOT NULL,
    fecha_pago              DATE                NULL CHECK (fecha_pago >= fecha_facturacion)
);

CREATE TABLE CUENTA (
    id                      SERIAL              PRIMARY KEY,
    cliente_id              INT                 NOT NULL REFERENCES CLIENTE,
    tipo_moneda_id          INT                 NOT NULL REFERENCES TIPO_MONEDA,
    sucursal_id             INT                 NOT NULL REFERENCES SUCURSAL,
    numero                  VARCHAR(20)         NOT NULL,
    estado                  BOOLEAN             NOT NULL,
    fecha_creacion          DATE                NOT NULL CHECK (fecha_creacion <= CURRENT_DATE) DEFAULT CURRENT_DATE,
    fecha_anulacion         DATE                NULL CHECK (AGE(fecha_anulacion, fecha_creacion) > '3 mons'),
    cci                     VARCHAR(30)         NOT NULL,
    saldo                   MONEY               NOT NULL CHECK (saldo >= MONEY '0'),
    saldo_usado             MONEY               NULL CHECK (saldo_usado < saldo_total),
    saldo_total             MONEY               NULL CHECK (saldo_total = saldo + saldo_usado)
);

CREATE TABLE TARJETA (
    id                      SERIAL              PRIMARY KEY,
    tipo_tarjeta_id         INT                 NOT NULL REFERENCES TIPO_TARJETA,
    marca_id                INT                 NOT NULL REFERENCES MARCA,
    numero                  VARCHAR(20)         NOT NULL,
    mes_expiracion          INT                 NOT NULL CHECK (mes_expiracion BETWEEN 1 and 12),
    año_expiracion          INT                 NOT NULL CHECK (LENGTH(año_expiracion :: VARCHAR) = 4),
    cvv                     CHAR(3)             NOT NULL,
    estado                  BOOLEAN             NOT NULL,
    fecha_adquisicion       DATE                NOT NULL CHECK (fecha_adquisicion <= CURRENT_DATE) DEFAULT CURRENT_DATE,
    fecha_anulacion         DATE                NULL CHECK (AGE(fecha_anulacion, fecha_adquisicion) > '3 mons')
);

CREATE TABLE CUENTA_TARJETA (
    cuenta_id               INT                 NOT NULL REFERENCES CUENTA,
    tarjeta_id              INT                 NOT NULL REFERENCES TARJETA,
  
    CONSTRAINT pk_cuenta_tarjeta
        PRIMARY KEY (cuenta_id, tarjeta_id)
);

CREATE TABLE PRESTAMO (
    id                      SERIAL              PRIMARY KEY,
    empleado_id             INT                 NOT NULL REFERENCES EMPLEADO,
    tipo_prestamo_id        INT                 NOT NULL REFERENCES TIPO_PRESTAMO,
    cliente_id              INT                 NOT NULL REFERENCES CLIENTE,
    fecha_solicitud         DATE                NOT NULL CHECK (fecha_solicitud <= CURRENT_DATE),
    fecha_aprobacion        DATE                NULL CHECK (fecha_aprobacion >= fecha_solicitud),
    monto_total             MONEY               NOT NULL,
    tasa_mensual            FLOAT               NOT NULL,
    numero_cuotas           INT                 NOT NULL CHECK (numero_cuotas >= 1),
    estado                  CHAR(1)             NOT NULL
);

CREATE TABLE CUOTA (
    id                      SERIAL              PRIMARY KEY,
    prestamo_id             INT                 NOT NULL REFERENCES PRESTAMO,
    numero_cuota            INT                 NOT NULL,
    monto                   MONEY               NOT NULL,
    monto_mora              MONEY               NOT NULL,
    fecha_vencimiento       DATE                NOT NULL,
    fecha_pago              DATE                NULL CHECK (fecha_pago > fecha_vencimiento - 7),
    monto_pago              MONEY               NULL CHECK (monto_pago = monto + monto_mora)
);

CREATE TABLE MOVIMIENTO (
    id                      SERIAL              PRIMARY KEY,
    movimiento_asociado_id  INT                 NULL REFERENCES MOVIMIENTO,
    canal_id                INT                 NOT NULL REFERENCES CANAL,
    tipo_movimiento_id      INT                 NOT NULL REFERENCES TIPO_MOVIMIENTO,
    cuenta_id               INT                 NULL REFERENCES CUENTA,
    cuenta_destino_id       INT                 NULL REFERENCES CUENTA,
    cuota_id                INT                 NULL REFERENCES CUOTA,
    empleado_id             INT                 NULL REFERENCES EMPLEADO,
    servicio_brindado_id    INT                 NULL REFERENCES SERVICIO_BRINDADO,
    monto                   MONEY               NOT NULL,
    fecha                   DATE                NOT NULL CHECK (fecha <= CURRENT_DATE),
    cci                     VARCHAR(30)         NULL
);

CREATE TABLE MOVIMIENTO_FRECUENTE (
    id                      SERIAL              PRIMARY KEY,
    cliente_id              INT                 NOT NULL REFERENCES CLIENTE,
    tipo_movimiento_id      INT                 NOT NULL REFERENCES TIPO_MOVIMIENTO,
    cuenta_id               INT                 NOT NULL REFERENCES CUENTA,
    cuenta_destino_id       INT                 NULL REFERENCES CUENTA,
    cuota_id                INT                 NULL REFERENCES CUOTA,
    servicio_brindado_id    INT                 NULL REFERENCES SERVICIO_BRINDADO,
    monto                   MONEY               NULL 
);

alter table movimiento_frecuente ADD monto money null; 

------------------------------------------------------------ E J E M P L O S ---------------------------------------------------------------

--insertando en tabla canal
insert into canal (descripcion) values ('Agente'),
				       ('Banca Móvil'),
				       ('Banca por internet'),
				       ('Cajeros automáticos'),
				       ('Agencias');

--insert en la tabla tipo cliente
select * from tipo_cliente;

insert into tipo_cliente (descripcion) values ('Persona natural'),
					      ('Persona jurídica');

--insert dentro de tipo_moneda
select * from tipo_moneda;

insert into tipo_moneda (codigo,descripcion) values ('SOL','Sol'),
						    ('EUR','Euro'),
						    ('USD','Dólar'),
						    ('JPY','Yen'),
						    ('MXN','Peso Mexicano'),
						    ('ARS','Peso Argentino'),
						    ('GBP','Libra Esterlina'),
						    ('BRL','Real Brasileño'),
					       	    ('VES','Bolívar');

--insert en la tabla tipo tarjeta
select * from tipo_tarjeta
insert into tipo_tarjeta (descripcion) values ('Débito'),
					      ('Crédito');
					       
--insert en tipo_movimiento
select * from tipo_movimiento
insert into tipo_movimiento (descripcion) values ('Depósito'),
					         ('Retiro');
					       
--insert en ubigeo
select * from ubigeo
insert into ubigeo (id, departamento, provincia, distrito) values ('140101', ' Lambayeque', ' Chiclayo', 'Chiclayo'),
					       			      ('130101 ', 'La Libertad ', ' Trujillo ', 'Trujillo'),
					       			      ('150101', ' Lima', 'Lima ', 'Lima'),
					       			      (' 040101', 'Arequipa ', 'Arequipa ', 'Arequipa'),
					       			      (' 160101', 'Loreto ', 'Maynas ', 'Iquitos');

--insert en tipo_prestamo
select*from tipo_prestamo 
insert into tipo_prestamo (id, descripcion) values (DEFAULT , 'Corto plazo'),
                                                    (DEFAULT, 'Mediano plazo'),
                                                    (DEFAULT, 'Largo plazo'),
                                                    (DEFAULT, 'Consumo');
                                    
--insert en marca
select*from marca
insert into marca(id, descripcion) values (DEFAULT, 'Visa'),
                                            (DEFAUL, 'Dinners Club'),
                                            (DEFAULT, 'MasterCard'),
                                            (DEFAULT, 'American Express');

--insert en sucursal
select*from sucursal
insert into sucursal(id, ubigeo_id, descripcion, direccion, telefono) values (DEFAULT, '140101','Sucursar secundaria del Banco en Chiclayo', 'Avenida Banlta #345', '979815647'),
                                                (DEFAULT, '140101','Sucursal principal del Banco en Chiclayo', 'Salavaery #345', '979810047'),
                                                (DEFAULT, '150101','Sucursal principal del Banco', 'Javier Prado #1345', '972851747');

--insert into empleados
select * from empleados
insert into empleado (id, numero_documento, nombres, apellido_paterno, apellido_materno, fecha_nacimiento, direccion, correo, telefono, estado) values 
                    (default, '69563233', 'Ramiro', 'Sanchez', 'Tuesta', '1992/05/15', 'Av. Bolognesi 359', 'rsanchez@gmail.com','958769569',true),
                    (default, '78964509', 'Camila', 'Requejo', 'Montenegro', '1990/02/15', 'Prolong. Bolognesi 709', 'ecieza9@gmail.com', '985864891', true),
                    (default, '78964508', 'Eduardo', 'Cieza', 'Robles', '1993/06/19', 'Luis Gonzales 500', 'ecieza8@gmail.com', '985864892', true),
                    (default, '78964507', 'Rocío', 'Melendrez', 'Robles', '1990/12/20', 'Av. Bolognesi 710', 'ecieza7@gmail.com', '985864893', true),
                    (default, '78964506', 'Eduardo', 'Cieza', 'Robles', '1995/01/23', 'Brr. San Eduardo 232', 'ecieza6@gmail.com', '985864894', true),
                    (default, '78964503', 'Eduardo', 'Balta', 'Robles', '1990/03/22', 'Av. Balta 701', 'ecieza5@gmail.com', '985864895', false),
                    (default, '78964501', 'Paola', 'Bolognesi', 'Lapoint', '1995/06/17', 'Av. Bolognesi 623', 'ecieza4@gmail.com', '985864896', true);

--insert en cliente
select*from cliente
insert into cliente(id, tipo_cliente_id, numero_documento, nombres, apellido_paterno, apellido_materno, fecha_nacimiento, direccion, correo,
                    telefono, estado) values
                    (DEFAULT, '1', '76453287', 'Andres Sergio', 'Roldan', 'Cabrera', '01/07/1999', 'Las Brisas #232', 
                    'andresitops@gmail.com', '988237673', true),
                    (DEFAULT, '2', '11233445562', 'TELEFONOS SARA', NULL, NULL, '04/02/16', 'Los Laaures #344', 'telefono@gmail.com',
                    '987654321', 'true'),
                    (DEFAULT, '1', '76454587', 'Pedro Sergio', 'Benel', 'Cabrera', '01/03/1997', 'Las Castros #232', 
                    'teamo@gmail.com', '988197673', TRUE),
                    (DEFAULT, '1', '75453287', 'Camilo Fernando', 'Castañeda', 'Cacho', '19/11/1999', 'Naranjos #932', 
                    'playboy@gmail.com', '988528673', true),
                    (DEFAULT, '1', '76111287', 'Luis Javier', 'Ica', 'Bances', '29/01/1994', 'Pedro Ruiz #232', 
                    'javilu@gmail.com', '981107673', true),
                    (DEFAULT, '2', '17645328701', 'Agua Perú', NULL, NULL, '11/10/1979', 'Banlta #1232', 
                    'aguita@gmail.com', '988007173', true);


--insert into servicio
insert into servicio (id, cliente_id, descripcion) values
                    (default, 1, 'Agua'),
                    (default, 2, 'Luz'),
                    (default, 3, 'Movistar Móvil Postpago'),
                    (default, 3, 'Movistar Fijo'), 
                    (default, 4, 'Entel Móvil Postpago'),
                    (default, 4, 'Entel Fijo');

--insert into servicio_brindado
insert into servicio_brindado (id, servicio_id, usuario, costo, fecha_facturacion, fecha_pago) values 
                    (default, 1, 'WER5634', 25.3, '2019/04/31', '2019/05/03'), 
                    (default, 1, 'TUR1235', 25.3, '2019/04/31', '2019/05/05'),
                    (default, 2, 'TUR1235', 25.3, '2019/04/31', '2019/0/05'),
                    (default, 3, '9586987856', 50.69, '2019/04/20','2019/05/01' ),
                    (default, 3, '9586987856', 50.69, '2019/04/20','2019/05/02' ),
                    (default, 3, '9586987856', 50.69, '2019/04/20','2019/05/10' ),
                    (default, 4, '562310', 75.5, '2019/04/31', '2019/05/02'),
                    (default, 4, '562345', 75.5, '2019/04/31', '2019/05/03');


--insert en cuenta
select*from cuenta 
insert into cuenta(id, cliente_id, tipo_modena_id, sucursal_id, numero, estado, fecha_creacion, fecha_anulacion, cci, saldo, saldo_usado, 
                    saldo_total) VALUES
                    (DEFAULT, 1, 1, 2, '7683113097540', true, CURRENT_DATE, null, '003 768 013113097540', '0', null, null),
                    (DEFAULT, 1, 3, 2, '7683113097444', true, CURRENT_DATE, null, '003 982 013116547540', '0', null, null),
                    (DEFAULT, 2, 1, 2, '8583113097004', true, CURRENT_DATE, null, '003 102 765416547540', '0', null, null),
                    (DEFAULT, 3, 1, 3, '8583003097004', true, CURRENT_DATE, null, '003 652 123416547540', '0', null, null),
                    (DEFAULT, 6, 2, 1, '9983003097329', true, CURRENT_DATE, null, '003 992 993416547567', '0', null, null);

--insert en tarjeta
select*from tarjeta
insert into tarjeta(id, tipo_tarjeta_id, marca_id, numero, mes_expiracion, año_expiracion, cvv, estado, fecha_adquisicion, fecha_anulacion)
                    VALUES
                    (DEFAULT, 1, 1, '4213 5500 5873 2387', 'enero', '2024', '986', TRUE, CURRENT_DATE, null),
                    (DEFAULT, 1, 1, '4213 2980 0967 2347', 'febrero', '2023', '956', false, '02/02/2018', CURRENT_DATE),
                    (DEFAULT, 2, 2, '4213 9876 1237 2347', 'marzo', '2023', '856', false, '02/02/2018', CURRENT_DATE),
                    (DEFAULT, 2, 4, '4213 7834 1237 1234', 'diciembre', '2024', '324', true, CURRENT_DATE, NULL),
                    (DEFAULT, 1, 3, '4213 7834 1237 1234', 'octubre', '2024', '774', true, CURRENT_DATE, NULL);

--insert en cuenta_tarjeta
select * from cuenta_tarjeta
insert into cuenta_tarjeta(cuenta_id, tarjeta_id) VALUES (1, 1), 
                                                        (5,4),
                                                        (4,2),
                                                        (4,5);

--insert en prestamo
insert into prestamo (id, empleado_id, tipo_prestamo_id, cliente_id, fecha_solicitud, fecha_aprobacion, monto_total,tasa_mensual,
                    numero_cuota, estado) values 
                    (default, 1, 1, 1, '2019/02/20', '2019/03/03', 1000, 0.05, 10, 'N'),
                    (default, 2, 1, 2, '2019/02/21', '2019/03/04', 1500, 0.05, 5, 'N'),
                    (default, 3, 2, 3, '2019/02/22', '2019/03/15', 2000, 0.05, 20, 'N');
                    (default, 1, 'WER5634', 25.3, '2019/04/31', '2019/05/03'), 
                    (default, 1, 'TUR1235', 25.3, '2019/04/31', '2019/05/05'),
                    (default, 2, 'TUR1235', 25.3, '2019/04/31', '2019/0/05'),
                    (default, 3, '9586987856', 50.69, '2019/04/20','2019/05/01' ),
                    (default, 3, '9586987856', 50.69, '2019/04/20','2019/05/02' ),
                    (default, 3, '9586987856', 50.69, '2019/04/20','2019/05/10' ),
                    (default, 4, '562310', 75.5, '2019/04/31', '2019/05/02'),
                    (default, 4, '562345', 75.5, '2019/04/31', '2019/05/03');

--insert cuota
select*from cuota 
insert into cuota(id, prestamo_id, numero_cuota, monto, monto_mora, fecha_vencimiento, fecha_pago, monto_pago) 
            values 
            (DEFAULT, 1, 1, 150, 0, '03/04/2019', '01/04/2019', 150 );
            (DEFAULT, 1, 2, 150, 0, '03/05/2019', '03/05/2019', 150 );
            (DEFAULT, 1, 3, 150, 52.5, '03/06/2019', '10/06/2019', 202.5 );
            (DEFAULT, 1, 4, 150, 0, '03/07/2019', '01/07/2019', 150 );
            (DEFAULT, 1, 5, 150, 0, '03/08/2019', null , NULL );
            (DEFAULT, 1, 6, 150, 0, '03/09/2019', null , NULL );
            (DEFAULT, 1, 7, 150, 0, '03/10/2019', null , NULL );
            (DEFAULT, 1, 8, 150, 0, '03/11/2019', null , NULL );
            (DEFAULT, 1, 9, 150, 0, '03/12/2019', null , NULL );
            (DEFAULT, 1, 10, 150, 0, '03/01/2020',null , NULL );
            (DEFAULT, 2, 1, 375, 0, '23/05/2019', '20/05/2019' , 375 );
            (DEFAULT, 2, 2, 375, 0, '23/06/2019', '23/06/2019' , 375 );
            (DEFAULT, 2, 3, 375, 0, '23/07/2019', null, NULL );
            (DEFAULT, 2, 4, 375, 0, '23/08/2019', null, NULL );
            (DEFAULT, 2, 5, 375, 0, '23/09/2019', null, NULL);



--insert en movimiento
select*from movimiento
insert into movimiento values();

--insert movimiento_frecuente
select*from MOVIMIENTO_FRECUENTE
insert into movimiento_frecuente() values ();




----------------------------------- C O N S U L T A S -----------------------------------------------------------------------                                                        
--consultar prestamos por cliente
create or replace function fn_consultar_prestamos_por_cliente(dni varchar) 
returns table( des varchar, f_solicitud date, f_aprobacion date, monto money, tasa float, cuotas int, est char ) as
$$
Declare
	id int = (select c.id from cliente c where c.numero_documento=dni);
Begin
	return query
	select tp.descripcion, p.fecha_solicitud, p.fecha_aprobacion, p.monto_total,  p.tasa_mensual, p.numero_cuotas, p.estado
	from prestamo p 
	inner join tipo_prestamo tp on p.tipo_prestamo_id=tp.id 
	where p.cliente_id=id;
end;
$$ language 'plpgsql'

--consultar movimientos por canal
create or replace function fn_consultar_movimientos_por_canal ( ident int ) 
returns table ( descrip varchar, numero varchar, monto money, fecha date ) as 
$$
Declare
Begin
	return query
	select tp.descripcion, c.numero, m.monto, m.fecha from movimiento m 
	inner join tipo_movimiento tp on m.tipo_movimiento_id=tp.id
	inner join cuenta c on m.cuenta_id=c.id
	where m.canal_id=ident;
end;
$$ language 'plpgsql'

--consultar cuenta por sucursal
create or replace function fn_consultar_cuenta_por_sucursal( cod int ) 
returns table ( nombre text, numero varchar, descrip_tm varchar, descrip_sucursal varchar, descrip_dpto varchar, descrip_prov varchar ) 
as
$$
Declare	
Begin
	return query
	select c.nombres ||' '||c.apellido_paterno||' '||c.apellido_materno as nombre, ct.numero, tm.descripcion, s.descripcion,
	dpto.descripcion , p.descripcion
	from cuenta ct
	inner join cliente c on ct.cliente_id=c.id
	inner join tipo_moneda tm on ct.tipo_moneda_id=tm.id
	inner join sucursal s on ct.sucursal_id=s.id
	inner join ubigeo u on s.ubigeo_id=u.id
	inner join departamento dpto on u.departamento_id=dpto.id
	inner join provincia p on u.provincia_id=p.id
	where s.id=cod;
	
end;
$$ language 'plpgsql'

--consultar cuenta por moneda
create or replace function fn_consultar_cuenta_por_moneda_cliente( cod varchar, dni varchar ) 
returns table ( nom text, numero_cuenta varchar, descrip varchar ) as
$$
Declare
	
Begin
	return query
	select c.nombres ||' '||c.apellido_paterno||' '||c.apellido_materno as nombre, ct.numero, tm.descripcion from cuenta ct
	inner join cliente c on ct.cliente_id=c.id
	inner join tipo_moneda tm on ct.tipo_moneda_id=tm.id
	where tm.codigo=cod and c.numero_documento=dni;
	
end;
$$ language 'plpgsql'

--consultar movimientos frecuentes
create or replace function fn_consultar_movimientos_frecuentes( dni varchar ) 
returns table (nom text, num VARCHAR ) as
$$
Declare
	id int = (select id from cliente where numero_documento=dni);
Begin
	return query
	select c.nombres ||' '||c.apellido_paterno||' '||c.apellido_materno as nombre, cnt.numero from movimiento_frecuente mf
	inner join cliente c on mf.cliente_id=c.id
	inner join tipo_movimiento tm on mf.tipo_movimiento_id=tm.id
	inner join cuenta cnt on mf.cuenta_id=cnt.id
	where c.id=id;
	
end;
$$ language 'plpgsql'
select * from fn_consultar_movimientos_frecuentes( ' ' ) 



--conocer mes 
Create or replace function fn_nombre_mes(mes_num int) returns character varying as
$$
Declare
nom_mes character varying;
Begin
	case mes_num
		when 1 then nom_mes='Enero';
		when 2 then nom_mes='Febrero';
		when 3 then nom_mes='Marzo';
		when 4 then nom_mes='Abril';
		when 5 then nom_mes='Mayo';
		when 6 then nom_mes='Junio';
		when 7 then nom_mes='Julio';
		when 8 then nom_mes='Agosto';
		when 9 then nom_mes='Setiembre';
		when 10 then nom_mes='Octubre';
		when 11 then nom_mes='Noviembre';
		when 12 then nom_mes='Diciembre';
		else nom_mes='Numero inválido';
	end case;
	return nom_mes;
end;
$$ language 'plpgsql';

--consultar tarjeta por tipo y por marca juntos
create or replace function fn_consultar_cuenta_por_moneda_cliente( cod int, marca_nombre varchar ) 
returns table ( numero varchar, mes_exp varchar , año_exp int, cvv char(3), estado boolean, f_adqui date ) as
$$
Declare
	id_marca int = (select id from marca where descripcion=marca_nombre);
Begin
	return query
	select t.numero, (select fn_nombre_mes(t.mes_expiracion)) as mes_venc , t.año_expiracion, t.cvv, t.estado, t.fecha_adquisicion from tarjeta t 
	inner join tipo_tarjeta tt on t.tipo_tarjeta_id=tt.id
	inner join marca m on t.marca_id=m.id
	where m.id=id_marca and tt.id=cod;
	
end;
$$ language 'plpgsql'

--consultar movimiento por tipo, por canal
create or replace function fn_consultar_movimientos_por_canal_tipo_movimiento ( tipo int, canal int ) 
returns table ( numero_cuenta varchar, monto money, fecha date ) as 
$$
Declare
Begin
	return query
	select c.numero, m.monto, m.fecha from movimiento m
	inner join tipo_movimiento tp on m.tipo_movimiento_id=tp.id
	inner join cuenta c on m.cuenta_id=c.id
	inner join canal cn on m.canal_id=cn.id
	where m.canal_id=canal and tp.id=tipo;
end;
$$ language 'plpgsql'
                                                        
-- Cada vez que se registre un prestamo se genere su programacion de cuotas
create or replace function tg_fn_generar_cronograma() returns trigger as
$$
DECLARE
    i int = 1;
    monto_por_cuota int;
    fecha_vencimiento date = new.fecha_aprobacion;
BEGIN
    monto_por_cuota = new.monto_total / new.numero_cuotas + new.monto_total * new.tasa_mensual;
    FOR i in 1..new.numero_cuotas loop
        fecha_vencimiento = fecha_vencimiento + interval '1 mon';
        insert into cuota values (default, new.id, i, monto, 0, fecha_vencimiento, null, null);
    end loop;
    return new;
END;
$$
LANGUAGE 'plpgsql'

create TRIGGER tg_generar_cronograma after insert on prestamo
for each row EXECUTE PROCEDURE tg_fn_generar_cronograma();


--Cada vez que se registre un nuevo movimiento por parte del cliente, se debe disminuir su 
--saldo en su cuenta seleccionada (si este paga con una de sus cuentas).
create or replace FUNCTION movimiento_saldo_menos() returns TRIGGER as
$$
    DECLARE
        saldo money;
    BEGIN
        select saldo into 
        IF (new.cuenta_id is not null) THEN

        end if;
    end;
$$
language 'plpgsql' 








