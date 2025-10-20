import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:untitled4/DataBaseManager.dart';
import 'package:untitled4/movie_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Notes',
      theme: ThemeData(

        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
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

class _MyHomePageState extends State<MyHomePage> {
  DataBaseManager db = DataBaseManager();
  List<Map<String, dynamic>> notes = [];
  String username = "";

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadNote();
    loadUserName();
  }

  Future<void> loadUserName() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      username = prefs.getString('username') ?? 'utilisateur';
    });
    print(username);
  }

  Future<void> changeUserName() async {
    TextEditingController controller = TextEditingController();
    await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("modifier"),
          content: TextField(controller: controller),
          actions: [
            TextButton(onPressed: () async{
              if (controller.text.isNotEmpty) {
                final prefs = await SharedPreferences.getInstance();
                await prefs.setString("username", controller.text);
                setState(() {
                  username = controller.text;

                });
    }
    },
        child: Text('enregistrer'))
            ],
        ));
  }

  Future<void> deleteNote(int id)async{
    await db.deleteNote(id);
    await loadNote();
  }


  Future<void> loadNote() async {
    final data = await db.getNotes();
    setState(() {
      notes = data;
    });

  }

  Future<void> addNoteDialog() async {
    TextEditingController controller = TextEditingController();
    await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("Nouvelle note"),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(hintText: "le nom de la note"),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text("Annuler")
            ),
            TextButton(
                onPressed: () async{
                  if (controller.text.isNotEmpty){
                    await db.insertNote(controller.text);
                    await loadNote();
                  }
                  Navigator.pop(context);
                },

                child: Text('Enregistrer'))
          ],

        ));
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text('bonjour $username'),
        actions: [
          IconButton(onPressed: changeUserName, icon: Icon(Icons.edit)),
          IconButton(onPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const MoviePage()),
            );
          }, icon: Icon(Icons.list)),

        ],
      ),
      body: notes.isEmpty
      ? const Center(
        child: Text("aucune note pour l'instant !")) :
          ListView.builder(
              itemCount: notes.length,
              itemBuilder: (context, index){
                final note = notes[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: ListTile(
                    title: Text(note['name']),
                    trailing: IconButton(
                        onPressed: (){
                          deleteNote(note['id']);
                        },
                        icon: Icon(Icons.delete)),
                  ),
                );
              }),
     floatingActionButton: FloatingActionButton(
         onPressed: (){
           addNoteDialog();
         },
         child: Icon(Icons.add),
     ),

     // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
