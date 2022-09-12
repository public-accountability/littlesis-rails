describe OligrapherAssetsService do
  specify do
    expect { OligrapherAssetsService.run("invalid_commit") }.to raise_error(RuntimeError)
  end
end
