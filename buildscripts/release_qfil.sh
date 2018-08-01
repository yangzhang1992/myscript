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

# 复制ELF文件，保留原有路径
function copy_debug_images()
{
  local dirPath
  rm -rf $TARGET_DEBUG_DIR
  mkdir -p $TARGET_DEBUG_DIR
  for f in `cat debug.list`;
  do
    echo $f
    dirPath=`dirname $f`
    echo $dirPath
    if [ ! -d $TARGET_DEBUG_DIR/$dirPath ]; then
      mkdir -p $TARGET_DEBUG_DIR/$dirPath
    fi
    cp -afr $PROJECT_CODE_ROOT/$f $TARGET_DEBUG_DIR/$dirPath/
    if [ $? != 0 ]; then
      echo "cp $f error!"
      return 1
    fi
  done
}

# 复制镜像文件，去除原有路径
function copy_release_images()
{
  rm -rf $TARGET_RELEASE_DIR
  mkdir -p $TARGET_RELEASE_DIR
  for f in `cat release.list`;
  do
    echo $f
    #dirPath = `dirname $f`
    #if [ ! -d $dirPath ]; then
    #  mkdir -p $dirPath
    #fi
    cp -afr $PROJECT_CODE_ROOT/$f $TARGET_RELEASE_DIR/
    if [ $? != 0 ]; then
      echo "cp $f error!"
      return 1
    fi
  done
}

create_base_environment

if [ x"$CURRENT_DATETIME" = x"" ]; then
  CURRENT_DATETIME=`date +%Y%m%d_%H%M`
fi

TARGET_RELEASE_DIR=$PROJECT_OUT_ROOT/release
TARGET_DEBUG_DIR=$PROJECT_OUT_ROOT/debug

copy_release_images
if [ $? != 0 ]; then
  exit 1
fi

copy_debug_images
if [ $? != 0 ]; then
  exit 1
fi

cd $PROJECT_BUILD_ROOT
if [ -f android.log  ] ; then
  cp android.log $PROJECT_SHARE_ROOT
fi

if [ -f amss.log  ] ; then
  cp amss.log $PROJECT_SHARE_ROOT
fi

cd $PROJECT_OUT_ROOT/release
python checksparse.py -i rawprogram0.xml  -o rawprogram_unsparse.xml -s $PROJECT_OUT_ROOT/release/
if [ $? = 0 ];then
    rm -rf checksparse.py
    rm -rf ptool.py
    # RM_ITEM="userdata.img cust.img vendor.img system.img"
    # a=(${RM_ITEM})
    # for var in ${a[@]};do echo $var;rm $var ;done
else
    echo "分包错误"
    exit 1
fi

if [ x"$IS_JENKINS_BUILD" == x"true" ]; then
  MNT_DIR=/mnt
  RELEASE_DIR=$MNT_DIR/$PROJECT_BRANCH_NAME/$JENKINS_BUILD_VARIANT
  mkdir -p $RELEASE_DIR
  rm -rf $PROJECT_OUT_ROOT/ota
  cp -afr $PROJECT_OUT_ROOT  $RELEASE_DIR/$CURRENT_DATETIME
fi
