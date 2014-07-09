# require "capybara/dsl"
# require "capybara/poltergeist"

class NetworkMap < ActiveRecord::Base
  include SingularTable
  include SoftDelete
  include Bootsy::Container
  # include Capybara::DSL    

  delegate :url_helpers, to: 'Rails.application.routes'

  belongs_to :sf_guard_user, foreign_key: "user_id", inverse_of: :network_maps
  belongs_to :user, foreign_key: "user_id", primary_key: "sf_guard_user_id", inverse_of: :network_maps
  delegate :user, to: :sf_guard_user

  scope :featured, -> { where(is_featured: true) }
  scope :public_scope, -> { where(is_private: false) }
  scope :private_scope, -> { where(is_private: true) }

  validates_presence_of :title

  def prepared_data
    hash = JSON.parse(data)
    JSON.dump({ 
      entities: hash['entities'].map { |entity| self.prepare_entity(entity) },
      rels: hash['rels'].map { |rel| self.prepare_rel(rel) },
      texts: hash['texts'].present? ? hash['texts'].map { |text| self.prepare_text(text) } : []
    })
  end

  def prepare_entity(entity)
    primary_ext = entity['primary_ext'].present? ? entity['primary_ext'] : (entity['url'].include?('person') ? 'Person' : 'Org')
    entity['primary_ext'] = primary_ext

    if entity['image'] and !entity['image'].include?('netmap') and !entity['image'].include?('anon')
      image_path = entity['image']
    elsif entity['filename']
      image_path = Image.image_path(entity['filename'], 'profile')
    else
      image_path = (primary_ext == 'Person' ? ActionController::Base.helpers.image_path('netmap-person.png') : ActionController::Base.helpers.image_path('netmap-org.png'))
    end

    url = ActionController::Base.helpers.url_for(Entity.legacy_url(entity['primary_ext'], entity['id'], entity['name']))

    {
      id: self.class.integerize(entity['id']),
      name: entity['name'],
      image: image_path,
      url: url,
      description: (entity['blurb'] || entity['description']),
      x: entity['x'],
      y: entity['y'],
      fixed: true,
      primary_ext: primary_ext,
      hide_image: entity['hide_image'].present? ? entity['hide_image'] : false
    }
  end

  def prepare_rel(rel)
    url = ActionController::Base.helpers.url_for(Relationship.legacy_url(rel['id']))

    {
      id: self.class.integerize(rel['id']),
      entity1_id: self.class.integerize(rel['entity1_id']),
      entity2_id: self.class.integerize(rel['entity2_id']),
      category_id: self.class.integerize(rel['category_id']),
      category_ids: Array(self.class.integerize(rel['category_ids'])),
      is_current: self.class.integerize(rel['is_current']),
      end_date: rel['end_date'],
      value: 1,
      label: rel['label'],
      url: url,
      x1: rel['x1'],
      y1: rel['y1'],
      fixed: true
    }
  end

  def prepare_text(text)
    text
  end

  def self.integerize(value)
    return nil if value.nil?
    return value.map { |elem| integerize(elem) } if value.instance_of?(Array)
    return integerize(value.split(',')) if value.instance_of?(String) and value.include?(',')
    return nil if value.to_i == 0 and value != "0"
    value.to_i
  end

  def name
    return "Map #{id}" if title.blank?
    title
  end

  def to_param
    title.nil? ? id.to_s : "#{id}-#{title.parameterize}"
  end

  def share_text
    title.nil? ? "Network map #{id}" : "Map of #{title}"
  end

  def generate_s3_thumb(s3 = nil)
    s3 = S3.s3 if s3.nil?
    bucket = s3.buckets[Lilsis::Application.config.aws_s3_bucket]

    url = Rails.application.routes.url_helpers.raw_map_url(self)
    local_path = "tmp/map-#{id}.png"
    s3_path = "images/maps/#{to_param}.png"

    system("phantomjs vendor/assets/javascripts/makemaps.js #{url} #{local_path}")

    obj = bucket.objects[s3_path]
    obj.write(Pathname.new(local_path), { acl: :public_read })

    File.delete(local_path)
    self.thumbnail = S3.url("/" + s3_path) if obj.exists?
    save
  end

  # def generate_thumbnail
  #   Capybara.run_server = false
  #   Capybara.register_driver :poltergeist do |app|
  #     Capybara::Poltergeist::Driver.new(app, {
  #       # Raise JavaScript errors to Ruby
  #       js_errors: false,
  #       # Additional command line options for PhantomJS
  #       phantomjs_options: ['--ignore-ssl-errors=yes'],
  #     })
  #   end
  #   Capybara.current_driver = :selenium
  #   Capybara.javascript_driver = :poltergeist    
  #   Capybara.app_host = 'http://lilsis.local'

  #   url = url_helpers.map_path(id: id)
  #   path = "app/assets/images/captures/map-#{id}.png"

  #   binding.pry

  #   visit url

  #   if page.driver.status_code == 200
  #     page.driver.save_screenshot(path, selector: '#netmap')
  #   else
  #     binding.pry
  #   end
  # end
end
