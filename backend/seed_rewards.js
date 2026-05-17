require('dotenv').config();
const mongoose = require('mongoose');
const Reward   = require('./models/Reward');

const rewards = [
  {
    name: 'Cocktail offert',
    description: 'Un cocktail signature dans un bar partenaire du littoral',
    cost: 100,
    category: 'experience',
    imageUrl: 'https://images.unsplash.com/photo-1551024601-bec78aea704b?w=600&q=70',
  },
  {
    name: 'Massage spa',
    description: 'Soin relaxant de 30 minutes dans un spa partenaire',
    cost: 500,
    category: 'experience',
    imageUrl: 'https://images.unsplash.com/photo-1544161515-4ab6ce6db874?w=600&q=70',
  },
  {
    name: 'Session de paddle',
    description: 'Location de paddle 2 heures avec moniteur',
    cost: 1000,
    category: 'experience',
    imageUrl: 'https://images.unsplash.com/photo-1502680390469-be75c86b636f?w=600&q=70',
  },
  {
    name: 'T-shirt Costalina',
    description: 'T-shirt en coton bio édition limitée',
    cost: 250,
    category: 'merch',
    imageUrl: 'https://images.unsplash.com/photo-1521572163474-6864f9cf17ab?w=600&q=70',
  },
  {
    name: 'Plantation d\'arbre',
    description: 'Un arbre planté à votre nom sur la côte tunisienne',
    cost: 200,
    category: 'eco',
    imageUrl: 'https://images.unsplash.com/photo-1542601906990-b4d3fb778b09?w=600&q=70',
  },
  {
    name: 'Excursion bateau',
    description: 'Sortie en mer guidée vers les îles Kuriat',
    cost: 1500,
    category: 'experience',
    imageUrl: 'https://images.unsplash.com/photo-1473116763249-2faaef81ccda?w=600&q=70',
  },
];

(async () => {
  try {
    await mongoose.connect(process.env.MONGODB_URI);
    console.log('Connected');
    await Reward.deleteMany({});
    const inserted = await Reward.insertMany(rewards);
    console.log(`Seeded ${inserted.length} rewards`);
    process.exit(0);
  } catch (err) {
    console.error(err);
    process.exit(1);
  }
})();