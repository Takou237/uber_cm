const { Client, LocalAuth } = require('whatsapp-web.js');
const qrcode = require('qrcode-terminal');
const nodemailer = require('nodemailer');
const db = require('../config/db'); 

// ==========================================
// 1. CONFIGURATION WHATSAPP (STABLE)
// ==========================================
const client = new Client({
    authStrategy: new LocalAuth({
        dataPath: './sessions' 
    }),
    webVersionCache: {
        type: 'remote',
        remotePath: 'https://raw.githubusercontent.com/wppconnect-team/wa-version/main/html/2.2412.54.html',
        strict: false,
    },
    puppeteer: {
        headless: true,
        args: [
            '--no-sandbox',
            '--disable-setuid-sandbox',
            '--disable-dev-shm-usage',
            '--disable-extensions'
        ],
    }
});

client.on('qr', (qr) => {
    qrcode.generate(qr, { small: true });
    console.log('📢 [WhatsApp] Nouveau QR Code généré. Scannez-le !');
});

client.on('ready', () => {
    console.log('✅ [WhatsApp] Client prêt et connecté !');
});

client.initialize();

// ==========================================
// 2. CONFIGURATION EMAIL (GMAIL)
// ==========================================
const transporter = nodemailer.createTransport({
    service: 'gmail',
    auth: {
        user: 'ebooks.ndemou@gmail.com',
        pass: 'grvt cnru qmun hcau' 
    }
});

// ==========================================
// 3. FONCTION : DEMANDE DE CODE (OTP)
// ==========================================
exports.requestOTP = async (req, res) => {
    const { phone, name, email, method } = req.body;
    const otpCode = Math.floor(1000 + Math.random() * 9000);

    try {
        // Logique UPSERT : On vérifie si l'utilisateur existe
        const userCheck = await db.query('SELECT * FROM users WHERE phone = $1', [phone]);

        if (userCheck.rows.length === 0) {
            // Création si nouveau
            await db.query(
                'INSERT INTO users (phone, name, email, otp_code, role) VALUES ($1, $2, $3, $4, $5)',
                [phone, name, email, otpCode, 'client']
            );
        } else {
            // Mise à jour si existant
            await db.query('UPDATE users SET otp_code = $1 WHERE phone = $2', [otpCode, phone]);
        }

        // ENVOI VIA WHATSAPP
        if (method === 'whatsapp') {
            const cleanPhone = phone.replace(/\D/g, ''); 
            const chatId = `${cleanPhone}@c.us`;
            await client.sendMessage(chatId, `Bonjour ${name}, votre code de vérification Uber CM est : *${otpCode}*`);
            console.log(`📲 OTP envoyé par WhatsApp à ${cleanPhone}`);
        } 
        // ENVOI VIA EMAIL
        else if (method === 'email') {
            await transporter.sendMail({
                from: '"Uber CM" <ebooks.ndemou@gmail.com>',
                to: email,
                subject: 'Votre code de vérification',
                text: `Bonjour ${name}, votre code de vérification est : ${otpCode}`
            });
            console.log(`📧 OTP envoyé par Email à ${email}`);
        }

        res.status(200).json({ success: true, message: "Code envoyé avec succès" });

    } catch (err) {
        console.error("❌ Erreur requestOTP:", err);
        res.status(500).json({ success: false, message: "Erreur lors de l'envoi du code" });
    }
};

// ==========================================
// 4. FONCTION : VÉRIFICATION DU CODE (OTP)
// ==========================================
exports.verifyOTP = async (req, res) => {
    const { phone, code } = req.body;

    try {
        // On vérifie si le couple téléphone/code existe en base
        const result = await db.query(
            'SELECT * FROM users WHERE phone = $1 AND otp_code = $2', 
            [phone, code]
        );

        if (result.rows.length > 0) {
            // Succès : On valide l'utilisateur et on vide le code utilisé
            await db.query('UPDATE users SET otp_code = NULL WHERE phone = $1', [phone]);
            
            console.log(`✅ Code validé pour ${phone}`);
            return res.status(200).json({ 
                success: true, 
                message: "Vérification réussie" 
            });
        } else {
            // Échec : Le code est faux ou expiré
            console.log(`⚠️ Tentative de vérification échouée pour ${phone}`);
            return res.status(400).json({ 
                success: false, 
                message: "Code de vérification incorrect" 
            });
        }
    } catch (err) {
        console.error("❌ Erreur verifyOTP:", err);
        return res.status(500).json({ success: false, message: "Erreur serveur" });
    }
};