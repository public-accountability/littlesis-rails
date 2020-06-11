describe Position do
  describe 'description_indicates_executive' do
    specify do
      expect(Position.description_indicates_executive('CHIEF EXECUTIVE OFFICER')).to be true
      expect(Position.description_indicates_executive('NON-EXECUTIVE DIRECTOR')).to be false
      expect(Position.description_indicates_executive('CCO')).to be true
    end
  end

  describe 'description_indicates_board_membership' do
    specify do
      expect(Position.description_indicates_board_membership('CHIEF EXECUTIVE OFFICER')).to be false
      expect(Position.description_indicates_board_membership('CCO')).to be false
      expect(Position.description_indicates_board_membership('MEMBER')).to be true
      expect(Position.description_indicates_board_membership('chairman of the BOARD')).to be true
    end
  end
end
