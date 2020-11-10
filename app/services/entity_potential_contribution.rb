class EntityPotentialFECContributionsService
  def initialize(entity, name: nil)
    @entity = entity

    @donors = if name
                FEC::Donor.seach_by_name(params[:name])
              else
                FEC::Donor.seach_by_name(entity.person.first_middle_last)
              end

  end
end
