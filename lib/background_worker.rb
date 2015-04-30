require 'background_worker/version'
require 'background_worker/config'
require 'background_worker/uid'
require 'background_worker/base'
require 'background_worker/persistent_state'

module BackgroundWorker
  # Configure worker
  #
  # eg:
  # BackgroundWorker.configure(
  #   logger: Rails.logger,
  #   enqueue_with: -> klass, method_name, opts { Resque.enqueue(klass, method_name, opts) },
  #   after_exception: -> e { Airbrake.notify(e) }
  # )
  def self.configure(options)
    @config = Config.new(options)
  end

  def self.enqueue(klass, method_name, options)
    config.enqueue_with.call(klass, method_name, options)
  end

  def self.logger
    config.logger
  end

  def self.verify_active_connections!
    Rails.cache.reconnect if defined?(Rails)
    ActiveRecord::Base.verify_active_connections! if defined?(ActiveRecord)
  end

  def self.after_exception(e)
    config.after_exception(e)
  end

  def self.config
    raise "Not configured!" unless @config
    @config
  end

end
