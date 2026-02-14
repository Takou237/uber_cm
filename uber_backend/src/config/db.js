const { Pool } = require('pg');
require('dotenv').config();

// Ici, on crée la connexion avec les infos du fichier .env
const pool = new Pool({
  user: process.env.DB_USER,
  host: process.env.DB_HOST,
  database: process.env.DB_DATABASE,
  password: process.env.DB_PASSWORD,
  port: process.env.DB_PORT,
});

// Ce petit bout de code sert à vérifier si la connexion marche
pool.connect((err, client, release) => {
  if (err) {
    return console.error('Erreur de connexion à PostgreSQL :', err.stack);
  }
  console.log('✅ Connecté avec succès à la base de données PostgreSQL !');
  release();
});

module.exports = pool;