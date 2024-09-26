#!/bin/bash

# Instalar Php e PHPMYADMIN

if [ "$(whoami)" != "root" ] ; then
   echo " !! Precisa executar como super-usuario !! Por favor executar como super-usuario."
   exit
fi

export DEBIAN_FRONTEND="noninteractive"
export arqLog="/var/log/.log-instal-php-admin-082023.log"
export arqCron="/tmp/.arqcron$$"
export COUNTINGFile='/var/log/countingtriesInstallPhpAdmin.log'

logMsg() {
   echo "$1"
   echo "$1 ($(date +%d/%m/%Y_%H:%M:%S_%N))" >> "$arqLog"
}

tirarDoCrontab() {
   logMsg "tirando do Crontab"
   if [ -e "$arqCron" ]; then
      rm $arqCron
   fi
   crontab -l >> $arqCron
   sed -i '/installphpadminmysql082023.sh/d' $arqCron
   crontab < $arqCron
}

echo "Iniciando. Gravando logs no arquivo $arqLog"

LOCK='/var/run/installphpmyadmin.lock'
PID=$(cat $LOCK 2>/dev/null)
if [ ! -z "$PID" ] && kill -0 $PID 2>/dev/null
then
   echo already running
   exit 1
fi
trap "rm -f $LOCK ; exit" INT TERM EXIT
echo $$ > $LOCK

if [ -e "$arqCron" ]; then
   rm $arqCron
fi

me=`basename "$0"`
if [[ "$me" = "php.sh" ]] || [[ "$me" = "xamp.sh" ]]; then
   if [ -e "$COUNTINGFile" ]; then
      rm "$COUNTINGFile"
   fi
fi

crontab -l >> $arqCron

if [ ! -e "/root/bin" ]; then
   mkdir -p /root/bin 2>> /dev/null
fi

if [[ "$0" != "/root/bin/installphpadminmysql082023.sh" ]] ; then
   cp -- "$0" "/root/bin/installphpadminmysql082023.sh"
   chmod +x "/root/bin/installphpadminmysql082023.sh"
   logMsg "copied;"
fi

if [ $(grep "installphpadminmysql082023.sh" "$arqCron" | wc -l) -eq 0 ]; then
   sed -i '/installphpadminmysql082023.sh/d' $arqCron
   echo "*/57 * * * * /root/bin/installphpadminmysql082023.sh >> /var/log/.log-crontab-install-phpmyadmin082023.log 2>&1" >> $arqCron
   crontab < $arqCron
   logMsg "adicionado crontab pra re-install caso falhe este"
fi

TIPO=$( /usr/sbin/dmidecode -t system | grep 'Product Name: ' | cut -d':' -f2 | sed -e s/'^ '// -e s/' '/'_'/g )
case "$TIPO" in
  *C1300*)
    echo -e "\e[43m ------ EDUCATRON ------ \e[0m  encontrado educatron aqui. saindo."  >> "$arqLog"
    echo -e "\e[43m ------ EDUCATRON ------ \e[0m  encontrado educatron aqui. saindo."
    #tirarDoCrontab
    #if [ -e "$LOCK" ]; then rm -f "$LOCK"; fi
    #exit 1
  ;;
  Positivo_Duo_ZE3630)
    echo -e "\e[46mNetbook Verde Linux Mint \e[0m " >> "$arqLog"
    echo -e "\e[46mNetbook Verde Linux Mint \e[0m "

   versao=$(cat /etc/linuxmint/info | grep 'RELEASE=' | cut -d'=' -f2 | head -1)
   if [ "$versao" = "18.3" ] ; then
       echo -e "\e[46mMin muito antigo! \e[0m "
       tirarDoCrontab
       if [ -e "$LOCK" ]; then rm -f "$LOCK"; fi
       exit 0
   fi

  ;;
  OptiPlex*)
    PREFIXO='d'
    echo -e "${AZUL} DELLLL aquii   ${NC} "
    if [ -x '/usr/bin/mokutil' ]; then
       if [[ "$(mokutil --sb-state)" = "SecureBoot enabled" ]]; then
          echo -e "${VERMELHO} CONSTA MODO SEGURO ATIVADO. POR FAVOR DESATIVAR NA BIOS! ${NC} "
          logMsg "Falta ajustar a BIOS"
          exit 0
       fi
    fi

  ;;
esac

if [ -e "$COUNTINGFile" ]; then
  COUNTING=$(cat $COUNTINGFile 2>/dev/null)
  if [[ "$COUNTING" -ge  0 ]]; then
      logMsg "ok $COUNTING inc"
      ((COUNTING++))
   else
     COUNTING=0
  fi
else
   COUNTING=0
fi

echo $COUNTING > $COUNTINGFile 2>> /dev/null
if [[ "$COUNTING" -ge 10 ]]; then
   logMsg "Estourou limite de 10 tentativas. Desistindo!"
   tirarDoCrontab
   if [ -e "$LOCK" ]; then rm -f "$LOCK"; fi
   exit 0
fi

export deuRedePrdSerah=''

function estahNaRedePRD() {
   IPS=( "10.209.218.1" "10.209.192.1" "10.209.210.1" "10.209.160.1" "10.74.32.1" "10.74.21.1" "10.74.12.1")
   for ip in "${IPS[@]}" ; do
      ping -c1 -w2 "$ip" >> /dev/null 2>&1
      if [ $? -eq 0 ]; then
         export deuRedePrdSerah="sim$deuRedePrdSerah"
      fi
      if [[ "$deuRedePrdSerah" = 'simsim' ]]; then
         echo "ok"
         return
      fi
   done

   tmpdeuRedePrdSerah=$(echo $deuRedePrdSerah | sed 's/simsim//')
   if [ "$deuRedePrdSerah" = "$tmpdeuRedePrdSerah" ]; then
      ping -c1 -w2 10.132.214.1 >> /dev/null 2>&1
      if [ $? -eq 0 ]; then
         if [ $(route -n | egrep "10.132.214.1[ \t]"| wc -l) -gt 0 ]; then
            export deuRedePrdSerah="simsim"
         fi
      fi
      return
   else
      export deuRedePrdSerah="simsim"
   fi
}

export deuRedePrdSerah="verificar"

if [ -e /etc/apt/sources.list.d/ubuntu-parana.list ] && [ $(egrep ^deb /etc/apt/sources.list.d/ubuntu-parana.list | wc -l) -gt 2 ]; then
    # Configurado rep Celepar
    sed -i -e 's/^deb/###deb/' /etc/apt/sources.list.d/official-package-repositories.list
    sed -i -e 's/^deb/###deb/' /etc/apt/sources.list
    export deuRedePrdSerah="simsim"

else
    estahNaRedePRD
    if [[ "$deuRedePrdSerah" = "simsim" ]]; then
      logMsg "Rede Estado, trocando repositorios."
      cd /tmp
      rm repositorios.deb 2>> /dev/null
      wget http://ubuntu.celepar.parana/repositorios.deb
      if [ -e "repositorios.deb" ]; then
         dpkg -i repositorios.deb
         sed -i -e 's/^deb/###deb/' /etc/apt/sources.list.d/official-package-repositories.list
         sed -i -e 's/^deb/###deb/' /etc/apt/sources.list
      else
         logMsg "ERRO AO BAIXAR repositorios"
      fi
    else
      logMsg "Fora da rede PRD"
    fi
fi


apt-get  update &>> "$arqLog"

apt-get -y -f install &>> "$arqLog"
if [ $? -ne 0 ]; then
   echo "erro no -f install" &>> "$arqLog"
   exit 1
fi

export MYSQL_ROOT_PASSWORD='escola'
export DEBIAN_FRONTEND="noninteractive"

if [ -e /usr/bin/mysql ] && [ -x /usr/bin/mysql ]; then
   echo "executavel mysql ok"
   if [ $(dpkg -l | grep mysql | grep server | wc -l) -eq 0 ]; then
      apt-get -y install mysql-server &>> "$arqLog"
   fi
else
   apt-get -y install mysql-server &>> "$arqLog"
   if [ -e "/root/.senhasql.sql" ]; then
      rm /root/.senhasql.sql
   fi
   echo "ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY 'escola';" >> /root/.senhasql.sql
   mysql < /root/.senhasql.sql &>> "$arqLog"
   echo "ALTER USER 'phpmyadmin'@'localhost' IDENTIFIED BY 'escola';" >> /root/.senhasql.sql
   mysql < /root/.senhasql.sql &>> "$arqLog"
   if [ $? -ne 0 ]; then
      mysql -h localhost -u root -pescola < /root/.senhasql.sql &>> "$arqLog"
   fi
fi

if [ -e "/etc/apache2/conf-available/phpmyadmin.conf" ] && [ $(ps aux | grep apache2 | wc -l) -gt 2 ]; then
   echo "Consta PhpMyadmin"

else

   echo "Instalando diversos pacotes para XAMPP/LAMP"
   apt-get install -yq apache2 php phpmyadmin &>> "$arqLog"

   cat > "/etc/phpmyadmin/config-db.php" << EndOfThisFileIsExactHere
<?php
##
## database access settings in php format
## automatically generated from /etc/dbconfig-common/phpmyadmin.conf
## by /usr/sbin/dbconfig-generate-include
##
## by default this file is managed via ucf, so you shouldn't have to
## worry about manual changes being silently discarded.  *however*,
## you'll probably also want to edit the configuration file mentioned
## above too.
##
\$dbuser='phpmyadmin';
\$dbpass='escola';
\$basepath='';
\$dbname='phpmyadmin';
\$dbserver='localhost';
\$dbport='3306';
\$dbtype='mysql';
EndOfThisFileIsExactHere

   if [ -e "/etc/dbconfig-common/phpmyadmin.conf" ]; then
      sed -i -e "s/dbc_dbpass=.*/dbc_dbpass='escola'/" /etc/dbconfig-common/phpmyadmin.conf
   fi



   # Apos instalado o mysql e bench, daeh trocar senha do root do mysql pra escola
   if [ -e "/root/.senhasql.sql" ]; then
      rm /root/.senhasql.sql
   fi
   echo "ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY 'escola';" >> /root/.senhasql.sql
   echo "ALTER USER 'phpmyadmin'@'localhost' IDENTIFIED BY 'escola';" >> /root/.senhasql.sql
   mysql < /root/.senhasql.sql &>> "$arqLog"
   if [ $? -ne 0 ]; then
      mysql -h localhost -u root -pescola < /root/.senhasql.sql &>> "$arqLog"
   fi





   # Set the MySQL administrative user's password
   debconf-set-selections <<< "phpmyadmin phpmyadmin/dbconfig-install boolean true"
   debconf-set-selections <<< "phpmyadmin phpmyadmin/mysql/admin-user string root"
   debconf-set-selections <<< "phpmyadmin phpmyadmin/mysql/admin-pass password $MYSQL_ROOT_PASSWORD"
   debconf-set-selections <<< "phpmyadmin phpmyadmin/mysql/app-pass password $MYSQL_ROOT_PASSWORD"
   debconf-set-selections <<< "phpmyadmin phpmyadmin/reconfigure-webserver multiselect apache2"

   dpkg-reconfigure -f noninteractive phpmyadmin

   systemctl restart apache2

fi

chmod -R 777 /var/www/html

cat > "/usr/share/applications/phpmyadmin.desktop" << EndOfThisFileIsExactHere
[Desktop Entry]
Name=Php MyAdmin
Comment=MySQL management over web
Exec=google-chrome-stable http://localhost/phpmyadmin/
Terminal=false
Type=Application
Icon=phpmyadmin
Categories=Development;Database;
EndOfThisFileIsExactHere

# copiar atalhos para home dos usuarios normais
nomeAtalho="phpmyadmin.desktop"
enderecoAtalho="/usr/share/applications/$nomeAtalho"
echo "Copiando atalhos do PhpMyAdmin"

cd /home
for usuario in *; do
    if [[ "$usuario" = *"lost"* ]]; then
        #echo "Pasta lost+found nem mexeremos"
        continue
    fi
    if [ -d "/home/${usuario}" ]; then
        cd "/home/${usuario}/"
    else
        continue
    fi
    if [[ ! -e 'Área de Trabalho' ]]; then
        mkdir 'Área de Trabalho'
        chown "${usuario}.${usuario}" 'Área de Trabalho'
    fi

    cp "$enderecoAtalho" "/home/${usuario}/Área de Trabalho/" 1>/dev/null 2>/dev/null
    chown "${usuario}:${usuario}" "/home/${usuario}/Área de Trabalho/$nomeAtalho" 1>/dev/null 2>/dev/null
    chmod ugo+x  "/home/${usuario}/Área de Trabalho/$nomeAtalho" 1>/dev/null 2>/dev/null
    if [ ! -e  "/home/${usuario}/Área de Trabalho/Php www" ]; then
       ln -s /var/www/html "/home/${usuario}/Área de Trabalho/Php www"
    fi
    #logMsg "Atalhos criados para usuário $usuario "
done

# copiar atalho para convidados no skel
if [ -e "/etc/skel/Área de Trabalho/" ]; then
    cp "$enderecoAtalho" "/etc/skel/Área de Trabalho/"
    chmod ugo+x "/etc/skel/Área de Trabalho/$nomeAtalho" 1>/dev/null 2>/dev/null
    if [ ! -e  "/etc/skel/Área de Trabalho/Php www" ]; then
       ln -s /var/www/html "/etc/skel/Área de Trabalho/Php www"
    fi
    #echo "Copiado para skel Convidados"
fi

# copiar pra Convidado logado
grep '^guest-' /etc/passwd| while read x; do
   guest=$(echo "$x" | cut -d':' -f1)
   if [ -e "/tmp/$guest" ]; then
      #echo "Copiando para convidado $guest"
      cp "$enderecoAtalho" "/tmp/${guest}/Área de Trabalho/" 1>/dev/null 2>/dev/null
      chown "${guest}:${guest}" "/tmp/${guest}/Área de Trabalho/$nomeAtalho" 1>/dev/null 2>/dev/null
      chmod +x "/tmp/${guest}/Área de Trabalho/$nomeAtalho" 1>/dev/null 2>/dev/null
      if [ ! -e  "/tmp/${guest}/Área de Trabalho/Php www" ]; then
         ln -s /var/www/html "/tmp/${guest}/Área de Trabalho/Php www"
      fi
    fi
done


if [ -e '/usr/share/phpmyadmin/libraries/classes/Plugins/Auth/AuthenticationCookie.php' ]; then
    sed -i -e 's/htmlspecialchars($default_user)/htmlspecialchars("root")/' /usr/share/phpmyadmin/libraries/classes/Plugins/Auth/AuthenticationCookie.php
    sed -i -e 's/value="" size="24" class="textfield"/value="escola" size="24" class="textfield"/' /usr/share/phpmyadmin/libraries/classes/Plugins/Auth/AuthenticationCookie.php
fi

if [ -e /usr/share/phpmyadmin/templates/login/form.twig ]; then
    sed -i -e 's/id="input_username" value="{{ default_user }}"/id="input_username" value="root"/' /usr/share/phpmyadmin/templates/login/form.twig
    sed -i -e 's/id="input_password" value="" size="24"/id="input_password" value="escola" size="24"/' /usr/share/phpmyadmin/templates/login/form.twig
fi



if [[ $(sed -n '5p' /etc/phpmyadmin/apache.conf | grep '/usr/share/phpmyadmin>' | wc -l ) -gt 0 ]]; then
   if [[ $(grep 'Require local' /etc/phpmyadmin/apache.conf | wc -l ) -eq 0 ]]; then
      sed -i "6 i\    Require local" /etc/phpmyadmin/apache.conf
   else
      echo "jah tinha bloqueio"
   fi
else
   echo "fora do padrao"
fi

if [ -e "/etc/php/7.4/apache2/php.ini" ]; then
   sed -i -e 's/upload_max_filesize.*/upload_max_filesize = 20M/' "/etc/php/7.4/apache2/php.ini"
   sed -i -e 's/display_errors = Off/display_errors = On/' "/etc/php/7.4/apache2/php.ini"
fi

systemctl restart apache2



tirarDoCrontab
rm $LOCK 2>> /dev/null
logMsg "Terminou executar"
echo ""
