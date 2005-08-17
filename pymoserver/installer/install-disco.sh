#!/bin/bash
# PyMO Server disk installer.
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

particion() {

OK=
while [ ! $OK ]; do
# Borramos el menu del disco
menu_disco=

# Buscamos los disco intalados
discos=`sfdisk -l |grep "Disk /dev/hd[a-z]\:" |cut -b11-13`
memoria=$((`dmesg |grep Memory| tr "/" " "| tr "k" " " |awk '{ print $2 }'`/1024))

# Creamos el menu con los discos
for disco in $discos ; do
    info_disco=`dmesg |grep "^$disco: " |grep -v CHS |cut -b6-|sed 's/ /\\ /g'`
    menu_disco="$menu_disco $disco  \"$info_disco\""
done

eval "$DIALOG --clear --title 'Particionado del disco' \
        --menu 'Elija el disco que desea usar para instalar el servidor' 12 51 3 \
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
disco\n" 10 51 2 \
        "Automatico"  "Particiona segun por defecto" \
        "Manual" "La particion la hace el usuario" 2> $tempfile

retval=$?

particion=`cat $tempfile`

case $retval in
  0)
    if [[ $particion = 'Automatico' ]] ; then
	advertencia "!! Esto borrara todo el contenido del disco !!"
	sino=$?
	if [ $sino == "0" ]; then 
	    advertencia "!! Si elije continuar no podra recuperar el \
conenido anterior del dico. Esta realmente seguro que desea borrar el disco? !!"
	    sino1=$?
	    if [ $sino1 == "0" ]; then
		tamanio_disco=$((`fdisk -s /dev/$disco`/1024))
		tamanio_part=$(($tamanio_disco-($memoria*2)))
		cd /tmp
		echo -e "0,$tamanio_part,L,*\n,,S\n" | sfdisk -q -uM /dev/$disco >>$LOGFILE 
		cd /dev
		MAKEDEV $disco
		mke2fs -q /dev/$disco\1
		mkswap /dev/$disco\2
		OK=1
		partroot=$disco\1
		partswap=$disco\2
		echo "s|PART_ROOT|$partroot|g" >> $parametros
		echo "s|PART_SWAP|$partswap|g" >> $parametros
		echo "s|DISCO|$disco|g" >> $parametros
		
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
tar xzvpf /install/vlps-0.3.tgz |awk '{ printf "XXX\n%i\nInstalando: %s\nXXX\n", (cnt++)/158.79,$0}' | $DIALOG --guage "Instalando Archivos" 15 70 

}

instalar_lilo() {
lilo -r /mnt
cd /
umount /mnt
}

configurar_servidor() {

cd /install/esquema

for listado in `find etc -type f`; do

    sed -f $parametros < ./$listado > /mnt/${listado/.esquema/}

done

case $conexion in

    'Dedicado')
	sed -f $parametros < interfaces-dedicado.esquema >/mnt/etc/network/interfaces
	;;
    'Local')
	sed -f $parametros < interfaces-local.esquema >/mnt/etc/network/interfaces
    ;;
    *)
	sed -f $parametros < interfaces.esquema >/mnt/etc/network/interfaces
    ;;

esac

sed -f $parametros <dns-host.esquema >/mnt/etc/bind/$dominio
sed -f $parametros <dns-reverso.esquema >/mnt/etc/bind/$red_interna

}
