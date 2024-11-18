module Scorpion
  module Rails
    module ActiveRecord
      require "scorpion/rails/active_record/model"
      require "scorpion/rails/active_record/relation"
      require "scorpion/rails/active_record/association"

      # Setup scorpion support for activerecord
      def self.install!
        return unless defined? ::ActiveRecord

        ActiveSupport.on_load(:active_record) { prepend(Scorpion::Rails::ActiveRecord::Model) }

        ::ActiveRecord::Relation.prepend(Scorpion::Rails::ActiveRecord::Relation)
        ::ActiveRecord::Associations::Association.prepend(Scorpion::Rails::ActiveRecord::Association)
      end
    end
  end
end

