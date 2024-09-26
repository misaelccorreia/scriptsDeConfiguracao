#!/bin/bash

# Instalar o NodeJs versão 20
export NODE_MAJOR=20

export DEBIAN_FRONTEND=noninteractive
export GREP_COLOR='0;31;42'
export NC="\033[0m"
export VERMELHO="\033[0;41m" # vermelho
export VERDE="\033[0;42m" # Verde
export AMARELO="\033[30;103m" # Amarelo

if [ ! $(/usr/bin/whoami) = 'root' ]; then
   echo "Por favor execute com SuperUsuário root para daí instalar programas"
   exit 1
fi

instalarNode20() {
   echo -e "${AMARELO} iniciando instalar NodeJs versao 20 ${NC} "
   cat > "nodesource-repo.gpg.key" << EndOfThisFileIsHere
-----BEGIN PGP PUBLIC KEY BLOCK-----

mQENBFdDN1ABCADaNd/I3j3tn40deQNgz7hB2NvT+syXe6k4ZmdiEcOfBvFrkS8B
hNS67t93etHsxEy7E0qwsZH32bKazMqe9zDwoa3aVImryjh6SHC9lMtW27JPHFeM
Srkt9YmH1WMwWcRO6eSY9B3PpazquhnvbammLuUojXRIxkDroy6Fw4UKmUNSRr32
9Ej87jRoR1B2/57Kfp2Y4+vFGGzSvh3AFQpBHq51qsNHALU6+8PjLfIt+5TPvaWR
TB+kAZnQZkaIQM2nr1n3oj6ak2RATY/+kjLizgFWzgEfbCrbsyq68UoY5FPBnu4Z
E3iDZpaIqwKr0seUC7iA1xM5eHi5kty1oB7HABEBAAG0Ik5Tb2xpZCA8bnNvbGlk
LWdwZ0Bub2Rlc291cmNlLmNvbT6JATgEEwECACIFAldDN1ACGwMGCwkIBwMCBhUI
AgkKCwQWAgMBAh4BAheAAAoJEC9ZtfmbG+C0y7wH/i4xnab36dtrYW7RZwL8i6Sc
NjMx4j9+U1kr/F6YtqWd+JwCbBdar5zRghxPcYEq/qf7MbgAYcs1eSOuTOb7n7+o
xUwdH2iCtHhKh3Jr2mRw1ks7BbFZPB5KmkxHaEBfLT4d+I91ZuUdPXJ+0SXs9gzk
Dbz65Uhoz3W03aiF8HeL5JNARZFMbHHNVL05U1sTGTCOtu+1c/33f3TulQ/XZ3Y4
hwGCpLe0Tv7g7Lp3iLMZMWYPEa0a7S4u8he5IEJQLd8bE8jltcQvrdr3Fm8kI2Jg
BJmUmX4PSfhuTCFaR/yeCt3UoW883bs9LfbTzIx9DJGpRIu8Y0IL3b4sj/GoZVq5
AQ0EV0M3UAEIAKrTaC62ayzqOIPa7nS90BHHck4Z33a2tZF/uof38xNOiyWGhT8u
JeFoTTHn5SQq5Ftyu4K3K2fbbpuu/APQF05AaljzVkDGNMW4pSkgOasdysj831cu
ssrHX2RYS22wg80k6C/Hwmh5F45faEuNxsV+bPx7oPUrt5n6GMx84vEP3i1+FDBi
0pt/B/QnDFBXki1BGvJ35f5NwDefK8VaInxXP3ZN/WIbtn5dqxppkV/YkO7GiJlp
Jlju9rf3kKUIQzKQWxFsbCAPIHoWv7rH9RSxgDithXtG6Yg5R1aeBbJaPNXL9wpJ
YBJbiMjkAFaz4B95FOqZm3r7oHugiCGsHX0AEQEAAYkBHwQYAQIACQUCV0M3UAIb
DAAKCRAvWbX5mxvgtE/OB/0VN88DR3Y3fuqy7lq/dthkn7Dqm9YXdorZl3L152eE
IF882aG8FE3qZdaLGjQO4oShAyNWmRfSGuoH0XERXAI9n0r8m4mDMxE6rtP7tHet
y/5M8x3CTyuMgx5GLDaEUvBusnTD+/v/fBMwRK/cZ9du5PSG4R50rtst+oYyC2ao
x4I2SgjtF/cY7bECsZDplzatN3gv34PkcdIg8SLHAVlL4N5tzumDeizRspcSyoy2
K2+hwKU4C4+dekLLTg8rjnRROvplV2KtaEk6rxKtIRFDCoQng8wfJuIMrDNKvqZw
FRGt7cbvW5MCnuH8MhItOl9Uxp1wHp6gtav/h8Gp6MBa
=MARt
-----END PGP PUBLIC KEY BLOCK-----
EndOfThisFileIsHere
    apt-get update

    apt-get install -y ca-certificates curl gnupg

    if [ ! -e "/etc/apt/keyrings" ]; then
       mkdir -p /etc/apt/keyrings
    fi
    #curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | sudo gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg
    if [ -e /etc/apt/keyrings/nodesource.gpg ]; then rm /etc/apt/keyrings/nodesource.gpg; fi
    cat nodesource-repo.gpg.key | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg
    echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_$NODE_MAJOR.x nodistro main" | sudo tee /etc/apt/sources.list.d/nodesource.list
    apt-get update
    apt-get install nodejs -y
    apt-get -y -f install

   if [ -e /usr/bin/node ] && [ -x /usr/bin/node ]; then 
      node --version
      if [[ "$(node --version | cut -c2-3)" -lt 20 ]]; then 
         echo -e "${VERMELHO} ERRO: falhou algo. Tentando novamente! ${NC} "
         dpkg --remove --force-remove-reinstreq libnode-dev
         dpkg --remove --force-remove-reinstreq libnode72:amd64
         apt-get install nodejs -y
         apt-get -y -f install
      fi
   else
      echo -e "${VERMELHO} ERRO: falhou algo. Tentando novamente!! ${NC} "
      dpkg --remove --force-remove-reinstreq libnode-dev
      dpkg --remove --force-remove-reinstreq libnode72:amd64
      apt-get install nodejs -y
      apt-get -y -f install
   fi
}

ok=0
if [ -e /usr/bin/node ] && [ -x /usr/bin/node ]; then 
   if [[ "$(node --version | cut -c2-3)" -lt 20 ]]; then 
      echo -e "${AMARELO} VERSAO infeerior a 20 do NODE ($(node --version)) ${NC} "
      instalarNode20
   else
      echo -e "${VERDE} VERSAO 20+ ok do NODE ($(node --version)) ${NC} "
      ok=1
   fi
else
   instalarNode20
fi

if [ -e /usr/bin/node ] && [ -x /usr/bin/node ]; then 
   if [[ "$(node --version | cut -c2-3)" -lt 20 ]]; then 
      echo -e "${VERMELHO} ERRO: falhou algo. Por favor tentar novamente! ${NC} "
   else
      if [ $ok -eq 0 ]; then
         echo -e "${VERDE} VERSAO 20+ ok do NODE ($(node --version)) ${NC} "
      fi
   fi
else
   echo -e "${VERMELHO} ERRO: falhou algo. Por favor tentar novamente! ${NC} "
fi

echo ""
