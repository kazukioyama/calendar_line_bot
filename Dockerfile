# production環境用 (development環境用のDockerfileは /dev/Dockerfile)
FROM ruby:2.7

RUN apt-get update -qq && \
    apt-get install -y build-essential libpq-dev nodejs

RUN gem install bundler

COPY . app
WORKDIR /app

RUN bundle install

COPY start.sh /usr/bin/
RUN chmod +x /usr/bin/start.sh
ENTRYPOINT ["start.sh"]
EXPOSE 3000

CMD ["bin/start"]
