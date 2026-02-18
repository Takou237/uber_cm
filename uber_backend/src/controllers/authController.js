const axios = require('axios');
const db = require('../config/db'); 

// ==========================================
// 1. CONFIGURATION BREVO (API KEY)
// ==========================================
const BREVO_API_KEY = process.env.BREVO_API_KEY;

// ==========================================
// 2. FONCTION : DEMANDE DE CODE (OTP)
// ==========================================
exports.requestOTP = async (req, res) => {
    const { phone, name, email } = req.body;
    const otpCode = Math.floor(1000 + Math.random() * 9000).toString();

    try {
        // Enregistrement en base de données
        const userCheck = await db.query('SELECT * FROM users WHERE phone = $1', [phone]);

        if (userCheck.rows.length === 0) {
            await db.query(
                'INSERT INTO users (phone, name, email, otp_code, role) VALUES ($1, $2, $3, $4, $5)',
                [phone, name, email, otpCode, 'client']
            );
            console.log("NOUVEL UTILISATEUR CRÉÉ :", insertResult.rows[0]);
        } else {
            await db.query('UPDATE users SET otp_code = $1 WHERE phone = $2', [otpCode, phone]);
        }

        // ENVOI DE L'EMAIL VIA L'API BREVO (Port 443 - Autorisé par Railway)
        await axios.post('https://api.brevo.com/v3/smtp/email', {
            sender: { name: "Uber CM", email: "daviladutau@gmail.com" }, // Ton email Brevo
            to: [{ email: email, name: name }],
            subject: "Votre code de vérification Uber CM",
            htmlContent: `<h4>Bonjour ${name},</h4><p>Votre code de vérification est : <strong>${otpCode}</strong></p>`
        }, {
            headers: {
                'api-key': BREVO_API_KEY,
                'Content-Type': 'application/json'
            }
        });
        
        try {
            const resDB = await db.query('INSERT INTO users ...');
            console.log("Résultat SQL :", resDB.rowCount, "ligne insérée");
        } catch (dbErr) {
            console.error("DÉTAIL ERREUR SQL :", dbErr);
        }

        console.log(`📧 OTP envoyé via Brevo à ${email}`);
        res.status(200).json({ success: true, message: "Code envoyé par email" });

    } catch (err) {
        console.error("❌ Erreur requestOTP:", err.response ? err.response.data : err.message);
        res.status(500).json({ success: false, message: "Erreur lors de l'envoi du code" });
    }
};

// ==========================================
// 3. FONCTION : VÉRIFICATION DU CODE (OTP)
// ==========================================
exports.verifyOTP = async (req, res) => {
    const { phone, code } = req.body;
    try {
        const result = await db.query(
            'SELECT * FROM users WHERE phone = $1 AND otp_code = $2', 
            [phone, code]
        );

        if (result.rows.length > 0) {
            await db.query('UPDATE users SET otp_code = NULL WHERE phone = $1', [phone]);
            console.log(`✅ Code validé pour ${phone}`);
            return res.status(200).json({ success: true, message: "Vérification réussie" });
        } else {
            return res.status(400).json({ success: false, message: "Code incorrect" });
        }
    } catch (err) {
        console.error("❌ Erreur verifyOTP:", err);
        return res.status(500).json({ success: false, message: "Erreur serveur" });
    }
};