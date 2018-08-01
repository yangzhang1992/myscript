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

  if [ ! -d $PROJECT_ROOT ]; then
    mkdir -p $PROJECT_ROOT
  fi

  if [ ! -d $PROJECT_BUILD_ROOT ]; then
    mkdir -p $PROJECT_BUILD_ROOT
  fi

  if [ ! -d $PROJECT_CODE_ROOT ]; then
    # 若代码目录不存在，则必须是clean_full
    mkdir -p $PROJECT_CODE_ROOT
    JENKINS_CLEAN_BUILD = clean_full
  fi

}

generate_static_xml()
{
    echo "enter generate_static_xml"
    manifest_static=$PROJECT_CODE_ROOT/manifest_static
    cd $PROJECT_CODE_ROOT


    if [  -d ${manifest_static} ];then
        rm -rf ${manifest_static}
    fi
    git clone ${REPO_URL} -b ${MANIFEST_BRANCH} ${manifest_static}

    if [ -d ${manifest_static}/yota/Snapshot_XML/${PROJECT_BRANCH_NAME} ];then
        echo "${manifest_static}/yota/${PROJECT_BRANCH_NAME}/Snapshot_XML exist"
    else
        echo "create ${manifest_static}/yota/Snapshot_XML/${PROJECT_BRANCH_NAME}"
        mkdir -p ${manifest_static}/yota/Snapshot_XML/${PROJECT_BRANCH_NAME}
    fi

    NEW_TAG=${PROJECT_BRANCH_NAME}_${CURRENT_DATETIME}.xml
    ${PROJECT_CODE_ROOT}/.repo/repo/repo manifest -o ${NEW_TAG} -r
    echo "cp ${NEW_TAG} ${manifest_static}/yota/Snapshot_XML/${PROJECT_BRANCH_NAME}"
    cp -rf ${NEW_TAG} ${manifest_static}/yota/Snapshot_XML/${PROJECT_BRANCH_NAME}

    mkdir -p ${PROJECT_SHARE_ROOT}
    cp -rf ${NEW_TAG} $PROJECT_TMP_ROOT

    #get old.xml
    export LAST_COMPILE=${PROJECT_TMP_ROOT}/last_compile.log
    if [ ! -f ${LAST_COMPILE} ];then
        echo "create log LAST_COMPILE:${LAST_COMPILE}"
        echo "" >${LAST_COMPILE}
    fi
    OLD_TAG=`cat ${LAST_COMPILE}`
    if [ -z ${OLD_TAG} ];then
    echo "OLD_TAG is empty,首次检测构建"
    BUILD_FLAG=1
    else
        echo "gen ReleaseNote.xml"
        cp ${manifest_static}/yota/Snapshot_XML/${PROJECT_BRANCH_NAME}/$OLD_TAG ./
        python $PROJECT_BUILD_ROOT/genRelease.py $OLD_TAG $NEW_TAG $PROJECT_CODE_ROOT
        cp $PROJECT_CODE_ROOT/ReleaseNote.xls  ${PROJECT_SHARE_ROOT}
    fi
    cp -rf ${NEW_TAG} $PROJECT_SHARE_ROOT
    echo "$NEW_TAG" >${LAST_COMPILE}

    cd ${manifest_static}
    git add --all
    git commit -m "auto submit snapshot for ${PROJECT_BRANCH_NAME}"
    git pull --rebase

    ret=`git push origin ${MANIFEST_BRANCH}`
    if [ $? != 0 ];then
        echo "-- submit static xml failed,try again --"
        git pull --rebase
        git push origin ${MANIFEST_BRANCH}
        if [ $? != 0 ];then
            echo "-- the 2nd submit static xml failed,exit -- "
        fi
    else
        echo "static xml uploaded successfully"
    fi

    echo "leave generate_static_xml"
}

sync_code()
{
  cd $PROJECT_CODE_ROOT

  echo "=====start repo sync======"
  # echo `pwd`
 # if [ ! -f $PROJECT_CODE_ROOT/.repo/manifest.xml ]; then
    echo $REPO_CMD init -u $REPO_URL -b $MANIFEST_BRANCH -m $MAINFEST_CONFIG --repo-url=ssh://172.16.7.21:29418/git_repo/repo.git --repo-branch=caf-stable --no-repo-verify
    $REPO_CMD init -u $REPO_URL -b $MANIFEST_BRANCH -m $MAINFEST_CONFIG --repo-url=ssh://172.16.7.21:29418/git_repo/repo.git --repo-branch=caf-stable --no-repo-verify
  #fi

  # $REPO_CMD forall -c git reset --hard

  $REPO_CMD sync -j8
  while [ $? != 0 ]; do
    echo “======sync failed, re-sync again======”
    sleep 3
    $REPO_CMD sync -j8
  done
}

# cd $PROJECT_CODE

create_base_environment

case $JENKINS_CLEAN_BUILD in
  clean_full)
    echo "CLEAN_BUILD:clean_full"
    rm -rf $PROJECT_CODE_ROOT
    mkdir -p $PROJECT_CODE_ROOT
    sync_code
    ;;
  clean_out)
    echo "CLEAN_BUILD:clean_out"
    rm -rf $PROJECT_CODE_ROOT/out
    sync_code
    ;;
  clean_none)
    echo "CLEAN_BUILD:clean_none"
    sync_code
    ;;
  update_none)
    echo "CLEAN_BUILD:update_none"
    ;;
  *)
    echo "CLEAN_BUILD: error!"
    exit 1
    ;;
esac
if [ x$IS_JENKINS_BUILD == xtrue ]; then
  generate_static_xml
fi
exit 0

