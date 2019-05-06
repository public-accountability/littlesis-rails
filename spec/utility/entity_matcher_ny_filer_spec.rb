describe EntityMatcher::NyFiler do
  describe 'extract_name_from' do
    def self.assert_correct_name(input, correct)
      it "can extract name from:  #{input}" do
        expect(EntityMatcher::NyFiler.extract_name_from(input))
          .to eq correct
      end
    end

    assert_correct_name 'FRIENDS OF JIMMY VAN BRAMER', 'JIMMY VAN BRAMER'
    assert_correct_name 'COMMITTEE TO ELECT LLINET ROSADO', 'LLINET ROSADO'
    assert_correct_name 'TONY AVELLA FOR QUEENS', 'TONY AVELLA'
    assert_correct_name 'CITIZENS FOR LISA RUBENSTEIN', 'LISA RUBENSTEIN'
    assert_correct_name 'CAMPAIGN TO ELECT MICHAEL CARPINELLI FOR SHERIFF', 'MICHAEL CARPINELLI'
    assert_correct_name 'SARA M GONZALEZ 2013', 'SARA M GONZALEZ'
    assert_correct_name 'MCCUSKER 4 MAYOR', 'MCCUSKER'
    assert_correct_name 'ERIE COUNTY FOR CAREY', 'CAREY'
    assert_correct_name 'CAREY FOR GOV', 'CAREY'
    assert_correct_name 'ERIRE COUNTY FOR CAREY (PARENTHETICAL)', 'CAREY'
    assert_correct_name "FINNERAN IN '82", 'FINNERAN'
  end
end
