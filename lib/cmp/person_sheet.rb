module Cmp
  class PersonSheet < Cmp::ExcelSheet
    HEADER_MAP = {
      cmpid: 'CMPID_indl',
      fullname: 'DMCFullname',
      salutation: 'DMCSalutation',
      firstname: 'DMCFirstname',
      middlename: 'DMCMiddlename',
      lastname: 'DMCLastname',
      suffix: 'DMCSuffix',
      gender: 'DMCGender',
      dob_2015: 'DMCDateofbirth_2015',
      dob_2016: 'DMCDateofbirth_2016',
      nationality: 'DMCCountryiesofnationality'
    }.freeze
  end
end
