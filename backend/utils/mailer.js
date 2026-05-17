const nodemailer = require('nodemailer');

// Returns null when EMAIL_USER / EMAIL_PASS are not configured so the server
// still starts without crashing. In that case the OTP is printed to console.
function createTransport() {
  const user = process.env.EMAIL_USER;
  const pass = process.env.EMAIL_PASS;
  if (!user || !pass) return null;

  return nodemailer.createTransport({
    service: 'gmail',
    auth: { user, pass },
  });
}

/**
 * Send a 6-digit OTP email.
 * Returns true on success, false if email is not configured or sending fails.
 */
async function sendOtp(to, name, otp) {
  const transport = createTransport();
  if (!transport) return false;

  try {
    await transport.sendMail({
      from: `"Costalina" <${process.env.EMAIL_USER}>`,
      to,
      subject: 'Votre code de réinitialisation Costalina',
      html: `
        <div style="font-family:sans-serif;max-width:480px;margin:auto">
          <h2 style="color:#1a6b60">Réinitialisation du mot de passe</h2>
          <p>Bonjour ${name},</p>
          <p>Votre code de vérification est :</p>
          <div style="font-size:36px;font-weight:bold;letter-spacing:8px;
                      color:#1a6b60;padding:20px 0">${otp}</div>
          <p style="color:#888;font-size:13px">
            Ce code expire dans 15 minutes.<br>
            Si vous n'avez pas demandé cette réinitialisation, ignorez cet email.
          </p>
        </div>
      `,
    });
    return true;
  } catch (err) {
    console.error('[mailer] Failed to send OTP email:', err.message);
    return false;
  }
}

module.exports = { sendOtp };