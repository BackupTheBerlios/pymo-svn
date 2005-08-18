
# PyMO Server Auxiliar functions
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

advertencia() {

$DIALOG --title "ADVERTENCIA" --defaultno \
        --yesno "$1\n\nDesea continuar?" 10 51 

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

parametros_ldap() {

    echo "s|SERVIDOR_LDAP|localhost|g" >>$parametros
    echo "s|BASE_LDAP|dc=`echo $dominio |sed -e 's/\./,dc=/g'`|g" >>$parametros
    echo "s|PASSWORD_LDAP|password|g" >>$parametros
    
}

parametros_red() {

    red_interna=`netmask $ip_interna/$mask_interna|sed 's/ //g'|awk -F"/" '{print $1}'`
    
    case $mask_interna in
	"255.255.255.0")
	    host_bits=`echo $ip_interna|awk -F"." '{print $4}'`
	    red_bits_dns=`echo $ip_interna|awk -F"." '{print $3"."$2"."$1}'`
	    ;;
	"255.255.0.0")
	    host_bits=`echo $ip_interna|awk -F"." '{print $3"."$4}'`
	    red_bits_dns=`echo $ip_interna|awk -F"." '{print $2"."$1}'`
	    ;;
	"255.0.0.0")
	    host_bits=`echo $ip_interna|awk -F"." '{print $2"."$3"."$4}'`
	    red_bits_dns=`echo $ip_interna|awk -F"." '{print $4}'`
	    ;;
    esac

    echo "s|IPMASK_INTERNA|`netmask $ip_interna/$mask_interna`|g" >>$parametros
    echo "s|HOST_INTERNA|$host_bits|g" >>$parametros
    echo "s|ZONA_DNS|$red_bits_dns|g" >>$parametros
    echo "s|NET_INTERNA|$red_interna|g" >>$parametros
    echo "s|IF_INTERNA|eth0|g" >>$parametros
    echo "s|IF_EXTERNA|eth1|g" >>$parametros

}

parametros_otros() {

echo "s|REDIRECTOR_DNS1||g" >>$parametros
echo "s|REDIRECTOR_DNS2||g" >>$parametros
echo "s|DEBIAN_US||g" >>$parametros
echo "s|DEBIAN_NONUS||g" >>$parametros

}

mensaje() {

$DIALOG --title "Instalacion de VLPS 0.3" --clear \
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


