# CLI Module
module Middleman::Cli
  # The CLI Console class
  class Console < Thor::Group
    include Thor::Actions

    check_unknown_options!

    class_option :environment,
                 aliases: '-e',
                 default: ENV['MM_ENV'] || ENV['RACK_ENV'] || 'development',
                 desc: 'The environment Middleman will run under'
    class_option :verbose,
                 type: :boolean,
                 default: false,
                 desc: 'Print debug messages'
    def console
      require 'middleman-core'
      require 'irb'

      opts = {
        environment: options['environment'],
        debug: options['verbose']
      }

      @app = ::Middleman::Application.new do
        config[:environment] = opts[:environment].to_sym if opts[:environment]

        ::Middleman::Logger.singleton(opts[:debug] ? 0 : 1, opts[:instrumenting] || false)
      end

      # TODO: get file watcher / reload! working in console

      interact_with @app
    end

    # Add to CLI
    Base.register(self, 'console', 'console [options]', 'Start an interactive console in the context of your Middleman application')

    # Map "c" to "console"
    Base.map('c' => 'console')

    private

    # Start an interactive console in the context of the provided object.
    # @param [Object] context
    # @return [void]
    def interact_with(context)
      IRB.setup nil
      IRB.conf[:MAIN_CONTEXT] = IRB::Irb.new.context
      require 'irb/ext/multi-irb'
      IRB.irb nil, context
    end
  end
end
