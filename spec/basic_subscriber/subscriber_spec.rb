# frozen_string_literal: true
RSpec.describe BasicSubscriber::Subscriber do
  subject { Class.new described_class }

  describe '#on' do
    it 'adds event to known list' do
      subject.on :event
      expect(subject.known_events).to eq %i(event)
    end

    it 'adds event to known list once' do
      3.times { subject.on :event }
      expect(subject.known_events).to eq %i(event)
    end

    it 'adds multiple events' do
      subject.on :event, :another_event
      expect(subject.known_events).to eq %i(event another_event)
    end
  end

  describe '#scope' do
    it 'adds scope to event name' do
      subject.class_eval do
        scope :scope do
          on :event
        end
      end

      expect(subject.known_events).to eq %i(event.scope)
    end

    it 'adds scope to enclosed events only' do
      subject.class_eval do
        scope :scope do
          on :event
        end

        on :other_event
      end

      expect(subject.known_events).to eq %i(event.scope other_event)
    end

    it 'adds enclosed scope when called inside of another scope' do
      subject.class_eval do
        scope :scope do
          scope :enclosed_scope do
            on :event
          end
        end
      end

      expect(subject.known_events).to eq %i(event.enclosed_scope.scope)
    end

    context 'when called without block' do
      it 'scopes all events below' do
        subject.class_eval do
          scope :scope
          on :event
        end

        expect(subject.known_events).to eq %i(event.scope)
      end

      it 'adds enclosed scope when called inside of another scope' do
        subject.class_eval do
          scope :scope do
            scope :enclosed_scope
            on :event
          end
        end

        expect(subject.known_events).to eq %i(event.enclosed_scope.scope)
      end

      it 'opens another scope when called another time' do
        subject.class_eval do
          scope :scope
          scope :enclosed_scope
          on :event
        end

        expect(subject.known_events).to eq %i(event.enclosed_scope.scope)
      end
    end
  end

  describe '#trigger' do
    it 'runs callback on event' do
      some_object = double
      expect(some_object).to receive(:some_method).with(some: :data)

      subject.class_eval do
        on :event do
          some_object.some_method payload
        end
      end

      subject.trigger :event, some: :data
    end

    it 'runs all subscribed callbacks' do
      some_object1 = double
      some_object2 = double
      expect(some_object1).to receive(:some_method1).with(some: :data)
      expect(some_object2).to receive(:some_method2).with(some: :data)

      subject.class_eval do
        on :event do
          some_object1.some_method1 payload
        end

        on :event do
          some_object2.some_method2 payload
        end
      end

      subject.trigger :event, some: :data
    end

    it 'runs subscribed callbacks only' do
      some_object1 = double
      some_object2 = double
      expect(some_object1).to receive(:some_method1).with(some: :data)
      expect(some_object2).not_to receive(:some_method2)

      subject.class_eval do
        on :event do
          some_object1.some_method1 payload
        end

        on :another_event do
          some_object2.some_method2 payload
        end
      end

      subject.trigger :event, some: :data
    end
  end

  describe '#unscoped_event_name' do
    it 'returns unscoped event name' do
      expect(described_class.new(:'event').unscoped_event_name).to eq(:event)
      expect(described_class.new(:'event.scope').unscoped_event_name).to eq(:event)
    end
  end

  describe '#scope_name' do
    it 'returns scope name' do
      expect(described_class.new(:'event').scope_name).to be_nil
      expect(described_class.new(:'event.scope').scope_name).to eq(:scope)
    end
  end
end
