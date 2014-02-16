require 'securerandom'
require 'speed_gun'
require 'speed_gun/event'

class SpeedGun::Profile
  # @return [String] profile ID
  attr_reader :id

  # @return [Array<SpeedGun::Event>] recorded events
  attr_reader :events

  # @return [SpeedGun::Config] the config of the profile
  attr_reader :config

  # @return [SpeedGun::Profile] instance of SpeedGun::Profile
  def initialize(config = SpeedGun.config.dup)
    @id = SecureRandom.uuid
    @events = []
    @config = config
  end

  # Record an event
  #
  # @param event [SpeedGun::Event] record event
  # @return [Array<SpeedGun::Event>] recorded events
  def record!(event)
    config.logger.debug(
      "[SpeedGun] Record Event: #{event.name}: #{'%0.2f' % (event.duration * 1000)}ms"
    )
    @events.push(event)
  end
end
