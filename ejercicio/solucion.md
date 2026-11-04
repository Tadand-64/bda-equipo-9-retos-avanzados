# Solución del mini ejercicio: Equipo 9

## Ejercicio 1: `secondarysort`

Resultado esperado:

```text
------------------------------------------------
5	2
5	9
------------------------------------------------
6	4
------------------------------------------------
7	1
7	2
7	3
```

1. Aparecen **3 líneas separadoras**, una por cada valor distinto del primer número: 5, 6 y 7. El Reduce escribe una al iniciar cada grupo.
2. Para **ordenar** se usa la llave completa (primero, segundo). Para **agrupar** se usa solo el primer número.

## Ejercicio 2: `join`

Resultado esperado con `inner`:

```text
201	[Sofia,95]
203	[Elena,88]
```

1. Aparecen **201 y 203** porque son las únicas llaves que existen en ambos datasets.
2. Con `outer` aparecen todas las llaves, y el lado sin dato queda vacío:

   ```text
   201	[Sofia,95]
   202	[Diego,]
   203	[Elena,88]
   204	[,70]
   ```

3. Ocurre **antes del Map**. `CompositeInputFormat` une los registros al leerlos, y el Map y el Reduce solo los reenvían. Por eso los archivos deben estar ordenados por llave.

## Ejercicio 3: encuentra el error

1. El trabajo falla con `java.lang.NumberFormatException: For input string: "x"`. Lo causa la línea `8 x`.
2. El Map convierte cada valor con `Integer.parseInt`, porque la llave compuesta está formada por dos enteros. La letra `x` no se puede convertir.
