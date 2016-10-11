require 'spec_helper'
require_relative '../../lib/importers/pdf_ecad'

describe 'Ecad PDF Import' do
  before(:each) do
    @importer = Importers::PdfEcad.new('fixtures/importers/careqa.pdf')
  end

  # it 'should list all works' do
  #   @importer.works.count.should == 130
  #   @importer.works[0][:iswc].should == 'T-039.782.970-7'
  #   @importer.works[9][:right_holders].size.should == 4
  #   @importer.works[9][:right_holders][2][:share].should == 25.00
  # end

  it 'should recognize a right holder for 100% line' do
    line = '4882         CARLOS DE SOUZA                        CARLOS CAREQA            582.66.28.18 ABRAMUS          CA   100,                        1'
    rh = @importer.right_holder(line)
    expect(rh[:name]).to eq('CARLOS DE SOUZA')
    expect(rh[:pseudos][0][:name]).to eq('CARLOS CAREQA')
    expect(rh[:pseudos][0][:main]).to be true
    expect(rh[:role]).to eq 'Author'
    expect(rh[:society_name]).to eq 'ABRAMUS'
    expect(rh[:ipi]).to eq '582662818'
    expect(rh[:external_ids][0][:source_name]).to eq 'Ecad'
    expect(rh[:external_ids][0][:source_id]).to eq '4882'
    expect(rh[:share]).to eq 100
  end

  it 'should recognize share for broken percent' do
    line = '16863        EDILSON DEL GROSSI FONSECA             EDILSON DEL GROSSI                     SICAM           CA 33,33                         2'
    rh = @importer.right_holder(line)
    expect(rh[:name]).to eq 'EDILSON DEL GROSSI FONSECA'
    expect(rh[:share]).to eq 33.33
    expect(rh[:ipi]).to be_nil
  end

  it 'should recognize share in right holder line' do
    line = '741          VELAS PROD. ARTISTICAS MUSICAIS E      VELAS                    247.22.09.80 ABRAMUS           E   8,33 20/09/95               2'
    rh = @importer.right_holder(line)
    expect(rh[:name]).to eq 'VELAS PROD. ARTISTICAS MUSICAIS E'
    expect(rh[:share]).to eq 8.33
    expect(rh[:role]).to eq 'Publisher'
  end

  # it "should return nil if it is not a right_holder" do
  #   line = "3810796       -   .   .   -          O RESTO E PO                                                LB             18/03/2010"
  #   rh = @importer.right_holder(line)
  #   rh.should be_nil
  # end
  #
  # it "should recognize work in line" do
  #   line = "3810796       -   .   .   -          O RESTO E PO                                                LB             18/03/2010"
  #   work = @importer.work(line)
  #   work.should_not be_nil
  #   work[:iswc].should == "-   .   .   -"
  #   work[:title].should == "O RESTO E PO"
  #   work[:external_ids][0][:source_name].should == "Ecad"
  #   work[:external_ids][0][:source_id].should == "3810796"
  #   work[:situation].should == "LB"
  #   work[:created_at].should == "18/03/2010"
  # end

end