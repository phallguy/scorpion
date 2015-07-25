module Scorpion
  # Builds an injectable constructor for a Scorpion::Object.
  class ObjectConstructor

    def initialize( base, arguments, &block )
      @base      = base
      @arguments = arguments
      @block     = block
    end

    def define
      @signature = []
      @body      = ""

      build_signature
      build_body

      add_initialize_block
      assemble
    end

    private
      attr_reader :base, :arguments, :block, :body, :signature

      def build_signature
        arguments.each do |key,expectation|
          signature << key

          base.initializer_injections.define_attribute key, *Array( expectation )
          base.attr_dependency key, *Array( expectation )
        end
      end

      def build_body
        arguments.each do |key,expectation|
          body << "@#{ key } = #{ key };"
        end
      end

      def add_initialize_block
        if block
          body << "__initialize_with_block( &block )"
          base.send :define_method, :__initialize_with_block, &block
        end
      end

      def assemble
        base.class_eval <<-RUBY, __FILE__, __LINE__ + 1
          def initialize( #{ signature.join( ', ' ) }, &block )
            #{ body }
          end
        RUBY
      end
  end
end