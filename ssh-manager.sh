#!/bin/bash
# -------------------------------------------------------------------
# SSH-Manager - Script de automatización SSH/ADB para Ubuntu
# Copyright (c) 2026 Eletrero
# Licencia: MIT (Permite uso comercial, modificación y distribución) 
# Repositorio Original: https://github.com/[TuUsuario]/[TuProyecto]
# -------------------------------------------------------------------

# --- Definición de Colores ---
ROJO='\033[0;31m'
VERDE='\033[0;32m'
AMARILLO='\033[1;33m'
AZUL='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' 

ARCHIVO_DATOS="$HOME/.ssh_conexiones.txt"
touch "$ARCHIVO_DATOS"

# --- Diccionario de Errores ---
# Esta función centraliza los mensajes para que sea fácil compartirlos.
lanzar_error() {
    case $1 in
        "ERR-01") echo -e "${ROJO}$1: No hay conexión ADB. Verifica el cable o los permisos en el celular.${NC}" ;;
        "ERR-02") echo -e "${ROJO}$1: Fallo en la conexión SSH. Revisa IP/Usuario o la red.${NC}" ;;
        "ERR-03") echo -e "${ROJO}$1: El archivo de conexiones está vacío o no existe.${NC}" ;;
        "ERR-04") echo -e "${ROJO}$1: Opción no válida. Selección fuera de rango.${NC}" ;;
        "ERR-05") echo -e "${ROJO}$1: Error al intentar guardar los datos.${NC}" ;;
    esac
    read -p "Presiona Enter para continuar..."
}

mostrar_menu() {
    clear
    echo -e "${AZUL}==========================================${NC}"
    echo -e "${CYAN}    GESTOR DE CONEXIONES SSH (UBUNTU)${NC}"
    echo -e "${AZUL}==========================================${NC}"
    echo -e "${AMARILLO}1)${NC} Nueva conexión por Cable (ADB)"
    echo -e "${AMARILLO}2)${NC} Nueva conexión por Wi-Fi"
    echo -e "${AMARILLO}3)${NC} Usar conexión guardada"
    echo -e "${AMARILLO}4)${NC} Configurar Llave SSH (Sin contraseña)"
    echo -e "${AMARILLO}5)${NC} Salir"
    echo -e "${AZUL}==========================================${NC}"
    echo -ne "${VERDE}Selecciona una opción: ${NC}"
}

conectar_y_guardar() {
    local tipo=$1; local user=$2; local host=$3; local port=$4
    echo -e "\n${CYAN}>> Intentando conectar a $user@$host:$port...${NC}"
    
    ssh -o ConnectTimeout=5 "$user@$host" -p "$port"

    if [ $? -eq 0 ]; then
        echo -e "\n${VERDE}✔ Conexión finalizada con éxito.${NC}"
        read -p "¿Quieres guardar esta conexión? (s/n): " guardar
        if [[ "$guardar" == "s" || "$guardar" == "S" ]]; then
            echo "$tipo|$user|$host|$port" >> "$ARCHIVO_DATOS" || lanzar_error "ERR-05"
        fi
    else
        lanzar_error "ERR-02"
    fi
}

while true; do
    mostrar_menu; read opcion
    case $opcion in
        1)
            echo -e "\n${AMARILLO}--- Configuración ADB ---${NC}"
            read -p "Puerto a leer/redirigir (ej. 2222): " pl
            read -p "Usuario: " u
            # Aplicando tu configuración de puertos simétricos
            adb forward tcp:"$pl" tcp:"$pl" 2>/dev/null
            if [ $? -ne 0 ]; then lanzar_error "ERR-01"; continue; fi
            conectar_y_guardar "ADB" "$u" "localhost" "$pl"
            ;;
        2)
            echo -e "\n${AMARILLO}--- Configuración Wi-Fi ---${NC}"
            read -p "Dirección IP: " ip; read -p "Usuario: " u; read -p "Puerto (22): " p
            conectar_y_guardar "WiFi" "$u" "$ip" "${p:-22}"
            ;;
        3)
            if [ ! -s "$ARCHIVO_DATOS" ]; then lanzar_error "ERR-03"; continue; fi
            IFS=$'\n' lineas=($(cat "$ARCHIVO_DATOS"))
            for i in "${!lineas[@]}"; do
                IFS='|' read -r t u h p <<< "${lineas[$i]}"
                echo -e "${CYAN}$((i+1)))${NC} [${AZUL}$t${NC}] $u@$h:${AMARILLO}$p${NC}"
            done
            read -p "Selecciona número: " n
            if [[ "$n" =~ ^[0-9]+$ ]] && [ "$n" -le "${#lineas[@]}" ]; then
                IFS='|' read -r t u h p <<< "${lineas[$((n-1))]}"
                [[ "$t" == "ADB" ]] && adb forward tcp:"$p" tcp:"$p"
                ssh "$u@$h" -p "$p" || lanzar_error "ERR-02"
            else
                lanzar_error "ERR-04"
            fi
            ;;
        4) 
            echo -e "\n${AMARILLO}--- Configuración de Llave ---${NC}"
            [ ! -f ~/.ssh/id_ed25519 ] && ssh-keygen -t ed25519 -N "" -f ~/.ssh/id_ed25519
            read -p "Usuario: " u; read -p "Host: " h; read -p "Puerto: " p
            ssh-copy-id -p "$p" "$u@$h" || lanzar_error "ERR-02"
            ;;
        5) exit 0 ;;
        *) lanzar_error "ERR-04" ;;
    esac
done
