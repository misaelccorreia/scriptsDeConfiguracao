#!/bin/bash

# Script para instalação de Extensoes no Visual Code do usuario escola e convidado

export arqLogDisto="/var/log/.log-install-extensoes-visual-code.log"
export GREP_COLOR='0;31;42'
export NC="\033[0m"
export VERMELHO="\033[0;41m" # vermelho
export VERDE="\033[0;42m" # Verde
export AMARELO="\033[30;103m" # Amarelo

export DEBIAN_FRONTEND=noninteractive

if [ ! $(/usr/bin/whoami) = 'root' ]; then
   echo "Por favor execute com SuperUsuário root para daí instalar o programas"
   exit 1
fi

echo "Iniciando. logs salvos no arquivo [$arqLogDisto]"
if [ -e "$arqLogDisto" ]; then
    echo "Iniciada RE-execucao as $(date +%d/%m/%Y_%H:%M:%S_%N)" >> "$arqLogDisto"
else
    echo "Iniciando em $(date +%d/%m/%Y_%H:%M:%S_%N)" >> "$arqLogDisto"
fi

logMsg() {
   echo "$1"
   echo "$1 ($(date +%d/%m/%Y_%H:%M:%S_%N))" >> "$arqLogDisto"
}


LOCK='/var/run/installextensoes-visual-code.lock'
PID=$(cat $LOCK 2>/dev/null)
if [ ! -z "$PID" ] && kill -0 $PID 2>/dev/null
then
   logMsg already running
   exit 1
fi
trap "rm -f $LOCK ; exit" INT TERM EXIT
echo $$ > $LOCK

cd /tmp/

if [ -e "code_1.93.0-1725459079_amd64.deb" ]; then
   rm "code_1.93.0-1725459079_amd64.deb"
fi
#if [ $(dpkg -l | grep ' code ' |  egrep "(1.87.2-1709912201|1.89.1-1715060508)" | wc -l) -eq 0 ]; then
if [ $(dpkg -l | grep "^ii[ \t]*code " | sed 's/^ii.*code *//' | grep "^1.[8-9][0-9]" | wc -l) -eq 0 ]; then
   wget -c "200.201.113.219/code_1.93.0-1725459079_amd64.deb"
   dpkg -i "code_1.93.0-1725459079_amd64.deb"

   apt-get update
   apt-get -y -f install
fi

arrumar_lancador_vscode() {
   echo "Arrumando lancado vsCode para convidados"
    cat > "/usr/share/code/codestart.sh" << EndOfThisFileIsExact
#!/bin/bash
if [ "\$(whoami | sed 's/-.*//')" = "guest" ]; then
   #echo "Usuario convidado sem acesso a este programa"
   #zenity --error --text '<span foreground="blue" font="16">Erro de permissão,\nUsuário Convidado sem acesso!</span>'
   sed -i -e "s#/home/escola#\$HOME#g" "\$HOME/.vscode/extensions/extensions.json"
   sed -i -e "s#/home/escola#\$HOME#g" "\$HOME/.vscode/extensions/ms-dotnettools.csdevkit-1.10.18-linux-x64/cache/discovery.json"
   /usr/share/code/code --no-sandbox --unity-launch
   echo "Usuario convidado era sem acesso a este programa"
else
   echo "ok continuar"
   /usr/share/code/code --unity-launch
fi
EndOfThisFileIsExact
   chmod +x /usr/share/code/codestart.sh
}

cat > "/tmp/.script-adicionar-code-extensoes.sh" << EndOfThisFileIsExactHere
#!/bin/bash

# Script para instalação de Extensoes no Visual Code do usuario escola e convidado

code --list-extensions

# GERAL
code --install-extension PKief.material-icon-theme
code --install-extension MS-vsliveshare.vsliveshare
code --install-extension ritwickdey.LiveServer
code --install-extension GitHub.vscode-pull-request-github
code --install-extension GitHub.codespaces
code --install-extension GitHub.remotehub
code --install-extension eamodio.gitlens

# Typescript
code --install-extension ms-vscode.vscode-typescript-next

# Python e Jupyter
code --install-extension ms-python.python
code --install-extension ms-python.vscode-pylance
code --install-extension ms-python.debugpy
code --install-extension ms-toolsai.jupyter
code --install-extension ms-python.autopep8

# Intelicode
code --install-extension VisualStudioExptTeam.intellicode-api-usage-examples
code --install-extension VisualStudioExptTeam.vscodeintellicode

# C
code --install-extension ms-vscode.cpptools

# C#
# code --install-extension ms-dotnettools.csharp
# code --install-extension ms-dotnettools.csdevkit
# Sao pesados estes 2

EndOfThisFileIsExactHere

chmod +x '/tmp/.script-adicionar-code-extensoes.sh'


su -c "/tmp/.script-adicionar-code-extensoes.sh" "escola" 2>&1 | tee -a "$arqLogDisto"
sleep 3
sync
echo -e "${AMARELO} Copiando para Convidados e para Pedagogico ... ${NC} "
if [ ! -e "/home/escola/.vscode" ]; then
   echo -e "${VERMELHO} ERRO: Faltou pasta .vscode no usuario escola! ${NC} "
   echo "Fim com ero em $(date +%d/%m/%Y_%H:%M:%S_%N)" >> "$arqLogDisto"
   exit 1
fi

if [ $(ls -1 /home/pedagogico/.vscode/extensions | wc -l) -lt 15 ]; then
   cp -r "/home/escola/.vscode" "/home/pedagogico/copiaVsCode$$"
   if [ -e "/home/pedagogico/.vscode" ]; then
      mv "/home/pedagogico/.vscode" "/home/pedagogico/.vscode$(date +%d_%m_%Y_%H_%M_%S_%N)"
   fi
   mv "/home/pedagogico/copiaVsCode$$" "/home/pedagogico/.vscode" 
   chown -R pedagogico.pedagogico "/home/pedagogico/.vscode" 
else
   su -c "/tmp/.script-adicionar-code-extensoes.sh" "pedagogico" 2>&1 | tee -a "$arqLogDisto"
   logMsg "Usuario pedagogico contem extensoes!"
fi


if [ ! -e /etc/skel/.vscode/extensions ] || [ $(ls -1 /etc/skel/.vscode/extensions | grep 'ms-vscode.cpptools' | wc -l) -eq 0 ]; then
   cp -r "/home/escola/.vscode" "/etc/copiaVsCode$$"
   if [ -e "/etc/skel/.vscode" ]; then
      mv "/etc/skel/.vscode" "/tmp/.vscode$(date +%d_%m_%Y_%H_%M_%S_%N)"
   fi
   mv "/etc/copiaVsCode$$" "/etc/skel/.vscode"
else
   logMsg "Usuario skel contem extensoes!"
fi

if [ -e "/home/framework" ]; then
   if [ $(ls -1 /home/framework/.vscode/extensions | wc -l) -lt 15 ]; then
      cp -r "/home/escola/.vscode" "/home/bkp-copiaVsCode$$"
      if [ -e "/home/framework/.vscode" ]; then
         mv "/home/framework/.vscode" "/tmp/.vscode$(date +%d_%m_%Y_%H_%M_%S_%N)"
      fi
      mv "/home/bkp-copiaVsCode$$" "/home/framework/.vscode" 
      chown -R framework.framework "/home/framework/.vscode"
   else
      logMsg "Usuario framework contem extensoes!"
   fi
else
   logMsg "Sem usuario framework!"
fi

arrumar_lancador_vscode

echo "Fim em $(date +%d/%m/%Y_%H:%M:%S_%N)" >> "$arqLogDisto"
if [ -e "$LOCK" ]; then rm -f "$LOCK"; fi
echo -e "${VERDE} Fim. Por favor testar! ${NC} "
echo ""
