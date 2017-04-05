# frozen_string_literal: true
module BasicSubscriber
  class Subscriber
    NAME_SEPARATOR = '.'
    attr_reader :event_name, :payload

    class << self
      def trigger(event_name, **payload)
        event_name = event_name.to_sym

        subscriber = new event_name, payload
        subscriptions[event_name].each { |block| subscriber.instance_exec(&block) }
        nil
      end

      def on(*event_names, &block)
        event_names.each { |name| subscriptions[scoped_name(name)].push block }
      end

      def scope(scope_name)
        scope_name = scope_name.to_sym
        if block_given?
          previous_scope = current_scope.dup
          subscope scope_name
          yield
          self.current_scope = previous_scope
        else
          parent_scope = current_scope[1..-1]
          self.current_scope = parent_scope if parent_scope&.any?
          subscope scope_name
        end
      end

      def known_events
        subscriptions.keys
      end

      private

      def subscriptions
        @subscriptions ||= Hash.new { |h, k| h[k] = [] }
      end

      def scoped_name(name)
        ([name] + current_scope).join(NAME_SEPARATOR).to_sym
      end

      def current_scope
        @current_scope ||= []
      end

      attr_writer :current_scope

      def subscope(name)
        @current_scope.unshift name
      end
    end

    def initialize(event_name, **payload)
      @event_name = event_name
      @payload = payload
    end

    def unscoped_event_name
      @unscoped_event_name ||= split_event_name.first.to_sym
    end

    def scope_name
      return @scope_name if defined? @scope_name
      @scope_name = begin
        scope_name = split_event_name[2]
        scope_name == '' ? nil : scope_name.to_sym
      end
    end

    private

    def split_event_name
      @split_event_name ||= event_name.to_s.partition NAME_SEPARATOR
    end
  end
end
