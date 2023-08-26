#!/bin/sh
#
# Autor: Rodrigo Lira 
# E-mail: eurodrigolira@gmail.com
# Blog: https://rodrigolira.eti.br
# 14/07/2018 - Versão 1.0
#
# Este script realiza um clone de uma maquina virtual no ESXi.
#
clear
echo -e "\e[41m+--------------------------------------------------+"
echo -e "|       ATENCAO       ATENCAO       ATENCAO        |"
echo -e "+--------------------------------------------------+\e[0m"
echo " "
echo -e "\e[41m+--------------------------------------------------+"
echo -e "|1 - ESTE SCRIPT REALIZA O CLONE DE UMA MAQUINA    |"
echo -e "|VIRTUAL NO ESXi 6.0, 6.5 E 6.7, O SCRIPT NAO FOI  |"
echo -e "|TESTATO EM OUTRAS VERSOES.                        |"
echo -e "|                                                  |"
echo -e "|2 - E NECESSARIO QUE A MAQUINA VIRTUAL ESTEJA     |"
echo -e "|DESLIGADA PARA O CLONE SER REALIZADO COM SUCESSO. |"
echo -e "|                                                  |"
echo -e "|3 - OS NOMES TEM QUE SER DIGITADOS CORRETAMENTE,  |" 
echo -e "|O SCRIPT NESSE MOMENTO NAO FAZ NENHUM TESTE SE    |"
echo -e "|O NOME FOI DIGITADO CORRETAMENTE.                 |"
echo -e "|                                                  |"
echo -e "|4 - NAO ME REPONSABILIZO CASO O SCRIPT NAO        |"
echo -e "|FUNCIONE COMO DESEJADO.                           |"
echo -e "|                                                  |"
echo -e "|              DUVIDAS E SUGESTOES                 |"
echo -e "|        E-mail: eurodrigolira@gmail.com           |"
echo -e "|        Blog: https://rodrigolira.eti.br          |"
echo -e "+--------------------------------------------------+\e[0m"
echo " "
echo -e "\e[41m+--------------------------------------------------+"
echo -e "|           DESEJA CONTINUAR? [SIM/NAO]            |"
echo -e "+--------------------------------------------------+\e[0m"
echo " "
read continua
if [ $continua == "SIM" ]; then
    clear
  else
    clear ; exit 0
fi
#
echo -e "\e[44m+--------------------------------------------------+"
echo -e "|      LISTA DE MAQUINAS VIRTUAIS DISPONIVEIS      |"
echo -e "+--------------------------------------------------+\e[0m"
echo " "
find /vmfs/volumes/ -type f -name "*.vmx" -exec ls {} \; | cut -f6 -d "/" | cut -f1 -d "."
echo " "
#
echo -e "\e[44m+--------------------------------------------------+"
echo -e "|   DIGITE O NOME DE QUAL MAQUINA DESEJA CLONAR    |"
echo -e "+--------------------------------------------------+\e[0m"
echo " "
read vm
clear
#
echo -e "\e[44m+--------------------------------------------------+"
echo -e "|          LISTA DE DATASTORES DISPONIVEIS         |"
echo -e "+--------------------------------------------------+\e[0m"
echo " "
esxcli storage filesystem list | grep VMFS | cut -d " " -f3
echo " "
#
echo -e "\e[44m+--------------------------------------------------+"
echo -e "|      DIGITE O NOME DO DATASTORE DE DESTINO       |"
echo -e "+--------------------------------------------------+\e[0m"
echo " "
read ds_dst
clear
#
echo -e "\e[44m+--------------------------------------------------+"
echo -e "|      DIGITE O NOME DA NOVA MAQUINA VIRTUAL       |"
echo -e "+--------------------------------------------------+\e[0m"
echo " "
read new_vm
clear
#
echo -e "\e[42m+--------------------------------------------------+"   
echo -e "|           CLONANDO A MAQUINA VIRTUAL             |"         
echo -e "+--------------------------------------------------+\e[0m"    
echo " "  
#
echo "[+] Criando a pasta da nova VM..."
mkdir /vmfs/volumes/"$ds_dst"/"$new_vm"
#
echo "[+] Entrando dentro da pasta da VM Template..."
pasta=`find /vmfs/volumes/ -type d -name "$vm"`
cd $pasta
#
echo "[+] Copiando os dados da VM Template para a nova VM..."
cp -R "$vm"* /vmfs/volumes/"$ds_dst"/"$new_vm"
#
echo "[+] Entrando na pasta da nova VM..."
cd /vmfs/volumes/"$ds_dst"/"$new_vm"
#
echo "[+] Renomeando o disco da nova VM..."
vmkfstools -E "$vm".vmdk "$new_vm".vmdk
#
echo "[+] Renomeando o arquivo de BIOS..."
mv "$vm".nvram "$new_vm".nvram
#
echo "[+] Renomeando o arquivo de snapshot..."
mv "$vm".vmsd "$new_vm".vmsd
#
echo "[+] Renomeando o arquivo de configuração..."
mv "$vm".vmx "$new_vm".vmx
#
echo "[+] Alterando o arquivo de configuração..."
sed -i "s/$vm/$new_vm/g" "$new_vm".vmx
#
echo "[+] Registrando a nova VM"
vim-cmd solo/registervm /vmfs/volumes/"$ds_dst"/"$new_vm"/"$new_vm".vmx
#
echo -e "\e[42m+--------------------------------------------------+"
echo -e "|           CLONE REALIZADO COM SUCESSO            |"
echo -e "+--------------------------------------------------+\e[0m"
echo -e " "
