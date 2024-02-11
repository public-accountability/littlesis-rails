## Development

LittleSis is developed using docker

Clone this repo: `git clone https://github.com/public-accountability/littlesis-rails`

Build the image: `bin/build`

Build a smaller production image: `env RAILS_ENV=production bin/build`

Install ruby gems and javascript packages

``` sh
docker compose run --rm app bundle config path vendor/bundle
docker compose run --rm app bundle install
docker compose run --rm app npm install
```

Start all the docker containers: `docker compose up -d`

Start one of the docker containers: `docker compose up -d postgres`

Run any command using the app container `docker compose exec app <CMD>`. For instance, to view all available rake tasks use `docker compose exec app bin/rake --tasks`.

To run a command in database as administrator use `docker compose exec -u postgres postgres psql`

Setup database user and database:

``` sh
docker compose exec -u postgres postgres psql --command="CREATE ROLE littlesis WITH NOSUPERUSER CREATEDB LOGIN PASSWORD 'themanbehindthemanbehindthethrone'"
docker compose exec -u postgres postgres psql --command="CREATE DATABASE littlesis WITH OWNER littlesis"
```

You can also access the database on the host: `psql postgresql://littlesis:themanbehindthemanbehindthethrone@localhost:8090/littlesis`

The folder data is mounted at /data inside the postgres container, which you can run any sql or pgdump files there, for instance: `docker compose exec -u postgres postgres pg_restore -d <DATABASE> /data/archive.pgdump`

Setup the database:

``` sh
docker compose exec app bin/rails db:reset
```

The test database

``` sh
docker compose exec -e RAILS_ENV=test app bin/rails db:reset
docker compose exec -e RAILS_ENV=test app bin/rails dartsass:build
docker compose exec -e RAILS_ENV=test app bin/rails javascript:build
docker compose exec -e RAILS_ENV=test app bin/rails assets:precompile
docker compose exec -e RAILS_ENV=test app bin/rails ts:configure

```

Compile assets:  `docker compose exec app bin/rails assets:precompile`

Run the tests: `docker compose exec -e RAILS_ENV=test app bin/rspec`

Create manticore indexes: `docker compose exec app bin/rails ts:rt:index` This may take a while.

Setup development users: `docker compose exec app bin/script create_development_users.rb`

Visit port `8080` for Puma and `8081` for nginx. The configurations for nginx and postgres are located the folder config/docker

``` sh
# Build javascript & css
bin/rails javascript:build
bin/rails dartsass:build

# Download oligrapher assets
bin/script download_oligrapher_assets.rb "v4.0.15"

# Compile assets
bin/rails assets:precompile

# Edit secret variables
bin/rails credentials:edit

# Thinking sphinx
bin/rake ts:configure
bin/rake ts:index

# Stats on new entities & relationships
bin/rake stats:year[2021]

# Unitedstates.io data
bin/rake legislators:import
bin/rake legislators:import_party_memberships
bin/rake legislators:import_relationships

# External Data tools
bin/data list
bin/data download nycc
bin/data transform nycc
bin/data load nycc
bin/data report nycc
bin/fec --help
bin/sec -- --help

# Update public data
bin/rails public_data:run

# Generate sitemap
bin/rails sitemap:run

# Update Network Map Collections
bin/rake maps:update_all_entity_map_collections

# Create users for testing
bin/script create_development_users.rb
bin/script create_example_user.rb

# Rails console
bin/rails console

# Send reset password instructions
bin/rails runner "User.find_by(email: <EMAIL>).send_reset_password_instructions"
```


### frequent production commands

``` sh
cd /littlesis
git fetch origin
git switch --detach COMMIT
bin/bundle install
npm ci
bin/rake javascript:build
bin/rake assets:precompile
bin/script download_oligrapher_assets.rb TAG
systemctl restart littlesis.service littlesis-goodjob.service
```
