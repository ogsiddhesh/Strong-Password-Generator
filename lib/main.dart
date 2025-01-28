import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Password Generator',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacity;
  String _password = '';
  bool _generating = false; // Track password generation state

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _opacity = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    ));
    _controller.forward(); // Start initial animation
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _generatePassword() {
    const chars =
        'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#\$%^&*()';
    Random rnd = Random();
    return String.fromCharCodes(Iterable.generate(
        10, (_) => chars.codeUnitAt(rnd.nextInt(chars.length))));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Password Generator'),
      ),
      body: Center(
        child: FadeTransition(
          opacity: _opacity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Text(
                'Sidd App',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (!_generating) { // Prevent multiple clicks during generation
                    setState(() {
                      _generating = true; // Set generating to true
                      _password = ''; // Clear previous password
                    });

                    _controller.reverse().then((_) { // Reverse animation
                      setState(() {
                        _password = _generatePassword(); // Generate password
                        _generating = false; // Set generating to false
                      });
                      _controller.forward(); // Start animation to show password
                    });
                  }
                },
                child: const Text('Generate Password'),
              ),
              const SizedBox(height: 20),
              AnimatedSwitcher( // Animate password visibility
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (Widget child, Animation<double> animation) {
                  return FadeTransition(
                    opacity: animation,
                    child: child,
                  );
                },
                child: Text(
                  _password,
                  key: ValueKey<String>(_password), // Key for AnimatedSwitcher
                  style: const TextStyle(fontSize: 20),
                ),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: _password));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Password copied!')),
                  );
                },
                child: const Text('Copy'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}