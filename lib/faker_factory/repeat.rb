module FakerFactory
  class Repeat
    attr_reader :count, :template

    def initialize(count, template = nil, &block)
      @count = count
      @template = block_given? ? block.call : template
    end
  end
end
