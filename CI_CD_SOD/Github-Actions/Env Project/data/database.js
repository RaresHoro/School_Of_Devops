import { MongoClient } from 'mongodb';

const clusterAddress = (process.env.MONGODB_CLUSTER_ADDRESS || '').trim(); // e.g. cluster0.x.mongodb.net
const dbUserRaw = process.env.MONGODB_USERNAME;
const dbPasswordRaw = process.env.MONGODB_PASSWORD;
const dbName = (process.env.MONGODB_DB_NAME || '').trim();

const dbUser = encodeURIComponent(dbUserRaw || '');
const dbPassword = encodeURIComponent(dbPasswordRaw || '');

if (!clusterAddress || !dbUser || !dbPassword || !dbName) {
  console.error('Missing one of: MONGODB_CLUSTER_ADDRESS / MONGODB_USERNAME / MONGODB_PASSWORD / MONGODB_DB_NAME');
  process.exit(1);
}

const uri = `mongodb+srv://${dbUser}:${dbPassword}@${clusterAddress}/?retryWrites=true&w=majority`;
const client = new MongoClient(uri, { serverSelectionTimeoutMS: 15000 });

console.log('Trying to connect to db');

let database;

try {
  await client.connect();
  await client.db('admin').command({ ping: 1 }); // sanity check
  console.log('Connected successfully to server');

  // Only set database AFTER successful connect:
  database = client.db(dbName);
} catch (error) {
  console.error('Connection failed:', error?.message || error);
  // Do NOT export a dead client; stop the process so callers don’t proceed with a bad DB.
  process.exit(1);
}

export default database;
