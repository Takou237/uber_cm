const express = require('express');
const cors = require('cors');
require('dotenv').config();
const db = require('./config/db'); 
const authRoutes = require('./routes/authRoutes');

const app = express();

// Middlewares (les outils de base)
app.use(cors());
app.use(express.json()); // Pour que le serveur comprenne le format JSON

app.use('/api/auth', authRoutes);

// Une petite route pour tester si le serveur répond
app.get('/', (req, res) => {
  res.send('Le serveur Uber_CM fonctionne !');
});

const PORT = process.env.PORT || 5000;
server.listen(PORT, '0.0.0.0', () => {
    console.log(`Serveur en ligne sur le port ${PORT}`);
});

app.listen(PORT, () => {
  console.log(`Serveur lancé sur : http://localhost:${PORT}`);
});