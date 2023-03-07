import 'package:flutter/material.dart';

import '../constants/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  bool switcher = true;
  int _counter = 3;
  int color = 1;

  void decrementCounter() {
    setState(() {
      _counter--;
      if (_counter == 0) {
        setState(() {
          switcher = !switcher;
        });
      } else if (_counter < 0) {
        setState(() {
          _counter++;
        });
      }
    });
  }

  Future<void> getSaveCounter() async {
    final prefs = await SharedPreferences.getInstance();

    if (prefs.containsKey('counter')) {
      _counter = prefs.getInt('counter')!;
      setState(() {});
    }
  }

  @override
  void initState() {
    getSaveCounter();
    super.initState();
  }

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
                child: Container(),
              ),

              //textfield + send button + row
              Row(
                children: [
                  //textField
                  const Expanded(
                    child: TextField(),
                  ),
                  //Iconbutton send
                  IconButton(
                    onPressed: () async {
                      final prefs = await SharedPreferences.getInstance();
                      decrementCounter();
                      prefs.setInt('counter', _counter);
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
}
