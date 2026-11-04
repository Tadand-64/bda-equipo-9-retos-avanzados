# Mini ejercicio: Equipo 9

**Requisito:** contenedor `hadoop` encendido y haber entrado como usuario `hadoop`.

Antes de ejecutar cada parte, escribe qué resultado esperas. Después compáralo con la salida de Hadoop.

🐳 Guarda la ruta del jar de ejemplos:

```bash
EX=/opt/hadoop/share/hadoop/mapreduce/hadoop-mapreduce-examples-3.3.6.jar
```

## Ejercicio 1: `secondarysort`

🐳 Crea la carpeta de entrada:

```bash
mkdir -p /tmp/ej9/numeros
```

🐳 Crea los datos:

```bash
printf '7 3\n5 9\n7 1\n5 2\n6 4\n7 2\n' > /tmp/ej9/numeros/numeros.txt
```

🐳 Ejecuta el ejemplo:

```bash
rm -rf /tmp/ej9/salida1; hadoop jar $EX secondarysort /tmp/ej9/numeros /tmp/ej9/salida1
```

🐳 Muestra el resultado:

```bash
cat /tmp/ej9/salida1/part-r-00000
```

**Preguntas:**

1. ¿Cuántas líneas separadoras aparecen y por qué?
2. ¿Qué parte de la llave compuesta se usa para ordenar y cuál para agrupar?

## Ejercicio 2: `join`

🐳 Crea las carpetas de entrada:

```bash
mkdir -p /tmp/ej9/alumnos /tmp/ej9/calificaciones
```

🐳 Crea los alumnos:

```bash
printf '201\tSofia\n202\tDiego\n203\tElena\n' > /tmp/ej9/alumnos/alumnos.txt
```

🐳 Crea las calificaciones:

```bash
printf '201\t95\n203\t88\n204\t70\n' > /tmp/ej9/calificaciones/calificaciones.txt
```

🐳 Ejecuta el `join` interno:

```bash
rm -rf /tmp/ej9/salida2; hadoop jar $EX join -r 1 \
  -inFormat org.apache.hadoop.mapreduce.lib.input.KeyValueTextInputFormat \
  -outFormat org.apache.hadoop.mapreduce.lib.output.TextOutputFormat \
  -outKey org.apache.hadoop.io.Text \
  -joinOp inner \
  /tmp/ej9/alumnos /tmp/ej9/calificaciones /tmp/ej9/salida2
```

🐳 Muestra el resultado:

```bash
cat /tmp/ej9/salida2/part-r-00000
```

**Preguntas:**

1. ¿Qué llaves aparecen y por qué?
2. Vuelve a ejecutarlo con `-joinOp outer` y otra carpeta de salida. ¿Qué cambia?
3. ¿En qué fase ocurre la unión: antes del Map, en el Map o en el Reduce?

## Ejercicio 3: encuentra el error

🐳 Agrega una línea con texto a los datos del ejercicio 1:

```bash
printf '8 x\n' >> /tmp/ej9/numeros/numeros.txt
```

🐳 Ejecuta el ejemplo:

```bash
rm -rf /tmp/ej9/salida3; hadoop jar $EX secondarysort /tmp/ej9/numeros /tmp/ej9/salida3
```

**Preguntas:**

1. ¿Qué error aparece y qué línea lo causa?
2. ¿Por qué `secondarysort` no acepta ese dato?
