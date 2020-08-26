# frozen_string_literal: true

command :help do
  desc 'Display this help text'
  action do |context|
    puts "\e[35mWelcome to Schmersion v#{Schmersion::VERSION}\e[0m"
    puts 'For documentation see https://github.com/krystal/schmersion.'
    puts

    puts 'The following commands are supported:'
    puts
    context.cli.commands.sort_by { |k, _v| k.to_s }.each do |_, command|
      if command.description
        puts "  \e[36m#{command.name.to_s.ljust(18, ' ')}\e[0m #{command.description}"
      end
    end
    puts
    puts 'For details for the options available for each command, use the --help option.'
    puts "For example 'schmersion pending --help'."
  end
end
