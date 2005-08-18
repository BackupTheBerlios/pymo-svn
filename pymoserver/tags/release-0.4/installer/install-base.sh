#!/bin/bash
# PyMO Server base installer.
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

nombre_equipo() {

$DIALOG --title "Nombre del equipo" --clear \
        --inputbox "El nombre del equipo es el que identifica a esta\
maquina. Todos los equipos deben tener un nombre.\n\
A continuacion ingrese el nombre de este equipo.\n\
Si no ingresa nada, por defecto es \"vlps\"" 16 51 2> $tempfile

retval=$?

case $retval in
  0)
    if [ `cat $tempfile` ] ; then
        echo "s|NOMBRE_MAQUINA|`cat $tempfile`|g" >>$parametros
    else
        echo "s|NOMBRE_MAQUINA|vlps|g" >>$parametros
    fi
    ;;
  1)
# El tipo elijo Cancel
    exit 1;;
  255)
# El tipo apreto ESC
    exit 1;;
esac

}

nombre_dominio() {
resultado=
OK=
while [ ! $OK ]; do

$DIALOG --title "Nombre de Domino" --clear \
        --inputbox "El nombre de Dominio es el que identifica a esta \
organizacion dentro de internet. Ejemplo de dominios son: vialibre.org.ar, \
cordoba.com.ar, csoft.net\n\
A continuacion ingrese su nombre de dominio.\n\
Este campo no puede quedar en blanco." 16 51 $resultado 2> $tempfile

retval=$?
resultado=`cat $tempfile`
case $retval in
  0)
    if [ `echo $resultado |egrep "^[a-z][0-9a-z]{2,}\.[a-z]{2,}"` ] ; then
	dominio=$resultado
	dominio_smb=`echo $dominio|awk -F"." '{print $1}'` 
        echo "s|DOMINIO_MAQUINA|$dominio|g" >>$parametros
        echo "s|DOMINIO_SMB|$dominio_smb|g" >>$parametros
	OK=1
    else
	echo $tempfile
	error "El nombre de dominio no es correcto"
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

