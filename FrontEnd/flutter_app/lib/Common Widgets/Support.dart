import 'package:flutter/material.dart';

class SupportPage extends StatefulWidget {
  const SupportPage({Key? key}) : super(key: key);

  @override
  _SupportPageState createState() => _SupportPageState();
}

class _SupportPageState extends State<SupportPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Support'),
        backgroundColor: Color.fromARGB(255, 56, 5, 97),
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/background.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: SingleChildScrollView(
          padding:const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text('How can we help you?', style: Theme.of(context).textTheme.displaySmall),
              const SizedBox(height: 30),
              Text('Your Name', style: Theme.of(context).textTheme.headlineSmall),
              TextField(
                controller: _nameController,
                decoration:const InputDecoration(
                  hintText: 'Enter your name',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                ),
              ),
             const SizedBox(height: 20),
              Text( 'Your Email', style: Theme.of(context).textTheme.headlineSmall),
             const TextField(
                decoration: InputDecoration(
                  hintText: 'Enter your email',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                ),
              ),
              
                      SizedBox(height: 20),

              Text('Your Message', style: Theme.of(context).textTheme.headlineSmall),
              TextField(
                controller: _messageController,
                maxLines: 9, 
                decoration:const InputDecoration(
                  hintText: 'Enter your message',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                ),
              ),
             const SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: ()async {
                    await Future.delayed(const Duration(seconds: 1));
                    Navigator.pop(context);
                    // add scaffold messanger showing its success
                    ScaffoldMessenger.of(context).showSnackBar(
                     const  SnackBar(
                        content: Text('Message sent successfully'),
                      ),
                    );

                  },
                  child: Text('Submit'),
                ),
              ),
            const SizedBox(height: 310),],
          ),
        ),
      ),
    );
  }
}
