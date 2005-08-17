#!/bin/bash
# PyMO Server network installer.
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

. $INSTDIR/install-funciones.sh

tipo_conexion() {

$DIALOG --clear --title "Tipo de conexion" \
        --menu "Elija a continuacion el tipo de conexion a internet que \
posee\n" 20 51 4 \
        "Dedicado"  "Un IP de un enlace dedicado" \
	"Local" "Usando la puerta de enlacen de la red" \
        "ADSL" "Conexion a travez de una linea " \
        "Modem" "Mediante un modem llamando por telefono" \
        "Ninguno" "Sin conexion a internet"  2> $tempfile

retval=$?

conexion=`cat $tempfile`

case $retval in
  0)
    echo "s|CONEXION|'$conexion'|g" >>$parametros;;
  1)
    exit 1;; 
# Apreto el Cancel
  255)
    exit 1;;
# Apreto escape
esac

}

ip_equipo () {
resultado=
OK=
while [ ! $OK ]; do

$DIALOG --title "IP del equipo" --clear \
        --inputbox "El numero de IP del equipo es el que identifica a esta\
maquina dentro de la red local.\n\
A continuacion ingrese el IP de este equipo.\n\
Si no ingresa nada, por defecto es \"172.16.1.1\"" 16 51 $resultado 2>$tempfile

retval=$?
resultado=`cat $tempfile`
case $retval in
  0)
    if [ $resultado ] ; then
    
	if [ `echo $resultado |egrep "^[0-9]{2,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}"` ] ; then
    	    echo "s|IP_INTERNA|$resultado|g" >>$parametros
	    OK=1
	    ip_interna=$resultado
	else
	    error "El formato no es correcto."
	fi
    else
        echo "s|IP_INTERNA|172.16.1.1|g" >>$parametros
	OK=1
	ip_interna="172.16.1.1"
    fi;;
    
  1)
# El tipo elijo Cancel
    exit 1;;
  255)
# El tipo apreto ESC
    exit 1;;
esac
done
}

mascara_equipo () {
OK=
resultado=
while [ ! $OK ]; do

$DIALOG --title "Mascara de red" --clear \
        --inputbox "La mascara de red es un numero que delimita el rango de\
la red IP en la que esta esta maquina.\n\
A continuacion ingrese la mascara de red.\n\
Si no ingresa nada, por defecto es \"255.255.255.0\"" 16 51 $resultado 2> $tempfile

retval=$?
resultado=`cat $tempfile`

case $retval in
  0)
    if [ $resultado ] ; then
	if [ `echo $resultado |egrep "^255\.(255|0)\.(255|0)\.(255|0)"` ] ; then
    	    echo "s|MASK_INTERNA|`cat $tempfile`|g" >>$parametros
	    OK=1
	    mask_interna=$resultado
	else
	    error "El formato no es correcto."
	fi
    else
        echo "s|MASK_INTERNA|255.255.255.0|g" >>$parametros
	OK=1
	mask_interna="255.255.255.0"
    fi
    ;;
  1)
# El tipo elijo Cancel
    exit 1;;
  255)
# El tipo apreto ESC
    exit 1;;
esac
done

}


gateway_equipo () {
resultado=
OK=
while [ ! $OK ]; do

$DIALOG --title "Puerta de enlace por defecto" --clear \
        --inputbox "La puerta de enlace por defecto es el numero de IP del\
equipo de conexion que conecta a esta red con internet.\n\
A continuacion ingrese la puerta de enlace por defecto.\n\
Si no ingresa nada, por defecto es \"172.16.1.254\"" 16 51 $redultado 2> $tempfile

retval=$?
resultado=`cat $tempfile`
case $retval in
  0)
    if [ $resultado ] ; then
	if [ `echo $resultado |egrep "^[0-9]{2,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}"` ] ; then
            echo "s|GW_INTERNA|`cat $tempfile`|g" >>$parametros
	    OK=1
	else
	    error "El formato no es correcto."
	fi
    else
        echo "s|GW_INTERNA|172.16.1.254|g" >>$parametros
	OK=1
    fi
    ;;
  1)
# El tipo elijo Cancel
    exit 1;;
  255)
# El tipo apreto ESC
    exit 1;;
esac
done
}



ip_externo() {
resultado=
OK=
while [ ! $OK ]; do

$DIALOG --title "IP de Internet" --clear \
        --inputbox "El numero de IP del equipo es el que identifica a esta\
maquina dentro de la red IP.\n\
A continuacion ingrese el IP de este equipo.\n\
Este campo no puede quedar vacio" 16 51 $resultado 2>$tempfile

retval=$?
resultado=`cat $tempfile`
case $retval in
  0)
    if [ $resultado ] ; then
    
	if [ `echo $resultado |egrep "^[0-9]{2,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}"` ] ; then
    	    echo "s|IP_EXTERNA|$resultado|g" >>$parametros
	    OK=1
	else
	    error "El formato no es correcto."
	fi
    else
        error "Este campo no puede quedar vacio"
	
    fi;;
    
  1)
# El tipo elijo Cancel
    exit 1;;
  255)
# El tipo apreto ESC
    exit 1;;
esac
done
}

mascara_externo() {
OK=
resultado=
while [ ! $OK ]; do

$DIALOG --title "Mascara de red" --clear \
        --inputbox "La mascara de red es un numero que delimita el rango de\
la red IP en la que esta esta maquina.\n\
A continuacion ingrese la mascara de red.\n\
Este campo no puede quedar vacio" 16 51 $resultado 2> $tempfile

retval=$?
resultado=`cat $tempfile`

case $retval in
  0)
    if [ $resultado ] ; then
	if [ `echo $resultado |egrep "^255\.255\.255\.[0-9]{1,3}"` ] ; then
    	    echo "s|MASK_EXTERNA|`cat $tempfile`|g" >>$parametros
	    OK=1
	else
	    error "El formato no es correcto."
	fi
    else
        error "Este campo no puede quedar vacio"
    fi
    ;;
  1)
# El tipo elijo Cancel
    exit 1;;
  255)
# El tipo apreto ESC
    exit 1;;
esac
done

}


gateway_externo() {
resultado=
OK=
while [ ! $OK ]; do

$DIALOG --title "Puerta de enlace" --clear \
        --inputbox "La puerta de enlace es el numero de IP del\
equipo de conexion (router) que permite la conexion con internet.\n\
A continuacion ingrese la puerta de enlace por defecto.\n\
Este campo no puede quedar vacio" 16 51 $redultado 2> $tempfile

retval=$?
resultado=`cat $tempfile`
case $retval in
  0)
    if [ $resultado ] ; then
	if [ `echo $resultado |egrep "^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}"` ] ; then
            echo "s|GW_EXTERNA|`cat $tempfile`|g" >>$parametros
	    OK=1
	else
	    error "El formato no es correcto."
	fi
    else
        error "Este campo no puede quedar vacio"
    fi
    ;;
  1)
# El tipo elijo Cancel
    exit 1;;
  255)
# El tipo apreto ESC
    exit 1;;
esac
done
}



usuario_ppp() {

OK=
while [ ! $OK ]; do

$DIALOG --title "Nombre de Usuario de la conexion" --clear \
        --inputbox "El nombre de usuario de la conexion es el asignado \
por el proveedor de internet para la conexion.\n\
A continuacion ingrese su nombre de usuario.\n\
Este campo no puede quedar en blanco." 16 51 2> $tempfile

retval=$?

case $retval in
  0)
    if [ `cat $tempfile` ] ; then
        echo "s|PPP_USER|`cat $tempfile`|g" >>$parametros
	OK=1
    else
	error "Este campo no puede quedar vacio"
    fi
    ;;    
  1)
# El tipo elijo Cancel
    exit 1;;
  255)
# El tipo apreto ESC
    exit 1;;
esac

done

}


password_ppp() {

OK=
while [ ! $OK ]; do

$DIALOG --title "Clave de la conexion" --clear \
        --passwordbox "La clave de la conexion es el asignado \
por el proveedor de internet para la conexion.\n\
A continuacion ingrese su clave de conexio.\n\
Este campo no puede quedar en blanco." 16 51 2> $tempfile

retval=$?

case $retval in
  0)
    if [ `cat $tempfile` ] ; then
        echo "s|PPP_PASSWORD|`cat $tempfile`|g" >>$parametros
	OK=1
    else
	error "Este campo no puede quedar vacio"
    fi
    ;;    
  1)
# El tipo elijo Cancel
    exit 1;;
  255)
# El tipo apreto ESC
    exit 1;;
esac

done

}

telefono_ppp() {
resultado=
OK=
while [ ! $OK ]; do

$DIALOG --title "Numero de Telefono" --clear \
        --inputbox "El numero de telefono lo da el proveedor de internet, \
si esta conectado a traves de una central telefonica recuerde anteponer el \
numero para obtener linea separado por 2 comas del telefono del proveedor \
de internet.\n\
A continuacion ingrese el numero de telefono.\n\
Este campo no puede quedar en blanco." 16 51 $resultado 2> $tempfile

retval=$?
resultado=`cat $tempfile`
case $retval in
  0)
    if [ `echo $resultado |egrep "^[0-9,]{5,}"` ] ; then
	dominio=`cat $tempfile`
        echo "s|PPP_TELEFONO|`cat $tempfile`|g" >>$parametros
	OK=1
    else
	error "El numero de telefono no tiene un formato correcto"
    fi
    ;;    
  1)
# El tipo elijo Cancel
    exit 1;;
  255)
# El tipo apreto ESC
    exit 1;;
esac

done

}

 