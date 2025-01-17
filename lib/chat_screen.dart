import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final model = GenerativeModel(
    model: 'gemini-1.5-flash',
    // model: 'tunedModels/testmodel-whfi5fwz2qfg',
    //TODO: Replace APIKEY-HERE with your API key from aistudio.google.com
    apiKey: "APIKEY-HERE",
    generationConfig: GenerationConfig(maxOutputTokens: 256),
  );

  late ChatSession chat;

  List<Message> history = [];

  bool _isLoading = false;
  String _errorMessage = '';

  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  Future<void> sendMessage(String message) async {
    var content = Content.text(message);
    try {
      setState(() {
        _errorMessage = '';
        history.add(Message(text: message, fromUser: true));
      });
      final response = await chat.sendMessage(content);

      setState(() {
        _isLoading = false;
        history.add(Message(text: response.text!, fromUser: false));
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
        history.add(Message(text: _errorMessage, fromUser: false));
      });
    }
  }

  @override
  void initState() {
    super.initState();
    chat = model.startChat();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            Expanded(
                child: ListView.builder(
              controller: _scrollController,
              itemBuilder: (context, idx) {
                final content = history[idx];
                return MessageWidget(
                  text: content.text,
                  // image: content.image,
                  isFromUser: content.fromUser,
                );
              },
              itemCount: history.length,
            )),
            Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      SizedBox(
                        height: 8,
                        child: _isLoading
                            ? const Center(child: LinearProgressIndicator())
                            : const SizedBox.shrink(),
                      ),
                      TextField(
                        controller: _controller,
                        decoration: const InputDecoration(
                          hintText: 'Type a message...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(18)),
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            vertical: 15,
                            horizontal: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _isLoading
                      ? null
                      : () {
                          if (_controller.text.isNotEmpty) {
                            sendMessage(_controller.text);
                            _controller.clear();
                            setState(() {
                              _isLoading = true;
                            });
                          }
                        },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class MessageWidget extends StatelessWidget {
  const MessageWidget({
    super.key,
    // this.image,
    this.text,
    this.isFromUser,
  });

  // final Image? image;
  final String? text;
  final bool? isFromUser;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: (isFromUser != null && isFromUser!)
          ? MainAxisAlignment.end
          : MainAxisAlignment.start,
      children: [
        Flexible(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 520),
            decoration: BoxDecoration(
              color: isFromUser != null && isFromUser!
                  ? Theme.of(context).colorScheme.primaryContainer
                  : Theme.of(context).colorScheme.tertiaryContainer,
              borderRadius: BorderRadius.circular(18).copyWith(
                bottomLeft:
                    Radius.circular(isFromUser != null && isFromUser! ? 18 : 0),
                bottomRight: Radius.circular(
                    isFromUser != null && !isFromUser! ? 18 : 0),
                topLeft: const Radius.circular(18),
                topRight: const Radius.circular(18),
              ),
            ),
            padding: const EdgeInsets.symmetric(
              vertical: 15,
              horizontal: 20,
            ),
            margin: const EdgeInsets.only(bottom: 8),
            child: Column(
              children: [
                if (text case final text?) MarkdownBody(data: text),
                // if (image case final image?) image,
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class Message {
  const Message({
    required this.text,
    this.fromUser = false,
  });

  final String text;
  final bool fromUser;
}
