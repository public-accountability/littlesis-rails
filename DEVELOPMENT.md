## Development

LittleSis is developed using docker or podman.

Clone this repo: `git clone https://github.com/public-accountability/littlesis-rails`

Build the image: `podman build -t littlesis:latest --env RAILS_ENV=development .`

Create folders: `mkdir -p tmp data data/external_data data/external_data/original data/external_data/csv public/oligrapher public/images public/images/large public/images/original public/images/profile public/images/small public/images/oligrapher`

Start the docker containers: `podman-compose up -d`

To run a command in the main app use `podman-compose exec app <CMD>` . For instance, to view all available rake tasks use `podman-compose exec bin/rake --tasks`. If this becomes tiresome, you might create some aliases like `abbr --add littlesis-rails 'podman-compose exec app bin/rails'`.

Setup the database: `podman-compose exec app bin/rails db:schema:load` && `podman-compose exec app bin/rails db:seed`

Alternatively, load a copy of the database: `zcat littlesis.sql.gz | psql postgresql://littlesis:themanbehindthemanbehindthethrone/littlesis`

Compile dev and test assets:  `podman-compose exec app bin/rails assets:precompile` && `podman-compose exec -e RAILS_ENV=test app bin/rails assets:precompile`

Setup the test database: `podman-compose exec -e RAILS_ENV=test app bin/rails db:reset`

Run the tests: `podman-compose exec -e RAILS_ENV=test app bin/rspec`

Create manticore indexes: `podman-compose exec bin/rake rake ts:index` This may take a while.

Setup development users: `podman-compose exec bin/script create_development_users.rb`

Visit port `8080` for Puma and `8081` for nginx. The configurations for nginx and postgres are located the folder config/docker

### LittleSis commands

``` sh
# Build javascript
bin/rake javascript:build

# Download oligrapher assets
bin/script oligrapher_download_assets.rb "v4.0.1"

# Compile assets
bin/rake assets:precompile

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
bin/rails runner "PublicData.run"

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
