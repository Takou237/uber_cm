const nodemailer = require('nodemailer');
const db = require('../config/db'); 

// ==========================================
// 1. CONFIGURATION EMAIL (GMAIL)
// ==========================================
const transporter = nodemailer.createTransport({
    service: 'gmail',
    auth: {
        user: 'ebooks.ndemou@gmail.com',
        pass: 'grvt cnru qmun hcau' 
    }
});

// ==========================================
// 2. FONCTION : DEMANDE DE CODE (OTP)
// ==========================================
exports.requestOTP = async (req, res) => {
    const { phone, name, email } = req.body;
    const otpCode = Math.floor(1000 + Math.random() * 9000).toString(); // Génère 4 chiffres

    try {
        // Sauvegarde ou mise à jour de l'utilisateur avec le code
        await db.query(
            'INSERT INTO users (phone, name, email, otp_code) VALUES ($1, $2, $3, $4) ON CONFLICT (phone) DO UPDATE SET otp_code = $4',
            [phone, name, email, otpCode]
        );

        // --- MODE TEST : ON N'UTILISE PAS NODEMAILER ICI POUR ÉVITER LE TIMEOUT ---
        console.log("-----------------------------------------");
        console.log(`✅ MODE TEST ACTIVÉ`);
        console.log(`📱 CODE OTP POUR ${phone} : ${otpCode}`);
        console.log("-----------------------------------------");

        // On répond immédiatement à Flutter
        return res.status(200).json({ 
            success: true, 
            message: "Code généré (vérifiez les logs Railway)" 
        });

    } catch (err) {
        console.error("❌ Erreur requestOTP:", err);
        return res.status(500).json({ success: false, message: "Erreur serveur" });
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
            // On efface le code après réussite
            await db.query('UPDATE users SET otp_code = NULL WHERE phone = $1', [phone]);
            console.log(`✅ Code validé avec succès pour ${phone}`);
            return res.status(200).json({ success: true, message: "Vérification réussie" });
        } else {
            return res.status(400).json({ success: false, message: "Code incorrect" });
        }
    } catch (err) {
        console.error("❌ Erreur verifyOTP:", err);
        return res.status(500).json({ success: false, message: "Erreur serveur" });
    }
};