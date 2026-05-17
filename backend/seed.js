require('dotenv').config();
const mongoose = require('mongoose');
const Beach    = require('./models/Beach');
const Alert    = require('./models/Alert');

const beaches = [
  { id:'skanes',             name:'Plage de Skanes',       city:'Monastir', risk:'modere', erosionMeters:-3.2, lat:35.7796, lng:10.8267, lastUpdate:'12 mai 2026',
    photoUrl:'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?w=900&q=70',
    photos:['https://images.unsplash.com/photo-1507525428034-b723cf961d3e?w=900&q=70','https://images.unsplash.com/photo-1519046904884-53103b34b206?w=900&q=70','https://images.unsplash.com/photo-1473116763249-2faaef81ccda?w=900&q=70'] },
  { id:'sayada',             name:'Plage de Sayada',       city:'Monastir', risk:'stable', erosionMeters:-0.4, lat:35.6800, lng:10.8923, lastUpdate:'10 mai 2026',
    photoUrl:'https://images.unsplash.com/photo-1519046904884-53103b34b206?w=900&q=70',
    photos:['https://images.unsplash.com/photo-1519046904884-53103b34b206?w=900&q=70','https://images.unsplash.com/photo-1505228395891-9a51e7e86bf6?w=900&q=70','https://images.unsplash.com/photo-1559827260-dc66d52bef19?w=900&q=70'] },
  { id:'teboulba',           name:'Plage de Teboulba',     city:'Monastir', risk:'modere', erosionMeters:-2.1, lat:35.6486, lng:10.9528, lastUpdate:'09 mai 2026',
    photoUrl:'https://images.unsplash.com/photo-1505228395891-9a51e7e86bf6?w=900&q=70',
    photos:['https://images.unsplash.com/photo-1505228395891-9a51e7e86bf6?w=900&q=70','https://images.unsplash.com/photo-1507525428034-b723cf961d3e?w=900&q=70','https://images.unsplash.com/photo-1473116763249-2faaef81ccda?w=900&q=70'] },
  { id:'kuriat',             name:'Îles Kuriat',            city:'Monastir', risk:'stable', erosionMeters:-0.2, lat:35.8044, lng:11.0258, lastUpdate:'07 mai 2026',
    photoUrl:'https://images.unsplash.com/photo-1559827260-dc66d52bef19?w=900&q=70',
    photos:['https://images.unsplash.com/photo-1559827260-dc66d52bef19?w=900&q=70','https://images.unsplash.com/photo-1519046904884-53103b34b206?w=900&q=70','https://images.unsplash.com/photo-1507525428034-b723cf961d3e?w=900&q=70'] },
  { id:'sousse',             name:'Plage de Sousse',        city:'Sousse',   risk:'eleve',  erosionMeters:-5.8, lat:35.8256, lng:10.6411, lastUpdate:'11 mai 2026',
    photoUrl:'https://images.unsplash.com/photo-1473116763249-2faaef81ccda?w=900&q=70',
    photos:['https://images.unsplash.com/photo-1473116763249-2faaef81ccda?w=900&q=70','https://images.unsplash.com/photo-1505228395891-9a51e7e86bf6?w=900&q=70','https://images.unsplash.com/photo-1559827260-dc66d52bef19?w=900&q=70'] },
  { id:'hammam-sousse',      name:'Plage Hammam Sousse',    city:'Sousse',   risk:'modere', erosionMeters:-2.4, lat:35.8609, lng:10.5927, lastUpdate:'10 mai 2026',
    photoUrl:'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?w=900&q=70',
    photos:['https://images.unsplash.com/photo-1507525428034-b723cf961d3e?w=900&q=70','https://images.unsplash.com/photo-1473116763249-2faaef81ccda?w=900&q=70','https://images.unsplash.com/photo-1519046904884-53103b34b206?w=900&q=70'] },
  { id:'hammamet',           name:'Plage de Hammamet',      city:'Hammamet', risk:'stable', erosionMeters:-0.6, lat:36.3988, lng:10.6131, lastUpdate:'11 mai 2026',
    photoUrl:'https://images.unsplash.com/photo-1519046904884-53103b34b206?w=900&q=70',
    photos:['https://images.unsplash.com/photo-1519046904884-53103b34b206?w=900&q=70','https://images.unsplash.com/photo-1559827260-dc66d52bef19?w=900&q=70','https://images.unsplash.com/photo-1505228395891-9a51e7e86bf6?w=900&q=70'] },
  { id:'nabeul',             name:'Plage de Nabeul',        city:'Nabeul',   risk:'modere', erosionMeters:-1.8, lat:36.4565, lng:10.7353, lastUpdate:'09 mai 2026',
    photoUrl:'https://images.unsplash.com/photo-1473116763249-2faaef81ccda?w=900&q=70',
    photos:['https://images.unsplash.com/photo-1473116763249-2faaef81ccda?w=900&q=70','https://images.unsplash.com/photo-1507525428034-b723cf961d3e?w=900&q=70','https://images.unsplash.com/photo-1519046904884-53103b34b206?w=900&q=70'] },
  { id:'gammarth',           name:'Plage de Gammarth',      city:'Tunis',    risk:'stable', erosionMeters:-0.3, lat:36.9189, lng:10.2869, lastUpdate:'12 mai 2026',
    photoUrl:'https://images.unsplash.com/photo-1559827260-dc66d52bef19?w=900&q=70',
    photos:['https://images.unsplash.com/photo-1559827260-dc66d52bef19?w=900&q=70','https://images.unsplash.com/photo-1505228395891-9a51e7e86bf6?w=900&q=70','https://images.unsplash.com/photo-1473116763249-2faaef81ccda?w=900&q=70'] },
  { id:'sidi-bou-said',      name:'Plage Sidi Bou Saïd',   city:'Tunis',    risk:'eleve',  erosionMeters:-4.1, lat:36.8703, lng:10.3411, lastUpdate:'11 mai 2026',
    photoUrl:'https://images.unsplash.com/photo-1505228395891-9a51e7e86bf6?w=900&q=70',
    photos:['https://images.unsplash.com/photo-1505228395891-9a51e7e86bf6?w=900&q=70','https://images.unsplash.com/photo-1507525428034-b723cf961d3e?w=900&q=70','https://images.unsplash.com/photo-1559827260-dc66d52bef19?w=900&q=70'] },
  { id:'bizerte',            name:'Plage de Bizerte',       city:'Bizerte',  risk:'stable', erosionMeters:-0.5, lat:37.2744, lng:9.8739,  lastUpdate:'08 mai 2026',
    photoUrl:'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?w=900&q=70',
    photos:['https://images.unsplash.com/photo-1507525428034-b723cf961d3e?w=900&q=70','https://images.unsplash.com/photo-1473116763249-2faaef81ccda?w=900&q=70','https://images.unsplash.com/photo-1519046904884-53103b34b206?w=900&q=70'] },
  { id:'raf-raf',            name:'Plage Raf Raf',          city:'Bizerte',  risk:'stable', erosionMeters:-0.1, lat:37.1847, lng:10.1764, lastUpdate:'07 mai 2026',
    photoUrl:'https://images.unsplash.com/photo-1519046904884-53103b34b206?w=900&q=70',
    photos:['https://images.unsplash.com/photo-1519046904884-53103b34b206?w=900&q=70','https://images.unsplash.com/photo-1505228395891-9a51e7e86bf6?w=900&q=70','https://images.unsplash.com/photo-1507525428034-b723cf961d3e?w=900&q=70'] },
  { id:'tabarka',            name:'Plage de Tabarka',       city:'Tabarka',  risk:'modere', erosionMeters:-1.5, lat:36.9543, lng:8.7586,  lastUpdate:'10 mai 2026',
    photoUrl:'https://images.unsplash.com/photo-1559827260-dc66d52bef19?w=900&q=70',
    photos:['https://images.unsplash.com/photo-1559827260-dc66d52bef19?w=900&q=70','https://images.unsplash.com/photo-1473116763249-2faaef81ccda?w=900&q=70','https://images.unsplash.com/photo-1505228395891-9a51e7e86bf6?w=900&q=70'] },
  { id:'sfax',               name:'Plage de Sfax',          city:'Sfax',     risk:'eleve',  erosionMeters:-6.2, lat:34.7478, lng:10.7661, lastUpdate:'09 mai 2026',
    photoUrl:'https://images.unsplash.com/photo-1473116763249-2faaef81ccda?w=900&q=70',
    photos:['https://images.unsplash.com/photo-1473116763249-2faaef81ccda?w=900&q=70','https://images.unsplash.com/photo-1519046904884-53103b34b206?w=900&q=70','https://images.unsplash.com/photo-1507525428034-b723cf961d3e?w=900&q=70'] },
  { id:'mahdia',             name:'Plage de Mahdia',        city:'Mahdia',   risk:'modere', erosionMeters:-2.7, lat:35.5044, lng:11.0622, lastUpdate:'08 mai 2026',
    photoUrl:'https://images.unsplash.com/photo-1505228395891-9a51e7e86bf6?w=900&q=70',
    photos:['https://images.unsplash.com/photo-1505228395891-9a51e7e86bf6?w=900&q=70','https://images.unsplash.com/photo-1559827260-dc66d52bef19?w=900&q=70','https://images.unsplash.com/photo-1473116763249-2faaef81ccda?w=900&q=70'] },
  { id:'djerba-sidi-mahres', name:'Plage Sidi Mahres',      city:'Djerba',   risk:'stable', erosionMeters:-0.3, lat:33.8731, lng:10.9286, lastUpdate:'11 mai 2026',
    photoUrl:'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?w=900&q=70',
    photos:['https://images.unsplash.com/photo-1507525428034-b723cf961d3e?w=900&q=70','https://images.unsplash.com/photo-1519046904884-53103b34b206?w=900&q=70','https://images.unsplash.com/photo-1559827260-dc66d52bef19?w=900&q=70'] },
  { id:'djerba-aghir',       name:'Plage Aghir',            city:'Djerba',   risk:'modere', erosionMeters:-1.9, lat:33.7731, lng:10.9922, lastUpdate:'10 mai 2026',
    photoUrl:'https://images.unsplash.com/photo-1519046904884-53103b34b206?w=900&q=70',
    photos:['https://images.unsplash.com/photo-1519046904884-53103b34b206?w=900&q=70','https://images.unsplash.com/photo-1473116763249-2faaef81ccda?w=900&q=70','https://images.unsplash.com/photo-1505228395891-9a51e7e86bf6?w=900&q=70'] },
  { id:'gabes',              name:'Plage de Gabès',         city:'Gabès',    risk:'eleve',  erosionMeters:-4.8, lat:33.8881, lng:10.0975, lastUpdate:'09 mai 2026',
    photoUrl:'https://images.unsplash.com/photo-1559827260-dc66d52bef19?w=900&q=70',
    photos:['https://images.unsplash.com/photo-1559827260-dc66d52bef19?w=900&q=70','https://images.unsplash.com/photo-1505228395891-9a51e7e86bf6?w=900&q=70','https://images.unsplash.com/photo-1507525428034-b723cf961d3e?w=900&q=70'] },
  { id:'zarzis',             name:'Plage de Zarzis',        city:'Zarzis',   risk:'stable', erosionMeters:-0.7, lat:33.5031, lng:11.1119, lastUpdate:'08 mai 2026',
    photoUrl:'https://images.unsplash.com/photo-1473116763249-2faaef81ccda?w=900&q=70',
    photos:['https://images.unsplash.com/photo-1473116763249-2faaef81ccda?w=900&q=70','https://images.unsplash.com/photo-1519046904884-53103b34b206?w=900&q=70','https://images.unsplash.com/photo-1559827260-dc66d52bef19?w=900&q=70'] },
  { id:'bekalta',            name:'Plage de Bekalta',       city:'Monastir', risk:'stable', erosionMeters:-0.8, lat:35.6189, lng:11.0089, lastUpdate:'08 mai 2026',
    photoUrl:'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?w=900&q=70',
    photos:['https://images.unsplash.com/photo-1507525428034-b723cf961d3e?w=900&q=70','https://images.unsplash.com/photo-1505228395891-9a51e7e86bf6?w=900&q=70','https://images.unsplash.com/photo-1473116763249-2faaef81ccda?w=900&q=70'] },
];

const alerts = [
  { beachId:'sousse',        beachName:'Plage de Sousse',      message:'Érosion accélérée détectée — action recommandée', risk:'eleve'  },
  { beachId:'sfax',          beachName:'Plage de Sfax',        message:'Recul critique de 6,2 m enregistré',              risk:'eleve'  },
  { beachId:'sidi-bou-said', beachName:'Plage Sidi Bou Saïd', message:'Érosion de 4,1 m — surveillance renforcée',       risk:'eleve'  },
  { beachId:'skanes',        beachName:'Plage de Skanes',      message:'Recul de 3,2 m sur les 12 derniers mois',         risk:'modere' },
  { beachId:'mahdia',        beachName:'Plage de Mahdia',      message:'Nouveau signalement citoyen à vérifier',          risk:'modere' },
  { beachId:'tabarka',       beachName:'Plage de Tabarka',     message:'Relevé terrain mis à jour',                       risk:'modere' },
  { beachId:'sayada',        beachName:'Plage de Sayada',      message:'Relevé terrain mis à jour',                       risk:'stable' },
  { beachId:'gammarth',      beachName:'Plage de Gammarth',    message:'Données satellite intégrées',                     risk:'stable' },
];

async function seed() {
  await mongoose.connect(process.env.MONGODB_URI);
  console.log('Connected to MongoDB');

  await Beach.deleteMany({});
  await Beach.insertMany(beaches);
  console.log(`✅  Seeded ${beaches.length} beaches`);

  await Alert.deleteMany({});
  await Alert.insertMany(alerts);
  console.log(`✅  Seeded ${alerts.length} alerts`);

  await mongoose.disconnect();
  console.log('Done.');
}

seed().catch(err => { console.error(err); process.exit(1); });