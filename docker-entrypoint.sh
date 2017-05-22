#!/usr/bin/env bash
cd `dirname ${0}`;
# 脚本支付负责从git提取对应的代码并将发布的版本提交git这种操作而已
. /deploy/.func.sh
test -z "${GIT}" && exitBy "没有变量\${GIT}"
test -z "${TAG}" && exitBy "没有变量\${TAG}"
# 默认的启动脚本/以及工作目录
export ENTRYPOINT=${ENTRYPOINT:-"start.sh"}
export WORKDIR=${WORKDIR:-"/app/server"}

export SERVER_DIR=/repo/${GIT}
info "拉取代码"
# 原始的项目git
git_clone ${SERVER_DIR} "${GIT}" "${TAG}"

# 提交产生的迁移文件
if [ ! -z "${DEPLOY_GIT}" ]
then
  export DEPLOY_DIR=/repo/${DEPLOY_GIT}
  # 部署备份的git
  git_clone ${DEPLOY_DIR} "${DEPLOY_GIT}"
  cd ${DEPLOY_DIR} && git checkout master && git clean -dxf && git checkout . && git pull
  mkdir /tmp/deploy && cd ${SERVER_DIR} && tar c . --exclude=.git | tar x -C /tmp/deploy && cp -r ${DEPLOY_DIR}/.git /tmp/deploy
  # todo: 补上环境变量以及mount的备份
  env|sort > /tmp/deploy/env.out
  git_push "部署备份" /tmp/deploy "部署版本 ${TAG} @ `my_ip`"
  cd / && rm -fr /tmp/deploy
else
  info "没有部署备份"
fi
# 更新工作目录
cd / && rm -fr ${WORKDIR} && mkdir -p ${WORKDIR} && cd ${SERVER_DIR} && tar c . --exclude=.git | tar x -C ${WORKDIR}
info "准备启动"
cd ${WORKDIR}
if [ "${ENTRYPOINT:0:1}" != "/" ]
then
  ENTRYPOINT=${WORKDIR}/${ENTRYPOINT}
fi
test -x "${ENTRYPOINT}" || exitBy "entrypoint[${WORKDIR}][${ENTRYPOINT}]失效"
info "执行启动脚本[${WORKDIR}][${ENTRYPOINT}]"
${ENTRYPOINT} || exitBy "启动脚本[${WORKDIR}][${ENTRYPOINT}]执行失败"
info "SUCC [${WORKDIR}][${ENTRYPOINT}]"
info "wait for shutdown"
tail -f /dev/stdout
