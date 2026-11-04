# Equipo 9: Retos avanzados de MapReduce

Guía para ejecutar `secondarysort`, `join` y `dbcount` (bonus) en Hadoop 3.3.6 usando solo este README.

## Integrantes

- *Ayala Carrazco Said Giulliano*
- *Carmona Capula Andrés Tadeo*
- *Hernández Huerta Ari Leonardo*

## Descripción y caso de uso
 
| Ejemplo | Qué hace | Caso real |
|---|---|---|
| `secondarysort` | Ordena por un primer valor y, dentro de cada grupo, por un segundo valor | Ver las compras de cada cliente ordenadas por monto |
| `join` | Une dos datasets por una llave común, como un `JOIN` de SQL | Unir clientes con sus pedidos |
| `dbcount` (bonus) | Lee registros de una base de datos, cuenta visitas por URL y guarda el total en otra tabla | Contar visitas a páginas a partir de un log de accesos |
 
## Requisitos
 
- Docker instalado y abierto.
- Conexión a internet si vas a instalar Hadoop desde cero.
- Para las rutas A y C: el contenedor `hadoop` de la práctica, con Hadoop 3.3.6.
En cada bloque de código se indica dónde se ejecuta:
 
- 💻 En la terminal de tu computadora.
- 🐳 Dentro del contenedor.
Si tu prompt dice `hadoop@...` o `root@...`, estás dentro del contenedor. Los comandos `docker` siempre se ejecutan en tu computadora.
 
> **Nunca ejecutes `docker rm hadoop`.** Borra el contenedor con Hadoop, Java y todos sus archivos.
 
---
 
## 1. Elige tu ruta
 
Primero revisa si ya tienes el contenedor.
 
💻 Lista todos los contenedores:
 
```bash
docker ps -a
```
 
| Lo que ves en la fila `hadoop` | Tu situación | Ruta |
|---|---|---|
| `STATUS` dice `Up` | Ya tienes la práctica abierta | [Ruta A](#ruta-a-ya-tengo-la-práctica-abierta) |
| No aparece `hadoop` | Eres usuario nuevo | [Ruta B](#ruta-b-soy-usuario-nuevo) |
| `STATUS` dice `Exited` | Cerraste o apagaste la práctica | [Ruta C](#ruta-c-volver-a-activar-la-práctica) |
 
### Ruta A: ya tengo la práctica abierta
 
💻 Entra al contenedor como usuario `hadoop`. Si ya estás dentro con el prompt `hadoop@...`, omite este paso:
 
```bash
docker exec -it -u hadoop hadoop bash
```
 
Si sale `container ... is not running`, tu contenedor está apagado. Usa la [Ruta C](#ruta-c-volver-a-activar-la-práctica).
 
Si estás dentro con el prompt `root@...`, cambia de usuario:
 
🐳
 
```bash
su - hadoop
```
 
Continúa en el [paso 2](#2-verifica-el-entorno).
 
### Ruta B: soy usuario nuevo
 
Esta ruta instala todo desde cero. La descarga de Hadoop pesa cerca de 700 MB.
 
💻 Crea y enciende el contenedor:
 
```bash
docker run -d --name hadoop -p 9870:9870 -p 9000:9000 debian:12 tail -f /dev/null
```
 
💻 Entra como `root`:
 
```bash
docker exec -it hadoop bash
```
 
🐳 Instala Java y las herramientas necesarias:
 
```bash
apt update && apt install -y openjdk-17-jdk wget nano procps
```
 
🐳 Descarga Hadoop 3.3.6:
 
```bash
wget https://archive.apache.org/dist/hadoop/common/hadoop-3.3.6/hadoop-3.3.6.tar.gz
```
 
🐳 Descomprímelo en `/opt/hadoop`:
 
```bash
tar -xzf hadoop-3.3.6.tar.gz -C /opt/ && mv /opt/hadoop-3.3.6 /opt/hadoop
```
 
🐳 Crea el usuario `hadoop` y dale la carpeta:
 
```bash
useradd -m -s /bin/bash hadoop && chown -R hadoop:hadoop /opt/hadoop
```
 
🐳 Agrega las variables de entorno. `JAVA_HOME` se calcula solo, así que funciona en procesadores Intel, AMD y ARM:
 
```bash
cat >> /home/hadoop/.bashrc <<'EOF'
export JAVA_HOME=$(dirname $(dirname $(readlink -f $(which java))))
export HADOOP_HOME=/opt/hadoop
export PATH=$PATH:$HADOOP_HOME/bin:$HADOOP_HOME/sbin
EOF
```
 
🐳 Cambia al usuario `hadoop`:
 
```bash
su - hadoop
```
 
Continúa en el [paso 2](#2-verifica-el-entorno).
 
### Ruta C: volver a activar la práctica
 
💻 Enciende el contenedor:
 
```bash
docker start hadoop
```
 
💻 Entra como usuario `hadoop`:
 
```bash
docker exec -it -u hadoop hadoop bash
```
 
Tu prompt debe cambiar a algo como `hadoop@...`.
 
Si vuelve a salir `container ... is not running`, el contenedor se está apagando solo. Revisa su estado y sus mensajes:
 
💻
 
```bash
docker ps -a
```
 
💻
 
```bash
docker logs hadoop
```
 
Continúa en el [paso 2](#2-verifica-el-entorno).
 
---
 
## 2. Verifica el entorno
 
A partir de aquí, todas las rutas siguen los mismos pasos. Los comandos se ejecutan como usuario `hadoop`.
 
🐳 Revisa Java:
 
```bash
java -version
```
 
Debe mostrar la versión `17`.
 
🐳 Revisa Hadoop:
 
```bash
hadoop version
```
 
Debe mostrar `Hadoop 3.3.6`.
 
🐳 Guarda la ruta del jar de ejemplos. Repite este comando cada vez que abras una terminal nueva:
 
```bash
EX=/opt/hadoop/share/hadoop/mapreduce/hadoop-mapreduce-examples-3.3.6.jar
```
 
---
 
## 3. Ejemplo `secondarysort`
 
**Formato de entrada:** dos enteros por línea, separados por un espacio o un tabulador.
 
🐳 Crea la carpeta de entrada:
 
```bash
mkdir -p /tmp/equipo9/secondarysort
```
 
🐳 Crea los datos:
 
```bash
printf '3 8\n1 5\n2 7\n1 2\n3 1\n2 4\n1 9\n' > /tmp/equipo9/secondarysort/numeros.txt
```
 
🐳 Borra una salida anterior, porque Hadoop no sobrescribe carpetas:
 
```bash
rm -rf /tmp/salida_ss
```
 
🐳 Ejecuta el ejemplo:
 
```bash
hadoop jar $EX secondarysort /tmp/equipo9/secondarysort /tmp/salida_ss
```
 
🐳 Muestra el resultado:
 
```bash
cat /tmp/salida_ss/part-r-00000
```
 
### Resultado esperado
 
```text
------------------------------------------------
1	2
1	5
1	9
------------------------------------------------
2	4
2	7
------------------------------------------------
3	1
3	8
```
 
### Cómo funciona
 
```text
Entrada:  "1 5"
Map:      emite la llave compuesta (1,5) con el valor 5
Shuffle:  ordena por (primero, segundo) y agrupa solo por el primero
Reduce:   recibe el grupo 1 con los valores [2, 5, 9] y escribe una línea
          separadora seguida de cada par
```
 
---
 
## 4. Ejemplo `join`
 
**Formato de entrada:** `llave<TAB>valor`, una carpeta por dataset y cada archivo ordenado por llave como texto.
 
Por defecto, `join` espera archivos SequenceFile. Por eso se usan las opciones `-inFormat`, `-outFormat` y `-outKey` para trabajar con texto.
 
🐳 Crea las carpetas de entrada:
 
```bash
mkdir -p /tmp/equipo9/join/clientes /tmp/equipo9/join/pedidos
```
 
🐳 Crea los clientes:
 
```bash
printf '101\tAna\n102\tLuis\n103\tMarta\n104\tPedro\n' > /tmp/equipo9/join/clientes/clientes.txt
```
 
🐳 Crea los pedidos:
 
```bash
printf '101\tLaptop\n101\tMouse\n103\tTeclado\n105\tMonitor\n' > /tmp/equipo9/join/pedidos/pedidos.txt
```
 
### Join interno (`inner`)
 
Solo conserva las llaves que existen en ambos datasets.
 
🐳 Borra una salida anterior:
 
```bash
rm -rf /tmp/salida_join
```
 
🐳 Ejecuta el ejemplo:
 
```bash
hadoop jar $EX join -r 1 \
  -inFormat org.apache.hadoop.mapreduce.lib.input.KeyValueTextInputFormat \
  -outFormat org.apache.hadoop.mapreduce.lib.output.TextOutputFormat \
  -outKey org.apache.hadoop.io.Text \
  -joinOp inner \
  /tmp/equipo9/join/clientes /tmp/equipo9/join/pedidos /tmp/salida_join
```
 
🐳 Muestra el resultado:
 
```bash
cat /tmp/salida_join/part-r-00000
```
 
Resultado esperado:
 
```text
101	[Ana,Mouse]
101	[Ana,Laptop]
103	[Marta,Teclado]
```
 
Las líneas de una misma llave no tienen un orden garantizado. Aquí `Mouse` aparece antes que `Laptop`, aunque en `pedidos.txt` esté después.
 
### Join externo (`outer`)
 
Conserva todas las llaves, aunque solo existan en uno de los datasets.
 
🐳 Borra una salida anterior:
 
```bash
rm -rf /tmp/salida_join_outer
```
 
🐳 Ejecuta el ejemplo:
 
```bash
hadoop jar $EX join -r 1 \
  -inFormat org.apache.hadoop.mapreduce.lib.input.KeyValueTextInputFormat \
  -outFormat org.apache.hadoop.mapreduce.lib.output.TextOutputFormat \
  -outKey org.apache.hadoop.io.Text \
  -joinOp outer \
  /tmp/equipo9/join/clientes /tmp/equipo9/join/pedidos /tmp/salida_join_outer
```
 
🐳 Muestra el resultado:
 
```bash
cat /tmp/salida_join_outer/part-r-00000
```
 
Resultado esperado:
 
```text
101	[Ana,Mouse]
101	[Ana,Laptop]
102	[Luis,]
103	[Marta,Teclado]
104	[Pedro,]
105	[,Monitor]
```
 
### Cómo funciona
 
Este ejemplo es un *map-side join*: la unión ocurre antes de la fase Map.
 
```text
clientes + pedidos (ordenados por llave)
        ↓
CompositeInputFormat une los registros por llave
        ↓
Map:    identidad, reenvía (101, [Ana,Laptop])
        ↓
Reduce: identidad, escribe el resultado
```
 
---
 
## 5. Bonus: ejemplo `dbcount`
 
**Entrada:** no usa archivos. El programa inicia un servidor HSQLDB, crea las tablas `HAccess` y `Pageview`, y genera datos aleatorios.
 
🐳 Entra a una carpeta donde puedas escribir:
 
```bash
mkdir -p /tmp/equipo9 && cd /tmp/equipo9
```
 
🐳 Busca el jar de HSQLDB incluido con Hadoop:
 
```bash
HSQL=$(find /opt/hadoop -name 'hsqldb*.jar' | head -1); echo $HSQL
```
 
Si el comando anterior no muestra ninguna ruta, descarga el jar:
 
🐳
 
```bash
wget -O /tmp/equipo9/hsqldb.jar https://repo1.maven.org/maven2/org/hsqldb/hsqldb/2.7.1/hsqldb-2.7.1.jar
```
 
🐳
 
```bash
HSQL=/tmp/equipo9/hsqldb.jar
```
 
🐳 Agrega el jar al classpath:
 
```bash
export HADOOP_CLASSPATH=$HSQL
```
 
🐳 Ejecuta el ejemplo:
 
```bash
hadoop jar $EX dbcount -libjars $HSQL
```
 
### Resultado esperado
 
No se genera un archivo `part-r-00000`, porque el resultado se guarda en la tabla `Pageview`. El log es largo, así que puedes ejecutar el ejemplo mostrando solo las líneas clave:
 
🐳
 
```bash
hadoop jar $EX dbcount -libjars $HSQL 2>&1 | grep -E "completed successfully|totalPageview|sumPageview"
```
 
Ejemplo de una ejecución real:
 
```text
INFO mapreduce.Job: Job job_local1334266441_0001 completed successfully
INFO examples.DBCountPageView: totalPageview=50
INFO examples.DBCountPageView: sumPageview=50
```
 
El número cambia en cada ejecución (entre 50 y 99) porque los datos son aleatorios, pero ambos valores deben coincidir.
 
### Cómo funciona
 
```text
Fila de HAccess:  (/a, referrer, tiempo)
Map:              emite (/a, 1)
Reduce:           suma los valores de cada URL
Salida:           escribe (/a, total) en la tabla Pageview
```
 
---
 
## 6. Copia los resultados a tu computadora
 
Ejecuta estos comandos en una terminal de tu computadora, dentro de la carpeta del repositorio. Si el prompt dice `hadoop@...` o `root@...`, abre otra terminal; ahí saldría `docker: command not found`.
 
Cada comando `docker cp` debe mostrar `Successfully copied`.
 
💻 Crea las carpetas. En PowerShell (Windows):
 
```powershell
mkdir datos, resultados -Force
```
 
💻 En Linux, macOS o Git Bash:
 
```bash
mkdir -p datos resultados
```
 
💻 Copia los datos de entrada:
 
```bash
docker cp hadoop:/tmp/equipo9/. datos/
```
 
💻 Copia el resultado de `secondarysort`:
 
```bash
docker cp hadoop:/tmp/salida_ss/part-r-00000 resultados/secondarysort.txt
```
 
💻 Copia el resultado de `join` interno:
 
```bash
docker cp hadoop:/tmp/salida_join/part-r-00000 resultados/join_inner.txt
```
 
💻 Copia el resultado de `join` externo:
 
```bash
docker cp hadoop:/tmp/salida_join_outer/part-r-00000 resultados/join_outer.txt
```
 
Si descargaste `hsqldb.jar` en `/tmp/equipo9`, también se copió a `datos/`. Bórralo para no subirlo a GitHub. En PowerShell (Windows):
 
```powershell
Remove-Item datos\hsqldb.jar
```
 
💻 En Linux, macOS o Git Bash:
 
```bash
rm datos/hsqldb.jar
```
 
La base de datos de `dbcount` se guarda en `/tmp/URLAccess`, así que `docker cp` no la copia.
 
Al ejecutar `git add .` en Windows, puede salir el aviso `LF will be replaced by CRLF`. Es normal y puedes ignorarlo.
 
---
 
## 7. Salir y volver después
 
🐳 Sal del contenedor:
 
```bash
exit
```
 
💻 Apaga el contenedor. Tus archivos se conservan:
 
```bash
docker stop hadoop
```
 
Para volver, sigue la [Ruta C](#ruta-c-volver-a-activar-la-práctica).
 
---
 
## Ejecutar todo con un script

Después de encender el contenedor, puedes correr todos los ejemplos con `scripts/ejecutar.sh`. El script crea los mismos datos que están en `datos/`.

💻 Copia el script al contenedor:

```bash
docker cp scripts/ejecutar.sh hadoop:/tmp/ejecutar.sh
```

💻 Ejecútalo como usuario `hadoop`:

```bash
docker exec -u hadoop hadoop bash /tmp/ejecutar.sh
```

Debe terminar con `=== Listo ===`. Las salidas de referencia están en `resultados/`.

El mini ejercicio está en `ejercicio/ejercicio.md` y su solución en `ejercicio/solucion.md`.

---

## Errores comunes
 
### Errores que nos salieron
 
| Error | Causa | Cómo lo resolvimos |
|---|---|---|
| `container ... is not running` | El contenedor estaba apagado | Ejecutar `docker start hadoop` y volver a entrar con `docker exec -it -u hadoop hadoop bash`; los archivos se conservan |
| `bash: docker: command not found` | Ejecutamos `docker cp` y `docker stop` dentro del contenedor | Salir con `exit` o abrir una terminal en la computadora |
| `Failed to create symlink ... libjars/*` en `dbcount` | Aviso de Hadoop en modo local | Ignorarlo: el trabajo terminó con `completed successfully` y los totales coincidieron |
| `Output Path is null` en `dbcount` | El resultado va a una tabla, no a una carpeta | Ignorarlo: es normal en este ejemplo |
| `usage: git remote add [<options>] <name> <url>` | Faltó el nombre `origin` en el comando | Ejecutar `git remote add origin` seguido de la URL del repositorio |
| `src refspec main does not match any` | Faltaba el commit y la rama no se llamaba `main` | Ejecutar `git commit` y luego `git branch -M main` |
| `rejected ... main -> main (fetch first)` | El repositorio de GitHub ya tenía contenido | Ejecutar `git pull origin main --allow-unrelated-histories --no-rebase --no-edit` y volver a hacer `git push -u origin main` |
| `LF will be replaced by CRLF` | Aviso de Git en Windows por los saltos de línea | Ignorarlo: no impide subir los archivos |
 
### Otros errores posibles
 
Estos no nos salieron, pero pueden aparecer.
 
| Error | Causa | Solución |
|---|---|---|
| `The container name "/hadoop" is already in use` | Ya tienes el contenedor | No crees otro ni lo borres; usa la Ruta A o C |
| `hadoop: command not found` | No estás como `hadoop` o faltan las variables | Ejecuta `su - hadoop` o revisa `~/.bashrc` |
| `Not a valid JAR` o un error por argumentos | `EX` está vacía en una terminal nueva | Vuelve a definir `EX` (paso 2) |
| `Output directory ... already exists` | La carpeta de salida ya existe | Bórrala con `rm -rf` |
| `Permission denied` en `/tmp/equipo9` | La carpeta quedó a nombre de `root` | 💻 `docker exec -u root hadoop chown -R hadoop:hadoop /tmp/equipo9` |
| `NumberFormatException` en `secondarysort` | Hay una línea con texto | Deja solo números enteros |
| `not a SequenceFile` en `join` | Falta `-inFormat` | Copia el comando completo |
| El `join` sale incompleto o desordenado | Las llaves no están ordenadas como texto | Ordena los archivos y usa llaves del mismo ancho: `10` queda antes de `9` |
| `ClassNotFoundException` o `No suitable driver` en `dbcount` | Falta el jar de HSQLDB | Revisa `$HSQL` y `HADOOP_CLASSPATH` |
 
