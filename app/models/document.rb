# frozen_string_literal: true

# rubocop:disable Rails/DynamicFindBy

class Document < ApplicationRecord
  has_many :references

  has_one_attached :primary_source_document

  validates :primary_source_document, presence: true, if: :primary_source?

  validates :url,
            url: true,
            presence: true,
            unless: :primary_source?

  validates :url_hash,
            presence: true,
            uniqueness: { case_sensitive: true },
            unless: :primary_source?

  validates :name, length: { maximum: 255 }
  validates :publication_date, date: true

  before_validation :trim_whitespace, :set_hash, :convert_date

  unless Rails.env.development?
    after_create -> { InternetArchiveJob.perform_later(url) }, :unless => :primary_source?
  end

  has_paper_trail on: [:update, :destroy], versions: { class_name: 'ApplicationVersion' }

  PER_PAGE = 20

  ACCEPTED_MIME_TYPES = ['application/pdf', 'text/html', 'image/png', 'image/jpeg', 'text/csv'].freeze

  enum ref_type: { generic: 1,
                   fec: 2,
                   primary_source: 3 }

  def url
    if primary_source?
      raise Exceptions::MissingAttachmentError unless primary_source_document.attached?
      Rails.application.routes.url_helpers.rails_blob_path(primary_source_document)
    else
      super
    end
  end

  def self.find_or_create!(attrs)
    find_by_url(attrs.fetch(:url)) || Document.create!(attrs)
  end

  # Retrieve a Document by url
  # input: String
  # output: <Document> | nil
  def self.find_by_url(url)
    raise Exceptions::InvalidUrlError if url.blank? || !valid_url?(url)

    find_by url_hash: url_to_hash(url)
  end

  def self.valid_url?(url)
    URI.parse(I18n.transliterate(url.strip)).is_a?(URI::HTTP)
  rescue URI::InvalidURIError
    false
  end

  def self.url_to_hash(url)
    Digest::SHA1.hexdigest(url)
  end

  private

  def trim_whitespace
    self[:url].strip! if self[:url].present? && !primary_source?
    name&.strip!
  end

  def set_hash
    if self[:url].present? && !primary_source?
      self.url_hash = Document.url_to_hash(url)
    end
  end

  def convert_date
    self.publication_date = LsDate.convert(publication_date) unless publication_date.nil?
  end
end

# rubocop:enable Rails/DynamicFindBy
