# frozen_string_literal: true

server 'hanse-ff',
       user: 'feuerwehrsport-statistik',
       roles: %w[app db web],
       error_500_url: 'https://feuerwehrsport-statistik.de/500'
