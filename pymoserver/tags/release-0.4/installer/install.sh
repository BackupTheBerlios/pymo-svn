#!/bin/bash
# PyMO Server installer.
# Copyright (C) 2001-2003 Fundación Via Libre
#
# This program is free software; you can redistribute it and/or modify it
# under the terms of the GNU General Public License as published by the
# Free Software Foundation; either version 2 of the License, or (at your
# option) any later version.
#
# This program is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# General Public License for more details.
#
# You should have received a copy of the GNU General Public License along
# with this program; if not, write to: The Free Software Foundation, Inc.,
# 59 Temple Place, Suite 330, Boston, MA 02111-1307, USA.
#
# On Debian GNU/Linux System you can find a copy of the GNU General Public
# License in "/usr/share/common-licenses/GPL".

DIALOG=${DIALOG=dialog}
tempfile=`tempfile 2>/dev/null` || tempfile=/tmp/test$$
trap "rm -f $tempfile" 0 1 2 5 15
parametros=/tmp/parametros_instalacion.txt
export PATH=/sbin:/usr/sbin:$PATH
LOGFILE=/tmp/instalacion.log
INSTDIR=/install

. $INSTDIR/install-base.sh
. $INSTDIR/install-red.sh
. $INSTDIR/install-disco.sh


mensaje "Bienvenido al asistente para la instalacion del Sevidor \
para Pequenias Organizaciones de la Fundacion Via Libre."

#Ingresamos el nombre de la maquina
nombre_equipo

#Ingresamos el dominio
nombre_dominio

#Generamos los parametros del LDAP
parametros_ldap

# Elejimos el tipo de conexion
tipo_conexion

# Tomamos los datos de la red local
ip_equipo
mascara_equipo

#numerored_equipo
if [[ $conexion = 'Dedicado' ]]; then
    ip_externo
    mascara_externo
    gateway_externo
fi


if [[ $conexion = 'Local' ]]; then
    gateway_equipo
fi

# Si la conexion es via modem tenemos que pedir usuario, password, telefono
if [[ $conexion = 'Modem' ]]; then
    # pedimos el usuario
    usuario_ppp
    
    # pedimos el password
    password_ppp
    
    # pedimos el numero de telefono
    telefono_ppp
    
fi

# Si la conexion es via ADSL tenemos que pedir usuario y password
if [[ $conexion = 'ADSL' ]]; then
    # pedimos el usuario
    usuario_ppp
    
    # pedimos el password
    password_ppp
    
fi

# Calculamos algunos parametros con los datos ingresados
parametros_red

# Definiciones por defecto
parametros_otros

# Elejimos el disco y lo particionamos
particion

# Desempacamos el tar y copiamos los archivos
copiar_archivos

# Configuramos las cosas que hacen falta
configurar_servidor

# Instalamos lilo y desmontamos el disco
instalar_lilo

mensaje "Se ha completado con exito la instalacion del servidor. \
Recuerde leer la documentacion para administrar el equipo."

# Reiniciamos la maquina
/sbin/shutdown -r now

# Altenativamente podemos cambiar el rootfs y "pasarnos" al servidor sin 
# reiniciar
# booteo_magico


