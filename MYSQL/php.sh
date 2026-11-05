#!/bin/bash

case "$1" in
    arrancar)
        echo "Levantando los contenedores..."
        docker compose up -d
        ;;
    cerrar)
        echo "Deteniendo los contenedores..."
        docker compose down
        ;;
    *)
        echo "Uso: $0 {arrancar|cerrar}"
        exit 1
        ;;
esac
