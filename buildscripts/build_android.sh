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

build_modules()
{
  if [ "$JENKINS_CLEAN_BUILD" = "clean_out" ]; then
    rm $PROJECT_CODE_ROOT/out -rf
  fi

  source build/envsetup.sh
  if [ "$1" = "8953" ]; then
    lunch msm8953_64-$JENKINS_BUILD_VARIANT
  fi
  if [ "$1" = "y3o" ]; then
    lunch Y3-$JENKINS_BUILD_VARIANT
  fi
  if [ "$1" = "YT" ]; then
    lunch YT-$JENKINS_BUILD_VARIANT
  fi
  if [ "$1" = "MR1" ]; then
    lunch sp7731e_1h20_native-$JENKINS_BUILD_VARIANT
  fi
  make -j24
}


# 1. 设置环境
create_base_environment
unset BUILD_ID
# 2. 检查代码目录是否存在
if [ ! -d $PROJECT_CODE_ROOT ]; then
  exit -1
else
  cd $PROJECT_CODE_ROOT
fi
# 3. 编译
if [ "$1" = "" ]; then
  echo "project error, stopped"
  echo "usages:build_android.sh projectname(8953,y3o)"
  exit 1
fi
build_modules $1

if [ $? != 0 ]; then
  exit 1
else
  exit 0
fi

