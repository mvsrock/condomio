print("Start inizializzazione replica set");
const adminDb = db.getSiblingDB('admin');
adminDb.auth('myuser', 'mypassword');

var cfg = {
    "_id": "rs0",
    "members": [
        {
            "_id": 0,
            "host": "mongodb:27017"
        }
    ]
};

print("Initialize replica set configuration");

try {
	rs.initiate(cfg);
} catch (e) {
	print(e)
}