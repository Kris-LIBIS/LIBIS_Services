# coding: utf-8

require 'libis/services/oracle_client'
require 'libis/tools/xml_document'

module Libis
  module Services
    module Scope

      class Search
        include ::Libis::Services::GenericSearch

        def initialize
          @doc = nil
        end

        def find(term, options = {})
          super
          OracleClient.new('SCOPE01', 'APLKN_ARCHV_LIAS', 'archvsc').
              call('kul_packages.scope_xml_meta_file_ed', [term.upcase])
          err_file = "/nas/vol03/oracle/scope01/#{term}_err.XML"
          if File.exist? err_file
            doc = XmlDocument.open(err_file)
            msg = doc.xpath('/error/error_msg').first.content
            msg_detail = doc.xpath('/error/error_').first.content
            File.delete(err_file)
            @doc = nil
            raise RuntimeError, "Scope search failed: '#{msg}'. Details: '#{msg_detail}'"
          else
            @doc = XmlDocument.open("/nas/vol03/oracle/scope01/#{term}_md.XML").to_hash
          end
        end

        def each(_ = {})
          yield @doc
        end

        def next_record(_ = {})
          yield @doc
        end

      end

    end
  end
end
