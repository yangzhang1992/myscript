#!/bin/bash
#
# Copyright (c) 2018, Chongqing BaoliYota Technology Company Limited. All rights reserved.
#

# 创建应有的目录，如果不是JENKINS构建，则需要配置环境变量
create_base_environment()
{
  if [ "$JOB_NAME" = "" ]; then
    echo "Called by local build. import build.properties ..."
    for line in $(cat build.properties)
    do
      export $line
    done
  fi
  # export
}

build_rom_modules()
{
  #if [ $1 = clean ]; then
    #rm $PROJECT_CODE_ROOT/out -rf
  #fi

  echo build mode: $1
}


# 1. 设置环境
create_base_environment
unset BUILD_ID
# 2. 检查代码目录是否存在
if [ ! -d $PROJECT_ROM_ROOT ]; then
  echo "code dir not exist"
  # exit 1
else
  cd $PROJECT_ROM_ROOT
fi
# 3. 编译
build_rom_modules $1

if [ $? != 0 ]; then
  echo "failure."
  exit 1
else
  echo "success."
  exit 0
fi

