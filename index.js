const express = require('express');
const mongoose = require('mongoose');
const multer = require('multer');
const path = require('path');

const app = express();
const PORT = 8889;

app.use(express.json());
app.use('/uploads', express.static('uploads'));

// ----------------------
// 1️⃣ Connexion MongoDB
// ----------------------
mongoose.connect('mongodb+srv://grounmoetezhechmi_db_user:LB6hA4pw3X7S4YnQ@football-academy-cluste.eqr02mk.mongodb.net/?retryWrites=true&w=majority&appName=football-academy-cluster', {
  useNewUrlParser: true,
  useUnifiedTopology: true,
})
.then(() => console.log('✅ Connecté à MongoDB'))
.catch((err) => console.error('❌ Erreur MongoDB :', err));

// ----------------------
// 2️⃣ Définition des modèles
// ----------------------
const movieSchema = new mongoose.Schema({
  title: { type: String, required: true },
  image: { type: String, required: true },
});

const userSchema = new mongoose.Schema({
  username: { type: String, required: true },
  email:    { type: String, required: true, unique: true },
  password: { type: String, required: true },
});

const Movie = mongoose.model('Movie', movieSchema);
const User = mongoose.model('User', userSchema);

// ----------------------
// 3️⃣ Configuration Multer
// ----------------------
const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    cb(null, 'uploads/');
  },
  filename: (req, file, cb) => {
    cb(null, Date.now() + path.extname(file.originalname));
  },
});
const upload = multer({ storage });

// ----------------------
// 4️⃣ Routes Movies
// ----------------------
app.get('/movies', async (req, res) => {
  try {
    const movies = await Movie.find();
    res.json(movies);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.post('/movies', upload.single('image'), async (req, res) => {
  const { title } = req.body;
  const image = req.file ? `/uploads/${req.file.filename}` : null;

  if (!title || !image) {
    return res.status(400).json({ error: "Le titre et l'image sont requis" });
  }

  try {
    const movie = new Movie({ title, image });
    await movie.save();
    res.status(201).json(movie);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// ----------------------
// 5️⃣ Routes Auth
// ----------------------
app.post('/signup', async (req, res) => {
  const { username, email, password } = req.body;

  try {
    const existingUser = await User.findOne({ email });
    if (existingUser) {
      return res.status(400).json({ message: 'Email already exists' });
    }

    const newUser = new User({ username, email, password });
    await newUser.save();

    res.status(201).json({ message: 'User created successfully', userId: newUser._id });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.post('/signin', async (req, res) => {
  const { email, password } = req.body;

  try {
    const user = await User.findOne({ email });

    if (!user) return res.status(404).json({ error: 'User not found' });
    if (user.password !== password) return res.status(401).json({ message: 'Invalid credentials' });

    res.status(200).json({ message: 'Login successful', userId: user._id });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// ----------------------
// 6️⃣ Démarrage du serveur
// ----------------------
app.listen(PORT, () => {
  console.log(`🚀 Server running on http://localhost:${PORT}`);
});
