#!/bin/bash 
#
# PyMO Server main installer.
# Copyright (C) 2001-2005 Fundación Vía Libre
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


mensaje "Bienvenido al asistente para la instalación del Servidor \
para Pequeña y medianas organizaciones de la Fundación Vía Libre."

mensajebig "Recuerde que el PyMO server es un proyecto que se \
encuentra en desarrollo, es decir, puede tener errores. Si \
encuentra alguno, por favor no dude en reportarlo. Lo mismo con \
respecto a cualquier sugerencia que Ud. pueda tener.\
\n\nContar con su opinión o reporte de errores nos ayudará a seguir \
mejorando esta distribución. Esas mejoras se verán reflejadas \
en cada una de las próximas versiones."

mensajebig "También nos interesa saber si la instalación resultó \
exitosa o si ocurrió algún imprevisto que la impidió.\
\n\nPor favor, tanto para reporte de errores, como sugerencias o para \
avisarnos si la instalación resultó exitosa o no, envíenos un \
correo electrónico a: pymoserver@vialibre.org.ar"

#Ingresamos en nombre de la organizacion
nombre_empresa

#Ingresamos el codigo de pais
codigo_pais

#Ingresamos la provincia
provincia

#Ingresamos la ciudad
ciudad

#Ingresamos el nombre de la maquina
nombre_equipo

#Ingresamos el dominio
nombre_dominio

#Generamos los parametros del LDAP
parametros_ldap

# Elejimos el tipo de conexion
tipo_conexion


#numerored_equipo
if [ "$conexion" = "Dedicado" ]; then

    find2nic

    # Tomamos los datos de la red local
    ip_equipo
    mascara_equipo
    ipdhcp
    if [ "$dhcp" = "no" ]; then
	ip_externo
	mascara_externo
	gateway_externo
	ip_dns1
	ip_dns2
    fi
fi


if [ "$conexion" = "Local" ]; then

    findnic
    dhcp="no" 
#    ipdhcp
#    if [[ $dhcp = 'no' ]]; then
	# Tomamos los datos de la red local
	ip_equipo
	mascara_equipo
	gateway_equipo
	ip_dns1
	ip_dns2
#    fi
fi


# Si la conexion es via modem tenemos que pedir usuario, password, telefono
if [ "$conexion" = "Modem" ]; then
    # pedimos el usuario
    usuario_ppp
    
    # pedimos el password
    password_ppp
    
    # pedimos el numero de telefono
    telefono_ppp
    
fi

# Si la conexion es via ADSL tenemos que pedir usuario y password
if [ "$conexion" = "ADSL" ]; then

    find2nic

    # Tomamos los datos de la red local
    ip_equipo
    mascara_equipo
    # pedimos el usuario
    usuario_ppp
    
    # pedimos el password
    password_ppp
    
    #Necesitamos los DNS
    ip_dns1
    ip_dns2
fi

if [ "$conexion" = "Ninguno" ]; then

    findnic
    dhcp="no" 
#    ipdhcp
#    if [[ $dhcp = 'no' ]]; then
	# Tomamos los datos de la red local
	ip_equipo
	mascara_equipo
#    fi
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
instalar_grub

# Entramos a la instalacion y hacemos el post-install
chroot /mnt /root/setup.sh

#rm -f /mnt/root/setup.sh

umount /mnt

mensaje "Se ha completado con éxito la instalación del servidor. \
Recuerde leer la documentación para administrar el equipo."

# Reiniciamos la maquina
/sbin/shutdown -r now

