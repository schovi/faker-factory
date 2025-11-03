module FakerFactory
  class Structure
    FAKER_MATCHER = /\%{(?<content>.*?)\}/

    class << self
      # Makes lambda from object
      def object_to_lambda(object)
        source_to_lambda(
          object_to_source(
            object
          )
        )
      end

      # For debug
      def source_to_lambda(string)
        eval(string)
      end

      # For debug
      def object_to_source(object)
        result = ""

        result << "lambda do\n"
        result << build_faker_element(object)
        result << "\nend"

        result
      end

      private

      def build_faker_element(element)
        case element
        when Hash
          build_faker_hash(element)
        when Array
          build_faker_array(element)
        when String
          build_faker_string(element)
        else
          element
        end
      end

      def build_faker_hash(element)
        keys = element.keys

        result = ""

        if keys.length == 1 && match = keys.first.to_s.match(FAKER_MATCHER)
          method = FakerFactory::Method::Control.new(match["content"]) do build_faker_element(element[keys.first]) end

          result << "#{method}"
        else
          result << "{"

          result << element.map do |key, value|
            "\"#{key.to_s}\" => #{build_faker_element(value)}"
          end.join(",")

          result << "}"
        end

        result
      end

      def build_faker_array(element)
        result = ""

        result << "["

        result << element.map do |value|
          build_faker_element(value)
        end.join(",")

        result << "]"

        result
      end

      def build_faker_string(source)
        partitions = partition_by_faker_matcher(source)

        if partitions.length == 1 && faker = partitions.first[:faker]
          return faker.to_s
        end

        result = partitions.map do |partition|
          if faker = partition[:faker]
            "\#\{#{faker}\}"
          else
            partition[:text]
          end
        end.join

        if partitions.length == 1 && partitions[0][:faker]
          result
        else
          "\"#{result}\""
        end
      end

      # Split faker string into partitions
      # input  < "some text %{number.number(10)} another %{name.name} end"
      # output > [
      #           { text:  "some text " },
      #           { faker: "Faker::Number.number(10)" },
      #           { text:  " another " },
      #           { faker: "Faker::Name.name" },
      #           { text:  " end" }
      #          ]
      def partition_by_faker_matcher string = ""
        result = []

        while true
          text, faker_placer, string = string.partition(FAKER_MATCHER)

          if text.length > 0
            result.push({ text: text })
          end

          if faker_placer.length > 0
            match = faker_placer.match(FAKER_MATCHER)
            result.push({ faker: Method::Faker.new(match[1]) })
          end

          break if string.length == 0
        end

        result
      end
    end
  end
end
