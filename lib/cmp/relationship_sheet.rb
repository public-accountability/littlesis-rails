# frozen_string_literal: true

module Cmp
  class RelationshipSheet < Cmp::ExcelSheet
    HEADER_MAP = {
      cmpid: 'CMPID_Affln',
      orbis: 'DMCUCIUniqueContactIdentifier',
      cmp_org_id: 'CMPID_ORGL',
      cmp_person_id: 'CMPID_indl',
      appointment_year: 'AppointmentYear',
      new_in_2016: /newIn2016/i,
      board_status_2016: 'BdStatus16',
      board_status_2015: 'BdStatus15',
      ex_status_2016: 'ExStatus16',
      ex_status_2015: 'ExStatus15',
      standardized_position: 'Standardizedposition',
      job_title: 'DMCOriginaljobtitleinEnglish'
    }.freeze
  end
end
