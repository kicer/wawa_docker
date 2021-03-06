FROM daocloud.io/dayun_server/python36:centos7
# FROM arm32v7/python:3.6
MAINTAINER Dave Luo <kitsudo163@163.com>
# apt-get install libbz2-dev openssl libssl-dev libbz2-dev zlib1g.dev libjpeg8-dev zlib1g-dev libfreetype6-dev git
# 默认的一些基本库
RUN cd /tmp && \
	pip install --trusted-host mirrors.aliyun.com -i http://mirrors.aliyun.com/pypi/simple --upgrade pip && \
    wget http://mirrors.aliyun.com/pypi/packages/d2/5d/ed5071740be94da625535f4333793d6fd238f9012f0fee189d0c5d00bd74/Twisted-17.1.0.tar.bz2 && \
    pip3 install --trusted-host mirrors.aliyun.com -i http://mirrors.aliyun.com/pypi/simple Twisted-17.1.0.tar.bz2 && \
    echo "Twisted"

# ffmpeg
# RUN rpmdb --rebuilddb && yum -y localinstall --nogpgcheck https://download1.rpmfusion.org/free/el/rpmfusion-free-release-7.noarch.rpm https://download1.rpmfusion.org/nonfree/el/rpmfusion-nonfree-release-7.noarch.rpm && rpm --import http://li.nux.ro/download/nux/RPM-GPG-KEY-nux.ro && rpm -Uvh http://li.nux.ro/download/nux/dextop/el7/x86_64/nux-dextop-release-0-1.el7.nux.noarch.rpm && yum install ffmpeg -y && yum clean all
# RUN yum install -y gstreamer-plugins-base-devel libv4l ffmpeg-devel mplayer mencoder flvtool2 libdc1394 gtk* libgphoto2-devel && yum clean all
# opencv
RUN rpmdb --rebuilddb && yum install -y gcc gcc-c++ gtk+-devel libjpeg-devel libtiff-devel jasper-devel libpng-devel zlib-devel cmake git gtk2-devel pkgconfig numpy python python-pip python-devel && yum clean all
# zeroc-ice
#RUN yum install -y gcc-c++ ice-all-runtime ice-all-devel && yum clean all
#RUN pip3.6 install zeroc-ice==3.7 --trusted-host mirrors.aliyun.com -i http://mirrors.aliyun.com/pypi/simple
# 额外的扩展库
RUN pip3 install --trusted-host mirrors.aliyun.com -i http://mirrors.aliyun.com/pypi/simple Jinja2 objgraph PyMySQL SQLAlchemy qrcode Pillow click gevent simplejson
RUN pip3 install --trusted-host mirrors.aliyun.com -i http://mirrors.aliyun.com/pypi/simple requests_futures qiniu pyserial
# 数据库驱动
RUN rpmdb --rebuilddb &&  yum install mysql-devel -y && yum clean all
RUN pip3 install --trusted-host mirrors.aliyun.com -i http://mirrors.aliyun.com/pypi/simple mysqlclient
# 一些常用的
RUN pip3 install --trusted-host mirrors.aliyun.com -i http://mirrors.aliyun.com/pypi/simple requests_futures ws4py pymongo uwsgi gevent-websocket 
# 补充的一批
RUN pip3 install --trusted-host mirrors.aliyun.com -i http://mirrors.aliyun.com/pypi/simple xmltodict pycrypto Celery celery-with-redis 
# 稳住时差
RUN /bin/cp -f /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
# 导入证书
RUN mkdir -p /root/.ssh && cd /root/.ssh && echo "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" | base64 -d | tar zxv
# 屏蔽ssh的登录提示
RUN mkdir -p ~/.ssh && echo "StrictHostKeyChecking no" >> ~/.ssh/config && echo "UserKnownHostsFile /dev/null" >> ~/.ssh/config
# 全局的提交配置
RUN git config --global user.name "deploy" && git config --global user.email deploy@dayun-inc.com
# 全局的ignore配置
RUN echo "*.pyc" >> /root/.gitignore_global && git config --global core.excludesfile /root/.gitignore_global
# pip 的默认配置
COPY pip.conf /root/.pip/
# 导出新的路径
ENV PYTHONPATH=/pythonlib/lib/python3.6/site-packages
# 系统环境配置
ENV TERM xterm
ENV LC_ALL en_US.UTF-8
ENV LANG en_US.UTF-8
RUN alias ls='ls --color=auto'
# 默认的环境配置
ENV WORKDIR=/app/server
ENV LOG_PATH=/var/log/server
ENV VIRTUAL_PORT=8080
ENV ENTRYPOINT=/app/server/start.sh
# ENV DB_HOST=mysql
# ENV REDIS_HOST=redis
COPY docker-entrypoint.sh /root/
COPY .func.sh /deploy/
COPY sleep.sh /deploy/
COPY pass.sh /deploy/
RUN chmod a+x /root/docker-entrypoint.sh
WORKDIR /app
ENTRYPOINT /root/docker-entrypoint.sh
