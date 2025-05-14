#!/bin/bash

usuarioact=andycast 

# Función auxiliar para verificar si Docker está instalado
verificar_docker(){
    if ! command -v docker &> /dev/null; then
        echo "Docker no está instalado. Ejecute primero la opción 1."
        return 1
    fi
    return 0
}

instalar_docker(){
    # Verificar si Docker ya está instalado
    if command -v docker &> /dev/null; then
        echo "Docker ya está instalado."
        docker --version
        return 0
    fi

    sudo apt update 
    sudo apt install apt-transport-https ca-certificates curl software-properties-common
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
    sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu focal stable"
    sudo apt update
    apt-cache policy docker-ce
    sudo apt install docker-ce
    #sudo systemctl status docker

    # Agregar el usuario actual al grupo docker
    echo "Agregando el usuario '${usuarioact}' al grupo docker..."
    sudo usermod -aG docker ${usuarioact}
    newgrp docker

    # Confirmar que el usuario ha sido agregado al grupo
    id -nG
}

montar_apache(){
    verificar_docker || return 1
    # Buscar y montar una imagen de Apache
    docker search httpd
    docker pull httpd
    docker run -d --name apache_server -p 8080:80 httpd
    echo "Apache montado correctamente. Ingrese con http://10.0.0.16:8080"

}

modificar_apache(){
    verificar_docker || return 1
    # Modificar el index.html de apache
    mkdir apachev2
    cd apachev2
    echo "<h1>Hola desde Docker, yo personalice esto profe Herman, saludos</h1>" > index.html

    docker run -d --name apache_personalizado -p 8081:80 -v $(pwd)/index.html:/usr/local/apache2/htdocs/index.html httpd
    cd ..
    echo "Apache modificado correctamente. Ingrese con http://10.0.0.16:8081"

}

crear_dockerfile(){
    verificar_docker || return 1
    cd apachev2
    # Crear un Dockerfile para personalizar la imagen de Apache
    touch Dockerfile
    sudo tee -a Dockerfile > /dev/null <<EOF
    # Dockerfile
    FROM httpd
    COPY index.html /usr/local/apache2/htdocs/index.html
EOF
    docker build -t apache_personalizado .
    docker run -d --name apache_clonado -p 8082:80 apache_personalizado
    echo "Imagen creada correctamente. Ingrese con http://10.0.0.16:8082"
}

# Crea contenedores con PostgreSQL y red para comunicación
contenedores_postgres(){
    verificar_docker || return 1
    docker pull postgres
    docker network create red_alumnos_profes

    docker run -d --name postgres_profes --network red_alumnos_profes \
      -e POSTGRES_DB=profes \
      -e POSTGRES_USER=profe \
      -e POSTGRES_PASSWORD=clave123 \
      postgres

    docker run -d --name postgres_alumnos --network red_alumnos_profes \
      -e POSTGRES_DB=alumnos \
      -e POSTGRES_USER=alumno \
      -e POSTGRES_PASSWORD=clave123 \
      postgres

    # Espera a que se inicien los contenedores
    sleep 5

    # Crear tablas y datos
    docker exec -i postgres_profes psql -U profe -d profes <<EOF
CREATE TABLE profesores(id SERIAL PRIMARY KEY, nombre TEXT);
INSERT INTO profesores(nombre) VALUES ('Herman'), ('Mirsa'), ('Karla'), ('Manuel'), ('Mike'), ('Edgar');
EOF

    docker exec -i postgres_alumnos psql -U alumno -d alumnos <<EOF
CREATE TABLE alumnos(id SERIAL PRIMARY KEY, nombre TEXT);
INSERT INTO alumnos(nombre) VALUES ('Andrea'), ('Paola'), ('Eduardo'), ('Santiago'), ('Humberto'), ('Paulina');
EOF
}

comunicacion_contenedores(){
    verificar_docker || return 1
    docker run -it --rm --network red_alumnos_profes \
  -e PGPASSWORD=clave123 \
  postgres psql -h postgres_profes -U profe -d profes -c "SELECT * FROM profesores;"
}

comunicacion_contenedores2(){
    verificar_docker || return 1
    docker run -it --rm --network red_alumnos_profes \
  -e PGPASSWORD=clave123 \
  postgres psql -h postgres_alumnos -U alumno -d alumnos -c "SELECT * FROM alumnos;"
}