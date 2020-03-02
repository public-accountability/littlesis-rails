# frozen_string_literal: true

describe 'OligrapherLockSerivce' do
  let(:user_one) { build(:user_with_id) }
  let(:user_two) { build(:user_with_id) }

  let(:map) do
    build(:network_map_version3,
          user_id: user_one.id,
          id: Faker::Number.unique.number(digits: 5),
          editors: [user_one.id, user_two.id])
  end

  let(:lock) do
    OligrapherLockService.new(map: map, current_user: user_one)
  end

  it 'is lockable when there is no lock'  do
    expect(lock.instance_variable_get(:@lock)).to be_nil
    expect(lock.locked?).to be false
  end

  it 'lets user create a lock' do
    expect { lock.lock }.to change(lock, :locked?).from(false).to(true)
    expect(lock.user_has_lock?).to eq true
  end

  it 'does not lock if other user has the lock' do
    OligrapherLockService.new(map: map, current_user: user_two).lock!
    expect(lock.locked?).to be true
    expect(lock.user_has_lock?).to eq false
    expect(lock.user_can_lock?).to eq false
  end

  it 'locking if lock is expired' do
    OligrapherLockService.new(map: map, current_user: user_two).lock!
    expect(lock.locked?).to be true
    expect(lock.user_can_lock?).to eq false
    lock.instance_variable_set(:@lock, OligrapherLockService::Lock.new(user_two.id, Time.current - 11.minutes))
    expect(lock.locked?).to be false
    expect(lock.user_can_lock?).to eq true
  end

  it 'raises error if user is not an editor' do
    expect do
      OligrapherLockService.new(map: map, current_user: build(:user_with_id))
    end.to raise_error(OligrapherLockService::Error)
  end
end
