#!/bin/bash
# Castellanos Martínez Andrea

validar_ip() {
    local ip="$1"
    local regex="^((25[0-5]|2[0-4][0-9]|1?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|1?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|1?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|1?[0-9][0-9]?))$"

    if [[ $ip =~ $regex ]]; then
        # Dividir la IP en partes usando IFS (Internal Field Separator)
        IFS='.' read -r -a partes <<< "$ip"

        # Verificar si el último octeto es 1 o 255
        if [[ "${partes[3]}" == "1" || "${partes[3]}" == "255" ]]; then
            return 1  # False (IP no válida)
        fi

        return 0  # True (IP válida)
    else
        return 1  # False (IP no válida)
    fi
}

# Pedir IP hasta que sea válida
until validar_ip "$ip"; do
    echo "Introduce la direccion que quieres fijar"
    read ip

    if validar_ip "$ip"; then
        echo "IP válida: $ip"
    else
        echo "IP inválida. Intenta de nuevo."
    fi
done

#Pedir rangos de red
until false; do
    echo "Introduce la dirección IP de inicio del rango de red:"
    read inicio

    IFS='.' read -r -a partesi <<< "$ip"
    ip_i="${partesi[0]}.${partesi[1]}.${partesi[2]}"
    IFS='.' read -r -a partes <<< "$inicio"
    ip_a="${partes[0]}.${partes[1]}.${partes[2]}"

    if validar_ip "$inicio"; then
        if [[ "$ip_i" != "$ip_a" ]]; then
            echo "Las direcciones IP deben pertenecer al mismo rango de red. Intenta de nuevo."
        else
            echo "IP válida: $inicio"
            break
        fi
    else
        echo "IP inválida. Intenta de nuevo."
    fi
done

until false; do
    echo "Introduce la dirección IP de fin del rango de red:"
    read fin

    # Validar la IP de fin
    if validar_ip "$fin"; then
        # Dividir las IPs en partes usando '.' como delimitador
        IFS='.' read -r -a partes2 <<< "$fin"
        IFS='.' read -r -a partes <<< "$inicio"
        # Obtener los últimos octetos de las IPs
        ultimo_octeto_inicio=${partes[3]}
        ultimo_octeto_fin=${partes2[3]}

        # Construir la IP base sin el último octeto
        ip_b="${partes2[0]}.${partes2[1]}.${partes2[2]}"

        # Validar que la IP de fin sea mayor que la de inicio
        if [[ "$fin" == "$inicio" || "$ultimo_octeto_fin" -le "$ultimo_octeto_inicio" ]]; then
            echo "La dirección IP de fin no puede ser igual o menor a la dirección IP de inicio. Intenta de nuevo."
        else
            # Validar que ambas IPs pertenezcan al mismo rango de red
            if [[ "$ip_a" != "$ip_b" ]]; then
                echo "Las direcciones IP deben pertenecer al mismo rango de red. Intenta de nuevo."
            else
                echo "IP válida: $fin"
                break
            fi
        fi
    else
        echo "IP inválida. Intenta de nuevo."
    fi
done

echo "Rango de red: $inicio - $fin"

#Fijar una IP en netplan
echo "network:
  version: 2
  renderer: networkd
  ethernets:
    enp0s3:
      dhcp4: true
    enp0s8:
      addresses: [$ip/24]
      nameservers:
        addresses: [8.8.8.8, 1.1.1.1]" | sudo tee /etc/netplan/50-cloud-init.yaml > /dev/null

echo "Fijando la IP $ip en netplan"

#Aplicar cambios
sudo netplan apply
echo "Aplicando cambios en netplan"

#Instalar isc-dhcp-server
sudo apt update
sudo apt-get install isc-dhcp-server -y

#Configurar el servidor DHCP
sudo sed -i "s/INTERFACESv4=\"\"/INTERFACESv4=\"enp0s8\"/g" /etc/default/isc-dhcp-server

#Configurar el archivo dhcpd.conf
sudo tee -a /etc/dhcp/dhcpd.conf > /dev/null <<EOF
group red-interna {
    subnet $(echo $ip | awk -F. '{print $1"."$2"."$3}').0 netmask 255.255.255.0 {
        range $inicio $fin;
        option routers $(echo $ip | awk -F. '{print $1"."$2"."$3}').1;
        option domain-name-servers 8.8.8.8;
        option domain-name "DHCP Server d Andrea";
        default-lease-time 1800;   
        max-lease-time 3600;       
    }
}
EOF

sudo service isc-dhcp-server restart
sudo service isc-dhcp-server status

