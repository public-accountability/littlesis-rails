# LittleSis Development

LittleSis is developed using Docker

## Setup

### Build the application

Clone this repo: `git clone https://github.com/public-accountability/littlesis-rails`

Build the docker image: `bin/build`

### Load the data

Start the PostgreSQL Docker containers: `docker compose up -d postgres`

You can also access the database on the host: `psql postgresql://littlesis:themanbehindthemanbehindthethrone@localhost:8090/littlesis`.

Contact LittleSis about getting a development copy of the database.  Our convention is to store this in the /data/ directory within the code base, and therefore accessible inside the Docker container.

To load the database, run:

``` sh
docker compose exec -u postgres postgres pg_restore -d littlesis /data/database.pgdump
```

### Compile the application and index the data

Start the remaining docker containers: `docker compose up -d`.

Compile assets:

``` sh
docker compose exec app bin/rails dartsass:build
docker compose exec app bin/rails javascript:build
docker compose exec app bin/rails assets:precompile
```

Create Manticore indexes:

``` sh
docker compose exec app bin/rails ts:rt:index
```

Indexing will likely take a while.

Setup development users: `docker compose exec app bin/script create_development_users.rb`.

Visit port `8080` for Puma and `8081` for nginx. The configurations for nginx and postgres are located the folder config/docker


### Docker Tips

Run any command using the app container `docker compose exec app <CMD>`. For instance, to view all available rake tasks use `docker compose exec app bin/rake --tasks`.

Re-install gems: `docker compose exec app bundle install`

To run a command in database as administrator use `docker compose exec -u postgres postgres psql`

To build a smaller production docker image: `env RAILS_ENV=production bin/build`

Disable docker cache: `env DOCKER_BUILD_OPTS="--no-cache" bin/build`


## Testing

LittleSis has quite extensive testing coverage.  The steps to run this locally are similar to the above except compiling should be against the test environment,

``` sh
docker compose exec -e RAILS_ENV=test app bin/rails db:reset
docker compose exec -e RAILS_ENV=test app bin/rails dartsass:build
docker compose exec -e RAILS_ENV=test app bin/rails javascript:build
docker compose exec -e RAILS_ENV=test app bin/rails assets:precompile
docker compose exec -e RAILS_ENV=test app bin/rails ts:configure
```

Run the tests: `docker compose exec -e RAILS_ENV=test app bin/rspec`


## bin/littlesis helper

``` fish
# add bin/littlesis to your path
ln -f -s /path/to/littlesis-rails/bin/littlesis /usr/local/bin/littlesis

# docker control
littlesis up
littlesis down
litltesis status
littlesis d top

# Testing
littlesis --test rails db:reset
littlesis --test rails assets:precompile
littlesis test
littlesis test spec/models/entity_spec.rb
littlesis lint app/models/entity.rb

# Create users for testing
littlesis script create_development_users.rb
littlesis script create_example_user.rb

# Rails tasks
littlesis rails -- --tasks
littlesis rails credentials:edit
littlesis rails db:migrate

# Thinking sphinx
littlesis rails ts:configure
littlesis rails ts:rt:index

# External data tools
littlesis data -- download nycc
littlesis data -- transform nycc
littlesis data -- load nycc
littlesis data -- report nycc
littlesis fec -- --help
littlesis sec -- --help
littlesis rails legislators:import
littlesis rails legislators:import_party_memberships
littlesis rails legislators:import_relationships
```

## Production


``` fish
function lscmd --description 'run a command as the littlesis user'
    sudo -u littlesis -D /littlesis fish -c "$argv"
end

lscmd git fetch
lscmd git pull
lscmd git switch --detach COMMIT

# bundle
lscmd bundle config path 'vendor/bundle'
lsbin bundle config without 'development test'
lscmd bundle install

# assets
lscmd npm ci
lscmd bundle exec rails javascript:build
lscmd bundle exec rails dartsass:build
lscmd bundle exec rails assets:precompile
lscmd bundle exec lib/scripts/download_oligrapher_assets.rb "v4.0.15"

# restarting
lscmd bundle exec pumactl phased-restart
systemctl restart littlesis.service littlesis-goodjob.service

# rails tasks
lscmd bundle exec rails users:send_reset_password_instructions[user@example.com]
lscmd bundle exec rails maps:screenshot:featured
lscmd bundle exec rails maps:screenshot:missing
lscmd bundle exec rails maps:update_all_entity_map_collections

# generate public dataset and sitemap
lscmd bundle exec rails public_data:run
lscmd bundle exec rails sitemap:run

# external data
lscmd bundle exec rails legislators:import
lscmd bundle exec rails legislators:import_party_memberships
lscmd bundle exec rails legislators:import_relationships
```
