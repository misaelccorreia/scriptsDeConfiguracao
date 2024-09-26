#!/bin/bash

export arqLog="/var/log/.log-instal-packet-tracer.log"
echo "executado em:  $(date +%d/%m/%Y_%H:%M:%S_%N)" &>> "$arqLog"

if [ ! -e "/etc/linuxmint/info" ]; then
   echo "Maquina Linux fora do padrao"
   exit 1
fi

if [ ! $(/usr/bin/whoami) = 'root' ]; then
   echo "Por favor execute com SuperUsuário root para daí instalar programas"
   exit 1
fi

echo "Iniciando. Gravando logs no arquivo $arqLog"

LOCK='/var/run/installpackettracer.lock'
PID=$(cat $LOCK 2>/dev/null)
if [ ! -z "$PID" ] && kill -0 $PID 2>/dev/null
then
   echo already running
   exit 1
fi
trap "rm -f $LOCK ; exit" INT TERM EXIT
echo $$ > $LOCK

export DEBIAN_FRONTEND=noninteractive
export okDpkgOuApt='sim'
export GREP_COLOR='0;31;42'
export NC="\033[0m"
export VERMELHO="\033[0;41m" # vermelho
export VERDE="\033[0;42m" # Verde
export LARANJA="\033[0;43m" # Amarelo
export AMARELO="\033[30;103m" # Amarelo

if [ -e "/opt/packettracer73" ]; then
   mv /opt/packettracer73 "/opt/packettracer73_$(date +%d_%m_%Y_%H_%M_%S_%N)"
fi
mkdir -p "/opt/packettracer73" 2>> /dev/null

if [ -x '/usr/bin/mokutil' ]; then
   if [[ "$(mokutil --sb-state)" = "SecureBoot enabled" ]]; then
      echo -e "${VERMELHO} CONSTA MODO SEGURO ATIVADO. POR FAVOR DESATIVAR NA BIOS! ${NC} "
      export okDpkgOuApt='nao'
   fi
fi

export arqPrograma="Packet_Tracer_7.3.0-.glibc2.27-x86_64.AppImage"
export repositorioArq="http://200.201.113.219/$arqPrograma"
#export repositorioArq="https://github.com/Diolinux/PacketTracer-AppImage/releases/download/Packet-Tracer-Appimage/$arqPrograma"

logMsg() {
   echo "$1"
   echo "$1 ($(date +%d/%m/%Y_%H:%M:%S_%N))" >> "$arqLog"
}


ajustarECriarAtalhos() {
   if [ -e /opt/mstech/updatemanager.jar ]; then
      versaoMint=$(cat /etc/linuxmint/info | grep 'RELEASE=' | cut -d'=' -f2 | head -1)
      if [ "$versaoMint" = "18.3" ]; then
         echo -e "${VERMELHO} Ainda não vimos funcionar nos Mint 18.3 dos Verdinhos! ${NC} "
         echo "Ainda não vimos funcionar nos Mint 18.3 dos Verdinhos! ($(date +%d/%m/%Y_%H:%M:%S_%N))" >> $arqLog
         return
      fi
   fi

   if [ -e "/opt/packettracer73/$arqPrograma" ]; then
      echo "ok."
      #mv "/opt/$arqPrograma" "/opt/packettracer73"
   else
      echo -e "${VERMELHO} Falhou no Download! Por favor tentar novamente ${NC} "
      echo "Falhou no Download! Por favor tentar novamente ($(date +%d/%m/%Y_%H:%M:%S_%N))" >> $arqLog
      return
   fi

   cd /opt/packettracer73/
   echo "Descompactando, por favor aguarde ..."
   chmod -R 777 /opt/packettracer73
   /opt/packettracer73/Packet_Tracer_7.3.0-.glibc2.27-x86_64.AppImage --appimage-extract >> $arqLog
   echo "ok, descompactado. Criando atalhos ..."

   cat > "/opt/packettracer73/app.png.b64" << EndOfThisFileIsHere
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
TkSuQmCC
EndOfThisFileIsHere
   base64 -d "/opt/packettracer73/app.png.b64" > "/opt/packettracer73/app.png"


   echo "[Desktop Entry]
Name=Cisco Packet Tracer 7.3
Exec=/usr/local/bin/packettracerstart.sh
Icon=/opt/packettracer73/app.png
Type=Application
Terminal=false
StartupNotify=true
MimeType=application/x-pkt;application/x-pka;application/x-pkz;application/x-pks;application/x-pksz;
Categories=Development;Education;" > /usr/share/applications/packettracer73.desktop

   chmod -R ugo+rx "/opt/packettracer73"

   for usuario in escola Aluno professor pedagogico admin administrador ; do
      if id "$usuario" >/dev/null 2>&1; then
         #ok='usuarioExiste'
         chown -R "${usuario}.$usuario" /opt/packettracer73
         break
      fi
   done
   chmod -R 777 /opt/packettracer73

   # copiar atalhos para home dos usuarios normais
   nomeAtalho="packettracer73.desktop"
   enderecoAtalho="/usr/share/applications/$nomeAtalho"

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
       #echo "Atalhos criados para usuário $usuario "
   done

   # copiar atalho para convidados no skel
   if [ -e "/etc/skel/Área de Trabalho/" ]; then
       cp "$enderecoAtalho" "/etc/skel/Área de Trabalho/"
       chmod ugo+x "/etc/skel/Área de Trabalho/$nomeAtalho" 1>/dev/null 2>/dev/null
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
       fi
   done





   cat > "/usr/local/bin/packettracerstart.sh" << EndOfThisFileIsExactHere
#!/bin/bash
if [ "\$(whoami | sed 's/-.*//')" = "guest" ]; then
   #echo "Usuario convidado acesso ao descompactado
   if [ -x "/opt/packettracer73/squashfs-root/AppRun" ]; then
      /opt/packettracer73/squashfs-root/AppRun
   else
      zenity --error --width=600 --text '<span foreground="blue" font="16">Erro de instalação!\nFaltando executável AppRun!</span>'
      #echo "Usuario convidado era sem acesso a este programa"
   fi
else
   echo "ok continuar"
   #/usr/share/code/code --unity-launch
   /opt/packettracer73/$arqPrograma
fi
EndOfThisFileIsExactHere
   chmod +x /usr/local/bin/packettracerstart.sh
   echo "Packet Tracer instalado no local, checando se tem xterm..."

}


if [[ ! -e "/usr/local/bin/packettracerstart.sh" ]] || [[ ! -e "/opt/packettracer73/squashfs-root/AppRun" ]]; then
   cd /opt/packettracer73
   if [[ -x /usr/bin/lftp ]]; then
      logMsg "Baixando arquivos pelo LFTP, aguarde ..."
      lftp -c "set net:idle 10
      set net:max-retries 0
      set net:reconnect-interval-base 3
      set net:reconnect-interval-max 3
      set ssl:verify-certificate false
      pget -n 10 -c \"${repositorioArq}\""

      logMsg "Lftp terminou de executar, vejamos ..."
      #if [ -e "$arqPrograma" ]; then
      #   wget --no-check-certificate --retry-connrefused --read-timeout=30 --tries=1 --waitretry=1 -q -c "${repositorioArq}.sha256sum"
      #   if sha256sum -c "${arqPrograma}.sha256sum" ; then
      #      logMsg "Checou ok o hash sha256."
            ajustarECriarAtalhos
      #   else
      #      logMsg "Falhou checagem de hash sha256. Remover e tentar novamente!"
      #      rm "$arqPrograma" >> "$arqLog" 2>> "$arqLog"
      #   fi
      #else
      #   logMsg " mas nem existe arquivo $arqPrograma . Por favor tentar novamente!"
      #fi

   else
      logMsg "Baixando arquivos pelo WGET, aguarde ..."
      wget --no-check-certificate --retry-connrefused --read-timeout=30 --tries=1 --waitretry=1 -q -c "${repositorioArq}"

      logMsg "Wget terminou de executar, vejamos ..."

      #if [ -e "$arqPrograma" ]; then
      #   wget --no-check-certificate --retry-connrefused --read-timeout=30 --tries=1 --waitretry=1 -q -c "${repositorioArq}.sha256sum"
      #   if sha256sum -c "${arqPrograma}.sha256sum" ; then
      #      logMsg "Checou ok o hash sha256."
            ajustarECriarAtalhos
      #   else
      #      logMsg "Falhou checagem de hash sha256. Remover e tentar novamente!"
      #      rm "$arqPrograma" >> "$arqLog" 2>> "$arqLog"
      #   fi
      #else
      #   logMsg " mas nem existe arquivo $arqPrograma . Por favor tentar novamente!"
      #fi

   fi

else
   #echo -e "${VERDE} Consta que instalou com sucesso. Por favor testar! ${NC} "
   logMsg "Consta instalado o Cisco Packet Tracer!"
fi


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
}




if [ ! -e "/usr/bin/xterm" ] || [ ! -x "/usr/bin/xterm" ]; then

   if [ -e /etc/apt/sources.list.d/ubuntu-parana.list ] && [ $(egrep ^deb /etc/apt/sources.list.d/ubuntu-parana.list | wc -l) -gt 2 ]; then
      # Configurado rep Celepar
      sed -i -e 's/^deb/###deb/' /etc/apt/sources.list.d/official-package-repositories.list
      sed -i -e 's/^deb/###deb/' /etc/apt/sources.list
      export deuRedePrdSerah="simsim"

   else
      # Checar se existe rota 10.74.
      rotas=$(route -n | grep ^[0-9] | grep -v '^0.0.0.0 ' | grep -v '^169.254.0.0 ' | cut -d' ' -f1)
      for rota in $rotas; do
         tmpRota=$(echo $rota | sed 's/^10\.74\.//')
         if [[ "$tmpRota" != "$rota" ]]; then
            export deuRedePrdSerah="simsim"
            break
         fi
      done
      if [[ "$deuRedePrdSerah" != "simsim" ]]; then
         estahNaRedePRD
      fi
      if [[ "$deuRedePrdSerah" = "simsim" ]]; then
         echo "Rede Estado, trocando repositorios."
         cd /tmp
         rm repositorios.deb 2>> /dev/null
         wget http://ubuntu.celepar.parana/repositorios.deb
         if [ -e "repositorios.deb" ]; then
            if [ $okDpkgOuApt = 'sim' ]; then
               dpkg -i repositorios.deb
               if [ -e /etc/apt/sources.list.d/ubuntu-parana.list ] && [ $(egrep ^deb /etc/apt/sources.list.d/ubuntu-parana.list | wc -l) -gt 2 ]; then
                  sed -i -e 's/^deb/###deb/' /etc/apt/sources.list.d/official-package-repositories.list
                  sed -i -e 's/^deb/###deb/' /etc/apt/sources.list
               else
                  echo -e "${VERMELHO} Algo deu errado, pois não conseguimos ajustar repositórios! ${NC} "
               fi
            fi
         else
            echo "ERRO AO BAIXAR repositorios"
         fi
      else
         echo "Fora da rede PRD"
      fi
   fi

   if [ $okDpkgOuApt = 'sim' ]; then
      apt-get  update  &>> "$arqLog"

      apt-get -y -f install  &>> "$arqLog"
      if [ $? -ne 0 ]; then
         echo "erro no -f install" &>> "$arqLog"
         exit 1
      fi

      apt-get -y install xterm
      if [ $? -ne 0 ]; then
         echo "erro no install do xterm" &>> "$arqLog"
      fi
   fi
fi



# ===================================================================== GNS3 ==============================================
##if [ -e /usr/bin/gns3 ] && [ -x /usr/bin/gns3 ]; then
##   echo "Tem o GNS3 no bin. $(date +%d/%m/%Y_%H:%M:%S_%N)" >> "$arqLog"
##   if id escola &> /dev/null ; then
##      usermod -aG ubridge,libvirt,kvm escola >> "$arqLog" 2>> "$arqLog"
##   fi
##   echo "GNS3 executável ok"
##
##else
##
##   echo "Tentar instalar o GNS3..."
##   if [ -e /etc/apt/sources.list.d/ubuntu-parana.list ] && [ $(egrep ^deb /etc/apt/sources.list.d/ubuntu-parana.list | wc -l) -gt 2 ]; then
##       # Configurado rep Celepar
##       sed -i -e 's/^deb/###deb/' /etc/apt/sources.list.d/official-package-repositories.list
##       sed -i -e 's/^deb/###deb/' /etc/apt/sources.list
##
##   else
##       estahNaRedePRD
##       if [[ "$deuRedePrdSerah" = "simsim" ]]; then
##         echo "Rede Estado, ajustando repositorios."
##         cd /tmp
##         rm repositorios.deb 2>> /dev/null
##         wget http://ubuntu.celepar.parana/repositorios.deb
##         if [ -e "repositorios.deb" ]; then
##            dpkg -i repositorios.deb
##            sed -i -e 's/^deb/###deb/' /etc/apt/sources.list.d/official-package-repositories.list
##            sed -i -e 's/^deb/###deb/' /etc/apt/sources.list
##         else
##            echo "ERRO AO BAIXAR repositorios"
##         fi
##       else
##         echo "Fora da rede PRD"
##       fi
##   fi
##
##   if [ $okDpkgOuApt = 'sim' ]; then
##      export DEBIAN_FRONTEND=noninteractive
##      add-apt-repository -y ppa:gns3/ppa >> "$arqLog" 2>> "$arqLog"
##      apt-get update >> "$arqLog" 2>> "$arqLog"
##      DEBIAN_FRONTEND=noninteractive apt-get -yq install gns3-gui gns3-server xterm >> "$arqLog" 2>> "$arqLog"
##      if [ $? -gt 0 ]; then
##         rm /var/lib/apt/lists/* >> "$arqLog" 2>> "$arqLog"
##         rm /var/lib/apt/lists/partial/* >> "$arqLog" 2>> "$arqLog"
##         apt-get clean >> "$arqLog" 2>> "$arqLog"
##         apt-get update >> "$arqLog" 2>> "$arqLog"
##         apt-get -f install >> "$arqLog" 2>> "$arqLog"
##         DEBIAN_FRONTEND=noninteractive apt-get -yq install gns3-gui gns3-server xterm >> "$arqLog" 2>> "$arqLog"
##      fi
##      if id escola &> /dev/null ; then
##         usermod -aG ubridge,libvirt,kvm escola >> "$arqLog" 2>> "$arqLog"
##      fi
##   fi
##fi
##
##
##if [ -e "/usr/share/applications/gns3.desktop" ]; then
##   # copiar atalhos para home dos usuarios normais
##   nomeAtalho="gns3.desktop"
##   enderecoAtalho="/usr/share/applications/$nomeAtalho"
##   echo "Copiando atalhos do GNS3"
##   sed -i -e 's/^Name=GNS3$/Name=GNS3 Network Simulator/' "$enderecoAtalho"
##
##   cd /home
##   for usuario in *; do
##       if [[ "$usuario" = *"lost"* ]]; then
##           #echo "Pasta lost+found nem mexeremos"
##           continue
##       fi
##       if [ -d "/home/${usuario}" ]; then
##           cd "/home/${usuario}/"
##       else
##           continue
##       fi
##       if [[ ! -e 'Área de Trabalho' ]]; then
##           mkdir 'Área de Trabalho'
##           chown "${usuario}.${usuario}" 'Área de Trabalho'
##       fi
##
##       cp "$enderecoAtalho" "/home/${usuario}/Área de Trabalho/" 1>/dev/null 2>/dev/null
##       chown "${usuario}:${usuario}" "/home/${usuario}/Área de Trabalho/$nomeAtalho" 1>/dev/null 2>/dev/null
##       chmod ugo+x  "/home/${usuario}/Área de Trabalho/$nomeAtalho" 1>/dev/null 2>/dev/null
##       #logMsg "Atalhos criados para usuário $usuario "
##   done
##
##   # copiar atalho para convidados no skel
##   if [ -e "/etc/skel/Área de Trabalho/" ]; then
##       cp "$enderecoAtalho" "/etc/skel/Área de Trabalho/"
##       chmod ugo+x "/etc/skel/Área de Trabalho/$nomeAtalho" 1>/dev/null 2>/dev/null
##       #echo "Copiado para skel Convidados"
##   fi
##
##   # copiar pra Convidado logado
##   grep '^guest-' /etc/passwd| while read x; do
##      guest=$(echo "$x" | cut -d':' -f1)
##      if [ -e "/tmp/$guest" ]; then
##         #echo "Copiando para convidado $guest"
##         cp "$enderecoAtalho" "/tmp/${guest}/Área de Trabalho/" 1>/dev/null 2>/dev/null
##         chown "${guest}:${guest}" "/tmp/${guest}/Área de Trabalho/$nomeAtalho" 1>/dev/null 2>/dev/null
##         chmod +x "/tmp/${guest}/Área de Trabalho/$nomeAtalho" 1>/dev/null 2>/dev/null
##       fi
##   done
##fi


##if [ $okDpkgOuApt = 'sim' ] && [[ -e '/usr/share/applications/gns3.desktop' ]] && [[ -e "/usr/local/bin/packettracerstart.sh" ]] && [[ -e "/opt/packettracer73/$arqPrograma" ]] && [[ -e "/opt/packettracer73/squashfs-root/AppRun" ]]; then
if [[ -e "/usr/local/bin/packettracerstart.sh" ]] && [[ -e "/opt/packettracer73/$arqPrograma" ]] && [[ -e "/opt/packettracer73/squashfs-root/AppRun" ]]; then
   echo -e "${VERDE} Consta que instalou. Por favor testar! ${NC} "
   echo "Consta que instalou. Por favor testar! ($(date +%d/%m/%Y_%H:%M:%S_%N))" >> $arqLog
else
   echo -e "${VERMELHO} Algo deu errado, não terminou tudo ok. Por favor tentar novamente! ${NC} "
   echo "Falhou algo na instalacao ($(date +%d/%m/%Y_%H:%M:%S_%N))" >> $arqLog
fi

rm $LOCK 2>> /dev/null
echo ""





