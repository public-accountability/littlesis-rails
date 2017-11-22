module MergingExampleMacros
  def verify_contact_info_length_type_and_entity_id(type, entity_id)
    expect(subject.contact_info.length).to eql 1
    expect(subject.contact_info.first).to be_a type
    expect(subject.contact_info.first.entity_id).to eql entity_id
  end
end

module MergingGroupMacros
  def reset_merger
    before { subject.send(:reset_instance_vars) }
  end
end
