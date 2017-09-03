#!/usr/bin/env bash
function info {
    echo "$@"
}
function error {
    echo "$@"
}
function exitBy {
    error $1
    exit 1
}
function run {
    info "$1"
    params=(${@})
    ${params[@]:1}
}
function prepare_git {
    # git需要环境默认拥有(包括设置PATH变量部分)
    git version 2>&- 1>&- || exitBy "需要安装git"
}
function git_push {
    prepare_git
    local TITLE="$1"
    local WORKDIR="$2"
    local MSG="$3"
    info ${TITLE} 开始
    cd "${WORKDIR}"
    git add -A && git commit -a -m "${MSG}"
    if [ $? -eq 0 ]
    then
      git push -u origin master || exitBy "${TITLE} 失败"
    else
      info "没有改动"
    fi
    cd -
}
function git_clone {
    prepare_git
    local WORKDIR="$1"
    local GIT="$2"
    local TAG="$3"
    mkdir -p ${WORKDIR} && cd ${WORKDIR}
    if [ ! -d "${WORKDIR}/.git" ]
    then
        info "检出代码"
        git clone --recursive ${GIT} ${WORKDIR} || exitBy "获取失败[${GIT}]"
        cd "${WORKDIR}"
        git submodule init
        git submodule sync
        git submodule update --init --recursive
    else
        cd "${WORKDIR}"
        git checkout -f "${TAG}" 2>/dev/null 1>/dev/null
        if [ $? -eq 0 ]
        then
	    git submodule update --init --recursive
            info 当前代码版本正确
        else
            git fetch --tags --progress ${GIT} +refs/heads/*:refs/remotes/origin/*
            git submodule update --init --recursive
        fi
    fi
    git checkout -f "${TAG}" || exitBy "没有指定的版本[${GIT}][${TAG}]"
    # 跟进submodule的版本
    git submodule update --init --recursive
    test `git diff|wc -l` -eq 0 || exitBy "无法获取干净的版本[${GIT}][${TAG}]"
    cd -
}
function _my_ip_1 {
    curl -sSL http://ip.cn|grep -P '(?<=当前 IP：)[0-9.]+' -o
}
function _my_ip_2 {
    curl -sSL http://1212.ip138.com/ic.asp | grep '\[[0-9.]\+\]' -o |grep '[^][]\+' -o
}
function my_ip {
    _my_ip_1 || _my_ip_2
}
