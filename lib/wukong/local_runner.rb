
module Wukong
  class Runner
    include Gorillib::FancyBuilder
  end

  # Run dataflow in pure ruby
  class LocalRunner < Runner
    collection :sources,  Wukong::Source
    collection :sinks,    Wukong::Sink
    member     :flow,     Wukong::Dataflow

    def run
      wire_flow
      setup
      sources.to_a.first.each do |record|
        result = flow.process(record)
      end
      stop
    end

  protected

    # @return a list with inputs, flow and outputs, in that order
    def stages
      sources.to_a.concat([flow]).concat(sinks.to_a)
    end

    def setup
      stages.each{|stage| stage.setup}
    end

    def stop
      stages.each{|stage| stage.stop}
    end

    def wire_flow
      flow.stages.to_a.last.output sink(:default_sink)
    end
  end
end