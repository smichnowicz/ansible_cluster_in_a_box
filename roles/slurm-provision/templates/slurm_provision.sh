#!/bin/sh

CVL_HOME="/cvl/home"
user_list=($(getent passwd | cut -d ":" -f1))
log_file="/root/slurm.log"

for user in ${user_list[*]}; do
    uid=$(id -u ${user})
    gid=$(id -g ${user})
    user_home=${CVL_HOME}/${user}
    if [ ! -d ${user_home} ]; then
        mkdir -p ${user_home}
        cp -r /etc/skel/* ${user_home}
        chown -R ${uid}:${gid} ${user_home}
        chmod 700 ${user_home}

        account=cvl
        cluster=m2cvl
        find=$(sacctmgr list cluster ${cluster} | grep ${cluster})
        if [ -z "${find}" ]; then
            su slurm -c "sacctmgr -i add cluster ${cluster}" || { echo "error to create cluster ${cluster}" >> ${log_file} && exit 1; }
        fi
        find=$(sacctmgr list account ${account} | grep ${account})
        if [ -z "${find}" ]; then
            su slurm -c "sacctmgr -i add account ${account} Description=CVL Organization=monash cluster=${cluster}" || { echo "error to create account ${account}" >> ${log_file} && exit 1; }
        fi
        find=$(sacctmgr list user ${username} | grep ${username})
        if [ -z "${find}" ]; then
            su slurm -c "sacctmgr -i add user ${username} account=${account} cluster=${cluster}" || { echo "error to create user ${username}" >> ${log_file} && exit 1; }
        fi
    fi
done


