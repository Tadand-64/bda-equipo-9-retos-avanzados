#!/bin/bash
# Ejecuta todos los ejemplos del equipo 9 dentro del contenedor.
# Requiere el contenedor "hadoop" encendido, con Hadoop 3.3.6.
set -e

# Variables de entorno: el script no siempre carga ~/.bashrc
export JAVA_HOME=$(dirname "$(dirname "$(readlink -f "$(which java)")")")
export HADOOP_HOME=/opt/hadoop
export PATH=$PATH:$HADOOP_HOME/bin:$HADOOP_HOME/sbin
EX=$HADOOP_HOME/share/hadoop/mapreduce/hadoop-mapreduce-examples-3.3.6.jar
JOIN_OPTS="-r 1 \
  -inFormat org.apache.hadoop.mapreduce.lib.input.KeyValueTextInputFormat \
  -outFormat org.apache.hadoop.mapreduce.lib.output.TextOutputFormat \
  -outKey org.apache.hadoop.io.Text"

echo "=== Preparando datos ==="
mkdir -p /tmp/equipo9/secondarysort /tmp/equipo9/join/clientes /tmp/equipo9/join/pedidos
printf '3 8\n1 5\n2 7\n1 2\n3 1\n2 4\n1 9\n' > /tmp/equipo9/secondarysort/numeros.txt
printf '101\tAna\n102\tLuis\n103\tMarta\n104\tPedro\n' > /tmp/equipo9/join/clientes/clientes.txt
printf '101\tLaptop\n101\tMouse\n103\tTeclado\n105\tMonitor\n' > /tmp/equipo9/join/pedidos/pedidos.txt

# Hadoop no sobrescribe carpetas de salida
rm -rf /tmp/salida_ss /tmp/salida_join /tmp/salida_join_outer

echo "=== secondarysort ==="
hadoop jar "$EX" secondarysort /tmp/equipo9/secondarysort /tmp/salida_ss
cat /tmp/salida_ss/part-r-00000

echo "=== join inner ==="
hadoop jar "$EX" join $JOIN_OPTS -joinOp inner \
  /tmp/equipo9/join/clientes /tmp/equipo9/join/pedidos /tmp/salida_join
cat /tmp/salida_join/part-r-00000

echo "=== join outer ==="
hadoop jar "$EX" join $JOIN_OPTS -joinOp outer \
  /tmp/equipo9/join/clientes /tmp/equipo9/join/pedidos /tmp/salida_join_outer
cat /tmp/salida_join_outer/part-r-00000

echo "=== dbcount (bonus) ==="
cd /tmp/equipo9
HSQL=$(find "$HADOOP_HOME" -name 'hsqldb*.jar' 2>/dev/null | head -1)
if [ -z "$HSQL" ]; then
  HSQL=/tmp/equipo9/hsqldb.jar
  [ -f "$HSQL" ] || wget -q -O "$HSQL" https://repo1.maven.org/maven2/org/hsqldb/hsqldb/2.7.1/hsqldb-2.7.1.jar
fi
export HADOOP_CLASSPATH=$HSQL
hadoop jar "$EX" dbcount -libjars "$HSQL" 2>&1 \
  | grep -E "completed successfully|totalPageview|sumPageview"

echo "=== Listo ==="
