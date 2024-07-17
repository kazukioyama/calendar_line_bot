FROM ruby:2.7

# パッケージリストを更新
RUN apt-get update

# vimパッケージをインストール
RUN apt-get install -y vim

# bundlerのバージョンを指定してインストール（rubyがv2以下の場合に必要）
RUN gem install bundler -v 2.4.22

COPY . app
WORKDIR /app

RUN bundle install
