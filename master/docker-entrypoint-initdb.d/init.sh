#!/bin/bash
set -eu

function createUserAndGrantPrivileges() {
    CREATE_DATABASE="CREATE DATABASE IF NOT EXISTS demo default charset utf8mb4 COLLATE utf8mb4_unicode_ci;"
    GRANT_RPIVILEGES_SXASSET_SQL="GRANT SELECT, INSERT, UPDATE, DELETE, SHOW VIEW, EXECUTE ON \`demo\`.* TO 'admin'@'%' identified by  '123qwe';"

    #定义创建账号的sql语句
    CREATE_USER_SQL="create user 'slave'@'%' identified by 'sync_123456';"
    #定义赋予同步账号权限的sql,这里设置两个权限，REPLICATION SLAVE，属于从节点副本的权限，REPLICATION CLIENT是副本客户端的权限，可以执行show master status语句
    GRANT_PRIVILEGES_SQL="grant replication slave, replication client on *.* to 'slave'@'%';"

    #定义刷新权限的sql
    FLUSH_PRIVILEGES_SQL="FLUSH PRIVILEGES;"
    mysql -u"root" -p"1qaztyui" -e "${CREATE_DATABASE} ${GRANT_RPIVILEGES_SXASSET_SQL} ${CREATE_USER_SQL} ${GRANT_PRIVILEGES_SQL} ${FLUSH_PRIVILEGES_SQL}"
}
createUserAndGrantPrivileges
echo "init mysql master"
