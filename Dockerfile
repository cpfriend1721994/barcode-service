FROM bitnami/ruby:2.7-prod
COPY Gemfile Gemfile.lock ./
RUN apt update && \
    apt install -y build-essential && \
    bundle install --no-deployment --without development --binstubs && \
    apt-get remove -y --auto-remove build-essential && \
    apt clean && \
    rm -rf /var/lib/apt/lists/*
ADD . .
CMD ruby --jit config.rb
