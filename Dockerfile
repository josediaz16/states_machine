FROM ruby:2.7
MAINTAINER nathalyvillamor6@gmail.com

ENV LANG=C.UTF-
ENV LC_ALL=C.UTF-8

RUN gem install bundler
RUN mkdir /states_machine

WORKDIR /states_machine

ENTRYPOINT ["./docker_entrypoint"]
