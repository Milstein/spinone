require 'spec_helper'

describe Github, type: :model, vcr: true do
  before(:each) do
    allow(Time).to receive(:now).and_return(Time.mktime(2015, 4, 8))
    subject.count = 0
  end

  let(:fixture_path) { "#{Sinatra::Application.root}/spec/fixtures/" }

  context "get_query_url" do
    it "default" do
      expect(subject.get_query_url).to eq("http://search.datacite.org/api?q=relatedIdentifier%3AURL%5C%3Ahttps%5C%3A%5C%2F%5C%2Fgithub.com*&start=0&rows=1000&fl=doi%2Ccreator%2Ctitle%2Cpublisher%2CpublicationYear%2CresourceTypeGeneral%2Cdatacentre_symbol%2CrelatedIdentifier%2Cxml%2Cminted%2Cupdated&fq=updated%3A%5B2015-04-07T00%3A00%3A00Z+TO+2015-04-08T23%3A59%3A59Z%5D+AND+has_metadata%3Atrue+AND+is_active%3Atrue&wt=json")
    end

    it "with zero rows" do
      expect(subject.get_query_url(rows: 0)).to eq("http://search.datacite.org/api?q=relatedIdentifier%3AURL%5C%3Ahttps%5C%3A%5C%2F%5C%2Fgithub.com*&start=0&rows=0&fl=doi%2Ccreator%2Ctitle%2Cpublisher%2CpublicationYear%2CresourceTypeGeneral%2Cdatacentre_symbol%2CrelatedIdentifier%2Cxml%2Cminted%2Cupdated&fq=updated%3A%5B2015-04-07T00%3A00%3A00Z+TO+2015-04-08T23%3A59%3A59Z%5D+AND+has_metadata%3Atrue+AND+is_active%3Atrue&wt=json")
    end

    it "with different from_date and until_date" do
      expect(subject.get_query_url(from_date: "2015-04-05", until_date: "2015-04-05")).to eq("http://search.datacite.org/api?q=relatedIdentifier%3AURL%5C%3Ahttps%5C%3A%5C%2F%5C%2Fgithub.com*&start=0&rows=1000&fl=doi%2Ccreator%2Ctitle%2Cpublisher%2CpublicationYear%2CresourceTypeGeneral%2Cdatacentre_symbol%2CrelatedIdentifier%2Cxml%2Cminted%2Cupdated&fq=updated%3A%5B2015-04-05T00%3A00%3A00Z+TO+2015-04-05T23%3A59%3A59Z%5D+AND+has_metadata%3Atrue+AND+is_active%3Atrue&wt=json")
    end

    it "with offset" do
      expect(subject.get_query_url(offset: 250)).to eq("http://search.datacite.org/api?q=relatedIdentifier%3AURL%5C%3Ahttps%5C%3A%5C%2F%5C%2Fgithub.com*&start=250&rows=1000&fl=doi%2Ccreator%2Ctitle%2Cpublisher%2CpublicationYear%2CresourceTypeGeneral%2Cdatacentre_symbol%2CrelatedIdentifier%2Cxml%2Cminted%2Cupdated&fq=updated%3A%5B2015-04-07T00%3A00%3A00Z+TO+2015-04-08T23%3A59%3A59Z%5D+AND+has_metadata%3Atrue+AND+is_active%3Atrue&wt=json")
    end

    it "with rows" do
      expect(subject.get_query_url(rows: 250)).to eq("http://search.datacite.org/api?q=relatedIdentifier%3AURL%5C%3Ahttps%5C%3A%5C%2F%5C%2Fgithub.com*&start=0&rows=250&fl=doi%2Ccreator%2Ctitle%2Cpublisher%2CpublicationYear%2CresourceTypeGeneral%2Cdatacentre_symbol%2CrelatedIdentifier%2Cxml%2Cminted%2Cupdated&fq=updated%3A%5B2015-04-07T00%3A00%3A00Z+TO+2015-04-08T23%3A59%3A59Z%5D+AND+has_metadata%3Atrue+AND+is_active%3Atrue&wt=json")
    end
  end

  context "get_total" do
    it "with works" do
      expect(subject.get_total).to eq(19)
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
      expect(response).to eq(19)
    end
  end

  context "get_data" do
    it "should report if there are no works returned by the Datacite Metadata Search API" do
      response = subject.get_data(from_date: "2009-04-07", until_date: "2009-04-08")
      expect(response["data"]["response"]["numFound"]).to eq(0)
    end

    it "should report if there are works returned by the Datacite Metadata Search API" do
      response = subject.get_data
      expect(response["data"]["response"]["numFound"]).to eq(19)
      doc = response["data"]["response"]["docs"].first
      expect(doc["doi"]).to eq("10.5281/ZENODO.16650")
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
      body = File.read(fixture_path + 'orcid_nil.json')
      result = JSON.parse(body)
      expect(subject.parse_data("data" => result)).to eq([])
    end

    it "should report if there are invalid works returned by the Datacite Metadata Search API" do
      body = File.read(fixture_path + 'orcid_invalid.json')
      result = JSON.parse(body)
      response = subject.parse_data("data" => result)

      expect(response.length).to eq(61)
    end

    it "should report if there are works returned by the Datacite Metadata Search API" do
      body = File.read(fixture_path + 'orcid.json')
      result = JSON.parse(body)
      response = subject.parse_data("data" => result)

      expect(response.length).to eq(63)
      expect(response.first[:prefix]).to eq("10.1594")
      expect(response.first[:message_type]).to eq("contribution")
      expect(response.first[:relation]).to eq("subj_id"=>"http://orcid.org/0000-0002-4133-2218",
                                              "obj_id"=>"http://doi.org/10.1594/PANGAEA.733793",
                                              "source_id"=>"datacite_orcid",
                                              "publisher_id"=>"TIB.PANGAEA")

      expect(response.first[:obj]).to eq("pid"=>"http://doi.org/10.1594/PANGAEA.733793",
                                         "DOI"=>"10.1594/PANGAEA.733793",
                                         "author"=>[],
                                         "container-title"=>"PANGAEA - Data Publisher for Earth & Environmental Science",
                                         "title"=>"Paleomagnetic measurements of 10 sediment profiles from the Antarctic continental slope",
                                         "issued"=>"1989",
                                         "publisher_id"=>"TIB.PANGAEA",
                                         "registration_agency"=>"datacite",
                                         "tracked"=>true,
                                         "type"=>nil)
    end
  end

  context "push_data" do
    it "should report if there are no works returned by the Datacite Metadata Search API" do
      result = []
      expect(subject.push_data(result)).to be_empty
    end

    it "should report if there are works returned by the Datacite Metadata Search API" do
      body = File.read(fixture_path + 'orcid.json')
      result = JSON.parse(body)
      result = subject.parse_data("data" => result)

      response = subject.push_data(result)
      expect(response.length).to eq(63)
      deposit = response.first
      expect(deposit).to eq("errors"=>[{"status"=>400, "title"=>"the server responded with status 422"}])
    end
  end
end