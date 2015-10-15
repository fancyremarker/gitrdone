FROM quay.io/aptible/ruby:ruby-2.1

ADD Gemfile /app/Gemfile
ADD Gemfile.lock /app/Gemfile.lock
WORKDIR /app
RUN bundle install --without development test

ADD . /app

ENV PORT 3000
ENV RACK_ENV production
EXPOSE 3000
