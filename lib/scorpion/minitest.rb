# frozen_string_literal: true

require "scorpion"

module Scorpion
  module Minitest
    def scorpion_nest
      self.class.scorpion_nest
    end

    def prepare(&block)
      scorpion_nest.prepare(&block)
    end

    def scorpion
      @scorpion ||= self.class.scorpion_nest.conceive
    end

    def self.included(base)
      base.send(:extend, Scorpion::Minitest::ClassMethods)

      base.teardown do
        scorpion.destroy
      end

      super
    end

    module ClassMethods
      def scorpion_nest
        @scorpion_nest ||= Scorpion.instance.build_nest
      end

      def infest_nest(klass)
        return unless klass < Scorpion::Rails::Nest
      end

      def capture(name, contract, &block)
        block ||= ->(hunt) { hunt.new(contract) }

        hunt(name, contract, &block)
      end

      def hunt(name, contract, value = :unspecified, &block)
        class_eval(<<-RUBY, __FILE__, __LINE__ + 1) # rubocop:disable Style/DocumentDynamicEvalDefinition
          def #{name}
            @#{name} ||= scorpion.fetch(#{contract})
          end
        RUBY

        setup do
          scorpion.prepare do |hunter|
            if value == :unspecified
              if block
                hunter.hunt_for(contract, &block)
              else
                require "minitest/mock"
                mock = ::Minitest::Mock.new
                hunter.hunt_for(contract, return: mock)
              end
            else
              hunter.hunt_for(contract, return: value)
            end
          end
        end
      end
    end
  end
end
