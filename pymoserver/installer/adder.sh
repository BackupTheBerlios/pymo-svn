#!/bin/bash
# PyMO Server user adder.
# Copyright (C) 2001-2005 Fundación Via Libre
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

#
USUARIO=$1
PASSWORD=$2
NOMBRE=$3
APELLIDO=$4

if [ -z "$APELLIDO" ]; then
    echo "Cantidad de parametros incorrecta"
    echo "Uso:  adder.sh username password nombre apellido"
    exit 1
fi

ID_NUMBER=$((`ldapsearch -x -h ldap.pymeslibres.com.ar -z 0 -b "ou=People,dc=pymeslibres,dc=com,dc=ar" -S uidNumber uidNumber | grep uidNumber |awk '{print $2}'|tail -1`+1))
ID_GRUPO=$((`ldapsearch -x -h ldap.pymeslibres.com.ar -z 0 -b "ou=groups,dc=pymeslibres,dc=com,dc=ar" -S gidNumber gidNumber | grep gidNumber |awk '{print $2}'|tail -1`+1))

sed "s/USUARIO/$USUARIO/g;s/PASSWORD/$PASSWORD/g;s/NOMBRE/$NOMBRE/g;s/APELLIDO/$APELLIDO/g;s/ID_NUMBER/$ID_NUMBER/g;s/ID_GRUPO/$ID_GRUPO/g" ./usuario.ldif > ./user.ldif


ldapadd -x -h ldap.pymeslibres.com.ar -D "cn=admin,dc=pymeslibres,dc=com,dc=ar" -W -f user.ldif
mkdir /home/$USUARIO
chown $USUARIO.$USUARIO /home/$USUARIO
echo "Usuario $USUARIO creado"
cd /home/$USUARIO
maildirmake Maildir
chown $USUARIO.$USUARIO /home/$USUARIO
echo "Maildir de $USUARIO creado" 


