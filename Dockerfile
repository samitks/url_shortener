FROM ruby:2.5

WORKDIR /url_shortner/app

COPY app/Gemfile .
RUN bundle install

COPY app .
EXPOSE 1234
CMD ["bundle", "exec", "ruby", "src/server.rb", "-p", "1234" ,"-o", "0.0.0.0"]
