#!/bin/bash

set -eu

user=root
root_password="1qaztyui"

_main() {
dockertag=$(docker ps | grep mysql-cluster_mysql_slave | awk '{print $1}')
dockertag=(${dockertag// / })
for dockerId in "${dockertag[@]}";do
  # 从服务器连接主互通
  echo ${dockerId}
  until $(docker exec ${dockerId} sh -c 'export MYSQL_PWD=1qaztyui; mysql -u root -e ";"')
  do
      echo "等待连接中,请稍候,每 1s 尝试连接一次,可能会重试多次,直到容器启动完毕......"
      sleep 1
  done
done

# 设置从服务器与主服务器互通命令
start_slave_cmd='export MYSQL_PWD='$root_password'; mysql -u root -e "'
start_slave_io_thread=${start_slave_cmd}'start slave io_thread;"'
start_slave_sql_thread=${start_slave_cmd}'start slave sql_thread;"'
# 执行从服务器与主服务器互通
for slave in "${dockertag[@]}";do
  # 从服务器连接主互通
  echo 'start slave'
  docker exec $slave sh -c "${start_slave_io_thread}"
  wait;
  docker exec $slave sh -c "$start_slave_sql_thread"
  wait;
  # 查看从服务器得状态
  docker exec $slave sh -c "export MYSQL_PWD='$root_password'; mysql -u root -e 'SHOW SLAVE STATUS \G'"
done

}

# check to see if this file is being run or sourced from another script
_is_sourced() {
    # https://unix.stackexchange.com/a/215279
    [ "${#FUNCNAME[@]}" -ge 2 ] \
        && [ "${FUNCNAME[0]}" = '_is_sourced' ] \
        && [ "${FUNCNAME[1]}" = 'source' ]
}

# If we are sourced from elsewhere, don't perform any further actions
if ! _is_sourced; then
    _main "$@"
fi