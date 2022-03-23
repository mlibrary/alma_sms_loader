# Alma SMS Loader - Archived

This was for using the Alma API to make a bulk change to SMS numbers. Since MLibrary has migrated to Alma this is not longer needed.

---

One off script for loading sms numbers into alma and making them internal segments

## Setting up for development

Clone the repo

```
git clone git@github.com:mlibrary/alma_sms_loader.git
cd alma_sms_loader
```

copy .env-example directory to .env

```
cp -r .env-example .env
```

edit .env/development with Alma Credentials

```ruby
#.env/development
ALMA_API_KEY='YOURAPIKEY'
ALMA_API_HOST='https://api-na.hosted.exlibrisgroup.com'
```

build web container

```
docker-compose build web
```

bundle install

```
docker-compose run web bundle install
```

add an appropriate sms.tsv

run the script

```
docker-compose run --rm web bundle exec ruby sms_loader.rb
```


