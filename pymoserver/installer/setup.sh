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
LOGFILE=/root/instalacion.log

error() {

$DIALOG --title "ERROR" \
        --msgbox "$1\n\n\
Presione <Enter> para continuar." --defaultno 8 51

case $? in
    0)
    ;;
  255)
    ;;
esac

}

mensaje() {

$DIALOG --title "Instalación de VLPS 0.5" --clear \
        --msgbox "$1\n\n\
Presione <Enter> para continuar." 10 51

case $? in
    0)
    ;;
  255)
# El tipo presiono ESC
    exit 1;;
esac
}


advertencia() {

$DIALOG --title "ADVERTENCIA" --defaultno \
        --yesno "$1\n\n¿Desea continuar?" 10 51 

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

squid_auth() {
$DIALOG --title "SQUID" --defaultno \
        --yesno "¿Dedea que Squid pida usuario y contraseña para habilitar \
la navegación?" 7 51 

case $? in
    0)
    conf_squid="${conf_squid}auth"
    ;;
    1)
    ;;
  255)
    ;;
esac
}

squid_content() {
$DIALOG --title "SQUID" --defaultno \
        --yesno "¿Dedea habilitar el filtro de contenido en Squid? Esto \
restringirá los lugares por donde se pueden navegar. Para más información \
revise el manual" 9 51 

case $? in
    0)
    conf_squid="${conf_squid}content"
    ;;
    1)
    ;;
  255)
    ;;
esac
}

echo "Generando certificados para CYRUS, APACHE, SLAPD, SSH y POSTFIX ."
/usr/local/sbin/mkcert.sh  -create_ca > /root/certificate_creation.log 2>&1
/usr/local/sbin/mkcert.sh  -servers_cert >> /root/certificate_creation.log 2>&1
chmod o+x /etc/ssl/private/

mensaje "Felicitaciones, ya esta instalado el servidor PYMO. Ahora es \
necesario realizar algunos pasos de post instalación"

# Montamos /proc
mount /proc

mensaje "Es necesario poner la clave del usuario root (el administrador). Esta \
clave es la mas importante de su sistema. Ponga una clave difícil de adivinar, \
y resguarde la en un lugar seguro"

clear
OK=
while [ ! "$OK" ] ; do

    passwd root

    case $? in
	0)
	    OK=1
	    echo "La clave se cambio con éxito"
	    ;;
	1)
	    echo "Error al cambiar la clave"
	    ;;
    esac
done

# levantamos el loopback, es para que podamos levantar slapd y smb
/sbin/ifconfig lo 127.0.0.1 netmask 255.0.0.0

# ponemos un ldap basico con lo minimo
slapadd -f /root/ldap/slapd.conf -l /root/ldap/base.ldif
slapindex -f /root/ldap/slapd.conf

# generamos la password para el slapd. La tenemos que cargar en 3 lugares
# /etc/ldap/slapd.conf, en /etc/gosa/gosa.conf y en el secrets.tdb de samba
BASE_LDAP=`cat /etc/ldap/ldap.conf |awk '/^base/ {print $2}'`
PASSWORD_LDAP=`pwgen 14 1`
PASSWORD_SLAPD=`slappasswd -u -s $PASSWORD_LDAP`  
smbpasswd -w "$PASSWORD_LDAP"
#echo "$PASSWROD_SLAPD" 
sed "s|SEGURO|$PASSWORD_SLAPD|g"  < /root/ldap/slapd.conf > /etc/ldap/slapd.conf
sed "s|SEGURO|$PASSWORD_SLAPD|g"  < /usr/local/sbin/smbldap_conf.pm > /usr/local/sbin/smbldap_conf.pm
sed "s|password_ldap|$PASSWORD_LDAP|g" < /etc/gosa/gosa_.conf > /etc/gosa/gosa.conf 
#rm /etc/gosa/goas_.conf

#echo "Levantando el servidor LDAP"
/etc/init.d/slapd start
#sleep 2

#echo "Levantando el servidor SAMBA"
/etc/init.d/samba start

# ahora samba genero el SID y lo cargo en el ldap y nosotros podemos
# obtenerlo para configurar el resto de la BASE_LDAP

LOCAL_SID=`net getlocalsid |awk '{print $6}'`
#echo "SID: $LOCAL_SID" 

#echo "Deteniendo el servidor LDAP"
/etc/init.d/slapd stop

sed "s/S-1-5-21-499806066-1916519050-1478737032/$LOCAL_SID/g" < /root/ldap/gosa_.ldif > /root/ldap/gosa.ldif
slapadd -l /root/ldap/gosa.ldif

#echo "Lavantando el servidor LDAP"
/etc/init.d/slapd start

mensaje "A continuación se pide la clave del administrador del \
servidor LDAP. Esta es la clave que se requiere a la hora de crear usuarios \
grupos en el LDAP.  Ponga una clave segura, y mantenga la en un lugar seguro"

OK=
while [ ! "$OK" ] ; do

$DIALOG --title "Clave" --clear \
        --passwordbox "Ingrese la clave para el LDAP" 8 51 2> $tempfile
case $? in
    0)
	CLAVE1=`cat $tempfile`
	$DIALOG --title "Clave" --clear \
    	    --passwordbox "Ingrese nuevamente la clave" 8 51 2>$tempfile
	case $? in
	    0)
		CLAVE2=`cat $tempfile`
		if [ "$CLAVE1" = "$CLAVE2" ]; then
		    OK=1
		fi
	    ;;
	    1)
	    ;;
	    esac
	;;
	1)
	;;
esac
done

clear
#echo "Cambiando la clave del administrador del LDAP"
ldappasswd -x -h localhost -D "cn=admin,$BASE_LDAP" -w $PASSWORD_LDAP -s $CLAVE1 "cn=admin,ou=people,$BASE_LDAP"

#echo "Deteniendo el servidor SAMBA"
/etc/init.d/samba stop

#echo "Deteniendo el servidor LDAP"
/etc/init.d/slapd stop


$DIALOG --title "SQUID" --defaultno \
        --yesno "Squid es un proxy web. Sirve para que otras máquinas puedan \
navegar sin la necesidad de darles acceso completo a Internet. También \
acelera la navegación guardando copias locales de paginas visitadas. \
Consume un poco más de recursos.\n\n¿Desea activarlo?" 13 51 

case $? in
    0)
    /usr/sbin/update-rc.d squid defaults 30 
    hostname `cat /etc/hostname`
    /usr/sbin/squid -z
    squid_auth
    squid_content
    cp -f /etc/squid/squid_$conf_squid.conf /etc/squid/squid.conf
    ;;
    1)
    ;;
  255)
    ;;
esac

conexion=`cat /root/parametros_instalacion.txt | awk -F \' '/CONEXION/ {print $2}'`

if [ "$conexion" = 'ADSL' ] || [ "$conexion" = 'Dedicado' ] ;then
    $DIALOG --title "Internet - NAT" --defaultno \
	    --yesno "El servidor puede ser usado para compartir Internet en \
forma transparente a las máquinas que están en la red local. En general se\
recomienda no activarlo.\n\n¿Desea activarlo?" 11 51 

    case $? in
	0)
	cp /etc/shorewall/masq_internet /etc/shorewall/ipmasq
	cp /etc/shorewall/policy_internet /etc/shorewall/policy
	;;
	1)
	;;
      255)
	;;
    esac

fi



echo "Habilitamos el ssl para apache" 
a2ensite ssl.conf
a2enmod ssl

mensaje "El sistema ya esta listo para ser usado. Una vez que se reinicie la \
máquina va a poder acceder desde un navegador a la configuración de usuario \
y grupos. Revise el manual para más información"

# Ya no necesitamos el setup :)
rm -f /root/setup.sh

# Desmontado /proc
umount /proc
