module Scorpion
  # Builds an injectable constructor for a Scorpion::Object.
  class ObjectConstructor

    def initialize( base, arguments, &block )
      @base      = base
      @arguments = arguments
      @block     = block
    end

    def define
      @signature       = []
      @block_signature = []
      @body            = ""

      build_signature
      build_body

      add_initialize_block
      assemble
    end

    private
      attr_reader :base, :arguments, :block, :body, :signature, :block_signature

      def build_signature
        arguments.each do |key,expectation|
          attr = base.initializer_injections.define_attribute key, *Array( expectation )
          signature << ( attr.lazy? ? "#{ key } = nil" : key )
          block_signature << key

          base.attr_dependency key, *Array( expectation )
        end
      end

      def build_body
        arguments.each do |key,expectation|
          body << "@#{ key } = #{ key }; "
        end
      end

      def add_initialize_block
        if block
          body << "__initialize_with_block( "
          if block_signature.any?
            body << block_signature.join( ', ')
            body << ', '
          end
          body << "&block )"
          fail ArityMismatch.new( block, block_signature.count.abs ) if block.arity.abs < block_signature.count
          base.send :define_method, :__initialize_with_block, &block
        end
      end

      def assemble
        source = <<-RUBY
          def initialize( #{ signature.join( ', ' ) }, &block )
            #{ body }
          end
        RUBY

        Scorpion.logger.warn source

        base.class_eval <<-RUBY, __FILE__, __LINE__ + 1
          #{ source }
        RUBY
      end
  end
end