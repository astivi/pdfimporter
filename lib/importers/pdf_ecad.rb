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

    def initialize(filename)
      @filename = filename
      @extract_right_holder_regex = /(\d+)\W+([\w\s]+)\W+([\w\s]+)\W+([\d\.]+)\s(\w+)\W+(\w+)\W+([\d,]+)\W+(\d+)/
    end

    def works
    end

    def right_holder(line)
      match = @extract_right_holder_regex.match(line)
      raise 'Invalid line read' if match.nil?
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
    end

    private

    def share(match)
      match[RightHolderIndexes::SHARE].to_f
    end

    def external_ids(match)
      external_ids = []
      external_ids << {:source_name => 'Ecad', :source_id => match[RightHolderIndexes::SOURCE_ID]}
    end

    def ipi(match)
      match[RightHolderIndexes::IPI].gsub('.', '')
    end

    def pseudos(match)
      pseudos = []
      pseudos << {:name => match[RightHolderIndexes::PSEUDO].strip, :main => true}
    end
  end
end