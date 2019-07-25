describe Sec do
  describe 'verify_cik!' do
    specify do
      expect { Sec.verify_cik!('') }.to raise_error(Sec::InvalidCikNumber)
    end

    specify do
      expect { Sec.verify_cik!('123') }.to raise_error(Sec::InvalidCikNumber)
    end

    specify do
      expect { Sec.verify_cik!('0000886982') }.not_to raise_error
    end
  end
end
