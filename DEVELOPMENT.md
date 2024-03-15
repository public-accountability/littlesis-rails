## Development

LittleSis is developed using Docker

### Build the application

Clone this repo: `git clone https://github.com/public-accountability/littlesis-rails`

Build the image: `bin/build`

Build a smaller production image: `env RAILS_ENV=production bin/build`

Install Ruby gems and JavaScript packages

``` sh
docker compose run --rm app bundle config path vendor/bundle
docker compose run --rm app bundle install
docker compose run --rm app npm install
```

### Load the data

Start the PostgreSQL Docker containers: `docker compose up -d postgres`

You can also access the database on the host: `psql postgresql://littlesis:themanbehindthemanbehindthethrone@localhost:8090/littlesis`.

Contact LittleSis about getting a development copy of the database.  Our convention is to store this in the /data/ directory within the code base.  The examples below assume this location.

The full database is quite large, so to reduce the size there are a handful of the tables to exclude that will significantly reduce it.  In order to do that, you can generate a table list from the database copy and use that list to filter the tables to import.

```
docker compose exec -u postgres postgres pg_restore -l data/database.pgdump > data/database.table-list
```

Edit the database.table-list file and comment out the the following TABLE DATA rows.

* external_data_fec_contributions
* external_data_nyc_contributions
* external_data_nycc
* external_data_nys_disclosures
* external_data_nys_filers
* external_entities
* ny_disclosures
* os_donations
* versions

Since the data folder is mounted at /data inside the postgres container, you can run any sql or pgdump files from there.  To load the database while filtering out the large tables, you can run:

``` sh
docker compose exec -u postgres postgres pg_restore -j 2 -v -L /data/database.table-list -d littlesis /data/database.pgdump
```

To load the entire database, you can run:

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

Create manticore configuration and indexes:

``` sh
docker compose exec app bundle exec rails ts:configure
docker compose exec app bin/rails ts:rt:index
```

Indexing will likely take a while.

Setup development users: `docker compose exec app bin/script create_development_users.rb`.

Visit port `8080` for Puma and `8081` for nginx. The configurations for nginx and postgres are located the folder config/docker

Run any command using the app container `docker compose exec app <CMD>`. For instance, to view all available rake tasks use `docker compose exec app bin/rake --tasks`.

To run a command in database as administrator use `docker compose exec -u postgres postgres psql`

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

---

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

### Frequent Production Commands

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
