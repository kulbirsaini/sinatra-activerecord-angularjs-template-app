namespace :db do
  desc 'Establiish fake connection to database'
  task :fake_connect do
    fake_connection_info = SinatraApp::Application.connection_info[SinatraApp::Application.environment].merge({ 'database' => 'test', 'schema_search_path' => 'public' })
    ActiveRecord::Base.establish_connection(fake_connection_info)
  end

  desc 'Connect to database'
  task :connect do
    ActiveRecord::Base.establish_connection(SinatraApp::Application.connection_info[SinatraApp::Application.environment])
  end

  desc 'Seed database'
  task :seed => [ :connect ] do
    seed_file = SinatraApp::Application.root.join('db/seed.rb')
    require seed_file if File.exists?(seed_file)
  end

  desc 'Migrate database'
  task :migrate => [ :connect ] do
    version = ENV['VERSION'].present? ? ENV['VERSION'].to_i : nil
    ActiveRecord::Migrator.migrate(SinatraApp::Application.migrations_dir, version)
    Rake::Task[:'db:seed'].invoke
  end

  desc 'Rollback migrations'
  task :rollback => [ :connect ] do
    ActiveRecord::Migrator.rollback(SinatraApp::Application.migrations_dir)
  end

  namespace :migrate do
    desc 'One migration up'
    task :up => [ :connect ] do
      step = ENV['STEP'].present? ? ENV['STEP'].to_i : 1
      ActiveRecord::Migrator.up(SinatraApp::Application.migrations_dir, get_next_version(step))
    end

    desc 'One migration down'
    task :down => [ :connect ] do
      step = ENV['STEP'].present? ? ENV['STEP'].to_i : 1
      ActiveRecord::Migrator.down(SinatraApp::Application.migrations_dir, get_previous_version(step))
    end
  end

  desc 'Create database'
  task :create => [ :fake_connect ] do
    ActiveRecord::Base.connection.create_database(SinatraApp::Application.connection_info[SinatraApp::Application.environment].fetch('database'))
  end

  desc 'Drop database'
  task :drop => [ :fake_connect ] do
    ActiveRecord::Base.connection.drop_database(SinatraApp::Application.connection_info[SinatraApp::Application.environment].fetch('database'))
  end
end

def get_next_version(step = 1)
  version = ActiveRecord::Migrator.current_version
  versions = ActiveRecord::Migrator.migrations(SinatraApp::Application.migrations_dir).map(&:version).sort
  next_version = versions.select{ |v| v > version }[step - 1]
  next_version ? next_version : versions.max
end

def get_previous_version(step = 1)
  version = ActiveRecord::Migrator.current_version
  versions = ActiveRecord::Migrator.migrations(SinatraApp::Application.migrations_dir).map(&:version).sort
  versions.select{ |v| v < version }[-step]
end
