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
  cd $PROJECT_BUILD_ROOT
  echo build modules: $1 $2
  source /opt/setenv_x64.sh
  case $2 in
    boot_images)
      cd boot_images/build/ms
      if [ "$JENKINS_CLEAN_BUILD" = "clean_out" ]; then
        echo "clean build..."
        ./build.sh  TARGET_FAMILY=8953 --prod -c
      fi
      echo "start build..."
      ./build.sh  TARGET_FAMILY=8953 --prod
      ;;
    trustzone_images)
      cd trustzone_images/build/ms
      if [ "$JENKINS_CLEAN_BUILD" = "clean_out" ]; then
        echo "clean build..."
        ./build.sh CHIPSET=msm8953 devcfg sampleapp -c
      fi
      echo "start build..."
      ./build.sh CHIPSET=msm8953 devcfg sampleapp
      ;;
    adsp_proc)
      cd adsp_proc
      if [ "$JENKINS_CLEAN_BUILD" = "clean_out" ]; then
        echo "clean build..."
        python ./build/build.py -c msm8953 -o clean
      fi
      echo "start build..."
      python ./build/build.py -c msm8953 -o all
      ;;
    rpm_proc)
      cd rpm_proc/build
      if [ "$JENKINS_CLEAN_BUILD" = "clean_out" ]; then
        echo "clean build..."
        ./build_8953.sh -c
      fi
      echo "start build..."
      ./build_8953.sh
      ;;
    modem_proc)
      cd modem_proc/build/ms
      if [ "$JENKINS_CLEAN_BUILD" = "clean_out" ]; then
        echo "clean build..."
        ./build.sh 8953.gen.prod -c
      fi
      echo "start build..."
      ./build.sh 8953.gen.prod -k
      ;;
    non-hlos)
      cd common/build
      echo "build..."
      python build.py --nonhlos
      ;;
    *)
      echo "unkown amss modules error!"
      ;;
  esac

}


if [ x"$1" = x ]; then
  bash -x ./build/tool/build.sh "" YT
  echo "project name error, stopped"
  echo "usages:build_amss.sh projectname(8953,y3o) modules(rpm_proc,modem_proc)"
  exit 1
fi

# 1. 设置环境
create_base_environment
unset BUILD_ID
# 2. 检查代码目录是否存在
if [ ! -d $PROJECT_CODE_ROOT/amss ]; then
   exit -1
else
  cd $PROJECT_CODE_ROOT/amss
  bash -x ./build/tool/build.sh "" $1
fi

if [ $? != 0 ]; then
  exit 1
else
  exit 0
fi

