require 'open3'

class Pdf2Table::Entry < ActiveRecord::Base
  belongs_to :api_user
  belongs_to :admin_user

  mount_uploader :pdf, Pdf2Table::PdfUploader
  mount_uploader :csv, Pdf2Table::OutputUploader
  mount_uploader :ods, Pdf2Table::OutputUploader

  def user=(user)
    if user.is_a?(APIUser)
      self.api_user = user
    elsif user.is_a?(AdminUser)
      self.admin_user = user
    end
  end

  def user
    admin_user || api_user
  end

  def perform
    temp_ods = Tempfile.new(["pdf2table-#{pdf.file.basename}", '.ods'])
    temp_csv = Tempfile.new(["pdf2table-#{pdf.file.basename}", '.csv'])
    _stdin, stdout, stderr, wait_thr = Open3.popen3('java', '-jar', Rails.configuration.pdf2table_path,
                                                    '-f',
                                                    '-o', temp_ods.path,
                                                    '-c', temp_csv.path,
                                                    pdf.file.path)
    self.success = false
    self.log = stdout.gets(nil).to_s
    stdout.close
    self.log += stderr.gets(nil).to_s
    stderr.close
    exit_code = wait_thr.value
    if exit_code.exitstatus.zero?
      self.ods = temp_ods
      self.csv = temp_csv
      self.csv_to_copy = CSV.read(temp_csv.path).map { |row| row.join("\t") }.join("\n")
      self.success = true
    end
    self.finished_at = Time.current
    save!
  end
end
