require "spec_helper"

describe "Vidibus::VersionScheduler::ScheduledVersion" do
  let(:now) {stub_time("2011-07-01 12:01")}
  let(:tomorrow) {now + 1.day}
  let(:book) {Book.create({:title => "title 1", :text => "text 1"})}
  let(:future_version) do
    book.version(:next, :title => "title 2").tap do |v|
      v.updated_at = tomorrow
      v.save
    end.version_object
  end
  let(:this) {book.scheduled_versions.build(:version_uuid => future_version.uuid)}

  describe "validation" do
    before {future_version}

    it "should pass with valid attributes" do
      expect(this).to be_valid
    end

    it "should fail without a version uuid" do
      expect(book.scheduled_versions.build).to be_invalid
    end

    it "should fail without a valid version uuid" do
      expect(book.scheduled_versions.build(:version_uuid => "123")).to be_invalid
    end
  end

  describe "#run_at" do
    before {this.valid?}

    it "should be set from version input before validation" do
      expect(this.run_at).to eql(tomorrow)
    end
  end

  describe "#job" do
    it "should be nil by default" do
      expect(this.job).to be_nil
    end

    it "should be created with the record" do
      this.save!
      expect(this.job).to be_a(Delayed::Backend::Mongoid::Job)
    end

    it "should be destroyed with the record" do
      this.save!
      job = this.job
      this.destroy
      expect {job.reload}.to raise_error(Mongoid::Errors::DocumentNotFound)
    end

    it "should contain a MigrationJob with appropriate id" do
      this.save!
      expect(YAML.load(this.job.handler)).to eql(Vidibus::VersionScheduler::MigrationJob.new(this.version_uuid))
    end

    it 'should add job to "versioning" queue' do
      this.save!
      expect(this.job.queue).to eq('versioning')
    end

    it "should handle a DocumentNotFound error" do
      this.job_id = "4e181aecfe197f75a900000c"
      expect { this.job }.not_to raise_error
    end
  end
end
