require 'spec_helper'

describe DataciteCrossref, type: :model, vcr: true do
  before(:each) do
    allow(Time).to receive(:now).and_return(Time.mktime(2015, 4, 8))
    subject.count = 0
  end

  let(:fixture_path) { "#{Sinatra::Application.root}/spec/fixtures/" }

  context "get_query_url" do
    it "default" do
      expect(subject.get_query_url).to eq("http://search.datacite.org/api?q=relatedIdentifier%3ADOI%5C%3A*&start=0&rows=200&fl=doi%2Ccreator%2Ctitle%2Cpublisher%2CpublicationYear%2CresourceTypeGeneral%2Cdatacentre_symbol%2CrelatedIdentifier%2Cxml%2Cminted%2Cupdated&fq=updated%3A%5B2015-04-07T00%3A00%3A00Z+TO+2015-04-08T23%3A59%3A59Z%5D+AND+has_metadata%3Atrue+AND+is_active%3Atrue&wt=json")
    end

    it "with zero rows" do
      expect(subject.get_query_url(rows: 0)).to eq("http://search.datacite.org/api?q=relatedIdentifier%3ADOI%5C%3A*&start=0&rows=0&fl=doi%2Ccreator%2Ctitle%2Cpublisher%2CpublicationYear%2CresourceTypeGeneral%2Cdatacentre_symbol%2CrelatedIdentifier%2Cxml%2Cminted%2Cupdated&fq=updated%3A%5B2015-04-07T00%3A00%3A00Z+TO+2015-04-08T23%3A59%3A59Z%5D+AND+has_metadata%3Atrue+AND+is_active%3Atrue&wt=json")
    end

    it "with different from_date and until_date" do
      expect(subject.get_query_url(from_date: "2015-04-05", until_date: "2015-04-05")).to eq("http://search.datacite.org/api?q=relatedIdentifier%3ADOI%5C%3A*&start=0&rows=200&fl=doi%2Ccreator%2Ctitle%2Cpublisher%2CpublicationYear%2CresourceTypeGeneral%2Cdatacentre_symbol%2CrelatedIdentifier%2Cxml%2Cminted%2Cupdated&fq=updated%3A%5B2015-04-05T00%3A00%3A00Z+TO+2015-04-05T23%3A59%3A59Z%5D+AND+has_metadata%3Atrue+AND+is_active%3Atrue&wt=json")
    end

    it "with offset" do
      expect(subject.get_query_url(offset: 250)).to eq("http://search.datacite.org/api?q=relatedIdentifier%3ADOI%5C%3A*&start=250&rows=200&fl=doi%2Ccreator%2Ctitle%2Cpublisher%2CpublicationYear%2CresourceTypeGeneral%2Cdatacentre_symbol%2CrelatedIdentifier%2Cxml%2Cminted%2Cupdated&fq=updated%3A%5B2015-04-07T00%3A00%3A00Z+TO+2015-04-08T23%3A59%3A59Z%5D+AND+has_metadata%3Atrue+AND+is_active%3Atrue&wt=json")
    end

    it "with rows" do
      expect(subject.get_query_url(rows: 250)).to eq("http://search.datacite.org/api?q=relatedIdentifier%3ADOI%5C%3A*&start=0&rows=250&fl=doi%2Ccreator%2Ctitle%2Cpublisher%2CpublicationYear%2CresourceTypeGeneral%2Cdatacentre_symbol%2CrelatedIdentifier%2Cxml%2Cminted%2Cupdated&fq=updated%3A%5B2015-04-07T00%3A00%3A00Z+TO+2015-04-08T23%3A59%3A59Z%5D+AND+has_metadata%3Atrue+AND+is_active%3Atrue&wt=json")
    end
  end

  context "get_total" do
    it "with works" do
      expect(subject.get_total).to eq(1181)
    end

    it "with no works" do
      expect(subject.get_total(from_date: "2009-04-07", until_date: "2009-04-08")).to eq(0)
    end
  end

  context "queue_jobs" do
    it "should report if there are no works returned by the Datacite Metadata Search API" do
      response = subject.queue_jobs(all: true, from_date: "2009-04-07", until_date: "2009-04-08")
      expect(response).to eq(0)
    end

    it "should report if there are works returned by the Datacite Metadata Search API" do
      response = subject.queue_jobs(all: true)
      expect(response).to eq(1181)
    end
  end

  context "get_data" do
    it "should report if there are no works returned by the Datacite Metadata Search API" do
      response = subject.get_data(from_date: "2009-04-07", until_date: "2009-04-08")
      expect(response["data"]["response"]["numFound"]).to eq(0)
    end

    it "should report if there are works returned by the Datacite Metadata Search API" do
      response = subject.get_data
      expect(response["data"]["response"]["numFound"]).to eq(1181)
      doc = response["data"]["response"]["docs"].first
      expect(doc["doi"]).to eq("10.5061/DRYAD.56M2G/1")
    end

    it "should catch errors with the Datacite Metadata Search API" do
      stub = stub_request(:get, subject.get_query_url(rows: 0)).to_return(:status => [408])
      response = subject.get_data(rows: 0)
      expect(response).to eq("errors" => [{"status"=>408, "title"=>"Request timeout"}])
      expect(stub).to have_been_requested
    end
  end

  context "parse_data" do
    it "should report if there are no works returned by the Datacite Metadata Search API" do
      body = File.read(fixture_path + 'related_identifier_nil.json')
      result = JSON.parse(body)
      expect(subject.parse_data("data" => result)).to eq([])
    end

    it "should report if there are works returned by the Datacite Metadata Search API" do
      body = File.read(fixture_path + 'related_identifier.json')
      result = JSON.parse(body)
      response = subject.parse_data("data" => result)

      expect(response.length).to eq(168)
      expect(response.first[:prefix]).to eq("10.5061")
      expect(response.first[:relation]).to eq("subj_id"=>"http://doi.org/10.5061/DRYAD.HT0HS",
                                              "obj_id"=>"http://doi.org/10.1186/S12864-015-1469-5",
                                              "relation_type_id"=>"is_referenced_by",
                                              "source_id"=>"datacite_crossref",
                                              "publisher_id"=>"CDL.DRYAD")

      expect(response.first[:subj]).to eq("pid"=>"http://doi.org/10.5061/DRYAD.HT0HS",
                                          "DOI"=>"10.5061/DRYAD.HT0HS",
                                          "author"=>[{"family"=>"McTavish", "given"=>"Emily Jane"}, {"family"=>"Hillis", "given"=>"David M."}],
                                          "title"=>"Data from: How does ascertainment bias in SNP analyses affect inferences about population history?",
                                          "container-title"=>"Dryad Digital Repository",
                                          "published"=>"2015",
                                          "issued"=>"2015-04-08T14:37:53Z",
                                          "publisher_id"=>"CDL.DRYAD",
                                          "registration_agency"=>"datacite",
                                          "tracked"=>true,
                                          "type"=>"dataset")
    end
  end

  context "push_data" do
    it "should report if there are no works returned by the Datacite Metadata Search API" do
      result = []
      expect(subject.push_data(result)).to be_empty
    end

    it "should report if there are works returned by the Datacite Metadata Search API" do
      body = File.read(fixture_path + 'related_identifier.json')
      result = JSON.parse(body)
      result = subject.parse_data("data" => result)

      response = subject.push_data(result)
      expect(response.length).to eq(65)
      deposit = response.first
      expect(deposit).to eq({"data"=>{"meta"=>{"status"=>"accepted", "message-type"=>"deposit", "message-version"=>"v7"}, "deposit"=>{"id"=>"8ac8bb26-c5c9-46ad-b6cd-479ecb1afe26", "state"=>"waiting", "message_type"=>"relation", "message_action"=>"create", "source_token"=>"7385e6bf-6980-45e6-ac18-b0ee6b84a50a", "callback"=>"http://10.2.2.14/api/agents", "prefix"=>"10.5517", "subj_id"=>"http://doi.org/10.5517/CC13D9MF", "obj_id"=>"http://doi.org/10.1016/J.INOCHE.2014.11.004", "relation_type_id"=>"is_supplement_to", "source_id"=>"datacite_crossref", "publisher_id"=>"BL.CCDC", "total"=>1, "occurred_at"=>"2016-04-21T05:06:49Z", "timestamp"=>"2016-04-21T05:06:49Z", "subj"=>{"pid"=>"http://doi.org/10.5517/CC13D9MF", "author"=>[{"given"=>"Nikolaos C.", "family"=>"Anastasiadis"}, {"given"=>"Ioannis", "family"=>"Mylonas-Margaritis"}, {"given"=>"Vassilis", "family"=>"Psycharis"}, {"given"=>"Catherine P.", "family"=>"Raptopoulou"}, {"given"=>"Dimitris A.", "family"=>"Kalofolias"}, {"given"=>"Constantinos J.", "family"=>"Milios"}, {"given"=>"Nikolaos", "family"=>"Klouras"}, {"given"=>"Spyros P.", "family"=>"Perlepes"}], "title"=>"CCDC 1024724: Experimental Crystal Structure Determination", "container-title"=>"Cambridge Crystallographic Data Centre", "issued"=>"2014", "DOI"=>"10.5517/CC13D9MF", "registration_agency"=>"datacite", "publisher_id"=>"BL.CCDC", "type"=>nil, "tracked"=>true}, "obj"=>{}}}})
    end
  end

  context "update_count" do
    it "should report if there are no works returned by the Datacite Metadata Search API" do
      subject.update_count(0)
      expect(subject.count).to eq(0)
    end

    it "should report if there are works returned by the Datacite Metadata Search API" do
      subject.update_count(12)
      expect(subject.count).to eq(12)
    end
  end
end