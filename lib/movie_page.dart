import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

import 'entities/movie.dart';

class MoviePage extends StatefulWidget {
  const MoviePage({super.key});

  @override
  State<MoviePage> createState() => _MoviePageState();
}

class _MoviePageState extends State<MoviePage> {
  List<Movie>  movies = [];
  bool isLoading = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchMovies();
  }

  Future<void> addMovieDialog() async {
    TextEditingController titleController = TextEditingController();
    XFile? pickedImage;
    final ImagePicker picker = ImagePicker();

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text("Ajouter un film"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(hintText: "Titre du film"),
                ),
                const SizedBox(height: 10),
                ElevatedButton.icon(
                  onPressed: () async {
                    try {
                      final img = await picker.pickImage(source: ImageSource.gallery);
                      if (img != null) setDialogState(() => pickedImage = img);
                    } catch (e) {
                      print("Erreur galerie: $e");
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Impossible d’ouvrir la galerie")),
                      );
                    }
                  },
                  icon: const Icon(Icons.image),
                  label: const Text("Choisir une image"),
                ),
                if (pickedImage != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Image.file(File(pickedImage!.path), height: 100, fit: BoxFit.cover),
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("Annuler")),
            TextButton(
              onPressed: () async {
                if (titleController.text.isNotEmpty && pickedImage != null) {
                  await uploadMovie(titleController.text, pickedImage!);
                  Navigator.pop(context);
                } else {
                  ScaffoldMessenger.of(context)
                      .showSnackBar(const SnackBar(content: Text("Titre ou image manquants")));
                }
              },
              child: const Text("Enregistrer"),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> uploadMovie(String title,XFile imageFile ) async{
    try {
      final file = File(imageFile.path);
      if (!file.existsSync()) return;

      var request = http.MultipartRequest(
        "POST",
        Uri.parse("https://backend-movies-esws.onrender.com/movies")
      );
      request.fields['title'] = title;
      request.files.add(await http.MultipartFile.fromPath('image', imageFile.path));
      final streamResponse = await request.send();
      final response = await http.Response.fromStream(streamResponse);
      if (response.statusCode ==200 || response.statusCode == 201){
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Film ajouté avec succes")));
        await fetchMovies();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("erreur lors de l'ajout de film")));
      }

    } catch (e){
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("erreur de serveur")));
    }
  }

  Future<void> fetchMovies() async {
    setState(() {
      isLoading = true;
    });
    try {
      final response = await http.get(Uri.parse("https://backend-movies-esws.onrender.com/movies"));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          movies = data.map((json) => Movie.fromJson(json)).toList();

        });
        print(movies);
      }else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("erreur de chargement des films")));
      }
    } catch (e){
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("erreur coté serveur ou network")));
    }finally {
      setState(() {
        isLoading = false;
      });
    }

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:  AppBar(title: Text("Liste des films"),),
      body: isLoading
             ? const Center(child: CircularProgressIndicator())
      : movies.isEmpty
      ? const Center(child: Text("Aucun film pour le moment"),)
      : ListView.builder(
          itemCount: movies.length,
          itemBuilder: (context , index){
            final movie = movies[index];
            return Card(
              margin: EdgeInsets.all(8),
              child: ListTile(
                leading: Image.network("https://backend-movies-esws.onrender.com${movie.image}",
                width: 50,
                fit: BoxFit.cover,
                errorBuilder: (context , error , stack) =>
                  const Icon(Icons.image_not_supported),
                ),
                title: Text(movie.title),

              ),
            );

          },
      ),
      floatingActionButton: FloatingActionButton(
          onPressed: addMovieDialog,
          child: Icon(Icons.add),),

    );
  }
}
