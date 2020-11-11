FROM ruby:2.7.2
ARG UNAME=app
ARG UID=1000
ARG GID=1000

LABEL maintainer="mrio@umich.edu"

RUN apt-get update -yqq && apt-get install -yqq --no-install-recommends \
  apt-transport-https

RUN gem install bundler:2.1.4

RUN groupadd -g ${GID} -o ${UNAME}
RUN useradd -m -d /app -u ${UID} -g ${GID} -o -s /bin/bash ${UNAME}
RUN mkdir -p /gems && chown ${UID}:${GID} /gems

USER $UNAME
COPY --chown=${UID}:${GID} Gemfile* /app/

ENV BUNDLE_PATH /gems

#Actually a secret
ENV ALMA_API_KEY 'YOUR_ALMA_API_KEY'

#Not that much of a secret
ENV ALMA_API_HOST 'https://api-na.hosted.exlibrisgroup.com'

WORKDIR /app
RUN bundle install

COPY --chown=${UID}:${GID} . /app
