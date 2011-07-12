require "spec_helper"

describe "Vidibus::VersionScheduler::VersionObserver" do
  let(:book_attributes) {{:title => "title 1", :text => "text 1"}}
  let(:new_book) {Book.new(book_attributes)}
  let(:book) {Book.create(book_attributes)}
  let(:future_version) do
    book.version(2, :title => "title 2").tap do |v|
      v.version_object.created_at = 1.day.since
      v.save
    end.version_object
  end
  let(:past_version) do
    book.update_attributes!(:title => "title 2")
    book.versions.last
  end

  before {stub_time("2011-07-01 12:01")}

  describe "saving a version" do
    it "should schedule it if it's future" do
      future_version
      scheduled_versions = book.reload.scheduled_versions
      scheduled_versions.should have(1).item
      scheduled_versions.first.version_uuid.should eql(future_version.uuid)
    end

    it "should not schedule it if it's past" do
      past_version
      book.reload.scheduled_versions.should have(:no).items
    end

    it "should remove it from schedule if it's past now" do
      future_version.update_attributes(:created_at => 1.day.ago)
      book.reload.scheduled_versions.should have(:no).items
    end

    it "should not remove other scheduled items if it's meant to remove just one" do
      version = future_version
      new_version = book.version(3, :title => "title 3").tap do |v|
        v.version_object.created_at = 1.day.since
        v.save
      end.version_object
      version.update_attributes(:created_at => 1.day.ago)
      scheduled_versions = book.reload.scheduled_versions
      scheduled_versions.should have(1).item
      scheduled_versions.first.version_uuid.should eql(new_version.uuid)
    end

    it "should create a new scheduled item if the version's creation time gets updated" do
      future_version.update_attributes!(:created_at => 2.days.since)
      book.reload.scheduled_versions.first.run_at.should eql(2.days.since)
    end

    it "should keep only one scheduled item if the version's creation time gets updated" do
      future_version.update_attributes(:created_at => 2.days.since)
      book.reload.scheduled_versions.should have(1).item
    end
  end
end