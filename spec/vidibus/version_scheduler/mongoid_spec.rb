require "spec_helper"

describe "Vidibus::VersionScheduler::Mongoid" do
  let(:now) {stub_time("2011-07-01 12:01")}
  let(:book_attributes) {{:title => "title", :text => "text"}}
  let(:new_book) {Book.new(book_attributes)}
  let(:book) {Book.create(book_attributes)}
  let(:past_version) do
    book.update_attributes(:title => "past title")
    book.versions.last.tap do |v|
      v.created_at = now - 1.day
    end
  end
  let(:future_version) do
    book.reload.version(:next, :title => "future title").tap do |v|
      v.version_object.created_at = now + 1.day
      v.save
    end.version_object
  end

  describe "#scheduled_versions" do
    it "should be an empty array by default" do
      expect(new_book.scheduled_versions).to eq([])
    end

    it "should contain scheduled versions that have created by the VersionObserver" do
      future_version
      expect(book.reload.scheduled_versions.size).to eq(1)
      expect(book.scheduled_versions.first).to be_a(Vidibus::VersionScheduler::ScheduledVersion)
    end

    it "should not prevent the versioned object from saving, if invalid" do
      future_version
      allow_any_instance_of(Vidibus::VersionScheduler::ScheduledVersion).to receive(:valid?) {false}
      expect(future_version.save).to be_truthy
    end
  end

  describe "#next_scheduled_version" do
    it "should be spec'd"
  end
end
