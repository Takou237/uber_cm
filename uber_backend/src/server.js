const express = require('express');
const cors = require('cors');
require('dotenv').config();
const db = require('./config/db'); 
const authRoutes = require('./routes/authRoutes');

const app = express(); // Initialisation de l'application

// Middlewares
app.use(cors());
app.use(express.json()); 

// Routes
app.use('/api/auth', authRoutes);

// Route de test
app.get('/', (req, res) => {
  res.send('Le serveur Uber_CM fonctionne !');
});

// --- ROUTE POUR LES CHAUFFEURS ---
app.get('/chauffeurs/:id', async (req, res) => {
  try {
    const { id } = req.params;
    
    // CORRECTION : On utilise 'db.query' pour correspondre à ton import
    const result = await db.query('SELECT * FROM chauffeurs WHERE id = $1', [id]);
    
    // Si le chauffeur n'existe pas
    if (result.rows.length === 0) {
      return res.status(404).json({ message: "Chauffeur non trouvé" });
    }
    
    // Si on le trouve, on renvoie ses données en JSON à l'application Flutter
    res.json(result.rows[0]);
    
  } catch (error) {
    console.error("Erreur serveur:", error.message);
    res.status(500).json({ message: "Erreur interne du serveur" });
  }
});

// Configuration du Port pour Railway
const PORT = process.env.PORT || 5000;

// Script de réparation automatique de la base de données
const initDB = async () => {
    try {
        console.log("⏳ Vérification de la structure de la base de données...");
        // Cette commande transforme la colonne phone en texte si elle était en nombre
        await db.query(`
            CREATE TABLE IF NOT EXISTS users (
                id SERIAL PRIMARY KEY,
                phone VARCHAR(20) UNIQUE,
                name VARCHAR(255),
                email VARCHAR(255),
                otp_code VARCHAR(10),
                role VARCHAR(50) DEFAULT 'user'
            );
            ALTER TABLE users ALTER COLUMN phone TYPE VARCHAR(20);
        `);
        console.log("✅ Base de données synchronisée (Types VARCHAR vérifiés)");
    } catch (err) {
        console.error("❌ Erreur lors de l'initDB:", err.message);
    }
};

// Démarrage du serveur
app.listen(PORT, '0.0.0.0', async () => {
    await initDB(); // On répare la DB juste après le lancement
    console.log(`✅ Serveur Uber_CM lancé avec succès sur le port ${PORT}`);
});