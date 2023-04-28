#!/bin/bash
set -eu

function prepareStartSlave() {
  #设置连接master的同步相关信息
  SYNC_SQL="change master to master_host='master', master_user='slave', master_password='sync_123456', master_port=3306, master_auto_position=1;"
  #开启同步
  START_SYNC_SQL="start slave;"
  #查看同步状态
  STATUS_SQL="show slave status\G;"

  mysql -u"root" -p"1qaztyui" -e "${SYNC_SQL}"
  # 在这里执行 start slave 不生效 因为重启后 start slave 就会失效 而执行完这里脚本后 mysql 会关闭临时服务
  # mysql -u"root" -p"1qaztyui" -e "${START_SYNC_SQL} ${STATUS_SQL}"
}

prepareStartSlave
echo "init mysql slave1"