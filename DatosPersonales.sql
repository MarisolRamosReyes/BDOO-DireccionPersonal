-- Crear un tipo de objeto para representar direcciones
CREATE TYPE TipoDireccion AS OBJECT (
    calle VARCHAR2(100),
    ciudad VARCHAR2(50),
    estado VARCHAR2(50),
    codigoPostal VARCHAR2(10)
);
/

-- Crear un tipo de objeto para representar a las personas con dirección
CREATE TYPE TipoPersona AS OBJECT (
    nombre VARCHAR2(50),
    apellido VARCHAR2(50),
    fechaNacimiento DATE,
    direccion TipoDireccion,
    MEMBER FUNCTION CalcularEdad RETURN NUMBER
)NOT FINAL;
/

-- Cuerpo (body) del tipo de objeto TipoPersona con un método para calcular la edad precisa
CREATE TYPE BODY TipoPersona AS
  -- Método para calcular la edad precisa
  MEMBER FUNCTION CalcularEdad RETURN NUMBER IS
    edad NUMBER;
    fecha_actual DATE := SYSDATE; -- Obtener la fecha actual

  BEGIN
    -- Calcular la diferencia de años entre la fecha de nacimiento y la fecha actual
    edad := EXTRACT(YEAR FROM fecha_actual) - EXTRACT(YEAR FROM self.fechaNacimiento);

    -- Ajustar la edad si aún no ha pasado el cumpleaños
    IF EXTRACT(MONTH FROM fecha_actual) < EXTRACT(MONTH FROM self.fechaNacimiento)
       OR (EXTRACT(MONTH FROM fecha_actual) = EXTRACT(MONTH FROM self.fechaNacimiento)
           AND EXTRACT(DAY FROM fecha_actual) < EXTRACT(DAY FROM self.fechaNacimiento)) THEN
      edad := edad - 1; -- Restar 1 año si no ha pasado el cumpleaños
    END IF;

    -- Devolver la edad calculada
    RETURN edad;
  END CalcularEdad;
END;
/

-- Crear un tipo de objeto para representar a los empleados que hereda de TipoPersona
CREATE TYPE TipoEmpleado UNDER TipoPersona (
    empleado_id NUMBER,
    salario NUMBER
);

-- Crear un tipo de objeto para representar a los clientes que hereda de TipoPersona
CREATE TYPE TipoCliente UNDER TipoPersona (
    cliente_id NUMBER,
    fechaRegistro DATE
);
/

-- Crear una tabla de objetos para almacenar empleados
CREATE TABLE Empleados OF TipoEmpleado;
CREATE TABLE Clientes OF TipoCliente;
/

-- Insertar datos de un empleado con dirección en la tabla de objetos Empleados
INSERT INTO Empleados VALUES (
    TipoEmpleado('Marisol', 'Ramos', TO_DATE('2002-05-28', 'YYYY-MM-DD'), TipoDireccion('Serafin Cantu', 'Castaos', 'Coahuila', '25870'), 101, 50000)
);

INSERT INTO Clientes VALUES (
    TipoCliente('Evelin', 'Barrera', TO_DATE('2002-01-09', 'YYYY-MM-DD'), TipoDireccion('Salinas', 'Monclova', 'Coahuila', '25790'), 101, TO_DATE('2023-09-11', 'YYYY-MM-DD'))
);

INSERT INTO Empleados VALUES (
    TipoEmpleado('Axel', 'Salazar', TO_DATE('2000-08-15', 'YYYY-MM-DD'), TipoDireccion('Fuentes', 'Monclova', 'Coahuila', '25790'), 102, 50000)
);
/

UPDATE Empleados e
SET e.direccion.ciudad = 'Castanios'
WHERE e.empleado_id = 101;

DELETE Empleados WHERE empleado_id = 102;

SELECT * FROM EMPLEADOS;
SELECT * FROM Clientes;