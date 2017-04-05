# frozen_string_literal: true
RSpec.describe BasicSubscriber do
  it "has a version number" do
    expect(BasicSubscriber::VERSION).not_to be nil
  end

  describe 'simple integration test' do
    it 'works as expected' do
      some_object = double

      subscriber = Class.new BasicSubscriber::Subscriber do
        scope :scope do
          on :event do
            some_object.some_method some: :data
          end
        end
      end
      base = Class.new BasicSubscriber::Subscription do
        subscribe subscriber
      end

      expect(some_object).to receive(:some_method).with(some: :data)

      base.trigger :'event.scope', some: :data
    end
  end
end
