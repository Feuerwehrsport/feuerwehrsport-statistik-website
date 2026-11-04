# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DebugJob do
  let(:job) { described_class.new }
  let(:tmp_root) { Pathname.new(Dir.mktmpdir) }
  let(:log_summary) { '' }
  let(:parser) { instance_double(RailsLogParser::Parser, summary: log_summary) }
  let(:sent_messages) { [] }

  before do
    FileUtils.mkdir_p(tmp_root.join('tmp'))
    allow(Rails).to receive(:root).and_return(tmp_root)
    allow(RailsLogParser::Parser).to receive_messages(log_path: '/path/to/log', from_file: parser)
    allow(Socket).to receive(:gethostname).and_return('myhost')
    allow(IO).to receive(:popen) do |command, mode, &block|
      io = StringIO.new
      block.call(io)
      sent_messages.push(command:, mode:, body: io.string)
    end
  end

  after { FileUtils.rm_rf(tmp_root) }

  def create_failed_execution(message)
    solid_job = SolidQueue::Job.create!(queue_name: 'default', class_name: 'FooJob', arguments: {})
    SolidQueue::FailedExecution.create!(
      job: solid_job,
      error: { exception_class: 'RuntimeError', message:, backtrace: (1..10).map { |i| "line #{i}" } },
    )
  end

  context 'without log lines and failed jobs' do
    it 'sends nothing' do
      job.perform_now
      expect(RailsLogParser::Parser).to have_received(:from_file).with('/path/to/log')
      expect(parser).to have_received(:summary).with(last_minutes: 22)
      expect(sent_messages).to eq []
    end
  end

  context 'with nil summary' do
    let(:log_summary) { nil }

    it 'sends nothing' do
      job.perform_now
      expect(sent_messages).to eq []
    end
  end

  context 'with interesting log lines' do
    let(:log_summary) { "Error in line 4\n" }

    it 'sends log summary' do
      job.perform_now
      expect(sent_messages.count).to eq 1
      expect(sent_messages.first[:command]).to eq(
        "/usr/bin/mail -s #{Shellwords.escape('Interesting log lines on myhost')} georf@georf.de",
      )
      expect(sent_messages.first[:body]).to eq "Error in line 4\n"
      expect(sent_messages.first[:mode]).to eq 'w'
    end
  end

  context 'with failed jobs' do
    let!(:failed_executions) { [create_failed_execution('first'), create_failed_execution('second')] }
    let(:state_file) { tmp_root.join("tmp/failed_jobs-#{Date.current}.json") }

    it 'sends failed jobs once per day and state' do
      job.perform_now

      expect(sent_messages.count).to eq 1
      expect(sent_messages.first[:command]).to eq(
        "/usr/bin/mail -s #{Shellwords.escape('2 solid queue jobs failed on myhost')} georf@georf.de",
      )
      body = sent_messages.first[:body]
      errors = body.split("\n\n--NEXT--\n\n")
      expect(errors.count).to eq 2
      first_error = JSON.parse(errors.first)
      expect(first_error['message']).to eq 'first'
      expect(first_error['backtrace']).to eq ['line 1', 'line 2', 'line 3', 'line 4', 'line 5']
      expect(body).to end_with "\n\nLink: https://feuerwehrsport-statistik.de/admin-jobs\n"
      expect(state_file.read).to eq failed_executions.map(&:id).sort.to_json

      # same failed jobs: no second message
      job.perform_now
      expect(sent_messages.count).to eq 1

      # new failed job: new message
      create_failed_execution('third')
      job.perform_now
      expect(sent_messages.count).to eq 2
      expect(sent_messages.last[:command]).to include('3\ solid\ queue\ jobs')
    end

    it 'does not change stored errors' do
      job.perform_now
      expect(SolidQueue::FailedExecution.first.error['backtrace'].count).to eq 10
    end
  end
end
