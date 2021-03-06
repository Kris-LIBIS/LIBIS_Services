# coding: utf-8

require 'libis/tools/xml_document'
require 'libis/services/soap_client'

module Libis
  module Services
    module Digitool

      class DigitoolConnector
        include Libis::Services::SoapClient

        def initialize(service, host = nil)
          @host = host || 'aleph08.libis.kuleuven.be:1801'
          @service = service.to_s.downcase
        end

        def init
          @base_url = "http://#{@host}/de_repository_web/services/"
          @wsdl_extension = '?wsdl'
        end

        protected

        def result_parser(response, options = {})
          result = get_xml_response(response)
          error = nil
          pids = nil
          mids = nil
          de = nil
          doc = Libis::Tools::XmlDocument.parse(result)
          doc.xpath('//error_description').each { |x| error ||= []; error << x.content unless x.content.nil? }
          doc.xpath('//pid').each { |x| pids ||= []; pids << x.content unless x.content.nil? }
          doc.xpath('//mid').each { |x| mids ||= []; mids << x.content unless x.content.nil? }
          doc.xpath('//xb:digital_entity').each { |x| de ||= []; de << x.to_s }
          {errors: error, pids: pids, mids: mids, digital_entities: de}
        end

        def get_xml_response(response)
          response.first[1][response.first[1][:result].snakecase.to_sym]
        end

      end
    end
  end
end
