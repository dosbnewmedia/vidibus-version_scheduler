require "spec_helper"

describe "Vidibus::VersionScheduler::VersionObserver" do
  let(:book_attributes) {{:title => "title 1", :text => "text 1"}}
  let(:new_book) {Book.new(book_attributes)}
  let(:book) {Book.create(book_attributes)}
  let(:future_version) do
    book.version(:next, :title => "title 2").tap do |v|
      v.updated_at = 1.day.since
      v.save
    end.version_object
  end
  let(:past_version) do
    book.update_attributes!(:title => "title 2")
    book.versions.last
  end

  before {stub_time("2011-07-01 12:01")}

  describe "saving a version" do
    it "should enable scheduling if the versioned object should be scheduled" do
      allow_any_instance_of(Vidibus::VersionScheduler::VersionObserver).to receive(:schedule).with(any_args)
      future_version
    end

    it "should not enable scheduling unless the versioned object includes Vidibus::VersionScheduler::Mongoid" do
      allow(Book).to receive(:ancestors) {[]}
      expect_any_instance_of(Vidibus::VersionScheduler::VersionObserver).to_not receive(:schedule).with(any_args)
      future_version
    end

    it "should schedule it if it's future" do
      future_version
      scheduled_versions = book.reload.scheduled_versions
      expect(scheduled_versions.size).to eq(1)
      expect(scheduled_versions.first.version_uuid).to eql(future_version.uuid)
    end

    it "should not schedule it if it's past" do
      past_version
      expect(book.reload.scheduled_versions.size).to eq(0)
    end

    it "should remove it from schedule if it's past now" do
      future_version.update_attributes(:created_at => 1.day.ago)
      expect(book.reload.scheduled_versions.size).to eq(0)
    end

    it "should not remove other scheduled items if it's meant to remove just one" do
      version = future_version
      new_version = book.version(:new, :title => "title 3").tap do |v|
        v.updated_at = 1.day.since
        v.save
      end.version_object
      version.update_attributes(:created_at => 1.day.ago)
      scheduled_versions = book.reload.scheduled_versions
      expect(scheduled_versions.size).to eq(1)
      expect(scheduled_versions.first.version_uuid).to eql(new_version.uuid)
    end

    it "should create a new scheduled item if the version's creation time gets updated" do
      future_version.update_attributes!(:created_at => 2.days.since)
      expect(book.reload.scheduled_versions.first.run_at).to eql(2.days.since)
    end

    it "should keep only one scheduled item if the version's creation time gets updated" do
      future_version.update_attributes(:created_at => 2.days.since)
      expect(book.reload.scheduled_versions.size).to eq(1)
    end
  end

  describe "destroying a version" do
    it "should destroy the scheduled version" do
      future_version
      scheduled_version = book.reload.scheduled_versions.first
      future_version.destroy
      expect {scheduled_version.reload}.to raise_error(Mongoid::Errors::DocumentNotFound)
    end
  end
end
