require './webapp'

warmup do |app|
  puts "Syncing currencies..."
  app.sync_currencies
  puts "Done!"
end

run Forix
