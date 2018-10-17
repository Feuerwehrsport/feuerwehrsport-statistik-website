Pdf2Table::Worker = Struct.new(:entry) do
  include M3::Delayable

  def perform
    entry = Pdf2Table::Entry.find_by(locked_at: nil)
    return if entry.nil?

    entry.perform if Pdf2Table::Entry.where(locked_at: nil, id: entry.id).update_all(locked_at: Time.current) == 1
    Pdf2Table::Worker.enqueue
  end
end
