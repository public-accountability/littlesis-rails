describe 'FlagForm' do
  it 'requires message and page' do
    expect(FlagForm.new(message: "example").valid?).to be false
  end

  it 'creates UserFlag'do
    flag_form = FlagForm.new(message: "example", page: 'https://littlesis.org', email: 'example@example.com')
    expect { flag_form. create_flag }.to change(UserFlag, :count).by(1)
  end
end
