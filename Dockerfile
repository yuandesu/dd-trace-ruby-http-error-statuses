FROM ruby:3.3-slim

RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    curl \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY Gemfile .
RUN bundle install
COPY config.ru .

EXPOSE 3000
CMD ["bundle", "exec", "puma", "-p", "3000"]
