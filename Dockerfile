FROM ruby:3.2.0-slim

RUN apt-get update -qq && apt-get install -y build-essential libpq-dev nodejs git

RUN mkdir /app
WORKDIR /app

ADD Gemfile /app/Gemfile
ADD Gemfile.lock /app/Gemfile.lock

ADD . /app
