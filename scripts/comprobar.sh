#!/bin/bash
# Comprueba que los archivos de datos y resultados del Equipo 9 estén completos.
set -e

echo "=== Comprobando datos de entrada ==="
for archivo in \
  datos/secondarysort/numeros.txt \
  datos/join/clientes/clientes.txt \
  datos/join/pedidos/pedidos.txt \
  ejercicio/datos/numeros/numeros.txt \
  ejercicio/datos/alumnos/alumnos.txt \
  ejercicio/datos/calificaciones/calificaciones.txt; do
  if [ -s "$archivo" ]; then
    echo "[OK] $archivo ($(wc -l < "$archivo") líneas)"
  else
    echo "[ERROR] Falta o está vacío: $archivo"
    exit 1
  fi
done

echo "=== Comprobando resultados de referencia ==="
for resultado in \
  resultados/secondarysort.txt \
  resultados/join_inner.txt \
  resultados/join_outer.txt \
  resultados/dbcount.txt \
  ejercicio/resultados/secondarysort_ej1.txt \
  ejercicio/resultados/join_inner_ej2.txt \
  ejercicio/resultados/join_outer_ej2.txt; do
  if [ -s "$resultado" ]; then
    echo "[OK] $resultado"
  else
    echo "[ERROR] Falta o está vacío: $resultado"
    exit 1
  fi
done

echo "=== Comprobación exitosa ==="
