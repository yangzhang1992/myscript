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

sign_modules()
{
  #mkdir -p $TARGET_RELEASE_DIR
  #添加QCOM_PLATFORM为后续平台化，暂时先注释掉。
  #local CFG=${PROJECT_CODE_ROOT}/common/config/${QCOM_PLATFORM}/${QCOM_PLATFORM}_secimage.xml
  #local TOOL_ROOT=${PROJECT_CODE_ROOT}/common/sectools
  local CFG=${PROJECT_CODE_ROOT}/common/config/$1/$1_secimage.xml
  local TOOL_ROOT=${PROJECT_CODE_ROOT}/common/sectools
  local OUTPUT=${TOOL_ROOT}/sign_out

  for f in `cat sign.list`;
  do
    echo $f
    #dirPath = `dirname $f`
    #if [ ! -d $dirPath ]; then
    #  mkdir -p $dirPath
    #fi
    #cp -afr $PROJECT_CODE_ROOT/$f $TARGET_RELEASE_DIR/$f
    ./${TOOL_ROOT}/sectools.py  secimage -i "${f}" -c "${CFG}" -o "${OUTPUT}"  -sa || return 1
  done
}

# 1. 设置环境
create_base_environment
unset BUILD_ID
sign_modules $1

if [ $? != 0 ]; then
  exit 1
else
  exit 0
fi


