# frozen_string_literal: true

# copies a (pdf) file of an import request to the selected competition
class Backend::ImportRequestFilesController < Backend::BackendController
  include ChangeLogging

  def transfer
    file = ImportRequestFile.find(params[:id])
    authorize!(:update, file.import_request)
    authorize!(:create, CompetitionFile)
    keys = params.fetch(:keys, []).select { |key| key.to_sym.in?(CompetitionFile::POSSIBLE_KEYS) }
    file.update!(transfer_competition_id: params[:competition_id], transfer_keys_string: keys.join(','))
    clean_cache
    redirect_back_or_to backend_import_request_path(file.import_request), notice: 'Datei übertragen.'
  end
end
