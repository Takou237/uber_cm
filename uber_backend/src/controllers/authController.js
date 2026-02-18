const axios = require('axios');
const db = require('../config/db'); 

const BREVO_API_KEY = process.env.BREVO_API_KEY;

exports.requestOTP = async (req, res) => {
    const { phone, name, email } = req.body;
    const otpCode = Math.floor(1000 + Math.random() * 9000).toString();

    try {
        // 1. Enregistrement ou mise à jour
        const userCheck = await db.query('SELECT * FROM users WHERE phone = $1', [phone]);

        if (userCheck.rows.length === 0) {
            // INSERT : La colonne created_at se remplira automatiquement grâce au DEFAULT CURRENT_TIMESTAMP
            await db.query(
                'INSERT INTO users (phone, name, email, otp_code, role) VALUES ($1, $2, $3, $4, $5)',
                [phone, name, email, otpCode, 'client']
            );
            console.log(`✅ Nouveau compte créé le ${new Date().toLocaleString()} pour : ${phone}`);
        } else {
            // UPDATE : On met à jour l'OTP
            await db.query('UPDATE users SET otp_code = $1 WHERE phone = $2', [otpCode, phone]);
            console.log(`✅ OTP mis à jour pour : ${phone}`);
        }

        // 2. Envoi de l'email
        try {
            await axios.post('https://api.brevo.com/v3/smtp/email', {
                sender: { name: "Uber CM", email: "daviladutau@gmail.com" },
                to: [{ email: email, name: name }],
                subject: "Votre code de vérification Uber CM",
                htmlContent: `<h4>Bonjour ${name},</h4><p>Votre code est : <strong>${otpCode}</strong></p><p>Demande effectuée le : ${new Date().toLocaleString()}</p>`
            }, {
                headers: {
                    'api-key': BREVO_API_KEY,
                    'Content-Type': 'application/json'
                }
            });
            console.log(`📧 Email envoyé à ${email}`);
        } catch (emailErr) {
            console.error("⚠️ Erreur Brevo :", emailErr.response ? emailErr.response.data : emailErr.message);
        }

        res.status(200).json({ success: true, message: "Opération réussie" });

    } catch (err) {
        console.error("❌ Erreur Base de données :", err.message);
        res.status(500).json({ success: false, message: "Erreur serveur" });
    }
};

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
