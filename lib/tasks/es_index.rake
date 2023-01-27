namespace :es_index do
  task :create => :environment do
    Product.__elasticsearch__.create_index!
  end
end
