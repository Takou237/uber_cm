const PORT = process.env.PORT || 5000;

// Script pour s'assurer que la table est correcte
const initDB = async () => {
    try {
        // On modifie la colonne si elle est en integer, ou on crée la table si elle n'existe pas
        await db.query(`
            CREATE TABLE IF NOT EXISTS users (
                id SERIAL PRIMARY KEY,
                phone VARCHAR(20),
                name VARCHAR(255),
                email VARCHAR(255),
                otp_code VARCHAR(10),
                role VARCHAR(50) DEFAULT 'user'
            );
            ALTER TABLE users ALTER COLUMN phone TYPE VARCHAR(20);
            ALTER TABLE users ALTER COLUMN otp_code TYPE VARCHAR(10);
        `);
        console.log("✅ Base de données synchronisée (Types VARCHAR vérifiés)");
    } catch (err) {
        console.error("❌ Erreur initDB:", err.message);
    }
};

app.listen(PORT, '0.0.0.0', async () => {
    await initDB(); // Lance la vérification au démarrage
    console.log(`✅ Serveur Uber_CM lancé avec succès sur le port ${PORT}`);
});
