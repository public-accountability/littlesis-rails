# frozen_string_literal: true

describe 'OligrapherLockSerivce' do
  let(:user_one) { create(:user) }
  let(:user_two) { create(:user) }

  let(:map) do
    build(:network_map_version3,
          user_id: user_one.id,
          id: Faker::Number.unique.number(digits: 5),
          editors: [
            { id: user_two.id, pending: false }
          ])
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
    expect(lock.as_json).to eq(locked: true, user_id: user_one.id)
  end

  it 'does not lock if other user has the lock' do
    OligrapherLockService.new(map: map, current_user: user_two).lock!
    expect(lock.locked?).to be true
    expect(lock.user_has_lock?).to eq false
    expect(lock.user_can_lock?).to eq false
    expect(lock.user_has_permission?).to eq true
  end

  it 'locking if lock is expired' do
    OligrapherLockService.new(map: map, current_user: user_two).lock!
    expect(lock.locked?).to be true
    expect(lock.user_can_lock?).to eq false
    lock.instance_variable_set(:@lock, OligrapherLockService::Lock.new(user_two.id, Time.current - 16.minutes))
    expect(lock.locked?).to be false
    expect(lock.user_can_lock?).to eq true
  end

  it 'does not lock if user is not an editor' do
    other_user_lock = OligrapherLockService.new(map: map, current_user: build(:user_with_id))
    other_user_lock.lock!
    expect(other_user_lock.user_has_lock?).to be false
    expect(other_user_lock.user_can_lock?).to be false
    expect(other_user_lock.user_has_permission?).to be false
  end

  it 'throws if user is not an editor' do
    lock = OligrapherLockService.new(map: map, current_user: build(:user_with_id))
    expect(lock.user_has_permission?).to be false
    expect { lock.as_json }.to raise_error(Exceptions::PermissionError)
  end

  it 'lets user release the lock' do
    expect { lock.lock }.to change(lock, :locked?).from(false).to(true)
    expect { lock.release! }.to change(lock, :user_has_lock?).from(true).to(false)
  end
end
