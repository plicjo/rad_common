module RadCommon
  module Generators
    class InstallGenerator < Rails::Generators::Base
      include Rails::Generators::Migration
      source_root File.expand_path('../templates', __FILE__)
      desc 'Used to install the rad_common depencency files and create migrations.'

      def create_initializer_file
        # initializers
        template '../../../../../spec/dummy/config/initializers/rad_common.rb', 'config/initializers/rad_common.rb'

        # controllers
        template '../../../../../spec/dummy/app/controllers/application_controller.rb', 'app/controllers/application_controller.rb'

        # models
        template '../../../../../spec/dummy/app/models/user.rb', 'app/models/user.rb'
        template '../../../../../spec/dummy/app/models/company.rb', 'app/models/company.rb'
        template '../../../../../spec/dummy/app/models/security_group.rb', 'app/models/security_group.rb'

        # views
        template '../../../../../spec/dummy/app/views/devise/confirmations/new.html.haml', 'app/views/devise/confirmations/new.html.haml'
        template '../../../../../spec/dummy/app/views/devise/passwords/edit.html.haml', 'app/views/devise/passwords/edit.html.haml'
        template '../../../../../spec/dummy/app/views/devise/passwords/new.html.haml', 'app/views/devise/passwords/new.html.haml'
        template '../../../../../spec/dummy/app/views/devise/registrations/edit.html.haml', 'app/views/devise/registrations/edit.html.haml'
        template '../../../../../spec/dummy/app/views/devise/registrations/new.html.haml', 'app/views/devise/registrations/new.html.haml'
        template '../../../../../spec/dummy/app/views/devise/sessions/new.html.haml', 'app/views/devise/sessions/new.html.haml'
        template '../../../../../spec/dummy/app/views/devise/shared/_links.html.haml', 'app/views/devise/shared/_links.html.haml'
        template '../../../../../spec/dummy/app/views/devise/unlocks/new.html.haml', 'app/views/devise/unlocks/new.html.haml'

        # templates

        # active_record templates
        copy_file '../../../../../spec/dummy/lib/templates/active_record/model/model.rb', 'lib/templates/active_record/model/model.rb'

        # haml` templates
        copy_file '../../../../../spec/dummy/lib/templates/haml/scaffold/_form.html.haml', 'lib/templates/haml/scaffold/_form.html.haml'
        copy_file '../../../../../spec/dummy/lib/templates/haml/scaffold/edit.html.haml', 'lib/templates/haml/scaffold/edit.html.haml'
        copy_file '../../../../../spec/dummy/lib/templates/haml/scaffold/index.html.haml', 'lib/templates/haml/scaffold/index.html.haml'
        copy_file '../../../../../spec/dummy/lib/templates/haml/scaffold/new.html.haml', 'lib/templates/haml/scaffold/new.html.haml'
        copy_file '../../../../../spec/dummy/lib/templates/haml/scaffold/show.html.haml', 'lib/templates/haml/scaffold/show.html.haml'

        # rails templates
        copy_file '../../../../../spec/dummy/lib/templates/rails/scaffold_controller/controller.rb', 'lib/templates/rails/scaffold_controller/controller.rb'

        # rspec templates
        copy_file '../../../../../spec/dummy/lib/templates/rspec/integration/request_spec.rb', 'lib/templates/rspec/integration/request_spec.rb'
        copy_file '../../../../../spec/dummy/lib/templates/rspec/scaffold/controller_spec.rb', 'lib/templates/rspec/scaffold/controller_spec.rb'

        gsub_file 'config/environments/production.rb', '#config.force_ssl = true', 'config.force_ssl = true'

        inject_into_class 'config/application.rb', 'Application' do <<-'RUBY'

    # added by rad_common
    config.generators do |g|
      g.helper false
      g.stylesheets false
      g.javascripts false
      g.view_specs false
      g.helper_specs false
      g.routing_specs false
    end

        RUBY
        end

        inject_into_file 'config/routes.rb', after: 'Application.routes.draw do' do <<-'RUBY'

  mount RadCommon::Engine => '/rad_common'
  get '/auth/:provider/callback' => 'rad_common/authentications#create'

        RUBY
        end

        apply_migration '../../../../../spec/dummy/db/migrate/20140302111111_add_radbear_user_fields.rb', 'add_radbear_user_fields'
        apply_migration '../../../../../spec/dummy/db/migrate/20140827111111_add_name_index_to_users.rb', 'add_name_index_to_users'
        apply_migration '../../../../../spec/dummy/db/migrate/20140903124700_expand_facebook_access_token.rb', 'expand_facebook_access_token'
        apply_migration '../../../../../spec/dummy/db/migrate/20141029233028_add_company_table.rb', 'add_company_table'
        apply_migration '../../../../../spec/dummy/db/migrate/20141110200841_add_logo_stuff_to_company.rb', 'add_logo_stuff_to_company'
        apply_migration '../../../../../spec/dummy/db/migrate/20150221211338_add_optional_emails.rb', 'add_optional_emails'
        apply_migration '../../../../../spec/dummy/db/migrate/20150810232946_add_user_global_search_default.rb', 'add_user_global_search_default'
        apply_migration '../../../../../spec/dummy/db/migrate/20150916175409_remove_twitter.rb', 'remove_twitter'
        apply_migration '../../../../../spec/dummy/db/migrate/20160929174209_add_string_limits.rb', 'add_string_limits'
        apply_migration '../../../../../spec/dummy/db/migrate/20170702133404_company_validity_check.rb', 'company_validity_check'
        apply_migration '../../../../../spec/dummy/db/migrate/20170811123959_security_groups.rb', 'security_groups'
        apply_migration '../../../../../spec/dummy/db/migrate/20171122123931_user_statuses.rb', 'user_statuses'
      end

      def self.next_migration_number(path)
        next_migration_number = current_migration_number(path) + 1
        if ActiveRecord::Base.timestamped_migrations
          [Time.now.utc.strftime('%Y%m%d%H%M%S'), '%.14d' % next_migration_number].max
        else
          '%.3d' % next_migration_number
        end
      end

      protected

        def apply_migration(source, filename)
          if self.class.migration_exists?('db/migrate', filename)
            say_status('skipped', "Migration #{filename}.rb already exists")
          else
            migration_template source, "db/migrate/#{filename}.rb"
          end
        end

    end
  end
end
