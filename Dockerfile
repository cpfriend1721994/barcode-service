FROM ruby:2.7-alpine
COPY Gemfile Gemfile.lock ./
RUN apk add --update --virtual build_deps ruby-dev build-base && \
    bundle install --no-deployment --without development --binstubs && \
    apk del build_deps && rm -rf /var/cache/apk/*
ADD . .
CMD ruby --jit server.rb
