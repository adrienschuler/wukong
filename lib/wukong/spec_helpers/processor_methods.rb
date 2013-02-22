module Wukong
  module SpecHelpers
    # This module defines methods to be included into the
    # Wukong::Processor class.
    module ProcessorSpecMethods

      # An array of accumulated records to process come match-time.
      attr_reader :given_records

      # Give a collection of records to the processor.
      #
      # @param [Array] records
      def given *records
        @given_records ||= []
        @given_records.concat(records)
        self                    # for chaining
      end

      # Give a collection of records to the processor but turn each
      # to JSON first.
      #
      # @param [Array] records
      def given_json *records
        self.given(*records.map { |record| MultiJson.dump(record) })
      end
      
      # Give a collection of records to the processor but join each
      # in a delimited format first.
      #
      # @param [Array] records
      def given_delimited delimiter, *records
        self.given(*records.map do |record|
                     record.map(&:to_s).join(delimiter)
                   end.join("\n"))
      end

      # Give a collection of records to the processor but join each
      # in TSV format first.
      #
      # @param [Array] records
      def given_tsv *records
        self.given_delimited("\t", *records)
      end

      # Give a collection of records to the processor but join each
      # in CSV format first.
      #
      # @param [Array] records
      def given_csv *records
        self.given_delimited(",", *records)
      end

      # Return the output of the processor on the given records.
      #
      # Calling this method, like passing the processor to an `emit`
      # matcher, will trigger processing of all the given records.
      #
      # Returns a SpecDriver, which is a subclass of array, so the
      # usual matchers like `include` and so on should work, as well
      # as explicitly indexing to introspect on particular records.
      #
      # @return [SpecDriver]
      def output
        SpecDriver.new(self).run
      end

      # Return the output of the processor on the given records,
      # parsing as a string with the given `delimiter` first.
      #
      # @param [String] delimiter
      # @see #output
      # @return [Array<String>]
      def delimited_output(delimiter)
        output.map { |record| record.split(delimiter) }
      end
      
      # Return the output of the processor on the given records,
      # parsing as TSV first.
      #
      # @see #output
      # @see #delimited_output
      # @return [Array<String>]
      def tsv_output
        delimited_output("\t")
      end
      
      # Return the output of the processor on the given records,
      # parsing as CSV first.
      #
      # @see #output
      # @see #delimited_output
      # @return [Array<String>]
      def csv_output
        delimited_output(",")
      end

      # Return the output of the processor on the given records,
      # parsing as JSONS first.
      #
      # @see #output
      # @return [Hash,Array]
      def json_output
        output.map { |record| MultiJson.load(record) }
      end

    end
  end
end