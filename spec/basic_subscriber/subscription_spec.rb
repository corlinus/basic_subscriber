# frozen_string_literal: true
RSpec.describe BasicSubscriber::Subscription do
  subject { Class.new described_class }

  describe '#subscribe' do
    it 'subscribes given subscriber to implemented events' do
      subscriber = double 'subscriber', known_events: %i(event1  event2)
      subject.subscribe(subscriber)
      expect(subject.send :mounts).to eq(event1: [subscriber], event2: [subscriber])
    end
  end

  describe '#trigger' do
    it 'triggers event on mounted subscriber' do
      subscriber = double 'subscriber', known_events: %i(event1  event2)
      subject.subscribe subscriber

      expect(subscriber).to receive(:trigger).with(:event1, some: :data)

      subject.trigger :event1, some: :data
    end

    it 'triggers event with scope' do
      subscriber = double 'subscriber', known_events: %i(event1.scoped)
      subject.subscribe subscriber

      expect(subscriber).to receive(:trigger).with(:'event1.scoped', some: :data)
      subject.trigger :'event1.scoped', some: :data
    end

    it 'triggers event on subscriber which implements event only' do
      subscriber1 = double 'subscriber1', known_events: %i(event1  event2)
      subscriber2 = double 'subscriber2', known_events: %i(event2  event3)
      subscriber3 = double 'subscriber3', known_events: %i(event1  event3)
      subject.subscribe subscriber1, subscriber2, subscriber3, subscriber3

      expect(subscriber1).to receive(:trigger).with(:event1, some: :data)
      expect(subscriber3).to receive(:trigger).with(:event1, some: :data)
      expect(subscriber2).not_to receive(:trigger)

      subject.trigger :event1, some: :data
    end
  end
end
