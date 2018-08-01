#!/bin/bash
#
# Copyright (c) 2018, Chongqing BaoliYota Technology Company Limited. All rights reserved.
#

# 创建应有的目录，如果不是JENKINS构建，则需要配置环境变量
function create_base_environment()
{
  if [ "$JOB_NAME" = "" ]; then
    echo "Called by local build. import build.properties ..."
    for line in $(cat build.properties)
    do
      export $line
    done
  fi
}


# 复制OTA文件，去除原有路径
function copy_ota_images()
{
  rm -rf $TARGET_RELEASE_OTA_DIR
  mkdir -p $TARGET_RELEASE_OTA_DIR
  for f in `cat ota_spreadtrum.list`;
  do
    echo $f
    #dirPath = `dirname $f`
    #if [ ! -d $dirPath ]; then
    #  mkdir -p $dirPath
    #cp -afr $PROJECT_CODE_ROOT/$f $TARGET_RELEASE_OTA_DIR/
    mv $PROJECT_CODE_ROOT/$f $TARGET_RELEASE_OTA_DIR/
    if [ $? != 0 ]; then
      echo "mv $f error!"
      return 1
    fi
  done
}

create_base_environment

TARGET_RELEASE_OTA_DIR=$PROJECT_OUT_ROOT/ota

# 检查是否编译了OTA
if [ "$BUILD_WITH_OTA" != "true" ]; then
  echo "not build ota, so not release"
  exit 0
fi

if [ x"$CURRENT_DATETIME" = x"" ]; then
  CURRENT_DATETIME=`date +%Y%m%d_%H%M`
fi

copy_ota_images
if [ $? != 0 ]; then
  exit 1
fi

cd $PROJECT_BUILD_ROOT

if [ x"$IS_JENKINS_BUILD" == x"true" ]; then
  MNT_DIR=/mnt
  RELEASE_DIR=$MNT_DIR/$PROJECT_BRANCH_NAME/$JENKINS_BUILD_VARIANT
  cp -afr $TARGET_RELEASE_OTA_DIR  $RELEASE_DIR/$CURRENT_DATETIME/
fi
