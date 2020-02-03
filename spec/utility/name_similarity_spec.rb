describe NameSimilarity do
  specify do
    expect(
      NameSimilarity::Person.similar?("Alice Cat", "Alicx Cat")
    ).to be true
  end

  specify do
    expect(
      NameSimilarity::Person.similar?("Alice Cat", "Alice Dog")
    ).to be false
  end
end
