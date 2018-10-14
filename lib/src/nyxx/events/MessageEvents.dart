part of nyxx;

/// Generic message event
abstract class MessageEvent {
  /// Message object associated with event
  Message message;

  MessageEvent._new() {
    client._events.onMessage.add(this);
  }
}

/// Sent when a new message is received.
class MessageReceivedEvent extends MessageEvent {
  /// The new message.
  @override
  Message message;

  MessageReceivedEvent._new(Map<String, dynamic> json) : super._new() {
    if (client.ready) {
      this.message = Message._new(json['d'] as Map<String, dynamic>);
      client._events.onMessageReceived.add(this);
      message.channel._onMessage.add(this);
    }
  }
}

/// Sent when a message is deleted.
class MessageDeleteEvent extends MessageEvent {

  @override
  /// The message, if cached.
  Message message;

  /// The ID of the message.
  Snowflake id;

  MessageDeleteEvent._new(Map<String, dynamic> json) : super._new() {
    if (client.ready) {
      if ((client.channels[Snowflake(json['d']['channel_id'] as String)]
      as MessageChannel)
          .messages[Snowflake(json['d']['id'] as String)] !=
          null) {
        this.message =
        (client.channels[Snowflake(json['d']['channel_id'] as String)]
        as MessageChannel)
            .messages[Snowflake(json['d']['id'] as String)];
        this.id = message.id;
        client._events.onMessageDelete.add(this);
      } else {
        this.id = Snowflake((json['d']['id'] as String));
        client._events.onMessageDelete.add(this);
      }
    }
  }
}

class MessageReactionEvent extends MessageEvent {
  /// User who fired event
  User user;

  /// Channel on which event was fired
  MessageChannel channel;

  @override
  /// Message to which emoji was added
  Message message;

  /// Emoji object.
  Emoji emoji;

  MessageReactionEvent._new(Map<String, dynamic> json, bool remove) : super._new() {
    this.user = client.users[Snowflake(json['d']['user_id'] as String)];
    this.channel = client.channels[Snowflake(json['d']['channel_id'] as String)]
    as MessageChannel;

    channel
        .getMessage(Snowflake(json['d']['message_id'] as String))
        .then((msg) {
      message = msg;

      if (json['d']['emoji']['id'] == null)
        emoji = UnicodeEmoji((json['d']['emoji']['name'] as String));
      else
        emoji = GuildEmoji._partial(json['d']['emoji'] as Map<String, dynamic>);

      if (remove) {
        this.message._onReactionRemove.add(this);
        client._events.onMessageReactionRemove.add(this);
      } else {
        this.message._onReactionAdded.add(this);
        client._events.onMessageReactionAdded.add(this);
      }
    });
  }
}

/// Emitted when all reaction are removed
class MessageReactionsRemovedEvent extends MessageEvent {
  /// Channel where reactions are removed
  MessageChannel channel;

  @override
  /// Message on which messages are removed
  Message message;

  /// Guild where event occurs
  Guild guild;

  MessageReactionsRemovedEvent._new(Map<String, dynamic> json) : super._new() {
    this.channel = client.channels[Snowflake(json['d']['channel_id'] as String)]
    as MessageChannel;

    this.guild = client.guilds[Snowflake(json['d']['guild_id'] as String)];

    channel
        .getMessage(Snowflake(json['d']['message_id'] as String))
        .then((msg) => message = msg);

    client._events.onMessageReactionsRemoved.add(this);
  }
}


/// Emitted when multiple messages are deleted at once.
class MessageDeleteBulkEvent  {
  /// List of deleted messages
  List<Snowflake> deletedMessages = List();

  /// Channel on which messages was deleted.
  Channel channel;

  MessageDeleteBulkEvent._new(Map<String, dynamic> json) {
    this.channel =
    client.channels[Snowflake(json['d']['channel_id'] as String)];

    json['d']['ids']
        .forEach((i) => deletedMessages.add(Snowflake(i.toString())));
    client._events.onMessageDeleteBulk.add(this);
  }
}

/// Sent when a message is updated.
class MessageUpdateEvent {
  /// The old message, if cached.
  Message oldMessage;

  /// Edited message
  Message newMessage;

  MessageUpdateEvent._new(Map<String, dynamic> json) {
    print(jsonEncode(json));

    var channel = client.channels[Snowflake(json['d']['channel_id'] as String)] as MessageChannel;
    this.oldMessage = channel.messages[Snowflake(json['d']['id'] as String)];

    if (oldMessage != null) {
      this.newMessage = Message._combine(oldMessage, json['d'] as Map<String, dynamic>);
    }

    client._events.onMessageUpdate.add(this);
    //channel.messages._cacheMessage(newMessage);
  }
}

