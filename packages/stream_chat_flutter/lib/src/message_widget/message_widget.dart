import 'package:contextmenu/contextmenu.dart';
import 'package:flutter/material.dart' hide ButtonStyle;
import 'package:flutter/services.dart';
import 'package:flutter_portal/flutter_portal.dart';
import 'package:meta/meta.dart';
import 'package:stream_chat_flutter/conditional_parent_builder/conditional_parent_builder.dart';
import 'package:stream_chat_flutter/platform_widget_builder/platform_widget_builder.dart';
import 'package:stream_chat_flutter/src/context_menu_items/context_menu_reaction_picker.dart';
import 'package:stream_chat_flutter/src/context_menu_items/stream_chat_context_menu_item.dart';
import 'package:stream_chat_flutter/src/dialogs/dialogs.dart';
import 'package:stream_chat_flutter/src/message_actions_modal/message_actions_modal.dart';
import 'package:stream_chat_flutter/src/message_widget/bottom_row.dart';
import 'package:stream_chat_flutter/src/message_widget/message_widget_content.dart';
import 'package:stream_chat_flutter/src/message_widget/reactions/message_reactions_modal.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';

/// The display behaviour of a widget
enum DisplayWidget {
  /// Hides the widget replacing its space with a spacer
  hide,

  /// Hides the widget not replacing its space
  gone,

  /// Shows the widget normally
  show,
}

/// {@template messageWidget}
/// ![screenshot](https://raw.githubusercontent.com/GetStream/stream-chat-flutter/master/packages/stream_chat_flutter/screenshots/message_widget.png)
/// ![screenshot](https://raw.githubusercontent.com/GetStream/stream-chat-flutter/master/packages/stream_chat_flutter/screenshots/message_widget_paint.png)
///
/// Shows a message with reactions, replies and user avatar.
///
/// Usually you don't use this widget as it's the default message widget used by
/// [MessageListView].
///
/// The widget components render the ui based on the first ancestor of type
/// [StreamChatTheme].
/// Modify it to change the widget appearance.
/// {@endtemplate}
class StreamMessageWidget extends StatefulWidget {
  /// {@macro messageWidget}
  StreamMessageWidget({
    super.key,
    required this.message,
    required this.messageTheme,
    this.reverse = false,
    this.translateUserAvatar = true,
    this.shape,
    this.attachmentShape,
    this.borderSide,
    this.attachmentBorderSide,
    this.borderRadiusGeometry,
    this.attachmentBorderRadiusGeometry,
    this.onMentionTap,
    this.onMessageTap,
    bool? showReactionPicker,
    @Deprecated('Use `showReactionPicker` instead')
    bool showReactionPickerIndicator = true,
    @internal this.showReactionPickerTail = false,
    this.showUserAvatar = DisplayWidget.show,
    this.showSendingIndicator = true,
    this.showThreadReplyIndicator = false,
    this.showInChannelIndicator = false,
    this.onReplyTap,
    this.onThreadTap,
    this.onConfirmDeleteTap,
    this.showUsername = true,
    this.showTimestamp = true,
    this.showReactions = true,
    this.showDeleteMessage = true,
    this.showEditMessage = true,
    this.showReplyMessage = true,
    this.showThreadReplyMessage = true,
    this.showResendMessage = true,
    this.showCopyMessage = true,
    this.showFlagButton = true,
    this.showPinButton = true,
    this.showPinHighlight = true,
    this.onUserAvatarTap,
    this.onLinkTap,
    this.onMessageActions,
    this.onShowMessage,
    this.userAvatarBuilder,
    this.quotedMessageBuilder,
    this.editMessageInputBuilder,
    this.textBuilder,
    @Deprecated('''
    Use [bottomRowBuilderWithDefaultWidget] instead.
    Will be removed in the next major version.
    ''') this.bottomRowBuilder,
    this.bottomRowBuilderWithDefaultWidget,
    @Deprecated('''
    Use [bottomRowBuilderWithDefaultWidget] instead.
    Will be removed in the next major version.
    ''') this.deletedBottomRowBuilder,
    this.customAttachmentBuilders,
    this.padding,
    this.textPadding = const EdgeInsets.symmetric(
      horizontal: 16,
      vertical: 8,
    ),
    this.attachmentPadding = EdgeInsets.zero,
    this.widthFactor = 0.78,
    this.onQuotedMessageTap,
    this.customActions = const [],
    this.onAttachmentTap,
    @Deprecated('''
    Use [bottomRowBuilderWithDefaultWidget] instead.
    Will be removed in the next major version.
    ''') this.usernameBuilder,
    this.imageAttachmentThumbnailSize = const Size(400, 400),
    this.imageAttachmentThumbnailResizeType = 'clip',
    this.imageAttachmentThumbnailCropType = 'center',
    this.attachmentActionsModalBuilder,
  })  : assert(
          bottomRowBuilder == null || bottomRowBuilderWithDefaultWidget == null,
          'You can only use one of the two bottom row builders',
        ),
        showReactionPicker = showReactionPicker ?? showReactionPickerIndicator,
        attachmentBuilders = {
          'image': (context, message, attachments) {
            final border = RoundedRectangleBorder(
              side: attachmentBorderSide ??
                  BorderSide(
                    color: StreamChatTheme.of(context).colorTheme.borders,
                  ),
              borderRadius: attachmentBorderRadiusGeometry ?? BorderRadius.zero,
            );

            final mediaQueryData = MediaQuery.of(context);
            if (attachments.length > 1) {
              return Padding(
                padding: attachmentPadding,
                child: WrapAttachmentWidget(
                  attachmentWidget: Material(
                    color: messageTheme.messageBackgroundColor,
                    child: StreamImageGroup(
                      constraints: BoxConstraints(
                        maxWidth: 400,
                        minWidth: 400,
                        maxHeight: mediaQueryData.size.height * 0.3,
                      ),
                      images: attachments,
                      message: message,
                      messageTheme: messageTheme,
                      onShowMessage: onShowMessage,
                      onReplyMessage: onReplyTap,
                      onAttachmentTap: onAttachmentTap,
                      imageThumbnailSize: imageAttachmentThumbnailSize,
                      imageThumbnailResizeType:
                          imageAttachmentThumbnailResizeType,
                      imageThumbnailCropType: imageAttachmentThumbnailCropType,
                      attachmentActionsModalBuilder:
                          attachmentActionsModalBuilder,
                    ),
                  ),
                  attachmentShape: border,
                ),
              );
            }

            return WrapAttachmentWidget(
              attachmentWidget: StreamImageAttachment(
                attachment: attachments[0],
                message: message,
                messageTheme: messageTheme,
                constraints: BoxConstraints(
                  maxWidth: 400,
                  minWidth: 400,
                  maxHeight: mediaQueryData.size.height * 0.3,
                ),
                onShowMessage: onShowMessage,
                onReplyMessage: onReplyTap,
                onAttachmentTap: onAttachmentTap != null
                    ? () {
                        onAttachmentTap.call(message, attachments[0]);
                      }
                    : null,
                imageThumbnailSize: imageAttachmentThumbnailSize,
                imageThumbnailResizeType: imageAttachmentThumbnailResizeType,
                imageThumbnailCropType: imageAttachmentThumbnailCropType,
                attachmentActionsModalBuilder: attachmentActionsModalBuilder,
              ),
              attachmentShape: border,
            );
          },
          'video': (context, message, attachments) {
            final border = RoundedRectangleBorder(
              side: attachmentBorderSide ??
                  BorderSide(
                    color: StreamChatTheme.of(context).colorTheme.borders,
                  ),
              borderRadius: attachmentBorderRadiusGeometry ?? BorderRadius.zero,
            );

            return WrapAttachmentWidget(
              attachmentWidget: Column(
                children: attachments.map((attachment) {
                  final mediaQueryData = MediaQuery.of(context);
                  return StreamVideoAttachment(
                    attachment: attachment,
                    messageTheme: messageTheme,
                    constraints: BoxConstraints(
                      maxWidth: 400,
                      minWidth: 400,
                      maxHeight: mediaQueryData.size.height * 0.3,
                    ),
                    message: message,
                    onShowMessage: onShowMessage,
                    onReplyMessage: onReplyTap,
                    onAttachmentTap: onAttachmentTap != null
                        ? () {
                            onAttachmentTap(message, attachment);
                          }
                        : null,
                    attachmentActionsModalBuilder:
                        attachmentActionsModalBuilder,
                  );
                }).toList(),
              ),
              attachmentShape: border,
            );
          },
          'giphy': (context, message, attachments) {
            final attachmentWidget = Column(
              children: [
                ...attachments.map((attachment) {
                  final mediaQueryData = MediaQuery.of(context);
                  return StreamGiphyAttachment(
                    attachment: attachment,
                    message: message,
                    constraints: BoxConstraints(
                      maxWidth: 400,
                      minWidth: 400,
                      maxHeight: mediaQueryData.size.height * 0.3,
                    ),
                    onShowMessage: onShowMessage,
                    onReplyMessage: onReplyTap,
                    onAttachmentTap: onAttachmentTap != null
                        ? () => onAttachmentTap(message, attachment)
                        : null,
                  );
                }),
              ],
            );

            // If the message is ephemeral, we don't want to show the border.
            if (message.isEphemeral) return attachmentWidget;

            final color = StreamChatTheme.of(context).colorTheme.borders;
            final border = RoundedRectangleBorder(
              side: attachmentBorderSide ?? BorderSide(color: color),
              borderRadius: attachmentBorderRadiusGeometry ?? BorderRadius.zero,
            );

            return WrapAttachmentWidget(
              attachmentShape: border,
              attachmentWidget: attachmentWidget,
            );
          },
          'file': (context, message, attachments) {
            final border = RoundedRectangleBorder(
              side: attachmentBorderSide ??
                  BorderSide(
                    color: StreamChatTheme.of(context).colorTheme.borders,
                  ),
              borderRadius: attachmentBorderRadiusGeometry ?? BorderRadius.zero,
            );

            return Column(
              children: attachments
                  .map<Widget>((attachment) {
                    final mediaQueryData = MediaQuery.of(context);
                    return WrapAttachmentWidget(
                      attachmentWidget: StreamFileAttachment(
                        message: message,
                        attachment: attachment,
                        constraints: BoxConstraints(
                          maxWidth: 400,
                          minWidth: 400,
                          maxHeight: mediaQueryData.size.height * 0.3,
                        ),
                        onAttachmentTap: onAttachmentTap != null
                            ? () {
                                onAttachmentTap(message, attachment);
                              }
                            : null,
                      ),
                      attachmentShape: border,
                    );
                  })
                  .insertBetween(SizedBox(
                    height: attachmentPadding.vertical / 2,
                  ))
                  .toList(),
            );
          },
        }..addAll(customAttachmentBuilders ?? {});

  /// {@template onMentionTap}
  /// Function called on mention tap
  /// {@endtemplate}
  final void Function(User)? onMentionTap;

  /// {@template onThreadTap}
  /// The function called when tapping on threads
  /// {@endtemplate}
  final void Function(Message)? onThreadTap;

  /// {@template onReplyTap}
  /// The function called when tapping on replies
  /// {@endtemplate}
  final void Function(Message)? onReplyTap;

  /// {@template onDeleteTap}
  /// The function called when delete confirmation button is tapped.
  /// {@endtemplate}
  final Future<void> Function(Message)? onConfirmDeleteTap;

  /// {@template editMessageInputBuilder}
  /// Widget builder for edit message layout
  /// {@endtemplate}
  final Widget Function(BuildContext, Message)? editMessageInputBuilder;

  /// {@template textBuilder}
  /// Widget builder for building text
  /// {@endtemplate}
  final Widget Function(BuildContext, Message)? textBuilder;

  /// {@template usernameBuilder}
  /// Widget builder for building username
  /// {@endtemplate}
  final Widget Function(BuildContext, Message)? usernameBuilder;

  /// {@template onMessageActions}
  /// Function called on long press
  /// {@endtemplate}
  final void Function(BuildContext, Message)? onMessageActions;

  /// {@template bottomRowBuilder}
  /// Widget builder for building a bottom row below the message
  /// {@endtemplate}
  final BottomRowBuilder? bottomRowBuilder;

  /// {@template bottomRowBuilderWithDefaultWidget}
  /// Widget builder for building a bottom row below the message.
  /// Also contains the default bottom row widget.
  /// {@endtemplate}
  final BottomRowBuilderWithDefaultWidget? bottomRowBuilderWithDefaultWidget;

  /// {@template deletedBottomRowBuilder}
  /// Widget builder for building a bottom row below a deleted message
  /// {@endtemplate}
  final Widget Function(BuildContext, Message)? deletedBottomRowBuilder;

  /// {@template userAvatarBuilder}
  /// Widget builder for building user avatar
  /// {@endtemplate}
  final Widget Function(BuildContext, User)? userAvatarBuilder;

  /// {@template quotedMessageBuilder}
  /// Widget builder for building quoted message
  /// {@endtemplate}
  final Widget Function(BuildContext, Message)? quotedMessageBuilder;

  /// {@template message}
  /// The message to display.
  /// {@endtemplate}
  final Message message;

  /// {@template messageTheme}
  /// The message theme
  /// {@endtemplate}
  final StreamMessageThemeData messageTheme;

  /// {@template reverse}
  /// If true the widget will be mirrored
  /// {@endtemplate}
  final bool reverse;

  /// {@template shape}
  /// The shape of the message text
  /// {@endtemplate}
  final ShapeBorder? shape;

  /// {@template attachmentShape}
  /// The shape of an attachment
  /// {@endtemplate}
  final ShapeBorder? attachmentShape;

  /// {@template borderSide}
  /// The borderSide of the message text
  /// {@endtemplate}
  final BorderSide? borderSide;

  /// {@template attachmentBorderSide}
  /// The borderSide of an attachment
  /// {@endtemplate}
  final BorderSide? attachmentBorderSide;

  /// {@template borderRadiusGeometry}
  /// The border radius of the message text
  /// {@endtemplate}
  final BorderRadiusGeometry? borderRadiusGeometry;

  /// {@template attachmentBorderRadiusGeometry}
  /// The border radius of an attachment
  /// {@endtemplate}
  final BorderRadiusGeometry? attachmentBorderRadiusGeometry;

  /// {@template padding}
  /// The padding of the widget
  /// {@endtemplate}
  final EdgeInsetsGeometry? padding;

  /// {@template textPadding}
  /// The internal padding of the message text
  /// {@endtemplate}
  final EdgeInsets textPadding;

  /// {@template attachmentPadding}
  /// The internal padding of an attachment
  /// {@endtemplate}
  final EdgeInsetsGeometry attachmentPadding;

  /// {@template widthFactor}
  /// The percentage of the available width the message content should take
  /// {@endtemplate}
  final double widthFactor;

  /// {@template showUserAvatar}
  /// It controls the display behaviour of the user avatar
  /// {@endtemplate}
  final DisplayWidget showUserAvatar;

  /// {@template showSendingIndicator}
  /// It controls the display behaviour of the sending indicator
  /// {@endtemplate}
  final bool showSendingIndicator;

  /// {@template showReactions}
  /// If `true` the message's reactions will be shown.
  /// {@endtemplate}
  final bool showReactions;

  /// {@template showThreadReplyIndicator}
  /// If true the widget will show the thread reply indicator
  /// {@endtemplate}
  final bool showThreadReplyIndicator;

  /// {@template showInChannelIndicator}
  /// If true the widget will show the show in channel indicator
  /// {@endtemplate}
  final bool showInChannelIndicator;

  /// {@template onUserAvatarTap}
  /// The function called when tapping on UserAvatar
  /// {@endtemplate}
  final void Function(User)? onUserAvatarTap;

  /// {@template onLinkTap}
  /// The function called when tapping on a link
  /// {@endtemplate}
  final void Function(String)? onLinkTap;

  /// {@template showReactionPicker}
  /// Whether or not to show the reaction picker.
  /// Used in [StreamMessageReactionsModal] and [MessageActionsModal].
  /// {@endtemplate}
  final bool showReactionPicker;

  /// {@template showReactionPickerIndicator}
  /// Used in [StreamMessageReactionsModal] and [MessageActionsModal]
  /// {@endtemplate}  @Deprecated('Use `showReactionPicker` instead')
  bool get showReactionPickerIndicator => showReactionPicker;

  /// {@template showReactionPickerTail}
  /// Whether or not to show the reaction picker tail
  /// {@endtemplate}
  @internal
  final bool showReactionPickerTail;

  /// {@template onShowMessage}
  /// Callback when show message is tapped
  /// {@endtemplate}
  final ShowMessageCallback? onShowMessage;

  /// {@template showUsername}
  /// If true show the users username next to the timestamp of the message
  /// {@endtemplate}
  final bool showUsername;

  /// {@template showTimestamp}
  /// Show message timestamp
  /// {@endtemplate}
  final bool showTimestamp;

  /// {@template showReplyMessage}
  /// Show reply action
  /// {@endtemplate}
  final bool showReplyMessage;

  /// {@template showThreadReplyMessage}
  /// Show thread reply action
  /// {@endtemplate}
  final bool showThreadReplyMessage;

  /// {@template showEditMessage}
  /// Show edit action
  /// {@endtemplate}
  final bool showEditMessage;

  /// {@template showCopyMessage}
  /// Show copy action
  /// {@endtemplate}
  final bool showCopyMessage;

  /// {@template showDeleteMessage}
  /// Show delete action
  /// {@endtemplate}
  final bool showDeleteMessage;

  /// {@template showResendMessage}
  /// Show resend action
  /// {@endtemplate}
  final bool showResendMessage;

  /// {@template showFlagButton}
  /// Show flag action
  /// {@endtemplate}
  final bool showFlagButton;

  /// {@template showPinButton}
  /// Show pin action
  /// {@endtemplate}
  final bool showPinButton;

  /// {@template showPinHighlight}
  /// Display Pin Highlight
  /// {@endtemplate}
  final bool showPinHighlight;

  /// {@template attachmentBuilders}
  /// Builder for respective attachment types
  /// {@endtemplate}
  final Map<String, AttachmentBuilder> attachmentBuilders;

  /// {@template customAttachmentBuilders}
  /// Builder for respective attachment types (user facing builder)
  /// {@endtemplate}
  final Map<String, AttachmentBuilder>? customAttachmentBuilders;

  /// {@template translateUserAvatar}
  /// Center user avatar with bottom of the message
  /// {@endtemplate}
  final bool translateUserAvatar;

  /// {@macro onQuotedMessageTap}
  final OnQuotedMessageTap? onQuotedMessageTap;

  /// {@macro onMessageTap}
  final void Function(Message)? onMessageTap;

  /// {@template customActions}
  /// List of custom actions shown on message long tap
  /// {@endtemplate}
  final List<StreamMessageAction> customActions;

  /// {@macro onMessageWidgetAttachmentTap}
  final OnMessageWidgetAttachmentTap? onAttachmentTap;

  /// {@macro attachmentActionsBuilder}
  final AttachmentActionsBuilder? attachmentActionsModalBuilder;

  /// Size of the image attachment thumbnail.
  final Size imageAttachmentThumbnailSize;

  /// Resize type of the image attachment thumbnail.
  ///
  /// Defaults to [crop]
  final String /*clip|crop|scale|fill*/ imageAttachmentThumbnailResizeType;

  /// Crop type of the image attachment thumbnail.
  ///
  /// Defaults to [center]
  final String /*center|top|bottom|left|right*/
      imageAttachmentThumbnailCropType;

  /// {@template copyWith}
  /// Creates a copy of [StreamMessageWidget] with specified attributes
  /// overridden.
  /// {@endtemplate}
  StreamMessageWidget copyWith({
    Key? key,
    void Function(User)? onMentionTap,
    void Function(Message)? onThreadTap,
    void Function(Message)? onReplyTap,
    Future<void> Function(Message)? onConfirmDeleteTap,
    Widget Function(BuildContext, Message)? editMessageInputBuilder,
    Widget Function(BuildContext, Message)? textBuilder,
    Widget Function(BuildContext, Message)? quotedMessageBuilder,
    @Deprecated('''
    Use [bottomRowBuilderWithDefaultWidget] instead.
    Will be removed in the next major version.
    ''') Widget Function(BuildContext, Message)? usernameBuilder,
    @Deprecated('''
    Use [bottomRowBuilderWithDefaultWidget] instead.
    Will be removed in the next major version.
    ''') BottomRowBuilder? bottomRowBuilder,
    BottomRowBuilderWithDefaultWidget? bottomRowBuilderWithDefaultWidget,
    @Deprecated('''
    Use [bottomRowBuilderWithDefaultWidget] instead.
    Will be removed in the next major version.
    ''') Widget Function(BuildContext, Message)? deletedBottomRowBuilder,
    void Function(BuildContext, Message)? onMessageActions,
    Message? message,
    StreamMessageThemeData? messageTheme,
    bool? reverse,
    ShapeBorder? shape,
    ShapeBorder? attachmentShape,
    BorderSide? borderSide,
    BorderSide? attachmentBorderSide,
    BorderRadiusGeometry? borderRadiusGeometry,
    BorderRadiusGeometry? attachmentBorderRadiusGeometry,
    EdgeInsetsGeometry? padding,
    EdgeInsets? textPadding,
    EdgeInsetsGeometry? attachmentPadding,
    double? widthFactor,
    DisplayWidget? showUserAvatar,
    bool? showSendingIndicator,
    bool? showReactions,
    bool? allRead,
    bool? showThreadReplyIndicator,
    bool? showInChannelIndicator,
    void Function(User)? onUserAvatarTap,
    void Function(String)? onLinkTap,
    bool? showReactionPicker,
    @Deprecated('Use `showReactionPicker` instead')
    bool? showReactionPickerIndicator,
    @internal bool? showReactionPickerTail,
    List<Read>? readList,
    ShowMessageCallback? onShowMessage,
    bool? showUsername,
    bool? showTimestamp,
    bool? showReplyMessage,
    bool? showThreadReplyMessage,
    bool? showEditMessage,
    bool? showCopyMessage,
    bool? showDeleteMessage,
    bool? showResendMessage,
    bool? showFlagButton,
    bool? showPinButton,
    bool? showPinHighlight,
    Map<String, AttachmentBuilder>? customAttachmentBuilders,
    bool? translateUserAvatar,
    OnQuotedMessageTap? onQuotedMessageTap,
    void Function(Message)? onMessageTap,
    List<StreamMessageAction>? customActions,
    void Function(Message message, Attachment attachment)? onAttachmentTap,
    Widget Function(BuildContext, User)? userAvatarBuilder,
    Size? imageAttachmentThumbnailSize,
    String? imageAttachmentThumbnailResizeType,
    String? imageAttachmentThumbnailCropType,
    AttachmentActionsBuilder? attachmentActionsModalBuilder,
  }) {
    assert(
      bottomRowBuilder == null || bottomRowBuilderWithDefaultWidget == null,
      'You can only use one of the two bottom row builders',
    );

    var _bottomRowBuilderWithDefaultWidget =
        bottomRowBuilderWithDefaultWidget ??
            this.bottomRowBuilderWithDefaultWidget;

    _bottomRowBuilderWithDefaultWidget ??= (context, message, defaultWidget) {
      final _bottomRowBuilder = bottomRowBuilder ?? this.bottomRowBuilder;
      if (_bottomRowBuilder != null) {
        return _bottomRowBuilder(context, message);
      }

      return defaultWidget.copyWith(
        onThreadTap: onThreadTap ?? this.onThreadTap,
        usernameBuilder: usernameBuilder ?? this.usernameBuilder,
        deletedBottomRowBuilder:
            deletedBottomRowBuilder ?? this.deletedBottomRowBuilder,
      );
    };

    return StreamMessageWidget(
      key: key ?? this.key,
      onMentionTap: onMentionTap ?? this.onMentionTap,
      onThreadTap: onThreadTap ?? this.onThreadTap,
      onReplyTap: onReplyTap ?? this.onReplyTap,
      onConfirmDeleteTap: onConfirmDeleteTap ?? this.onConfirmDeleteTap,
      editMessageInputBuilder:
          editMessageInputBuilder ?? this.editMessageInputBuilder,
      textBuilder: textBuilder ?? this.textBuilder,
      quotedMessageBuilder: quotedMessageBuilder ?? this.quotedMessageBuilder,
      bottomRowBuilderWithDefaultWidget: _bottomRowBuilderWithDefaultWidget,
      onMessageActions: onMessageActions ?? this.onMessageActions,
      message: message ?? this.message,
      messageTheme: messageTheme ?? this.messageTheme,
      reverse: reverse ?? this.reverse,
      shape: shape ?? this.shape,
      attachmentShape: attachmentShape ?? this.attachmentShape,
      borderSide: borderSide ?? this.borderSide,
      attachmentBorderSide: attachmentBorderSide ?? this.attachmentBorderSide,
      borderRadiusGeometry: borderRadiusGeometry ?? this.borderRadiusGeometry,
      attachmentBorderRadiusGeometry:
          attachmentBorderRadiusGeometry ?? this.attachmentBorderRadiusGeometry,
      padding: padding ?? this.padding,
      textPadding: textPadding ?? this.textPadding,
      attachmentPadding: attachmentPadding ?? this.attachmentPadding,
      widthFactor: widthFactor ?? this.widthFactor,
      showUserAvatar: showUserAvatar ?? this.showUserAvatar,
      showSendingIndicator: showSendingIndicator ?? this.showSendingIndicator,
      showReactions: showReactions ?? this.showReactions,
      showThreadReplyIndicator:
          showThreadReplyIndicator ?? this.showThreadReplyIndicator,
      showInChannelIndicator:
          showInChannelIndicator ?? this.showInChannelIndicator,
      onUserAvatarTap: onUserAvatarTap ?? this.onUserAvatarTap,
      onLinkTap: onLinkTap ?? this.onLinkTap,
      showReactionPicker: showReactionPicker ??
          showReactionPickerIndicator ??
          this.showReactionPicker,
      showReactionPickerTail:
          showReactionPickerTail ?? this.showReactionPickerTail,
      onShowMessage: onShowMessage ?? this.onShowMessage,
      showUsername: showUsername ?? this.showUsername,
      showTimestamp: showTimestamp ?? this.showTimestamp,
      showReplyMessage: showReplyMessage ?? this.showReplyMessage,
      showThreadReplyMessage:
          showThreadReplyMessage ?? this.showThreadReplyMessage,
      showEditMessage: showEditMessage ?? this.showEditMessage,
      showCopyMessage: showCopyMessage ?? this.showCopyMessage,
      showDeleteMessage: showDeleteMessage ?? this.showDeleteMessage,
      showResendMessage: showResendMessage ?? this.showResendMessage,
      showFlagButton: showFlagButton ?? this.showFlagButton,
      showPinButton: showPinButton ?? this.showPinButton,
      showPinHighlight: showPinHighlight ?? this.showPinHighlight,
      customAttachmentBuilders:
          customAttachmentBuilders ?? this.customAttachmentBuilders,
      translateUserAvatar: translateUserAvatar ?? this.translateUserAvatar,
      onQuotedMessageTap: onQuotedMessageTap ?? this.onQuotedMessageTap,
      onMessageTap: onMessageTap ?? this.onMessageTap,
      customActions: customActions ?? this.customActions,
      onAttachmentTap: onAttachmentTap ?? this.onAttachmentTap,
      userAvatarBuilder: userAvatarBuilder ?? this.userAvatarBuilder,
      imageAttachmentThumbnailSize:
          imageAttachmentThumbnailSize ?? this.imageAttachmentThumbnailSize,
      imageAttachmentThumbnailResizeType: imageAttachmentThumbnailResizeType ??
          this.imageAttachmentThumbnailResizeType,
      imageAttachmentThumbnailCropType: imageAttachmentThumbnailCropType ??
          this.imageAttachmentThumbnailCropType,
      attachmentActionsModalBuilder:
          attachmentActionsModalBuilder ?? this.attachmentActionsModalBuilder,
    );
  }

  @override
  _StreamMessageWidgetState createState() => _StreamMessageWidgetState();
}

class _StreamMessageWidgetState extends State<StreamMessageWidget>
    with AutomaticKeepAliveClientMixin<StreamMessageWidget> {
  bool get showThreadReplyIndicator => widget.showThreadReplyIndicator;

  bool get showSendingIndicator => widget.showSendingIndicator;

  bool get isDeleted => widget.message.isDeleted;

  bool get showUsername => widget.showUsername;

  bool get showTimeStamp => widget.showTimestamp;

  bool get showInChannel => widget.showInChannelIndicator;

  /// {@template hasQuotedMessage}
  /// `true` if [StreamMessageWidget.quotedMessage] is not null.
  /// {@endtemplate}
  bool get hasQuotedMessage => widget.message.quotedMessage != null;

  bool get isSendFailed => widget.message.state.isSendingFailed;

  bool get isUpdateFailed => widget.message.state.isUpdatingFailed;

  bool get isDeleteFailed => widget.message.state.isDeletingFailed;

  /// {@template isFailedState}
  /// Whether the message has failed to be sent, updated, or deleted.
  /// {@endtemplate}
  bool get isFailedState => isSendFailed || isUpdateFailed || isDeleteFailed;

  /// {@template isGiphy}
  /// `true` if any of the [message]'s attachments are a giphy.
  /// {@endtemplate}
  bool get isGiphy =>
      widget.message.attachments.any((element) => element.type == 'giphy');

  /// {@template isOnlyEmoji}
  /// `true` if [message.text] contains only emoji.
  /// {@endtemplate}
  bool get isOnlyEmoji => widget.message.text?.isOnlyEmoji == true;

  /// {@template hasNonUrlAttachments}
  /// `true` if any of the [message]'s attachments are a giphy and do not
  /// have a [Attachment.titleLink].
  /// {@endtemplate}
  bool get hasNonUrlAttachments => widget.message.attachments
      .where((it) => it.titleLink == null || it.type == 'giphy')
      .isNotEmpty;

  /// {@template hasUrlAttachments}
  /// `true` if any of the [message]'s attachments are a giphy with a
  /// [Attachment.titleLink].
  /// {@endtemplate}
  bool get hasUrlAttachments => widget.message.attachments
      .any((it) => it.titleLink != null && it.type != 'giphy');

  /// {@template showBottomRow}
  /// Show the [BottomRow] widget if any of the following are `true`:
  /// * [StreamMessageWidget.showThreadReplyIndicator]
  /// * [StreamMessageWidget.showUsername]
  /// * [StreamMessageWidget.showTimestamp]
  /// * [StreamMessageWidget.showInChannelIndicator]
  /// * [StreamMessageWidget.showSendingIndicator]
  /// * [StreamMessageWidget.message.isDeleted]
  /// {@endtemplate}
  bool get showBottomRow =>
      showThreadReplyIndicator ||
      showUsername ||
      showTimeStamp ||
      showInChannel ||
      showSendingIndicator;

  /// {@template isPinned}
  /// Whether [StreamMessageWidget.message] is pinned or not.
  /// {@endtemplate}
  bool get isPinned => widget.message.pinned;

  /// {@template shouldShowReactions}
  /// Should show message reactions if [StreamMessageWidget.showReactions] is
  /// `true`, if there are reactions to show, and if the message is not deleted.
  /// {@endtemplate}
  bool get shouldShowReactions =>
      widget.showReactions &&
      (widget.message.reactionCounts?.isNotEmpty == true) &&
      !widget.message.isDeleted;

  bool get shouldShowReplyAction =>
      widget.showReplyMessage && !isFailedState && widget.onReplyTap != null;

  bool get shouldShowEditAction =>
      widget.showEditMessage &&
      !isDeleteFailed &&
      !widget.message.attachments.any((element) => element.type == 'giphy');

  bool get shouldShowResendAction =>
      widget.showResendMessage && (isSendFailed || isUpdateFailed);

  bool get shouldShowCopyAction =>
      widget.showCopyMessage &&
      !isFailedState &&
      widget.message.text?.trim().isNotEmpty == true;

  bool get shouldShowEditMessage =>
      widget.showEditMessage &&
      !isDeleteFailed &&
      !widget.message.attachments.any((element) => element.type == 'giphy');

  bool get shouldShowThreadReplyAction =>
      widget.showThreadReplyMessage &&
      !isFailedState &&
      widget.onThreadTap != null;

  bool get shouldShowDeleteAction => widget.showDeleteMessage || isDeleteFailed;

  @override
  bool get wantKeepAlive => widget.message.attachments.isNotEmpty;

  late StreamChatThemeData _streamChatTheme;
  late StreamChatState _streamChat;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _streamChatTheme = StreamChatTheme.of(context);
    _streamChat = StreamChat.of(context);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final avatarWidth =
        widget.messageTheme.avatarTheme?.constraints.maxWidth ?? 40;
    final bottomRowPadding =
        widget.showUserAvatar != DisplayWidget.gone ? avatarWidth + 8.5 : 0.5;

    final showReactions = shouldShowReactions;

    return ConditionalParentBuilder(
      builder: (context, child) {
        if (!widget.message.state.isDeleted) {
          return ContextMenuArea(
            verticalPadding: 0,
            builder: (_) => _buildContextMenu(),
            child: child,
          );
        }

        return child;
      },
      child: Material(
        type: MaterialType.transparency,
        child: AnimatedContainer(
          duration: const Duration(seconds: 1),
          color: widget.message.pinned && widget.showPinHighlight
              ? _streamChatTheme.colorTheme.highlight
              : _streamChatTheme.colorTheme.barsBg.withOpacity(0),
          child: Portal(
            child: PlatformWidgetBuilder(
              mobile: (context, child) {
                return InkWell(
                  onTap: () => widget.onMessageTap!(widget.message),
                  onLongPress: widget.message.state.isDeleted
                      ? null
                      : () => onLongPress(context),
                  child: child,
                );
              },
              desktop: (_, child) => MouseRegion(child: child),
              web: (_, child) => MouseRegion(child: child),
              child: Padding(
                padding: widget.padding ?? const EdgeInsets.all(8),
                child: FractionallySizedBox(
                  alignment: widget.reverse
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  widthFactor: widget.widthFactor,
                  child: Builder(builder: (context) {
                    var _bottomRowBuilderWithDefaultWidget =
                        widget.bottomRowBuilderWithDefaultWidget;

                    _bottomRowBuilderWithDefaultWidget ??=
                        (context, message, defaultWidget) {
                      final _bottomRowBuilder = widget.bottomRowBuilder;
                      if (_bottomRowBuilder != null) {
                        return _bottomRowBuilder(context, message);
                      }

                      return defaultWidget.copyWith(
                        onThreadTap: widget.onThreadTap,
                        usernameBuilder: widget.usernameBuilder,
                        deletedBottomRowBuilder: widget.deletedBottomRowBuilder,
                      );
                    };

                    return MessageWidgetContent(
                      streamChatTheme: _streamChatTheme,
                      showUsername: showUsername,
                      showTimeStamp: showTimeStamp,
                      showThreadReplyIndicator: showThreadReplyIndicator,
                      showSendingIndicator: showSendingIndicator,
                      showInChannel: showInChannel,
                      isGiphy: isGiphy,
                      isOnlyEmoji: isOnlyEmoji,
                      hasUrlAttachments: hasUrlAttachments,
                      messageTheme: widget.messageTheme,
                      reverse: widget.reverse,
                      message: widget.message,
                      hasNonUrlAttachments: hasNonUrlAttachments,
                      shouldShowReactions: shouldShowReactions,
                      hasQuotedMessage: hasQuotedMessage,
                      textPadding: widget.textPadding,
                      attachmentBuilders: widget.attachmentBuilders,
                      attachmentPadding: widget.attachmentPadding,
                      avatarWidth: avatarWidth,
                      bottomRowPadding: bottomRowPadding,
                      isFailedState: isFailedState,
                      isPinned: isPinned,
                      messageWidget: widget,
                      showBottomRow: showBottomRow,
                      showPinHighlight: widget.showPinHighlight,
                      showReactionPickerTail: widget.showReactionPickerTail,
                      showReactions: showReactions,
                      onReactionsTap: () => _showMessageReactionsModal(context),
                      showUserAvatar: widget.showUserAvatar,
                      streamChat: _streamChat,
                      translateUserAvatar: widget.translateUserAvatar,
                      shape: widget.shape,
                      borderSide: widget.borderSide,
                      borderRadiusGeometry: widget.borderRadiusGeometry,
                      textBuilder: widget.textBuilder,
                      quotedMessageBuilder: widget.quotedMessageBuilder,
                      onLinkTap: widget.onLinkTap,
                      onMentionTap: widget.onMentionTap,
                      onQuotedMessageTap: widget.onQuotedMessageTap,
                      bottomRowBuilderWithDefaultWidget:
                          _bottomRowBuilderWithDefaultWidget,
                      onUserAvatarTap: widget.onUserAvatarTap,
                      userAvatarBuilder: widget.userAvatarBuilder,
                    );
                  }),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildContextMenu() {
    final channel = StreamChannel.of(context).channel;

    return [
      if (widget.showReactionPicker)
        StreamChatContextMenuItem(
          child: StreamChannel(
            channel: channel,
            child: ContextMenuReactionPicker(
              message: widget.message,
            ),
          ),
        ),
      if (shouldShowReplyAction) ...[
        StreamChatContextMenuItem(
          leading: StreamSvgIcon.reply(),
          title: Text(context.translations.replyLabel),
          onClick: () {
            Navigator.of(context, rootNavigator: true).pop();
            widget.onReplyTap!(widget.message);
          },
        ),
      ],
      if (shouldShowThreadReplyAction)
        StreamChatContextMenuItem(
          leading: StreamSvgIcon.thread(),
          title: Text(context.translations.threadReplyLabel),
          onClick: () {
            Navigator.of(context, rootNavigator: true).pop();
            widget.onThreadTap!(widget.message);
          },
        ),
      if (shouldShowCopyAction)
        StreamChatContextMenuItem(
          leading: StreamSvgIcon.copy(),
          title: Text(context.translations.copyMessageLabel),
          onClick: () {
            Navigator.of(context, rootNavigator: true).pop();
            final text = widget.message.text;
            if (text != null) Clipboard.setData(ClipboardData(text: text));
          },
        ),
      if (shouldShowEditAction) ...[
        StreamChatContextMenuItem(
          leading: StreamSvgIcon.edit(color: Colors.grey),
          title: Text(context.translations.editMessageLabel),
          onClick: () {
            Navigator.of(context, rootNavigator: true).pop();
            showModalBottomSheet(
              context: context,
              elevation: 2,
              clipBehavior: Clip.hardEdge,
              isScrollControlled: true,
              backgroundColor:
                  StreamMessageInputTheme.of(context).inputBackgroundColor,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              builder: (_) => EditMessageSheet(
                message: widget.message,
                channel: StreamChannel.of(context).channel,
                editMessageInputBuilder: widget.editMessageInputBuilder,
              ),
            );
          },
        ),
      ],
      if (widget.showPinButton)
        StreamChatContextMenuItem(
          leading: StreamSvgIcon.pin(
            color: Colors.grey,
            size: 24,
          ),
          title: Text(
            context.translations.togglePinUnpinText(
              pinned: widget.message.pinned,
            ),
          ),
          onClick: () async {
            Navigator.of(context, rootNavigator: true).pop();
            try {
              if (!widget.message.pinned) {
                await channel.pinMessage(widget.message);
              } else {
                await channel.unpinMessage(widget.message);
              }
            } catch (e) {
              throw Exception(e);
            }
          },
        ),
      if (shouldShowResendAction)
        StreamChatContextMenuItem(
          leading: StreamSvgIcon.iconSendMessage(),
          title: Text(
            context.translations.toggleResendOrResendEditedMessage(
              isUpdateFailed: widget.message.state.isUpdatingFailed,
            ),
          ),
          onClick: () {
            Navigator.of(context, rootNavigator: true).pop();
            final isUpdateFailed = widget.message.state.isUpdatingFailed;
            final channel = StreamChannel.of(context).channel;
            if (isUpdateFailed) {
              channel.updateMessage(widget.message);
            } else {
              channel.sendMessage(widget.message);
            }
          },
        ),
      if (shouldShowDeleteAction)
        StreamChatContextMenuItem(
          leading: StreamSvgIcon.delete(color: Colors.red),
          title: Text(
            context.translations.deleteMessageLabel,
            style: const TextStyle(color: Colors.red),
          ),
          onClick: () async {
            Navigator.of(context, rootNavigator: true).pop();
            final deleted = await showDialog<bool?>(
              context: context,
              barrierDismissible: false,
              builder: (_) => const DeleteMessageDialog(),
            );
            if (deleted == true) {
              try {
                final onConfirmDeleteTap = widget.onConfirmDeleteTap;
                if (onConfirmDeleteTap != null) {
                  await onConfirmDeleteTap(widget.message);
                } else {
                  await StreamChannel.of(context)
                      .channel
                      .deleteMessage(widget.message);
                }
              } catch (e) {
                showDialog(
                  context: context,
                  builder: (_) => const MessageDialog(),
                );
              }
            }
          },
        ),
      ...widget.customActions.map(
        (e) => StreamChatContextMenuItem(
          leading: e.leading,
          title: e.title,
          onClick: () => e.onTap?.call(widget.message),
        ),
      ),
    ];
  }

  void _showMessageReactionsModal(BuildContext context) {
    final channel = StreamChannel.of(context).channel;

    showDialog(
      useRootNavigator: false,
      context: context,
      useSafeArea: false,
      barrierColor: _streamChatTheme.colorTheme.overlay,
      builder: (context) => StreamChannel(
        channel: channel,
        child: StreamMessageReactionsModal(
          showReactionPicker: widget.showReactionPicker,
          messageWidget: widget.copyWith(
            key: const Key('MessageWidget'),
            message: widget.message.copyWith(
              text: (widget.message.text?.length ?? 0) > 200
                  ? '${widget.message.text!.substring(0, 200)}...'
                  : widget.message.text,
            ),
            showReactions: false,
            showUsername: false,
            showTimestamp: false,
            translateUserAvatar: false,
            showSendingIndicator: false,
            padding: EdgeInsets.zero,
            // Show the tail if the reaction picker is visible.
            showReactionPickerTail: widget.showReactionPicker,
            showPinHighlight: false,
            showUserAvatar:
                widget.message.user!.id == channel.client.state.currentUser!.id
                    ? DisplayWidget.gone
                    : DisplayWidget.show,
          ),
          onUserAvatarTap: widget.onUserAvatarTap,
          messageTheme: widget.messageTheme,
          reverse: widget.reverse,
          message: widget.message,
        ),
      ),
    );
  }

  void onLongPress(BuildContext context) {
    if (widget.message.isEphemeral || widget.message.state.isOutgoing) {
      return;
    }

    if (widget.onMessageActions != null) {
      return widget.onMessageActions!(context, widget.message);
    }

    return _showMessageActionModalBottomSheet(context);
  }

  void _showMessageActionModalBottomSheet(BuildContext context) {
    final channel = StreamChannel.of(context).channel;

    showDialog(
      useRootNavigator: false,
      context: context,
      useSafeArea: false,
      barrierColor: _streamChatTheme.colorTheme.overlay,
      builder: (context) {
        return StreamChannel(
          channel: channel,
          child: MessageActionsModal(
            messageWidget: widget.copyWith(
              key: const Key('MessageWidget'),
              message: widget.message.copyWith(
                text: (widget.message.text?.length ?? 0) > 200
                    ? '${widget.message.text!.substring(0, 200)}...'
                    : widget.message.text,
              ),
              showReactions: false,
              showUsername: false,
              showTimestamp: false,
              translateUserAvatar: false,
              showSendingIndicator: false,
              padding: EdgeInsets.zero,
              // Show both the tail and indicator if the indicator is shown.
              showReactionPickerTail: widget.showReactionPickerIndicator,
              showPinHighlight: false,
              showUserAvatar: widget.message.user!.id ==
                      channel.client.state.currentUser!.id
                  ? DisplayWidget.gone
                  : DisplayWidget.show,
            ),
            onCopyTap: (message) {
              final text = message.text;
              if (text != null) Clipboard.setData(ClipboardData(text: text));
            },
            messageTheme: widget.messageTheme,
            reverse: widget.reverse,
            showDeleteMessage: shouldShowDeleteAction,
            onConfirmDeleteTap: widget.onConfirmDeleteTap,
            message: widget.message,
            editMessageInputBuilder: widget.editMessageInputBuilder,
            onReplyTap: widget.onReplyTap,
            onThreadReplyTap: widget.onThreadTap,
            showResendMessage: shouldShowResendAction,
            showCopyMessage: shouldShowCopyAction,
            showEditMessage: shouldShowEditAction,
            showReactionPicker: widget.showReactionPickerIndicator,
            showReplyMessage: shouldShowReplyAction,
            showThreadReplyMessage: shouldShowThreadReplyAction,
            showFlagButton: widget.showFlagButton,
            showPinButton: widget.showPinButton,
            customActions: widget.customActions,
          ),
        );
      },
    );
  }
}
