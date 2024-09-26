#!/bin/bash

if [ ! $(/usr/bin/whoami) = 'root' ]; then
   echo "Por favor execute com SuperUsuário root!"
   exit 1
fi


#VERIFICANDO SE ESTA NO IP 10
:'
export deuRedePrdSerah=''
function estahNaRedePRD() {
   ping -c1 -w2 10.209.218.1 >> /dev/null 2>&1
   if [ $? -eq 0 ]; then
      # assumindo super raridade de rede particular ter uso deste ip prd
      export deuRedePrdSerah='sim'
   fi

   ping -c1 -w2 10.209.192.1 >> /dev/null 2>&1
   if [ $? -eq 0 ]; then
      # assumindo super raridade de rede particular ter uso deste ip prd
      export deuRedePrdSerah="sim$deuRedePrdSerah"
   fi

   ping -c1 -w2 10.209.210.1 >> /dev/null 2>&1
   if [ $? -eq 0 ]; then
      # assumindo super raridade de rede particular ter uso deste ip prd
      export deuRedePrdSerah="sim$deuRedePrdSerah"
   fi

   ping -c1 -w2 10.209.160.1 >> /dev/null 2>&1
   if [ $? -eq 0 ]; then
      # assumindo super raridade de rede particular ter uso deste ip prd
      export deuRedePrdSerah="sim$deuRedePrdSerah"
   fi

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
}'
#Recurso alterado manualmente 
export deuRedePrdSerah="simsim"

if [ ! -e "/usr/bin/mysql-workbench" ]; then
   #estahNaRedePRD //nao irei fazer essa verificacao funcao desabilitada
      if [[ "$deuRedePrdSerah" = "simsim" ]]; then
         echo "Rede Estado, trocando repositorios daeh .."
         cd /tmp
         if [[ ! -e "/etc/apt/sources.list.d/ubuntu-parana.list" ]]; then
            rm repositorios.deb 2>> /dev/null
            wget http://ubuntu.celepar.parana/repositorios.deb
            if [ -e "repositorios.deb" ]; then
               dpkg -i repositorios.deb
               sed -i -e 's/^deb/###deb/' /etc/apt/sources.list.d/official-package-repositories.list
               sed -i -e 's/^deb/###deb/' /etc/apt/sources.list
            else
               echo "ERRO AO BAIXAR repositorios"
            fi
         fi
      else
      echo "Ha algum erro causado provavelmente pela configuracao de rede"
   fi

   apt-get  update

   if [ "$(ps aux | grep sshd | grep sbin | wc -l)" -eq 0 ]; then
      # sem ssh dai instalando ...
      apt-get -y install ssh
   fi

   # Instalar ENTAO
   mkdir -p /tmp/.configs-bench-users 2>> /dev/null
   cd "/tmp/.configs-bench-users"
   if [ $(ls -1 | grep ".deb$" | wc -l) -gt 0 ]; then
      rm -- *deb 2>> /dev/null
   fi
   #Remove .deb anteriores

   versaoBaseMint=$(cat /etc/linuxmint/info | grep 'RELEASE=' | cut -d'=' -f2 | cut -c1-2 | head -1)
   if [ "$versaoBaseMint" = "21" ]; then
      wget --no-check-certificate -c http://cdn.mysql.com//Downloads/MySQLGUITools/mysql-workbench-community-dbgsym_8.0.34-1ubuntu22.04_amd64.deb
      if [ ! -e 'mysql-workbench-community-dbgsym_8.0.34-1ubuntu22.04_amd64.deb' ]; then
         wget -c 200.201.113.219/mysql-workbench-community-dbgsym_8.0.34-1ubuntu22.04_amd64.deb
      fi
      wget --no-check-certificate -c http://cdn.mysql.com//Downloads/MySQLGUITools/mysql-workbench-community_8.0.34-1ubuntu22.04_amd64.deb
      if [ ! -e "mysql-workbench-community_8.0.34-1ubuntu22.04_amd64.deb" ]; then
         wget -c 200.201.113.219/mysql-workbench-community_8.0.34-1ubuntu22.04_amd64.deb
      fi
   else
      wget --no-check-certificate -c http://downloads.mysql.com/archives/get/p/8/file/mysql-workbench-community_8.0.27-1ubuntu20.04_amd64.deb
      if [ ! -e "mysql-workbench-community_8.0.27-1ubuntu20.04_amd64.deb" ]; then
         wget -c 200.201.113.219/mysql-workbench-community_8.0.27-1ubuntu20.04_amd64.deb
      fi
      wget --no-check-certificate -c http://downloads.mysql.com/archives/get/p/8/file/mysql-workbench-community-dbgsym_8.0.27-1ubuntu20.04_amd64.deb
      if [ ! -e "mysql-workbench-community-dbgsym_8.0.27-1ubuntu20.04_amd64.deb" ]; then
         wget -c 200.201.113.219/mysql-workbench-community-dbgsym_8.0.27-1ubuntu20.04_amd64.deb
      fi
   fi
   #verifica a versao mas estamos instalando em virginia 21
   apt-get -y install mysql-server
   dpkg -i mysql*deb
   apt-get -y -f install
fi


# Apos instalado o mysql e bench, daeh trocar senha do root do mysql pra escola
echo "ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY 'escola';" > /root/senhasql.sql
mysql < /root/senhasql.sql 2>> /dev/null

# agora colar config do bench com senha salva pra usuario escola e convidado
mkdir -p /tmp/.configs-bench-users 2>> /dev/null
cat > "/tmp/.configs-bench-users/config.tar.gz.b64" << EndOfThisFileIsExactHere
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
/wEiWORlAAgCAA==
EndOfThisFileIsExactHere
base64 -d "/tmp/.configs-bench-users/config.tar.gz.b64" > /tmp/.configs-bench-users/config.tar.gz
cd "/tmp/.configs-bench-users"
tar -xzf config.tar.gz
if [ -e '/home/escola/.mysql' ] && [ -e '/home/escola/.mysql/workbench' ]; then
   mv '/home/escola/.mysql/workbench' '/home/escola/.mysql/workbench-antigo'
fi
cp -r .mysql /home/escola
chown -R escola.escola /home/escola/.mysql
cp -r .mysql /etc/skel
if [ -e /home/framework ]; then
   cp -r .mysql /home/framework/
fi

atalho="/usr/share/applications/mysql-workbench.desktop"
arqAtalho=$(basename $atalho)
# copiar atalho para home dos usuarios normais
cd /home
for usuario in *; do
    if [[ "$usuario" = *"lost"* ]]; then
        echo "Pasta lost+found nem mexeremos"
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
    if [ ! -e "$atalho" ]; then
        echo "Nao existe atalho pra copiar"; continue
    fi
    cp "$atalho" "/home/${usuario}/Área de Trabalho/" 1>/dev/null 2>/dev/null
    chown "${usuario}:${usuario}" "/home/${usuario}/Área de Trabalho/${arqAtalho}" 1>/dev/null 2>/dev/null
    chmod ugo+x  "/home/${usuario}/Área de Trabalho/${arqAtalho}" 1>/dev/null 2>/dev/null
    echo "Atalhos criados para usuário $usuario "
done
# copiar atalho para convidados no skel
if [ -e "/etc/skel/Área de Trabalho/" ]; then
    cp "$atalho" "/etc/skel/Área de Trabalho/"
    chmod ugo+x "/etc/skel/Área de Trabalho/$arqAtalho" 1>/dev/null 2>/dev/null
    echo "Copiado para skel Convidados"
fi

# copiar pra Convidado logado
grep '^guest-' /etc/passwd| while read x; do
   guest=$(echo "$x" | cut -d':' -f1)
   if [ -e "/tmp/$guest" ]; then
       echo "Copiando para convidado $guest"
      cp "$atalho" "/tmp/${guest}/Área de Trabalho/" 1>/dev/null 2>/dev/null
      chown -R "${guest}:${guest}" "/tmp/${guest}/Área de Trabalho/" 1>/dev/null 2>/dev/null
      chmod +x "/tmp/${guest}/Área de Trabalho/$arqAtalho" 1>/dev/null 2>/dev/null
    fi
done



echo "fim"

