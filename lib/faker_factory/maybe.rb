module FakerFactory
  class Maybe
    attr_reader :probability, :template

    def initialize(probability = 50, template = nil, &block)
      @probability = probability
      @template = block_given? ? block.call : template
    end
  end
end
