#!/bin/bash
set -e  # Detener el script si ocurre un error

# Verificar si el script se ejecuta como root
if [ "$EUID" -ne 0 ]; then
  echo "Por favor, ejecuta este script como root."
  exit 1
fi

# 1. Instalar RKE2
echo "Instalando RKE2..."
curl -sfL https://get.rke2.io | sh -

# 2. Habilitar y arrancar el servicio RKE2
echo "Habilitando y arrancando el servicio RKE2..."
systemctl enable rke2-server.service
systemctl start rke2-server.service

# 3. Configurar PATH para RKE2
echo "Configurando el PATH para RKE2..."
if ! grep -q "/var/lib/rancher/rke2/bin" ~/.bashrc; then
    echo "export PATH=\$PATH:/var/lib/rancher/rke2/bin" >> ~/.bashrc
fi
export PATH=$PATH:/var/lib/rancher/rke2/bin

# 4. Configurar Kubectl
echo "Configurando Kubectl..."
mkdir -p ~/.kube
cp /etc/rancher/rke2/rke2.yaml ~/.kube/config
chown $(id -u):$(id -g) ~/.kube/config

# 5. Alias para Kubectl
echo "Creando alias para Kubectl..."
if ! grep -q "alias k=kubectl" ~/.bashrc; then
    echo "alias k=kubectl" >> ~/.bashrc
fi

# 6. Mostrar el token del nodo
echo "Mostrando el token del nodo para unir otros nodos al clúster:"
cat /var/lib/rancher/rke2/server/node-token

# 7. Confirmar instalación exitosa
echo "RKE2 instalado y configurado exitosamente."
