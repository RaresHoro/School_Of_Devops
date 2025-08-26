import { MongoClient } from 'mongodb';

const clusterAddress = process.env.MONGODB_CLUSTER_ADDRESS;
const dbUser = process.env.MONGODB_USERNAME;
const dbPassword = process.env.MONGODB_PASSWORD;
const dbName = process.env.MONGODB_DB_NAME;

const uri = `mongodb+srv://${dbUser}:${dbPassword}@${clusterAddress}/?retryWrites=true&w=majority`;


const client = new MongoClient(uri, { serverSelectionTimeoutMS: 15000 });

async function connectMongo() {
  try {
    console.log('Trying to connect to db…');
    await client.connect();
    await client.db('admin').command({ ping: 1 });   // sanity check
    console.log(`✅ Connected successfully, DB ready: ${dbName}`);
  } catch (err) {
    console.error('❌ Connection failed:', err.message);
  } finally {
    await client.close();
    console.log('Connection closed.');
  }
}

await connectMongo();