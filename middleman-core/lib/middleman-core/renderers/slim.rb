# Load gem
require 'slim'

module SafeTemplate
  def render(*)
    super.html_safe
  end
end

class Slim::Template
  include SafeTemplate

  def precompiled_preamble(locals)
    "__in_slim_template = true\n" << super
  end
end

module Middleman
  module Renderers
    # Slim renderer
    class Slim < ::Middleman::Extension
      # Setup extension
      def initialize(_app, _options={}, &_block)
        super

        # Setup Slim options to work with partials
        ::Slim::Engine.set_options(
          buffer: '@_out_buf',
          use_html_safe: true,
          generator: ::Temple::Generators::RailsOutputBuffer,
          disable_escape: true
        )
      end

      def after_configuration
        context_hack = {
          context: app.template_context_class.new(app)
        }

        ::Slim::Embedded::SassEngine.disable_option_validator!
        %w(sass scss markdown).each do |engine|
          ::Slim::Embedded.options[engine.to_sym] = context_hack
        end
      end
    end
  end
end
