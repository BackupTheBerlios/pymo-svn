#!/bin/bash 
#
# PyMO Server network installer.
# Copyright (C) 2001-2005 Fundaci�n Via Libre
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

$DIALOG --clear --title "Tipo de conexi�n" \
        --menu "Elija a continuaci�n el tipo de conexi�n a Internet que \
posee\n" 20 51 4 \
        "Dedicado"  " IP de un enlace dedicado" \
	"Local" "Usando la puerta de enlaces de la red" \
        "ADSL" "Conexi�n a trav�s de una l�nea " \
        "Ninguno" "Sin conexi�n a Internet"  2> $tempfile

retval=$?

conexion=`cat $tempfile`

case $retval in
  0)
    echo "s|CONEXION|'$conexion'|g" >>$parametros;;
  1)
    exit 1;; 
# Elijio Cancel
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
        --inputbox "El n�mero de IP del equipo es el que identifica a esta \
m�quina dentro de la red local.\n\
A continuaci�n ingrese el IP de este equipo.\n\
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
# Elijo Cancel
    exit 1;;
  255)
# Apreto ESC
    exit 1;;
esac
done
}

mascara_equipo () {
OK=
resultado=
while [ ! $OK ]; do

$DIALOG --title "M�scara de red" --clear \
        --inputbox "La m�scara de red es un n�mero que delimita el rango en \
la red IP de  esta m�quina.\n\
A continuaci�n ingrese la mascara de red.\n\
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
# Elijo Cancel
    exit 1;;
  255)
# Apreto ESC
    exit 1;;
esac
done

}


gateway_equipo () {
resultado=
OK=
while [ ! $OK ]; do

$DIALOG --title "Puerta de enlace por defecto" --clear \
        --inputbox "La puerta de enlace por defecto es el n�mero de IP del \
equipo de conexi�n que conecta a esta red con Internet.\n\
A continuaci�n ingrese la puerta de enlace por defecto.\n\
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
# Elijo Cancel
    exit 1;;
  255)
# Apreto ESC
    exit 1;;
esac
done
}



ip_externo() {
resultado=
OK=
while [ ! $OK ]; do

$DIALOG --title "IP de Internet" --clear \
        --inputbox "El n�mero de IP del equipo es el que identifica a esta \
m�quina dentro de la red Internet.\n\
A continuaci�n ingrese el IP de este equipo.\n\
Este campo no puede quedar vac�o" 16 51 $resultado 2>$tempfile

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
        error "Este campo no puede quedar vac�o"
	
    fi;;
    
  1)
# Elijo Cancel
    exit 1;;
  255)
# Apreto ESC
    exit 1;;
esac
done
}

mascara_externo() {
OK=
resultado=
while [ ! $OK ]; do

$DIALOG --title "M�scara de red" --clear \
        --inputbox "La m�scara de red es un n�mero que delimita el rango en \
la red de esta m�quina.\n\
A continuaci�n ingrese la mascara de red.\n\
Este campo no puede quedar vac�o" 16 51 $resultado 2> $tempfile

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
        error "Este campo no puede quedar vac�o"
    fi
    ;;
  1)
# Elijo Cancel
    exit 1;;
  255)
# Apreto ESC
    exit 1;;
esac
done

}


gateway_externo() {
resultado=
OK=
while [ ! $OK ]; do

$DIALOG --title "Puerta de enlace" --clear \
        --inputbox "La puerta de enlace es el n�mero de IP del \
equipo de conexi�n (router) que permite la conexi�n con Internet.\n\
A continuaci�n ingrese la puerta de enlace por defecto.\n\
Este campo no puede quedar vac�o" 16 51 $redultado 2> $tempfile

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
        error "Este campo no puede quedar vac�o"
    fi
    ;;
  1)
# Elijo Cancel
    exit 1;;
  255)
# Apreto ESC
    exit 1;;
esac
done
}



usuario_ppp() {

OK=
while [ ! $OK ]; do

$DIALOG --title "Nombre de Usuario de la conexi�n" --clear \
        --inputbox "El nombre de usuario de la conexi�n es el asignado \
por el proveedor de Internet para la conexi�n.\n\
A continuaci�n ingrese su nombre de usuario.\n\
Este campo no puede quedar en blanco." 16 51 2> $tempfile

retval=$?

case $retval in
  0)
    if [ `cat $tempfile` ] ; then
        echo "s|PPP_USER|`cat $tempfile`|g" >>$parametros
	OK=1
    else
	error "Este campo no puede quedar vac�o"
    fi
    ;;    
  1)
# Elijo Cancel
    exit 1;;
  255)
# Apreto ESC
    exit 1;;
esac

done

}


password_ppp() {

OK=
while [ ! $OK ]; do

$DIALOG --title "Clave de la conexi�n" --clear \
        --passwordbox "La clave de la conexi�n es el asignado \
por el proveedor de Internet para la conexi�n.\n\
A continuaci�n ingrese su clave de conexi�n.\n\
Este campo no puede quedar en blanco." 16 51 2> $tempfile

retval=$?

case $retval in
  0)
    if [ `cat $tempfile` ] ; then
        echo "s|PPP_PASSWORD|`cat $tempfile`|g" >>$parametros
	OK=1
    else
	error "Este campo no puede quedar vac�o"
    fi
    ;;    
  1)
# Elijo Cancel
    exit 1;;
  255)
# Apreto ESC
    exit 1;;
esac

done

}

telefono_ppp() {
resultado=
OK=
while [ ! $OK ]; do

$DIALOG --title "N�mero de Tel�fono" --clear \
        --inputbox "El n�mero de tel�fono lo da el proveedor de Internet, \
si est� conectado a trav�s de una central telef�nica recuerde anteponer el \
n�mero para obtener l�nea separado por 2 comas del tel�fono del proveedor \
de Internet.\n\
A continuaci�n ingrese el n�mero de tel�fono.\n\
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
	error "El n�mero de tel�fono no tiene un formato correcto"
    fi
    ;;    
  1)
# Elijo Cancel
    exit 1;;
  255)
# Apreto ESC
    exit 1;;
esac

done

}


ip_dns1() {
resultado=
OK=
while [ ! $OK ]; do

$DIALOG --title "DNS primario" --clear \
        --inputbox "El DNS es el que convierte de nombre a n�mero de IP. \
	A continuaci�n ingrese el IP del DNS primario.\n\
Este campo no puede quedar vac�o" 16 51 $resultado 2>$tempfile

retval=$?
resultado=`cat $tempfile`
case $retval in
  0)
    if [ $resultado ] ; then
    
	if [ `echo $resultado |egrep "^[0-9]{2,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}"` ] ; then
    	    echo "s|REDIRECTOR_DNS1|$resultado|g" >>$parametros
	    OK=1
	else
	    error "El formato no es correcto."
	fi
    else
        error "Este campo no puede quedar vac�o"
	
    fi;;
    
  1)
# Elijo Cancel
    exit 1;;
  255)
# Apreto ESC
    exit 1;;
esac
done
}

ip_dns2() {
resultado=
OK=
while [ ! $OK ]; do

$DIALOG --title "DNS secundario" --clear \
        --inputbox "El DNS es el que convierte de nombre a n�mero de IP. \
	A continuaci�n ingrese el IP del DNS secundario.\n\
Este campo no puede quedar vac�o" 16 51 $resultado 2>$tempfile

retval=$?
resultado=`cat $tempfile`
case $retval in
  0)
    if [ $resultado ] ; then
    
	if [ `echo $resultado |egrep "^[0-9]{2,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}"` ] ; then
    	    echo "s|REDIRECTOR_DNS2|$resultado|g" >>$parametros
	    OK=1
	else
	    error "El formato no es correcto."
	fi
    else
        error "Este campo no puede quedar vac�o"
	
    fi;;
    
  1)
# Elijo Cancel
    exit 1;;
  255)
# Apreto ESC
    exit 1;;
esac
done
}


ipdhcp() {

    pregunta "Desea obtener la configuraci�n de la red usando DHCP"
	    sino1=$?
	    if [ $sino1 == "0" ]; then
		dhcp="si"		
	    else
		dhcp="no"
	    fi

} 

findnic() {

    pcinic=`lspci |grep "Ethernet controller" |wc -l`
    nicdev=`dmesg  |awk '/eth/ {print $1}' |sort|uniq|wc -l`

    if [ $pcinic -lt '1' ] ; then 
	if [ $nicdev  -lt '1' ] ; then

	    error "No se encontr� ninguna placa de red PCI y se pudo cargar \
	    ninguna placa de red ISA. Es necesario tener una placa de red \
	    disponible para que el PyMO server pueda trabajar. Si la maquina \
	    tiene una placa de red y no fue detectada, ignore este mensaje y \
	    una vez finalizada la instalaci�n trate de activar la placa de red."

	fi

    else
    
	if [ $nicdev  -lt '1' ] ; then

	    error "Se encontr� por lo menos una placa de red PCI pero no se \
	    cargar el driver correspondiente. Es necesario tener una placa de \
	    red disponible para que el PyMO server pueda trabajar. Una vez \
	    finalizada la instalaci�n trate de activar la placa de red."

	fi
    fi
    
} 

find2nic() {

    pcinic=`lspci |grep "Ethernet controller" |wc -l`
    nicdev=`dmesg  |awk '/eth/ {print $1}' |sort|uniq|wc -l`

    if [ $pcinic -lt '2' ] ; then 
	if [ $nicdev  -lt '2' ] ; then

	    error "Esta configuraci�n requiere 2 placas de red, pero se \
	    detectaron $picnic placa/s de red PCI y se han podido configurar \
	    $nicdev placa/s. Si la maquina tiene las 2 placas de red y no \
	    fueron detectadas correctamente, ignore este mensaje y \
	    una vez finalizada la instalaci�n trate de activar la placa de red."

	fi

    else
    
	if [ $nicdev  -lt '2' ] ; then

	    error "No se han podido cargar el driver alguna/s de las placas \
	    de red. Por lo que hay: $nicdev placas disponibles y se necesitan \
	    2 para esta configuraci�n. Una vez finalizada la instalaci�n trate \
	    de activar la/s placa/s de red."


	fi
    fi
    
} 
