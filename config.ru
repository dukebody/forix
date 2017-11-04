require './webapp'

warmup do |app|
  puts "Syncing currencies..."
  sync_currencies
  puts "Done!"
end

run Sinatra::Application
