from flask import Flask, request, jsonify
import pandas as pd
from sklearn.neighbors import NearestNeighbors
import firebase_admin
from firebase_admin import credentials, firestore

app = Flask(__name__)

# Initialize Firebase Admin SDK
cred = credentials.Certificate("contacte-b2228-firebase-adminsdk-68rah-ea7147d102.json")
firebase_admin.initialize_app(cred)
db = firestore.client()

# Retrieve user data from Firestore
def get_user_data():
    users_ref = db.collection('users')
    docs = users_ref.stream()
    data = []
    for doc in docs:
        user_data = doc.to_dict()
        user_data['user_id'] = doc.id
        data.append(user_data)
    print(f"Retrieved data: {data}")
    return data

# Prepare data for training
def prepare_data(data):
    df = pd.DataFrame(data)
    df.set_index('user_id', inplace=True)
    df_encoded = pd.get_dummies(df['interests'].apply(pd.Series), prefix='', prefix_sep='').groupby(level=0, axis=1).sum()
    print(f"Encoded data:\n{df_encoded}")
    return df_encoded

# Train the model
def train_model(df_encoded):
    model = NearestNeighbors(n_neighbors=5, algorithm='auto', metric='cosine')
    model.fit(df_encoded)
    return model

# Suggest friends based on user_id with at least 2 common interests
def suggest_friends(user_id, model, df_encoded):
    user_vector = df_encoded.loc[user_id].values.reshape(1, -1)
    distances, indices = model.kneighbors(user_vector)
    potential_friends = df_encoded.iloc[indices[0]].index.tolist()
    print(f"Potential friends before filtering: {potential_friends}")
    potential_friends.remove(user_id)  # Remove the user from the suggestions

    # Filter friends with at least 2 common interests
    user_interests = df_encoded.loc[user_id]
    print(f"User interests for {user_id}: {user_interests}")
    suggestions = []
    for friend in potential_friends:
        friend_interests = df_encoded.loc[friend]
        common_interests = (user_interests & friend_interests).sum()
        print(f"Common interests with {friend}: {common_interests}")
        if common_interests >= 2:
            suggestions.append(friend)

    print(f"Suggested friends: {suggestions}")
    return suggestions

# Set up the data and model
data = get_user_data()
df_encoded = prepare_data(data)
model = train_model(df_encoded)

# API endpoint for suggesting friends
@app.route('/suggest_friends', methods=['POST'])
def suggest_friends_api():
    user_id = request.json['user_id']
    suggestions = suggest_friends(user_id, model, df_encoded)
    return jsonify(suggestions)

if __name__ == '__main__':
    app.run(debug=True)



