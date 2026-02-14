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
    const { phone, name, email, method } = req.body; // 'method' sera ignoré ou forcé sur email
    const otpCode = Math.floor(1000 + Math.random() * 9000);

    try {
        const userCheck = await db.query('SELECT * FROM users WHERE phone = $1', [phone]);

        if (userCheck.rows.length === 0) {
            await db.query(
                'INSERT INTO users (phone, name, email, otp_code, role) VALUES ($1, $2, $3, $4, $5)',
                [phone, name, email, otpCode, 'client']
            );
        } else {
            await db.query('UPDATE users SET otp_code = $1 WHERE phone = $2', [otpCode, phone]);
        }

        // On envoie par EMAIL uniquement (plus fiable sur serveur)
        await transporter.sendMail({
            from: '"Uber CM" <ebooks.ndemou@gmail.com>',
            to: email,
            subject: 'Votre code de vérification',
            text: `Bonjour ${name}, votre code de vérification est : ${otpCode}`
        });
        
        console.log(`📧 OTP envoyé par Email à ${email}`);
        res.status(200).json({ success: true, message: "Code envoyé par email" });

    } catch (err) {
        console.error("❌ Erreur requestOTP:", err);
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