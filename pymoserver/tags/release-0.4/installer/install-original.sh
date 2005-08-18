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


tipo_conexion() {

$DIALOG --clear --title "Tipo de conexion" \
        --menu "Elija a continuacion el tipo de conexion a internet que \
posee\n" 20 51 4 \
        "Dedicado"  "Un IP de un enlace dedicado" \
        "ADSL" "Conexion a travez de " \
        "Modem" "Mediante un modem llamando por telefono" \
        "Ninguno" "Sin conexion a internet"  2> $tempfile

retval=$?

conexion=`cat $tempfile`

case $retval in
  0)
    echo "CONEXION = '$conexion'" >>$parametros;;
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
maquina dentro de la red IP.\n\
A continuacion ingrese el IP de este equipo.\n\
Si no ingresa nada, por defecto es \"172.16.1.1\"" 16 51 $resultado 2>$tempfile

retval=$?
resultado=`cat $tempfile`
case $retval in
  0)
    if [ $resultado ] ; then
    
	if [ `echo $resultado |egrep "^[0-9]{2,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}"` ] ; then
    	    echo "IP_INTERNA = $resultado" >>$parametros
	    OK=1
	else
	    error "El formato no es correcto."
	fi
    else
        echo "IP_INTERNA = 172.16.1.1" >>$parametros
	OK=1
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
	if [ `echo $resultado |egrep "^[0-9]{2,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}"` ] ; then
    	    echo "MASK_INTERNA = `cat $tempfile`" >>$parametros
	    OK=1
	else
	    error "El formato no es correcto."
	fi
    else
        echo "MASK_INTERNA = 255.255.255.0" >>$parametros
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
            echo "GW_INTERNA = `cat $tempfile`" >>$parametros
	    OK=1
	else
	    error "El formato no es correcto."
	fi
    else
        echo "GW_INTERNA = 255.255.255.0" >>$parametros
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
        echo "NOMBRE_MAQUINA = `cat $tempfile`" >>$parametros
    else
        echo "NOMBRE_MAQUINA = vlps" >>$parametros
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
        echo "DOMINIO_MAQUINA = $dominio" >>$parametros
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

parametros_ldap() {

    echo "SERVIDOR_LDAP = localhost" >>$parametros
    echo "BASE_LDAP = dc=`echo $dominio |sed -e 's/\./, dc=/g'`" >>$parametros

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
        echo "PPP_USER = `cat $tempfile`" >>$parametros
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
        echo "PPP_PASSWORD = `cat $tempfile`" >>$parametros
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
        echo "PPP_TELEFONO = `cat $tempfile`" >>$parametros
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


error() {

$DIALOG --title "ERROR" \
        --msgbox "$1\n\n\
Presione <Enter> para continuar." 8 51

case $? in
    0)
    ;;
  255)
    ;;
esac


}

advertencia() {

$DIALOG --title "ADVERTENCIA" \
        --yesno "$1\n\n\
Desea continuar?" 10 51

case $? in
    0)
    return 0
    ;;
    1)
    return 1
    ;;
  255)
    ;;
esac

}




particion() {

OK=
while [ ! $OK ]; do

discos=`sfdisk -l |grep "Disk /dev/hd[a-z]\:" |cut -b11-13`
memoria=$((`dmesg |grep Memory| tr "/" " "| tr "k" " " |awk '{ print $2 }'`/1024))

for disco in $discos ; do
    info_disco=`dmesg |grep "^$disco: " |grep -v CHS |cut -b6-|sed 's/ /\\ /g'`
    menu_disco="$menu_disco $disco  \"$info_disco\""
done

eval "$DIALOG --clear --title 'Particionado del disco' \
        --menu 'Elija el disco que desea usar para instalar el servidor' 10 51 4 \
        $menu_disco 2> $tempfile "

retval=$?
disco=`cat $tempfile`

case $retval in
  0)
    ;;
  1)
    exit 1;; 
# Apreto el Cancel
  255)
    exit 1;;
# Apreto escape
esac


$DIALOG --clear --title "Particionado del disco" \
        --menu "Elija a continuacion como quiere realizar el particionado del \
disco\n" 10 51 4 \
        "Automatico"  "Particiona segun por defecto" \
        "Manual" "La particion la hace el usuario" 2> $tempfile

retval=$?

particion=`cat $tempfile`

case $retval in
  0)
    if [[ $particion = 'Automatico' ]] ; then
	advertencia "!! Esto borrara todo el contenido del disco !!"
	sino=$?
	if [ $sino ]; then 
	    advertencia "!! Esta realmente seguro que desea borrar el disco? !!"
	    sino1=$?
	    if [ $sino1 ]; then
		tamanio_disco=$((`fdisk -s /dev/$disco`/1024))
		tamanio_part=$(($tamanio_disco-($memoria*2)))
		cd /tmp
		echo -e "0,$tamanio_part,L,*\n,,S\n" | sfdisk -q -uM /dev/$disco >>$LOGFILE 
		cd /dev
		MAKEDEV $disco
		mke2fs -q /dev/$disco\1
		mkswap /dev/$disco\2
		OK=1
		return 0
	    fi
	fi	    
    else
	advertencia "Debe crear 2 particiones. Una de las particiones tiene \
que ser tipo linux y la otra tipo swap"
	sino=$?
	if [ $sino ]; then 
	    error "Funcion no implementada!"
	    # cfdisk
	    OK=1
	    return 0
	fi	    
    fi
    ;;
  1)
    exit 1;; 
# Apreto el Cancel
  255)
    exit 1;;
# Apreto escape
esac
done
}


copiar_archivos() { 

mount /dev/$disco\1 /mnt
cd /mnt
tar xzvpf /root/vlps-0.3.tgz |awk '{ printf "XXX\n%i\nInstalando: %s\nXXX\n", (cnt++)/158.79,$0}' | $DIALOG --guage "Instalando Archivos" 15 70 
cp -f /root/fstab /mnt/etc/fstab
cp -f /root/lilo.conf /mnt/etc/lilo.conf
lilo -r /mnt
umont /mnt

}

$DIALOG --title "Instalacion de VLPS 0.3" --clear \
        --msgbox "Bienvenido al asistente para la instalacion del Sevidor \
para Pequenias Organizaciones de la Fundacion Via Libre.\n\n\
Presione <Enter> para continuar." 10 51

case $? in
    0)
    if [ -a $parametros ] ; then
	mv $parametros $parametros.old
    fi
    touch $parametros;;
  255)
# El tipo presiono ESC
    exit 1;;
esac

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

particion

copiar_archivos

$DIALOG --title "Instalacion de VLPS 0.3" --clear \
        --msgbox "Se ha completado con exito la instalacion del servidor. \
Recuerde leer la documentacion para administrar el equipo.\n\n\
Presione <Enter> para continuar." 10 51

/sbin/shutdown -r -t now

#NOMBRE_MAQUNA	vlps				Nombre de la maquina.
#DOMINIO_MAQUINA	pymes.com.ar			Nombre de dominio.
#BASE_LDAP	dc=pymes, dc=com, dc=ar		Root del arbol ldap
#SERVIDOR_LDAP	localhost			Ubicacion del LDAP
#IP_INTERNA	192.168.1.50			IP interna
#NET_INTERNA	192.168.1.0			Red insterna
#MASK_INTERNA	255.255.255.0			Mascara de la red interna
#GW_INTERNA	192.168.1.11			Pueta de Enlace red interna
#IF_INTERNA	eth0				Interface red interna
#CT_EXTERNA	none				Tipo de conexion externa. Puede ser none, static, dhcp, adsl, ppp.
#IP_EXTERNA					IP externa
#MASK_EXTERNA					Mascara de la red externa
#IF_EXTERNA					Interface red externa
#PPP_USER					Usuario para el ADSL o el PPP
#PPP_PASSWORD					Password para el ADSL o el PPP
#PPP_TELEFONO					Numero de telefono para el PPP
#PART_ROOT					Particion Root
#PART_BOOT					Particion Boot
#PART_SWAP					Particion Swap
#REDIRECTOR_DNS1					IP del dns forward del bind	
#REDIRECTOR_DNS2					IP del dns forward del bind
#NOMBRE_DNS					Campo NS
#CORREO_DNS					Campo MX
#BUSQUEDA_DNS	fsl.org.ar			Campo search en resolv.conf
#SERVIDOR_DNS1	192.168.1.100			Campo nameserver en resolv.conf
#SERVIDOR_DNS2					Campo nameserver en resolv.conf
#DEBIAN_US	debian.fsl.org.ar/debian-US	Donde busca los archivos para debian
#DEBIAN_NONUS	debian.fsl.org.ar/debian-non-US	Donde busca los archivos para debian non-US


