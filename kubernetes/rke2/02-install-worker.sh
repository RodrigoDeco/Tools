#!/bin/bash

# Verificar si se ejecuta como root
if [ "$EUID" -ne 0 ]; then
  echo "Por favor, ejecuta este script como root."
  exit 1
fi

# Verificar que las variables de entorno necesarias estén definidas
if [ -z "$RKE2_MASTER_SERVER" ] || [ -z "$RKE2_TOKEN" ]; then
  echo "ERROR: Las variables de entorno RKE2_MASTER_SERVER y RKE2_TOKEN deben estar definidas."
  echo "Ejemplo: export RKE2_MASTER_SERVER=https://<server>:9345"
  echo "         export RKE2_TOKEN=<token>"
  exit 1
fi

# Descargar e instalar RKE2 como agente
echo "Instalando RKE2 como agente..."
curl -sfL https://get.rke2.io | INSTALL_RKE2_TYPE="agent" sh -

# Habilitar el servicio rke2-agent
echo "Habilitando el servicio rke2-agent..."
systemctl enable rke2-agent.service

# Crear directorio de configuración si no existe
CONFIG_DIR="/etc/rancher/rke2"
mkdir -p $CONFIG_DIR

# Crear archivo config.yaml utilizando variables de entorno
echo "Creando archivo de configuración para rke2-agent..."
cat <<EOF > $CONFIG_DIR/config.yaml
server: $RKE2_MASTER_SERVER
token: $RKE2_TOKEN
EOF

# Verificar configuración generada
echo "Configuración generada en $CONFIG_DIR/config.yaml:"
cat $CONFIG_DIR/config.yaml

# Iniciar el servicio rke2-agent
echo "Iniciando el servicio rke2-agent..."
systemctl start rke2-agent.service

# Confirmar estado del servicio
echo "Verificando estado del servicio rke2-agent..."
systemctl status rke2-agent.service

echo "Instalación y configuración de RKE2 como agente completada."
