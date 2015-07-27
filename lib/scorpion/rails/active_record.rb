module Scorpion
  module Rails
    module ActiveRecord
      require 'scorpion/rails/active_record/model'
      require 'scorpion/rails/active_record/relation'
      require 'scorpion/rails/active_record/association'

      # Setup scorpion support for activerecord
      def self.install!
        return unless defined? ::ActiveRecord

        ::ActiveRecord::Base.send :prepend, Scorpion::Rails::ActiveRecord::Model
        ::ActiveRecord::Relation.send :prepend, Scorpion::Rails::ActiveRecord::Relation
        ::ActiveRecord::Associations::Association.send :prepend, Scorpion::Rails::ActiveRecord::Association

        # TODO extend Scorpion::Hunter to support AR
      end
    end
  end
end

