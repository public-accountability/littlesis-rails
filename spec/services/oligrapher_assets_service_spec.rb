describe OligrapherAssetsService do
  let(:commit) { '02a246dc16382f6161d556a176af350e144a7d7e' }
  let(:filename) { "oligrapher-#{commit}.js" }

  specify do
    expect { OligrapherAssetsService.new(commit, skip_fetch: true) }.not_to raise_error
  end

  specify do
    expect { OligrapherAssetsService.new('invalid_branch_or_commit_hash', skip_fetch: true) }
      .to raise_error(Exceptions::OligrapherAssetsError)
  end

  it '#run - checkouts, installs js packages, and builds' do
    service = OligrapherAssetsService.new(commit, skip_fetch: true)
    expect(service).to receive(:system).with(/checkout --force -q/).and_call_original
    expect(service).to receive(:system).with('yarn install --silent').and_return(true)
    expect(service).to receive(:system)
                         .with("yarn run webpack --env output_path=#{OligrapherAssetsService::ASSET_DIR} --env filename=#{filename} --env production --env public_path=/oligrapher/")
                         .and_return(true)

    service.run
  end

  it 'raises error if yarn fails to build' do
    service = OligrapherAssetsService.new(commit, skip_fetch: true)
    expect(service).to receive(:system).with(/checkout --force -q/).and_call_original
    expect(service).to receive(:system).with('yarn install --silent').and_return(true)
    expect(service).to receive(:system)
                         .with("yarn run webpack --env output_path=#{OligrapherAssetsService::ASSET_DIR} --env filename=#{filename} --env production --env public_path=/oligrapher/")
                         .and_return(false)

    expect { service.run }.to raise_error(Exceptions::OligrapherAssetsError)
  end
end
