FROM ruby:2.4

RUN apt-get update -qq && apt-get install -y build-essential

ENV APP_HOME /app  

RUN mkdir $APP_HOME  
WORKDIR $APP_HOME

ADD Gemfile* $APP_HOME/  

RUN bundle install

EXPOSE 9292

ADD . $APP_HOME
