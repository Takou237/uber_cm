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
        const userCheck = await db.query(
            'SELECT * FROM users WHERE phone = $1',
            [phone]
        );

        if (userCheck.rows.length === 0) {

            const insertResult = await db.query(
                `INSERT INTO users (phone, name, email, otp_code, role)
                 VALUES ($1,$2,$3,$4,$5)
                 RETURNING *`,
                [phone, name, email, otpCode, 'client']
            );

            console.log("✅ User créé :", insertResult.rows[0]);

        } else {

            await db.query(
                'UPDATE users SET otp_code = $1 WHERE phone = $2',
                [otpCode, phone]
            );

            console.log("🔄 OTP mis à jour");

        }

        // ENVOI EMAIL (laisse ton code Brevo ici)

        res.status(200).json({
            success: true,
            message: "Code envoyé"
        });

    } catch (err) {
        console.error("❌ requestOTP ERROR:", err);
        res.status(500).json({
            success: false,
            message: "Erreur serveur"
        });
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