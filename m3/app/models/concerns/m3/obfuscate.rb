# frozen_string_literal: true

module M3::Obfuscate
  extend ActiveSupport::Concern

  class_methods do
    def obfuscate_base_key
      Rails.application.secrets.secret_key_base
    end

    def obfuscate_cipher
      OpenSSL::Cipher.new('aes-256-cbc')
    end

    def obfuscate_cipher_key
      Digest::SHA256.digest(obfuscate_base_key)
    end

    def obfuscate_decrypt(value)
      c = obfuscate_cipher.decrypt
      c.key = obfuscate_cipher_key
      (c.update(obfuscate_base64_decode(value.to_s)) + c.final).force_encoding('UTF-8')
    rescue OpenSSL::Cipher::CipherError
      ''
    end

    def obfuscate_encrypt(value)
      c = obfuscate_cipher.encrypt
      c.key = obfuscate_cipher_key
      obfuscate_base64_encode(c.update(value.to_s) + c.final)
    end

    def obfuscate_base64_encode(string)
      Base64.encode64(string).strip.gsub(/==$/, '').tr('/', '-').gsub(/\s/, '')
    end

    def obfuscate_base64_decode(string)
      Base64.decode64("#{string.tr('-', '/').tr(' ', '+')}==")
    end

    def obfuscate(*attr_names, &block)
      attr_names.each do |attr_name|
        define_method(attr_name) do
          value = public_send(:"obfuscate_#{attr_name}")
          value.blank? ? '' : obfuscate_decrypt(value)
        end

        define_method(:"#{attr_name}=") do |value|
          value = yield(value) if block.present?
          public_send(:"obfuscate_#{attr_name}=", value.blank? ? '' : obfuscate_encrypt(value))
        end
      end
    end
  end

  included do
    delegate :obfuscate_decrypt, :obfuscate_encrypt, to: :class
  end
end
