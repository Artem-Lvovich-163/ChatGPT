// ignore_for_file: prefer_const_declarations

import 'dart:convert';

import 'package:chattutorial/models/models.dart';
import 'package:flutter/material.dart';

import '../constants/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  bool switcher = true;
  int _counter = 5;
  late bool isLoading;
  final TextEditingController _textEditingController = TextEditingController();
  final _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];

  void decrementCounter() {
    if (_counter > 0) {
      setState(() {
        _counter--;
        if (_counter == 0) {
          switcher = !switcher;
        }
      });
    }
  }

  // Future<void> getSaveCounter() async {
  //   final prefs = await SharedPreferences.getInstance();

  //   if (prefs.containsKey('counter')) {
  //     _counter = prefs.getInt('counter')!;
  //     setState(() {});
  //     if (_counter == 0) {
  //       setState(() {
  //         switcher = false;
  //       });
  //     }
  //   }
  // }

  void _scrollDown() {
    _scrollController.animateTo(_scrollController.position.maxScrollExtent,
        duration: const Duration(microseconds: 300), curve: Curves.easeOut);
  }

  @override
  void initState() {
    //getSaveCounter();
    super.initState();
    isLoading = false;
  }

  //функция вызова api
  Future<String> generateResponse(String promt) async {
    final apiKey = apiSecretKey;
    var url = Uri.http('api.openai.com', '/v1/completions');
    final response = await http.post(url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode({
          'model': 'text-davinci-003',
          'promt': promt,
          'temperature': 0,
          'max-token': 2000,
          'top_p': 1,
          'frequency-penalty': 0.0,
          'presence-penalty': 0.0
        }));
    //decode responce
    Map<String, dynamic> newresponse = jsonDecode(response.body);
    return newresponse['choices'][0]['text'];
  }

  //анимация скролла в поле чата

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: cardColor,
        elevation: 3,
        title: const Text('ChatGPT'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: SafeArea(
          child: Column(
            children: [
              //flexible container
              Flexible(
                child: _buildList(),
              ),
              //индикатор загрузки
              Visibility(
                visible: isLoading,
                child: const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 15),

              //textfield + send button + row
              Row(
                children: [
                  //textField
                  Expanded(
                    child: TextField(
                      textCapitalization: TextCapitalization.sentences,
                      controller: _textEditingController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5),
                          ),
                          focusedBorder: const OutlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.white, width: 1),
                          ),
                          hintText: 'Введите запрос',
                          hintStyle: const TextStyle(color: Colors.white),
                          fillColor: Colors.white),
                    ),
                  ),
                  //Iconbutton send
                  IconButton(
                    onPressed: () {
                      // отобразить запрос юзера
                      setState(() {
                        _messages.add(
                          ChatMessage(
                              text: _textEditingController.text,
                              chatMessageType: ChatMessageType.user),
                        );
                        isLoading = true;
                      });
                      var input = _textEditingController.text;
                      _textEditingController.clear();
                      Future.delayed(const Duration(milliseconds: 50))
                          .then((value) => _scrollDown());

                      // вызвать chat gpt
                      generateResponse(input).then((value) {
                        setState(() {
                          isLoading = false;

                          // отобразить запрос chat gpt

                          _messages.add(ChatMessage(
                              text: value,
                              chatMessageType: ChatMessageType.bot));
                        });
                      });
                      _textEditingController.clear();
                      Future.delayed(const Duration(milliseconds: 50))
                          .then((value) => _scrollDown());

                      // final prefs = await SharedPreferences.getInstance();

                      // prefs.setInt('counter', _counter);
                      //decrementCounter();
                    },
                    icon: const Icon(Icons.send),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              //row 1/25 + button add limit
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Text(
                    '$_counter',
                    style: const TextStyle(color: Colors.white, fontSize: 20),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          switcher ? scaffoldBackgroundColor : Colors.purple,
                    ),
                    onPressed: () {},
                    child: const Text('Добавить лимит'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  ListView _buildList() {
    return ListView.builder(
      itemCount: _messages.length,
      controller: _scrollController,
      itemBuilder: (context, index) {
        var message = _messages[index];
        return ChatMessageWidget(
          text: message.text,
          chatMessageType: message.chatMessageType,
        );
      },
    );
  }
}

class ChatMessageWidget extends StatelessWidget {
  final String text;
  final ChatMessageType chatMessageType;
  const ChatMessageWidget(
      {super.key, required this.text, required this.chatMessageType});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: chatMessageType == ChatMessageType.bot
          ? cardColor
          : scaffoldBackgroundColor,
      child: Row(
        children: [
          chatMessageType == ChatMessageType.bot
              ? Container(
                  margin: const EdgeInsets.only(right: 16),
                  child: CircleAvatar(
                    backgroundColor: const Color.fromRGBO(16, 163, 127, 1),
                    child: Image.asset(
                      'assets/images/logo-gpt.png',
                      color: Colors.white,
                      scale: 1.5,
                    ),
                  ),
                )
              : Container(
                  margin: const EdgeInsets.only(right: 16),
                  child: const Icon(
                    Icons.person,
                    color: Colors.white,
                  ),
                ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    text,
                    style: const TextStyle(color: Colors.white),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
