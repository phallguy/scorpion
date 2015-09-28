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
      add_super

      assemble
    end

    private
      attr_reader :base, :arguments, :block, :body

      def define_dependencies
        # Override the inherited injections cause we're about to define a new
        # initializer.
        base.instance_variable_set :@initializer_injections, AttributeSet.new

        arguments.each do |key,expectation|
          base.initializer_injections.define_attribute key, *Array( expectation )
          base.attr_dependency key, *Array( expectation )
        end
      end

      def build_body
        if arguments.present?
          body << "injections = dependencies.slice( :#{ arguments.keys.join(', :') } )"
          body << "inject_from( dependencies )"
        else
          body << "injections = {}"
        end
      end

      def add_super
        body << "super" if base.superclass < Scorpion::Object
      end

      def add_initialize_block
        if block
          base_name = base.name || base.object_id.to_s
          base_name = base_name.gsub /::/, '_'
          name = "__initialize_with_block_#{ base_name }"
          if block.arity != 0
            body << "#{ name }( *args, **injections, &block )"
          else
            body << "#{ name }"
          end
          base.send :define_method, :"#{ name }", &block
        end
      end

      def assemble
        source = %Q|def initialize( *args, **dependencies, &block )\n\t#{ body.join( "\n\t" ) }\nend|

        # puts base.name
        # puts source

        base.class_eval <<-RUBY, __FILE__, __LINE__ + 1
#{ source }
        RUBY
      end
  end
end