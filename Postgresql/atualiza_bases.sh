#!/bin/bash

# ARRAY BASES UTF-8 "appurcamp" "dw" "events" "heimdall" "site" "sou"
bases_utf8=("bases" "utf8")
# ARRAY ISO-8859-1 "alfa" "eventos" "horarios" "planos"
bases_iso88591=("bases" "iso")

if [ $# -lt 1 ]; then
   echo "Por favor, digite pelo menos o nome de uma base de dados!"
   exit 1
fi
export PGPASSWORD="senhadousuariopg"
for BASE in $*; do
    echo "Iniciando $BASE "
    echo "----------------------------------"
    echo "Desconectando usuários $BASE"
    echo `date`
    /usr/bin/psql -U postgres -h 127.0.0.1 -d postgres -p 54320 -c "SELECT pg_terminate_backend(pg_stat_activity.pid) FROM pg_stat_activity WHERE pg_stat_activity.datname = '$BASE'"

    echo "-----------------------------------"
    echo "Dropando base $BASE"
    echo `date`
    /usr/bin/dropdb -U postgres -h localhost -p 54320 $BASE

    if [[ " ${bases_utf8[@]} " =~ " ${BASE} " ]]; then
        echo "é utf"

        echo "-----------------------------------"
        echo "Criando base $BASE"
        echo `date`
        /usr/bin/createdb -U postgres -h localhost $BASE -p 54320 

    fi
    if [[ " ${bases_iso88591[@]} " =~ " ${BASE} " ]]; then
        echo "é iso"

        echo "-----------------------------------"
        echo "Criando base $BASE"
        echo `date`
        /usr/bin/createdb -U postgres -h localhost $BASE -p 54320 --encoding='LATIN1' --lc-collate='pt_BR.ISO-8859-1' --lc-ctype='pt_BR.ISO-8859-1' --template='template0'

    fi
    echo "----------------------------------"
    echo "pg_restore $BASE"
    echo `date`

    /usr/bin/pg_restore -U postgres -h localhost -p 54320 -Fc -v -d $BASE ${BASE}_ontem.pgbkp >./log/log_${BASE} 2>./log/log_erro_${BASE}
    echo "concluído $BASE"
    echo "==================================="
done
