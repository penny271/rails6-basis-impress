FROM oiax/rails6-deps:latest

ARG UID=1000
ARG GID=1000

RUN mkdir /var/mail
RUN groupadd -g $GID devel
RUN useradd -u $UID -g devel -m devel
RUN echo "devel ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

WORKDIR /tmp
COPY init/Gemfile /tmp/Gemfile
COPY init/Gemfile.lock /tmp/Gemfile.lock
RUN bundle install

#  ! 不要 20230726 重複してる
COPY ./apps /apps

RUN apk add --no-cache openssl shared-mime-info

USER devel

RUN openssl rand -hex 64 > /home/devel/.secret_key_base
RUN echo $'export SECRET_KEY_BASE=$(cat /home/devel/.secret_key_base)' \
  >> /home/devel/.bashrc

WORKDIR /apps

#! 20230726
# ¥ 最後の行のCOPY . /appsでは、DockerfileがRailsアプリケーションのルートにあると仮定しているため、.はRailsアプリケーションであるカレントディレクトリを指しています。
# この修正により、bin/railsファイルを含むRailsアプリケーション全体がDockerコンテナで利用可能になるはずです。
# Dockerfileを修正したら、Dockerイメージを再構築します：
# COPY . /apps
