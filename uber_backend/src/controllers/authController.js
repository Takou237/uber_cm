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
// --- REMPLACE TON BLOC NODEMAILER PAR ÇA ---
console.log("-----------------------------------------");
console.log(`CODE OTP POUR ${phone} : ${otpCode}`);
console.log("-----------------------------------------");

// On répond DIRECTEMENT à Flutter sans attendre Gmail
return res.status(200).json({ 
  success: true, 
  message: "Mode Test : Code envoyé dans les logs" 
});
// -------------------------------------------

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