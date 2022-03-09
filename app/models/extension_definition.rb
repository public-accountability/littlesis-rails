# frozen_string_literal: true

class ExtensionDefinition < ApplicationRecord
  has_many :extension_records,
           foreign_key: 'definition_id',
           inverse_of: :extension_definition,
           dependent: :nullify

  has_many :entities,
           through: :extension_records,
           inverse_of: :extension_definitions

  PERSON_ID = 1
  ORG_ID = 2

  # locale (:en | :es) => { id => name }
  DISPLAY_NAMES = {
    :en => {
      1 => "Person",
      2 => "Organization",
      3 => "Political Candidate",
      4 => "Elected Representative",
      5 => "Business",
      6 => "Government Body",
      7 => "School",
      8 => "Membership Organization",
      9 => "Philanthropy",
      10 => "Other Not-for-Profit",
      11 => "Political Fundraising Committee",
      12 => "Private Company",
      13 => "Public Company",
      14 => "Industry/Trade Association",
      15 => "Law Firm",
      16 => "Lobbying Firm",
      17 => "Public Relations Firm",
      18 => "Individual Campaign Committee",
      19 => "PAC",
      20 => "Other Campaign Committee",
      21 => "Media Organization",
      22 => "Policy/Think Tank",
      23 => "Cultural/Arts",
      24 => "Social Club",
      25 => "Professional Association",
      26 => "Political Party",
      27 => "Labor Union",
      28 => "Government-Sponsored Enterprise",
      29 => "Business Person",
      30 => "Lobbyist",
      31 => "Academic",
      32 => "Media Personality",
      33 => "Consulting Firm",
      34 => "Public Intellectual",
      35 => "Public Official",
      36 => "Lawyer",
      37 => "Couple",
      38 => "Academic Research Institute",
      39 => "Government Advisory Body",
      40 => "Elite Consensus Group"
    }.freeze,
    :es => {
      1 => "Persona",
      2 => "Organización",
      3 => "Candidato (político)",
      4 => "Representante",
      5 => "Negocio",
      6 => "Cuerpo/organismo de gobierno",
      7 => "Colegio",
      8 => "Asociaciones y sociedades",
      9 => "Filantropía",
      10 => "Otras organizaciones sin ánimo de lucro",
      11 => "Comité de recaudación con fines políticos",
      12 => "Compañía privada",
      13 => "Compañía pública",
      14 => "Asociaciones industriales/comerciales",
      15 => "Bufete de abogados",
      16 => "Cabildeo",
      17 => "Relaciones públicas",
      18 => "Comité de campaña individual",
      19 => "PAC",
      20 => "Otros comités de campaña",
      21 => "Organización de medios",
      22 => "Think Tank",
      23 => "Cultura/Arte",
      24 => "Clubs sociales",
      25 => "Asociaciones profesionales",
      26 => "Partido político",
      27 => "Sindicato",
      28 => "Iniciativas patrocinadas por el gobierno",
      29 => "Persona de negocios",
      30 => "Cabildo",
      31 => "Académico",
      32 => "Personalidad mediática",
      33 => "Consultoría",
      34 => "Intelectual público",
      35 => "Funcionario público",
      36 => "Abogado",
      37 => "Pareja",
      38 => "Instituto de investigación académica",
      39 => "Organismo asesor del gobierno",
      40 => "Grupo de consenso de élite"
    }.freeze
  }.freeze

  def self.not_tier_one
    where.not(tier: 1)
  end

  def self.matches_parent_id_or_nil(parent_id)
    arel_table[:parent_id].eq(parent_id).or(arel_table[:parent_id].eq(nil))
  end

  def self.person_types
    not_tier_one
      .where(matches_parent_id_or_nil(PERSON_ID))
      .order(name: :asc)
  end

  def self.org_types
    not_tier_one
      .where(matches_parent_id_or_nil(ORG_ID))
      .order(name: :asc)
  end

  def self.org_types_tier2
    where(matches_parent_id_or_nil(ORG_ID))
      .where(tier: 2)
      .order(name: :asc)
  end

  def self.org_types_tier3
    where(matches_parent_id_or_nil(ORG_ID))
      .where(tier: 3)
      .order(name: :asc)
  end

  def self.definition_ids_with_fields
    where(has_fields: true).map(&:id)
  end

  # { name => id }
  def self.id_lookup
    @id_lookup ||= all.each_with_object({}) do |ed, hash|
      hash.store ed.name, ed.id
    end.freeze
  end
end
