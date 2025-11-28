# EXPLICACIÓN DETALLADA DEL CÓDIGO - EXAMEN FINAL
## Base de Datos: DF_Eval_Junior - Pipelines de Ingestión

---

## 🎯 CONCEPTOS CLAVE PARA RESPONDER PREGUNTAS

### 1. SCOPE_IDENTITY() vs @@IDENTITY vs IDENT_CURRENT()

**SCOPE_IDENTITY()** (el que usamos):
- Devuelve el último valor IDENTITY insertado **en el scope actual**
- **Scope = sesión + procedimiento/función actual**
- NO se ve afectado por triggers en otras tablas
- **ES LA OPCIÓN MÁS SEGURA** para procedimientos almacenados

**@@IDENTITY**:
- Devuelve el último valor IDENTITY insertado en la **sesión actual**
- **Incluye cualquier tabla** aunque sea en un trigger diferente
- **PROBLEMA**: Si un trigger inserta en otra tabla con IDENTITY, @@IDENTITY devuelve ese valor, no el que necesitas

**IDENT_CURRENT('NombreTabla')**:
- Devuelve el último IDENTITY de una tabla específica
- **Funciona en cualquier sesión**, no solo la actual
- Puede devolver valores insertados por otros usuarios

**Ejemplo trampa:**
```sql
-- Si dentro del trigger de EjecucionPipeline se inserta en AlertaEjecucion
-- que también tiene IDENTITY:
INSERT INTO EjecucionPipeline (...) VALUES (...);
-- En este momento se dispara el trigger y se inserta en AlertaEjecucion

SELECT @@IDENTITY; -- Devuelve el ID de AlertaEjecucion (MALO!)
SELECT SCOPE_IDENTITY(); -- Devuelve el ID de EjecucionPipeline (BIEN!)
```

---

### 2. PARÁMETROS OUTPUT EN PROCEDIMIENTOS

**Sintaxis correcta:**
```sql
CREATE PROCEDURE sp_AltaEjecucionPipeline
    @idPipeline INT,
    @idEjecucionGenerado INT OUTPUT  -- La palabra OUTPUT es clave
AS
BEGIN
    INSERT INTO EjecucionPipeline (...) VALUES (...);
    SET @idEjecucionGenerado = SCOPE_IDENTITY();  -- Asignar valor al parámetro OUTPUT
END;
```

**Llamada correcta:**
```sql
DECLARE @miID INT;
EXEC sp_AltaEjecucionPipeline
    @idPipeline = 10,
    ...,
    @idEjecucionGenerado = @miID OUTPUT;  -- También lleva OUTPUT al llamar

PRINT @miID;  -- Ahora @miID tiene el valor
```

**⚠️ ERRORES COMUNES EN PREGUNTAS:**
- "¿Se puede omitir OUTPUT al llamar el procedimiento?" **NO** - Es obligatorio en ambos lados
- "¿Puede tener múltiples parámetros OUTPUT?" **SÍ** - Todos los que necesites
- "¿El parámetro OUTPUT puede ser NULL?" **SÍ** - Si no se asigna dentro del SP

---

### 3. TRY-CATCH Y MANEJO DE ERRORES

**Estructura completa:**
```sql
BEGIN TRY
    -- Código que puede fallar
    INSERT INTO tabla (...) VALUES (...);
END TRY
BEGIN CATCH
    -- Capturar información del error
    DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
    DECLARE @ErrorNumber INT = ERROR_NUMBER();
    DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
    DECLARE @ErrorState INT = ERROR_STATE();
    DECLARE @ErrorLine INT = ERROR_LINE();
    DECLARE @ErrorProcedure NVARCHAR(200) = ERROR_PROCEDURE();

    -- Relanzar el error
    THROW;  -- Relanza el error original
END CATCH
```

**THROW vs RAISERROR:**
- **THROW** (moderno, recomendado):
  - Sintaxis simple: `THROW 50001, 'Mensaje', 1;`
  - Relanza automáticamente: `THROW;`
  - Siempre detiene la ejecución

- **RAISERROR** (antiguo):
  - Sintaxis: `RAISERROR('Mensaje', 16, 1);`
  - Necesita `WITH LOG` para loguear
  - Puede no detener la ejecución según severidad

**⚠️ PREGUNTAS TRAMPOSAS:**
- "¿TRY-CATCH captura todos los errores?" **NO** - No captura errores de compilación ni errores de severidad 20+
- "¿Se puede tener un TRY-CATCH dentro de otro?" **SÍ** - Se pueden anidar
- "¿THROW sin parámetros funciona fuera del CATCH?" **NO** - Solo dentro de CATCH

---

### 4. TRIGGERS AFTER INSERT Y TABLA INSERTED

**Conceptos fundamentales:**

**Tabla lógica INSERTED:**
- Es una **tabla temporal en memoria**
- Contiene **todas las filas** que se insertaron
- Existe solo durante la ejecución del trigger
- Tiene la **misma estructura** que la tabla base

**¿Cuántas veces se ejecuta el trigger?**
- **UNA SOLA VEZ por sentencia INSERT**, no por fila
- Si insertas 100 filas: trigger se ejecuta 1 vez, inserted tiene 100 filas

**Ejemplos:**
```sql
-- Inserción simple: inserted tiene 1 fila
INSERT INTO EjecucionPipeline VALUES (10, '2025-01-01', ...);

-- Inserción múltiple: inserted tiene 3 filas, trigger se ejecuta 1 vez
INSERT INTO EjecucionPipeline VALUES
    (10, '2025-01-01', ...),
    (10, '2025-01-02', ...),
    (10, '2025-01-03', ...);

-- INSERT SELECT: inserted tiene N filas, trigger se ejecuta 1 vez
INSERT INTO EjecucionPipeline
SELECT * FROM OtraTabla WHERE condicion;
```

**⚠️ ERROR MORTAL: Usar CURSORES en triggers**
```sql
-- ❌ INCORRECTO (pero común en código antiguo)
DECLARE cur CURSOR FOR SELECT * FROM inserted;
OPEN cur;
FETCH NEXT FROM cur INTO @variables;
WHILE @@FETCH_STATUS = 0
BEGIN
    -- Procesar fila por fila
    FETCH NEXT FROM cur;
END

-- ✅ CORRECTO (basado en conjuntos)
INSERT INTO AlertaEjecucion (idEjecucion, mensaje, fechaHora)
SELECT
    i.idEjecucion,
    'Mensaje',
    GETDATE()
FROM inserted i
WHERE condicion;
```

**Por qué NO usar cursores:**
1. **Muy lento** - Procesa fila por fila en lugar de todo junto
2. **Más código** - Más complejo de mantener
3. **Problemas de concurrencia** - Bloqueos innecesarios
4. **Violación de paradigma relacional** - SQL está diseñado para conjuntos

---

### 5. ROLLBACK EN TRIGGERS

**Comportamiento crítico:**
```sql
CREATE TRIGGER trg_Ejemplo
ON Tabla
AFTER INSERT
AS
BEGIN
    IF (condicion_mala)
    BEGIN
        ROLLBACK TRANSACTION;  -- Revierte TODO
        RAISERROR('Error', 16, 1);
        RETURN;
    END
END;
```

**¿Qué revierte ROLLBACK en un trigger?**
1. ❌ **El INSERT que disparó el trigger** (las filas de inserted no se insertan)
2. ❌ **Cualquier INSERT/UPDATE/DELETE previo en inserted** antes del ROLLBACK
3. ❌ **Cambios en otras tablas** hechos por el trigger (ej: AlertaEjecucion)

**⚠️ IMPORTANTE:**
```sql
-- Si el trigger hace esto:
INSERT INTO AlertaEjecucion (...) VALUES (...);  -- Paso 1
ROLLBACK TRANSACTION;  -- Paso 2

-- ¿Queda registrada la alerta?
-- DEPENDE de cuándo se hizo el INSERT respecto al ROLLBACK
```

**En nuestro código:**
```sql
-- ✅ Esto SÍ funciona porque insertamos alertas ANTES del ROLLBACK
INSERT INTO AlertaEjecucion (...)
SELECT ... FROM inserted WHERE porcentaje < 80;  -- Se inserta

IF EXISTS (SELECT ... WHERE porcentaje < 50)
BEGIN
    ROLLBACK TRANSACTION;  -- Solo revierte EjecucionPipeline, NO AlertaEjecucion
    -- porque AlertaEjecucion ya fue COMMITEADA implícitamente
END
```

**PERO CUIDADO:**
En realidad, en un trigger AFTER INSERT, **TODO está en la misma transacción**. El ROLLBACK revierte:
- El INSERT original en EjecucionPipeline
- **TAMBIÉN las alertas insertadas en AlertaEjecucion**

**Para que las alertas persistan, necesitarías:**
```sql
BEGIN TRANSACTION;
    INSERT INTO AlertaEjecucion (...);
COMMIT TRANSACTION;  -- Commit explícito antes del ROLLBACK

ROLLBACK TRANSACTION;  -- Este solo revierte lo que no se commitió
```

Pero en triggers AFTER, esto es **complicado y puede causar problemas**. Por eso, si realmente quieres alertas persistentes incluso con ROLLBACK, deberías:
1. Usar un trigger INSTEAD OF (en lugar de AFTER)
2. O registrar en una tabla externa (linked server, archivo, log)
3. O usar Service Broker / Extended Events

---

### 6. CÁLCULO DE PORCENTAJES Y DIVISIÓN POR CERO

**El problema:**
```sql
-- ❌ Esto falla si filasLeidas = 0
SELECT (filasCargadas * 100) / filasLeidas;  -- Error: Divide by zero

-- ❌ Esto da 0 para todo porque es división entera
SELECT (filasCargadas * 100) / filasLeidas;  -- Si filasLeidas = 100 y filasCargadas = 50, da 50 no 50.0

-- ✅ Correcto: usar CASE y conversión a decimal
SELECT
    CASE
        WHEN filasLeidas = 0 THEN 0
        ELSE (filasCargadas * 100.0) / filasLeidas  -- El .0 convierte a decimal
    END AS porcentajeExito
```

**Detalles importantes:**
- `100.0` en lugar de `100` → fuerza división decimal
- `CASE WHEN ... THEN ... END` → evita división por cero
- Sin el `.0`, SQL Server hace división entera: `50 / 100 = 0` (no `0.5`)

**⚠️ PREGUNTAS TÍPICAS:**
- "¿Por qué multiplicar por 100.0 y no por 100?" → Para obtener decimales
- "¿Se puede usar NULLIF en lugar de CASE?" → Sí: `(filasCargadas * 100.0) / NULLIF(filasLeidas, 0)` pero devuelve NULL, no 0
- "¿El orden importa en la expresión?" → Sí: `100.0 * filasCargadas / filasLeidas` funciona igual

---

### 7. OPERACIONES BASADAS EN CONJUNTOS (SET-BASED)

**Comparación:**

**❌ Enfoque procedural (fila por fila):**
```sql
DECLARE cur CURSOR FOR SELECT * FROM inserted;
OPEN cur;
FETCH NEXT FROM cur INTO @id, @leidas, @cargadas;

WHILE @@FETCH_STATUS = 0
BEGIN
    DECLARE @porcentaje DECIMAL(5,2);
    SET @porcentaje = (@cargadas * 100.0) / @leidas;

    IF @porcentaje < 80
    BEGIN
        INSERT INTO AlertaEjecucion VALUES (@id, 'Bajo', GETDATE());
    END

    FETCH NEXT FROM cur INTO @id, @leidas, @cargadas;
END

CLOSE cur;
DEALLOCATE cur;
```

**✅ Enfoque set-based (todo junto):**
```sql
INSERT INTO AlertaEjecucion (idEjecucion, mensaje, fechaHora)
SELECT
    i.idEjecucion,
    'Ejecución con porcentaje de éxito bajo',
    GETDATE()
FROM inserted i
WHERE (i.filasCargadas * 100.0) / NULLIF(i.filasLeidas, 0) < 80;
```

**Ventajas del enfoque set-based:**
1. **10-100x más rápido** - Procesamiento paralelo
2. **Menos código** - 4 líneas vs 20 líneas
3. **Menos errores** - No hay que gestionar cursores
4. **Escalable** - Funciona igual con 1 fila que con 1 millón

---

### 8. EXISTS VS COUNT VS IN

**Para verificar existencia:**

```sql
-- ✅ MEJOR: EXISTS (se detiene en la primera coincidencia)
IF EXISTS (SELECT 1 FROM Pipeline WHERE idPipeline = @idPipeline)
BEGIN
    -- El pipeline existe
END

-- ⚠️ MENOS EFICIENTE: COUNT (cuenta todas las filas)
IF (SELECT COUNT(*) FROM Pipeline WHERE idPipeline = @idPipeline) > 0
BEGIN
    -- El pipeline existe
END

-- ❌ MALO: Traer datos innecesarios
DECLARE @existe INT;
SELECT @existe = idPipeline FROM Pipeline WHERE idPipeline = @idPipeline;
IF @existe IS NOT NULL
BEGIN
    -- El pipeline existe
END
```

**Por qué EXISTS es mejor:**
1. Se detiene al encontrar la primera fila (no sigue buscando)
2. No construye un resultado completo en memoria
3. El optimizador puede usar índices más eficientemente

**IN vs EXISTS:**
```sql
-- Estos son equivalentes, pero EXISTS es más claro
SELECT * FROM A WHERE id IN (SELECT id FROM B WHERE condicion);
SELECT * FROM A WHERE EXISTS (SELECT 1 FROM B WHERE B.id = A.id AND condicion);

-- EXISTS es mejor cuando hay correlación (WHERE B.id = A.id)
-- IN es mejor para listas pequeñas constantes: WHERE id IN (1, 2, 3)
```

---

### 9. STRING_AGG Y AGREGACIÓN DE MENSAJES

**En nuestro código:**
```sql
SELECT @mensajeError = STRING_AGG(
    'ID Ejecución: ' + CAST(idEjecucion AS VARCHAR(10)) +
    ' - Porcentaje: ' + CAST(porcentaje AS VARCHAR(10)) + '%',
    '; '  -- Separador
)
FROM inserted
WHERE porcentaje < 50;
```

**STRING_AGG (SQL Server 2017+):**
- Concatena valores de múltiples filas en un solo string
- Segundo parámetro: separador
- **Muy útil para mensajes de error que incluyen múltiples registros**

**Alternativas en versiones antiguas:**
```sql
-- SQL Server 2016 y anteriores: FOR XML PATH
SELECT @mensajeError = STUFF((
    SELECT '; ' + 'ID: ' + CAST(idEjecucion AS VARCHAR(10))
    FROM inserted
    WHERE porcentaje < 50
    FOR XML PATH('')
), 1, 2, '');  -- STUFF elimina los primeros 2 caracteres ('; ')
```

---

### 10. TRANSACCIONES IMPLÍCITAS VS EXPLÍCITAS

**Transacción implícita:**
```sql
-- SQL Server automáticamente inicia una transacción
INSERT INTO Tabla VALUES (...);
-- Si no hay error, se hace COMMIT automático
```

**Transacción explícita:**
```sql
BEGIN TRANSACTION;
    INSERT INTO Tabla1 VALUES (...);
    INSERT INTO Tabla2 VALUES (...);
COMMIT TRANSACTION;  -- O ROLLBACK si hay error
```

**En triggers:**
- El trigger se ejecuta **dentro de la transacción** del INSERT que lo disparó
- `ROLLBACK TRANSACTION` en el trigger revierte TODO, incluido el INSERT original
- **No puedes hacer COMMIT en un trigger** (error: "Cannot use COMMIT within a trigger")

**⚠️ PREGUNTA TRAMPA:**
"¿Puedo hacer BEGIN TRANSACTION en un trigger?"
- **Técnicamente sí**, pero crea una transacción anidada
- Genera complicaciones con @@TRANCOUNT
- **No es recomendado** - Usa la transacción existente

---

## 📊 CASOS DE PRUEBA Y COMPORTAMIENTO ESPERADO

### Caso 1: Ejecución exitosa (porcentaje > 80%)
```sql
filasLeidas = 10000
filasCargadas = 9500
porcentaje = (9500 * 100.0) / 10000 = 95%
```
**Resultado:**
- ✅ Se inserta en EjecucionPipeline
- ❌ NO se genera alerta
- ✅ Procedimiento devuelve ID exitosamente

---

### Caso 2: Ejecución con alerta (50% <= porcentaje < 80%)
```sql
filasLeidas = 10000
filasCargadas = 7000
porcentaje = (7000 * 100.0) / 10000 = 70%
```
**Resultado:**
- ✅ Se inserta en EjecucionPipeline
- ✅ Se genera alerta en AlertaEjecucion
- ✅ Procedimiento devuelve ID exitosamente
- ❌ NO se hace ROLLBACK

**Flujo:**
1. Procedimiento inserta en EjecucionPipeline
2. Trigger se dispara
3. Trigger calcula: 70% < 80 → TRUE
4. Trigger inserta alerta: "Ejecución con porcentaje de éxito bajo: 70%"
5. Trigger verifica: 70% < 50 → FALSE
6. Trigger termina sin ROLLBACK
7. Procedimiento obtiene SCOPE_IDENTITY() exitosamente

---

### Caso 3: Ejecución crítica (porcentaje < 50%)
```sql
filasLeidas = 10000
filasCargadas = 3000
porcentaje = (3000 * 100.0) / 10000 = 30%
```
**Resultado:**
- ❌ NO se inserta en EjecucionPipeline (ROLLBACK)
- ⚠️ Se intenta insertar alerta, pero el ROLLBACK la revierte
- ❌ Procedimiento lanza error al cliente
- ❌ @idEjecucionGenerado queda sin valor (o NULL)

**Flujo:**
1. Procedimiento inserta en EjecucionPipeline (temporalmente)
2. Trigger se dispara
3. Trigger calcula: 30% < 80 → TRUE
4. Trigger inserta alerta (temporalmente)
5. Trigger verifica: 30% < 50 → TRUE
6. Trigger ejecuta ROLLBACK → **Revierte todo** (EjecucionPipeline + alerta)
7. Trigger lanza THROW con mensaje de error
8. Procedimiento captura error en CATCH
9. Procedimiento relanza error con THROW
10. Cliente recibe: "Ejecución crítica detectada (porcentaje < 50%). ID Ejecución: XXX - Porcentaje: 30%"

---

### Caso 4: División por cero (filasLeidas = 0)
```sql
filasLeidas = 0
filasCargadas = 0
porcentaje = CASE WHEN 0 = 0 THEN 0 ELSE ... END = 0%
```
**Resultado:**
- ✅ Se inserta en EjecucionPipeline (porcentaje se considera 0%)
- ✅ Se genera alerta (0% < 80%)
- ✅ Se hace ROLLBACK (0% < 50%)
- ❌ Procedimiento lanza error

**Sin el CASE:**
```sql
-- ❌ Esto fallaría
porcentaje = (0 * 100.0) / 0  -- Error: Divide by zero error encountered.
```

---

### Caso 5: Pipeline inexistente
```sql
@idPipeline = 999  (no existe en tabla Pipeline)
```
**Resultado:**
- ❌ NO se inserta en EjecucionPipeline
- ❌ NO se dispara el trigger (porque no hay INSERT)
- ❌ Procedimiento lanza error: "El pipeline especificado no existe en la base de datos."
- ❌ @idEjecucionGenerado queda sin valor

**Flujo:**
1. Procedimiento verifica: `EXISTS (SELECT 1 FROM Pipeline WHERE idPipeline = 999)` → FALSE
2. Procedimiento ejecuta: `THROW 50001, 'El pipeline especificado no existe...', 1;`
3. Bloque CATCH captura el error
4. Procedimiento relanza con THROW
5. Cliente recibe el error

---

## 🔍 PREGUNTAS TIPO MULTIPLE CHOICE - ANÁLISIS

### Pregunta 1: SCOPE_IDENTITY()
**El procedimiento sp_AltaEjecucionPipeline usa SCOPE_IDENTITY() para devolver el ID generado. ¿Cuál afirmación es correcta?**

A) SCOPE_IDENTITY() devuelve el último IDENTITY insertado en cualquier tabla de la sesión.
B) Si el trigger inserta en AlertaEjecucion (que tiene IDENTITY), SCOPE_IDENTITY() devuelve el ID de AlertaEjecucion.
C) SCOPE_IDENTITY() solo devuelve el ID insertado en el scope actual, ignorando triggers en otras tablas.
D) @@IDENTITY es más seguro que SCOPE_IDENTITY() en este contexto.

**RESPUESTA CORRECTA: C**

**Explicación:**
- A) ❌ Eso es @@IDENTITY, no SCOPE_IDENTITY()
- B) ❌ SCOPE_IDENTITY() ignora lo que pasa en otros scopes (triggers)
- C) ✅ CORRECTO - Solo devuelve el ID de EjecucionPipeline insertado en el procedimiento
- D) ❌ Al revés: SCOPE_IDENTITY() es más seguro que @@IDENTITY

---

### Pregunta 2: Parámetros OUTPUT
**Respecto al parámetro OUTPUT en sp_AltaEjecucionPipeline:**

A) Se puede omitir la palabra OUTPUT al llamar el procedimiento si se declara la variable.
B) El parámetro OUTPUT debe ser asignado dentro del procedimiento para tener valor.
C) Un procedimiento puede tener múltiples parámetros OUTPUT.
D) Si hay un error antes de asignar el OUTPUT, el parámetro retiene su valor previo.

**RESPUESTA CORRECTA: B, C y D son correctas**

**Explicación:**
- A) ❌ OUTPUT es obligatorio tanto en la declaración como en la llamada
- B) ✅ Si no haces `SET @idEjecucionGenerado = SCOPE_IDENTITY()`, queda NULL
- C) ✅ Puedes tener cuantos OUTPUT necesites
- D) ✅ Si falla antes del SET, el OUTPUT queda con el valor que tenía (NULL si no se inicializó)

---

### Pregunta 3: Trigger y tabla INSERTED
**El trigger trg_ControlarEjecucionPipeline recibe múltiples inserciones. ¿Cuál afirmación es correcta?**

A) El trigger se ejecuta una vez por cada fila insertada.
B) La tabla INSERTED puede contener múltiples filas en una sola ejecución del trigger.
C) Los cursores son necesarios para procesar cada fila de INSERTED.
D) Si INSERTED tiene 10 filas y el trigger hace ROLLBACK, solo se revierten las filas que no cumplan la condición.

**RESPUESTA CORRECTA: B**

**Explicación:**
- A) ❌ El trigger se ejecuta UNA VEZ por sentencia INSERT, no por fila
- B) ✅ CORRECTO - INSERTED es una tabla con todas las filas insertadas
- C) ❌ Los cursores NO son necesarios, de hecho son mala práctica
- D) ❌ ROLLBACK revierte TODAS las filas, no selectivamente

---

### Pregunta 4: ROLLBACK en triggers
**Cuando el trigger ejecuta ROLLBACK TRANSACTION:**

A) Solo revierte el INSERT en EjecucionPipeline, no las alertas en AlertaEjecucion.
B) Revierte todo, incluyendo las alertas insertadas antes del ROLLBACK.
C) El procedimiento almacenado no puede capturar este error.
D) SCOPE_IDENTITY() en el procedimiento devuelve NULL después del ROLLBACK.

**RESPUESTA CORRECTA: B y D**

**Explicación:**
- A) ❌ ROLLBACK revierte TODO en la transacción
- B) ✅ CORRECTO - Incluye EjecucionPipeline Y AlertaEjecucion
- C) ❌ El procedimiento SÍ puede capturar el error en TRY-CATCH
- D) ✅ CORRECTO - Después del ROLLBACK, SCOPE_IDENTITY() puede devolver NULL

---

### Pregunta 5: Cálculo de porcentaje
**En el trigger, el cálculo del porcentaje usa `(filasCargadas * 100.0) / filasLeidas`. ¿Por qué el `.0` en `100.0`?**

A) Es un error, debería ser solo `100`.
B) Fuerza la división a devolver un decimal en lugar de un entero.
C) Sin el `.0`, el resultado sería siempre 0 o 1.
D) Es para cumplir con el estándar ANSI SQL.

**RESPUESTA CORRECTA: B y C**

**Explicación:**
- A) ❌ NO es un error, es intencional
- B) ✅ CORRECTO - `100.0` convierte la operación a decimal
- C) ✅ CORRECTO - Sin `.0`, `50/100 = 0` (división entera)
- D) ❌ No tiene que ver con el estándar, es comportamiento de SQL Server

---

### Pregunta 6: EXISTS vs COUNT
**El procedimiento usa `IF NOT EXISTS (SELECT 1 FROM Pipeline WHERE ...)`. ¿Por qué es mejor que COUNT?**

A) EXISTS es más rápido porque se detiene en la primera coincidencia.
B) COUNT es más preciso porque cuenta todas las filas.
C) EXISTS puede usar índices mientras que COUNT no.
D) No hay diferencia, es solo preferencia de estilo.

**RESPUESTA CORRECTA: A**

**Explicación:**
- A) ✅ CORRECTO - EXISTS se detiene al encontrar la primera fila
- B) ❌ No necesitamos contar, solo verificar existencia
- C) ❌ Ambos pueden usar índices
- D) ❌ Hay diferencia de rendimiento

---

### Pregunta 7: Orden de ejecución
**Cuando se ejecuta `EXEC sp_AltaEjecucionPipeline` con datos que generan porcentaje de 30% (< 50%), ¿en qué orden ocurren los eventos?**

1. El procedimiento inserta en EjecucionPipeline
2. El trigger se dispara
3. El trigger inserta alerta en AlertaEjecucion
4. El trigger hace ROLLBACK
5. El procedimiento captura error
6. El procedimiento relanza error

A) 1 → 2 → 3 → 4 → 5 → 6
B) 1 → 2 → 4 → 5 → 6 (sin paso 3)
C) 1 → 5 → 6 (trigger no se ejecuta)
D) 1 → 2 → 3 → 5 → 4 → 6

**RESPUESTA CORRECTA: A**

**Explicación:**
El trigger se ejecuta completamente (incluido insertar la alerta) antes del ROLLBACK. Aunque luego el ROLLBACK revierte tanto el INSERT en EjecucionPipeline como la alerta, el orden de ejecución sigue siendo 1-2-3-4-5-6.

---

### Pregunta 8: Múltiples inserciones
**Si ejecutamos un INSERT que inserta 5 filas en EjecucionPipeline, 3 con porcentaje > 80%, 1 con porcentaje = 60% y 1 con porcentaje = 40%:**

A) Se insertan las 3 filas con porcentaje > 80%, las otras 2 se rechazan.
B) Se rechazan todas las 5 filas por el ROLLBACK.
C) Se insertan las 4 primeras, solo se rechaza la de 40%.
D) Depende del orden en que fueron insertadas.

**RESPUESTA CORRECTA: B**

**Explicación:**
ROLLBACK revierte TODA la transacción. No importa cuántas filas cumplan la condición: si UNA fila tiene porcentaje < 50%, TODAS se revierten. Es todo o nada.

---

### Pregunta 9: THROW vs RAISERROR
**El código usa THROW para relanzar errores. ¿Cuál es la diferencia con RAISERROR?**

A) THROW es más antiguo que RAISERROR.
B) THROW siempre detiene la ejecución, RAISERROR puede no hacerlo según la severidad.
C) RAISERROR puede relanzar errores con solo `RAISERROR;`, THROW no.
D) No hay diferencia funcional entre ambos.

**RESPUESTA CORRECTA: B**

**Explicación:**
- A) ❌ Al revés: THROW es más moderno (SQL Server 2012+)
- B) ✅ CORRECTO - RAISERROR con severidad < 11 no detiene la ejecución
- C) ❌ Al revés: THROW puede relanzar con solo `THROW;`
- D) ❌ Tienen diferencias importantes

---

### Pregunta 10: STRING_AGG
**El trigger usa STRING_AGG para construir mensajes de error con múltiples ejecuciones. ¿Qué pasa si hay solo 1 fila en INSERTED con porcentaje < 50%?**

A) STRING_AGG falla porque necesita al menos 2 filas.
B) STRING_AGG devuelve un string con una sola ejecución (sin separadores).
C) Es más eficiente usar un cursor en este caso.
D) STRING_AGG devuelve NULL.

**RESPUESTA CORRECTA: B**

**Explicación:**
- A) ❌ STRING_AGG funciona con 1 fila
- B) ✅ CORRECTO - Devuelve el mensaje de esa única fila
- C) ❌ STRING_AGG siempre es más eficiente que cursores
- D) ❌ Solo devuelve NULL si no hay filas o todos los valores son NULL

---

## 🎓 TIPS PARA EL EXAMEN

### 1. Lee TODAS las opciones antes de responder
- A veces la respuesta correcta es "B y C son correctas"
- No te quedes con la primera que te parece bien

### 2. Busca palabras absolutas que suelen ser falsas:
- "SIEMPRE", "NUNCA", "TODOS", "NINGUNO"
- Ejemplo: "SCOPE_IDENTITY() SIEMPRE devuelve un valor" → FALSO (puede ser NULL)

### 3. Presta atención a detalles técnicos:
- `.0` vs sin `.0` en divisiones
- `OUTPUT` al declarar vs al llamar
- `SCOPE_IDENTITY()` vs `@@IDENTITY`
- Trigger `AFTER` vs `INSTEAD OF`

### 4. Piensa en el flujo completo:
- Procedimiento → INSERT → Trigger → ROLLBACK → CATCH → THROW
- Cada paso afecta al siguiente

### 5. Casos extremos comunes:
- División por cero
- NULL values
- Múltiples filas en INSERT
- Transacciones anidadas
- Errores en triggers

### 6. Si la pregunta es sobre rendimiento:
- EXISTS > COUNT para verificar existencia
- Set-based > Cursores
- Índices ayudan a ambos

### 7. Errores comunes que aparecen en preguntas:
- Olvidar OUTPUT al llamar el procedimiento
- Confundir SCOPE_IDENTITY() con @@IDENTITY
- Pensar que ROLLBACK es selectivo
- Creer que triggers se ejecutan fila por fila

---

## 📝 RESUMEN EJECUTIVO

| Concepto | Debes saber |
|----------|-------------|
| **SCOPE_IDENTITY()** | Solo devuelve ID del scope actual, ignora triggers |
| **OUTPUT** | Obligatorio en declaración Y llamada |
| **INSERTED** | Tabla temporal con todas las filas insertadas |
| **Trigger AFTER** | Se ejecuta 1 vez por sentencia, no por fila |
| **ROLLBACK** | Revierte TODO, no es selectivo |
| **TRY-CATCH** | Captura errores de triggers también |
| **Division decimal** | Usar `.0` para evitar división entera |
| **EXISTS** | Más rápido que COUNT para verificar existencia |
| **STRING_AGG** | Concatena múltiples filas en un string |
| **Set-based** | Siempre mejor que cursores en triggers |

¡Éxitos en el examen! 🚀
