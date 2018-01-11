module Cmp
  class PersonSheet < Cmp::ExcelSheet
    HEADER_MAP = {
      cmpname: /CMP-IndlName/,
      cmpid: 'CMPID_indl',
      fullname: 'DMCFullname',
      salutation: 'DMCSalutation',
      firstname: 'DMCFirstname',
      middlename: 'DMCMiddlename',
      lastname: 'DMCLastname',
      suffix: 'DMCSuffix',
      gender: 'DMCGender'
      # date of birth: which year?
    }.freeze
  end
end
