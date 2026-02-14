const express = require('express');
const cors = require('cors');
require('dotenv').config();
const db = require('./config/db'); 
const authRoutes = require('./routes/authRoutes');

const app = express();

// Middlewares
app.use(cors());
app.use(express.json()); 

// Routes
app.use('/api/auth', authRoutes);

// Route de test
app.get('/', (req, res) => {
  res.send('Le serveur Uber_CM fonctionne !');
});

// Configuration du Port pour Railway
const PORT = process.env.PORT || 5000;

// Une seule écoute propre utilisant "app"
app.listen(PORT, '0.0.0.0', () => {
    console.log(`✅ Serveur Uber_CM lancé avec succès sur le port ${PORT}`);
});
