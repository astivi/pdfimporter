require 'pdf-reader'

module Importers
  class PdfEcad
    CATEGORIES = {'CA' => 'Author', 'E' => 'Publisher', 'V' => 'Versionist', 'SE' => 'SubPublisher'}

    module RightHolderIndexes
      SOURCE_ID = 1
      NAME = 2
      PSEUDO = 3
      IPI = 4
      SOCIETY_NAME = 5
      ROLE = 6
      SHARE = 7
    end

    module WorkIndexes
      SOURCE_ID = 1
      ISWC = 2
      TITLE = 3
      SITUATION = 4
      CREATED_AT = 5
    end

    def initialize(filename)
      @filename = filename
      @extract_right_holder_regex = /(\d+)\W+([\w\s\.]+)\W+([\w\s]+)?\W+([\d\.]+)?\s(\w+)?\W+(\w+)\W+([\d]+,[\d]*).*/
      @extract_work_regex = /(\d+)\W+(.\-.{3}\..{3}\..{3}\-.)\W+([\w\s]+)\W+(\w+)\W+(.+)/
    end

    def works
      reader = PDF::Reader.new(@filename)
      parsing_work = true
      works = []
      work = nil
      right_holders = []
      reader.pages.each do |page|
        lines = page.text.split(/\r?\n/)
        (0..lines.size-1).each do |line|
          if parsing_work
            work = work(lines[line])
            parsing_work = false unless work.nil?
          else
            rh = right_holder(lines[line])
            if rh.nil?
              work[:right_holders] = right_holders
              works << work
              parsing_work = true
              right_holders = []
            else
              right_holders << rh
            end
          end
        end
      end
      works
    end

    def right_holder(line)
      match = @extract_right_holder_regex.match(line)
      return nil if match.nil?
      {
          :name => match[RightHolderIndexes::NAME].strip,
          :pseudos => pseudos(match),
          :role => CATEGORIES[match[RightHolderIndexes::ROLE]],
          :society_name => match[RightHolderIndexes::SOCIETY_NAME],
          :ipi => ipi(match),
          :external_ids => external_ids(match),
          :share => share(match)
      }
    end

    def work(line)
      match = @extract_work_regex.match(line)
      return nil if match.nil?
      {
          :external_ids => external_ids(match),
          :iswc => match[WorkIndexes::ISWC].strip,
          :title => match[WorkIndexes::TITLE].strip,
          :situation => match[WorkIndexes::SITUATION],
          :created_at => match[WorkIndexes::CREATED_AT]
      }
    end

    private

    def share(match)
      match[RightHolderIndexes::SHARE].gsub(',', '.').to_f #gsub necessario por causa do locale, encontrar solução independente do locale.
    end

    def external_ids(match)
      external_ids = []
      external_ids << {:source_name => 'Ecad', :source_id => match[RightHolderIndexes::SOURCE_ID]}
    end

    def ipi(match)
      match[RightHolderIndexes::IPI].gsub('.', '') unless match[RightHolderIndexes::IPI].nil?
    end

    def pseudos(match)
      pseudos = []
      pseudos << {:name => match[RightHolderIndexes::PSEUDO].strip, :main => true} unless match[RightHolderIndexes::PSEUDO].nil?
    end
  end
end