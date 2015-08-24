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
      @body            = []

      define_dependencies
      build_body

      add_initialize_block
      assemble
    end

    private
      attr_reader :base, :arguments, :block, :body

      def define_dependencies
        arguments.each do |key,expectation|
          base.initializer_injections.define_attribute key, *Array( expectation )
          base.attr_dependency key, *Array( expectation )
        end
      end

      def build_body
        body << "injections = args.slice( :#{ arguments.keys.join(', :') } )"
        body << "inject_from( injections )"
        body << "super" if base.superclass < Scorpion::Object
      end

      def add_initialize_block
        if block
          name = "__initialize_with_block_#{ base.name || base.object_id }"
          body << "#{ name }( **injections, &block )"
          base.send :define_method, :"#{ name }", &block
        end
      end

      def assemble
        source = %Q| def initialize( **args, &block )\n\t#{ body.join( "\n\t" ) }\nend |

        # puts source

        base.class_eval <<-RUBY, __FILE__, __LINE__ + 1
#{ source }
        RUBY
      end
  end
end