# BasicSubscriber

Basic PubSub realization.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'basic_subscriber'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install basic_subscriber

## Usage

### Subscriber class

```ruby
class MySubscription < BasicSubscriber::Subscriber
  # register event subscription
  on :event do
    # do something...
  end

  # register anoter event subscription
  on :event do
    # do something else...
  end

  # register subscription to multiple events
  on :event, :another_event do
    # do something...
  end

  # register event in scope
  scope :my_scope do
    on :scoped_event do
      # trigger this event as :'scoped_event.my_scope'
    end

    # it's also possible to create nested scopes
    scope :another_scope do
      on :event do
        # this is event :'event.another_scope.my_scope'
      end
    end
  end

  # set scope for all events below
  scope :my_another_scope

  on :event do
    # this is event :'event.my_another_scope'
  end

  on :my_event do
    # this event is also in :my_another_scope
  end

  # nested scope will be created if `scope` called twice without block
  scope :my_scope

  on :event do
    # this is :'event.my_scope.my_another_scope'
  end
end
```

### Subscription class

```ruby
class MySubscription < BasicSubscriber::Subscription
  subscribe MySubscriber
end
```

To subscribe another subscriptions pass multiple classes to `subscribe` or call it several times

```ruby
subscribe MySubscriber, MyAnotherSubscriber
subscribe SomeSubscriber
```

### Trigger event

To trigger event use

```ruby
MySubscription.trigger :'event.my_scope', some: :data
```

### In subscriber instance

There are methods available In all event subscriptions

```ruby
# returns hash passed on event trigger
payload # => {some: :data}

# returns full event name
event_name # => :'event.my_scope'

# returns first event name part
unscoped_event_name # => :event

# returns event scope
scope_name # => :my_scope
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/corlinus/basic_subscriber. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

