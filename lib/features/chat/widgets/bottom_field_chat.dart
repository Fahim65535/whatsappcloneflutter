// ignore_for_file: use_build_context_synchronously

import 'dart:io';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:enough_giphy_flutter/enough_giphy_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:whatsapp_fullstack/common/enums/enums.dart';
import 'package:whatsapp_fullstack/common/utils/color.dart';
import 'package:whatsapp_fullstack/common/utils/utils.dart';
import 'package:whatsapp_fullstack/common/widgets/message_reply_preview.dart';
import 'package:whatsapp_fullstack/features/chat/controller/chat_controller.dart';
import 'package:whatsapp_fullstack/provider/mesage_reply_provider.dart';

class BottomFieldChat extends ConsumerStatefulWidget {
  final String receiverUserId;

  const BottomFieldChat({
    Key? key,
    required this.receiverUserId,
  }) : super(key: key);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _BottomFieldChatState();
}

class _BottomFieldChatState extends ConsumerState<BottomFieldChat> {
  bool showSendbutton = false;
  final _messageController = TextEditingController();
  bool isshowEmojiContainer = false;
  FocusNode focusNode = FocusNode();
  FlutterSoundRecorder? _soundrecorder;
  bool isRecordingInit = false;
  bool isRecording = false;

  @override
  void initState() {
    super.initState();
    _soundrecorder = FlutterSoundRecorder();
    openAudio();
  }

  void openAudio() async {
    final status = await Permission.microphone.request();
    if (status != PermissionStatus.granted) {
      throw RecordingPermissionException('Mic permission denied');
    }
    await _soundrecorder!.openRecorder();
    isRecordingInit = true;
  }

  void sendTextMessage() async {
    if (showSendbutton) {
      ref.read(chatControllerProvider).sendtextMessage(
            context,
            _messageController.text.trim(),
            widget.receiverUserId,
          );
      setState(() {
        _messageController.text = '';
      });
    } else {
      var tempDir = await getTemporaryDirectory();
      var path = '${tempDir.path}/flutter_sound.aac';

      if (!isRecordingInit) {
        return;
      }

      if (isRecording) {
        await _soundrecorder!.stopRecorder();
        sendFileMessage(File(path), MessageEnum.audio);
      } else {
        await _soundrecorder!.startRecorder(
          toFile: path,
        );
      }

      setState(() {
        isRecording = !isRecording;
      });
    }
  }

  void sendFileMessage(File file, MessageEnum messageEnum) {
    ref.read(chatControllerProvider).sendFileMessage(
          context,
          widget.receiverUserId,
          file,
          messageEnum,
        );
  }

  void selectImage() async {
    File? image = await pickImageFromGallery(context);

    if (image != null) {
      sendFileMessage(image, MessageEnum.image);
    }
  }

  void selectVideo() async {
    File? video = await pickVideoFromGallery(context);

    if (video != null) {
      sendFileMessage(video, MessageEnum.video);
    }
  }

  void selectGIF() async {
    final gif = await pickGIF(context);

    if (gif != null) {
      ref.read(chatControllerProvider).sendGIFmessage(
            context,
            gif.url,
            widget.receiverUserId,
          );
    }
  }

  void showEmojiContainer() {
    setState(() {
      isshowEmojiContainer = true;
    });
  }

  void hideEmojiContainer() {
    setState(() {
      isshowEmojiContainer = false;
    });
  }

  void showKeyboard() => focusNode.requestFocus();

  void hideKeyboard() => focusNode.unfocus();

  void toggleEmojiKeyboardContainer() {
    if (isshowEmojiContainer) {
      showKeyboard();
      hideEmojiContainer();
    } else {
      hideKeyboard();
      showEmojiContainer();
    }
  }

  @override
  void dispose() {
    super.dispose();
    _messageController.dispose();
    _soundrecorder!.closeRecorder();
    isRecordingInit = false;
  }

  @override
  Widget build(BuildContext context) {
    final messageReply = ref.watch(messageReplyProvider);
    final isShowMessageReply = messageReply != null;
    return Column(
      children: [
        isShowMessageReply ? const MessageReplyPreview() : const SizedBox(),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                focusNode: focusNode,
                controller: _messageController,
                onChanged: (val) {
                  if (val.isNotEmpty) {
                    setState(() {
                      showSendbutton = true;
                    });
                  } else {
                    setState(() {
                      showSendbutton = false;
                    });
                  }
                },
                decoration: InputDecoration(
                  hintText: 'Message',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20.0),
                    borderSide: const BorderSide(
                      width: 0,
                      style: BorderStyle.none,
                    ),
                  ),
                  contentPadding: const EdgeInsets.all(10),
                  fillColor: mobileChatBoxColor,
                  filled: true,
                  prefixIcon: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: SizedBox(
                      width: 100,
                      child: Row(
                        children: [
                          IconButton(
                            onPressed: toggleEmojiKeyboardContainer,
                            icon: const Icon(Icons.emoji_emotions),
                            color: Colors.grey,
                          ),
                          IconButton(
                            onPressed: selectGIF,
                            icon: const Icon(Icons.gif),
                            color: Colors.grey,
                          ),
                        ],
                      ),
                    ),
                  ),
                  suffixIcon: SizedBox(
                    width: 100,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        IconButton(
                          onPressed: selectVideo,
                          icon: const Icon(Icons.attach_file),
                          color: Colors.grey,
                        ),
                        IconButton(
                          onPressed: selectImage,
                          icon: const Icon(Icons.camera_alt),
                          color: Colors.grey,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                top: 4,
                bottom: 6,
                left: 4,
                right: 2,
              ),
              child: CircleAvatar(
                backgroundColor: const Color(0xFF128C7E),
                radius: 25,
                child: GestureDetector(
                  onTap: sendTextMessage,
                  child: Icon(
                    showSendbutton
                        ? Icons.send
                        : isRecording
                            ? Icons.close
                            : Icons.mic,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
        isshowEmojiContainer
            ? SizedBox(
                height: 210,
                child: EmojiPicker(
                  onEmojiSelected: (category, emoji) {
                    setState(() {
                      _messageController.text =
                          _messageController.text + emoji.emoji;
                    });

                    if (!showSendbutton) {
                      setState(() {
                        showSendbutton = true;
                      });
                    }
                  },
                ),
              )
            : const SizedBox(),
      ],
    );
  }
}
