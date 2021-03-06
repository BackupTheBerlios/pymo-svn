#!/bin/bash
#
# PyMO Server disk installer.
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

particion() {

OK=
while [ ! $OK ]; do
# Borramos el menu del disco
menu_disco=

# Esto es para qemu, para que no quede basura en el listado
sfdisk -l > /dev/null

# Buscamos los disco intalados
discos=`sfdisk -l |grep "Disk /dev/[hs]d[a-z]\:" |cut -b11-13`
memoria=$((`dmesg |grep Memory| tr "/" " "| tr "k" " " |awk '{ print $2 }'`/1024))

# Creamos el menu con los discos
for disco in $discos ; do
    info_disco=`dmesg |grep "^$disco: " |grep -v CHS |cut -b6-|sed 's/ /\\ /g' |grep . || dmesg|perl -w -e 'BEGIN{$d=shift}undef $/;$_=<>;m/^.*Vendor:\s*(.*?)\s*Rev:.*?scsi disk\s+$d.*/s; print "$1\n"' $disco |grep . || echo "Dispositivo desconocido"`
    menu_disco="$menu_disco $disco  \"$info_disco\""
done

eval "$DIALOG --clear --title 'Selecci�n del disco' \
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


#$DIALOG --clear --title "Particionado del disco" \
#        --menu "Elija a continuaci�n c�mo quiere realizar el particionado del \
#disco\n" 10 51 2 \
#        "Autom�tico"  "Particiona por defecto" \
#        "Manual" "La partici�n la hace el usuario" 2> $tempfile

#retval=$?

#particion=`cat $tempfile`

#case $retval in
#  0)
#    if [[ $particion = 'Autom�tico' ]] ; then
	advertencia "!! Esto borrar� todo el contenido del disco !!"
	sino=$?
	if [ $sino == "0" ]; then 
	    advertencia "!! Si elige continuar no podr� recuperar el \
contenido anterior del disco. Est� realmente seguro que desea borrar el disco? !!"
	    sino1=$?
	    if [ "$sino1" == "0" ]; then
		tamanio_disco=$((`fdisk -s /dev/$disco`/1024))
		tamanio_part=$(($tamanio_disco-($memoria*2)))
		cd /tmp
		echo -e "0,$tamanio_part,L,*\n,,S\n" | sfdisk -q -uM /dev/$disco >>$LOGFILE 
		cd /dev
		MAKEDEV $disco
		mke2fs -j -q /dev/$disco\1
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
#    else
#	advertencia "Debe crear 2 particiones. Una de las particiones tiene \
#que ser tipo linux y la otra tipo swap"
#	sino=$?
#	if [ $sino ]; then 
#	    error "Funci�n no implementada!"
	    # cfdisk
#	fi	    
#    fi
#    ;;
#  1)
#    exit 1;; 
# Apreto el Cancel
#  255)
#    exit 1;;
# Apreto escape
#esac
done
}


copiar_archivos() { 

mount /dev/$disco\1 /mnt
cd /mnt
tar xzvpf /install/vlps-0.5.tar.gz |awk '{ printf "XXX\n%i\nInstalando: %s\nXXX\n", (cnt++)/297.60,$0}' | $DIALOG --guage "Instalando Archivos" 15 70 

}

instalar_grub() {
chroot /mnt bash -c "grub-install --no-floppy /dev/$disco"

}

configurar_servidor() {

cd /install/esquema

for listado in `find etc -type f`; do

    sed -f $parametros < ./$listado > /mnt/${listado/.esquema/}

done

# Configuramos las conexiones
if [ "$dhcp" == 'no' ]; then
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
else
    case $conexion in

	'Dedicado')
	    sed -f $parametros < interfaces-dedicado-dhcp.esquema >/mnt/etc/network/interfaces
	;;
	'Local')
	    sed -f $parametros < interfaces-local-dhcp.esquema >/mnt/etc/network/interfaces
	;;
	*)
	    sed -f $parametros < interfaces.esquema >/mnt/etc/network/interfaces
	;;

    esac
fi

sed -f $parametros <dns-host.esquema >/mnt/etc/bind/db.$dominio
sed -f $parametros <dns-reverso.esquema >/mnt/etc/bind/db.$red_interna

#if [ "$conexion" = 'Modem']; then
#    cd /mnt/etc/ppp
#    ln -s ppp_on_boot.dsl ppp_on_boot 
#fi

# Ponemos los scrips administrativos previamente configurados.
cd /install/esquema

for listado in `find ldap -type f`; do
    sed -f $parametros < ./$listado > /mnt/root/${listado/.esquema/}
done

cp $parametros /mnt/root

cp /install/setup.sh /mnt/root/setup.sh
chmod u+x /mnt/root/setup.sh


# Intalamos los archivos necesarios para el firewall
cd /install/esquema/shorewall/$conexion

for i in `ls |grep -v ".esquema"` ; do
    cp $i /mnt/etc/shorewall/
done
for i in `ls |grep ".esquema"` ; do
    sed -f $parametros < $i >/mnt/etc/shorewall/${i/.esquema//}
done

# Configuracion para samba y ldap
sed -f $parametros < smbldap_conf.pm.esquema >/mnt/usr/local/sbin/smbldap_conf.pm

}
