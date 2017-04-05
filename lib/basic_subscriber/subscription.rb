# frozen_string_literal: true
module BasicSubscriber
  class Subscription
    class << self
      def subscribe(*subscriptions)
        subscriptions.each { |s| s.known_events.each { |e| mounts[e].push(s).uniq! } }
      end

      def trigger(event_name, **payload)
        event_name = event_name.to_sym
        mounts[event_name].each { |subscriber| subscriber.trigger event_name, payload }
        nil
      end

      private

      def mounts
        @mounts ||= Hash.new { |h, k| h[k] = [] }
      end
    end
  end
end
