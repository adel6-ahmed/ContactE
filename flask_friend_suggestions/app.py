from flask import Flask, request, jsonify
import pandas as pd
from sklearn.neighbors import NearestNeighbors
import firebase_admin
from firebase_admin import credentials, firestore
import os
import threading
import time

app = Flask(__name__)

# Initialize Firebase Admin SDK
try:
    cred = credentials.Certificate("contacte-b2228-firebase-adminsdk-68rah-ea7147d102.json")
    firebase_admin.initialize_app(cred)
    db = firestore.client()
except Exception as e:
    print(f"Firebase initialization error: {e}")

# Global variables with refresh mechanism
user_data = []
df_encoded = pd.DataFrame()
model = None
last_refresh_time = 0
REFRESH_INTERVAL = 300  # 5 minutes

def get_user_data():
    try:
        users_ref = db.collection('users')
        docs = users_ref.stream()
        data = []
        for doc in docs:
            user_data = doc.to_dict()
            user_data['user_id'] = doc.id
            data.append(user_data)
        print(f"Retrieved {len(data)} users")
        return data
    except Exception as e:
        print(f"Error retrieving user data: {e}")
        return []

def prepare_data(data):
    if not data:
        return pd.DataFrame()
    
    df = pd.DataFrame(data)
    df.set_index('user_id', inplace=True)
    
    # Handle interests safely
    if 'interests' in df.columns:
        interests_df = df['interests'].apply(lambda x: pd.Series(x) if isinstance(x, dict) else pd.Series())
        df_encoded = pd.get_dummies(interests_df, prefix='', prefix_sep='')
        df_encoded = df_encoded.groupby(df_encoded.columns, axis=1).sum()
    else:
        df_encoded = pd.DataFrame(index=df.index)
    
    print(f"Encoded data shape: {df_encoded.shape}")
    return df_encoded

def train_model(df_encoded):
    if df_encoded.empty or len(df_encoded) < 2:
        return None
    
    try:
        model = NearestNeighbors(n_neighbors=min(6, len(df_encoded)), algorithm='auto', metric='cosine')
        model.fit(df_encoded)
        return model
    except Exception as e:
        print(f"Model training error: {e}")
        return None

def refresh_data():
    global user_data, df_encoded, model, last_refresh_time
    try:
        print("Refreshing user data and model...")
        user_data = get_user_data()
        df_encoded = prepare_data(user_data)
        model = train_model(df_encoded)
        last_refresh_time = time.time()
        print("Data refresh completed successfully")
    except Exception as e:
        print(f"Error refreshing data: {e}")

def ensure_fresh_data():
    global last_refresh_time
    current_time = time.time()
    if current_time - last_refresh_time > REFRESH_INTERVAL or not model:
        refresh_data()

# Initial data load
refresh_data()

def suggest_friends(user_id, model, df_encoded):
    if model is None or df_encoded.empty:
        return []
    
    if user_id not in df_encoded.index:
        return []
    
    try:
        user_vector = df_encoded.loc[user_id].values.reshape(1, -1)
        n_neighbors = min(6, len(df_encoded))
        distances, indices = model.kneighbors(user_vector, n_neighbors=n_neighbors)
        
        potential_friends = df_encoded.iloc[indices[0]].index.tolist()
        print(f"Potential friends before filtering: {potential_friends}")
        
        # Remove the user from suggestions
        if user_id in potential_friends:
            potential_friends.remove(user_id)
        
        # Filter friends with at least 1 common interest
        user_interests = df_encoded.loc[user_id]
        suggestions = []
        
        for friend in potential_friends:
            friend_interests = df_encoded.loc[friend]
            common_interests = (user_interests.astype(bool) & friend_interests.astype(bool)).sum()
            print(f"Common interests with {friend}: {common_interests}")
            if common_interests >= 1:  # Reduced threshold
                suggestions.append(friend)
        
        print(f"Suggested friends: {suggestions}")
        return suggestions
        
    except Exception as e:
        print(f"Error in suggest_friends: {e}")
        return []

@app.route('/suggest_friends', methods=['POST'])
def suggest_friends_api():
    try:
        if not request.json or 'user_id' not in request.json:
            return jsonify({'error': 'user_id is required'}), 400
        
        user_id = request.json['user_id']
        
        # Ensure we have fresh data
        ensure_fresh_data()
        
        if model is None:
            return jsonify({'error': 'Model not trained or insufficient data'}), 500
        
        suggestions = suggest_friends(user_id, model, df_encoded)
        return jsonify({'suggestions': suggestions})
        
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@app.route('/refresh_data', methods=['POST'])
def refresh_data_api():
    try:
        refresh_data()
        return jsonify({'message': 'Data refreshed successfully'})
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@app.route('/health', methods=['GET'])
def health_check():
    return jsonify({
        'status': 'healthy',
        'users_count': len(user_data),
        'model_trained': model is not None,
        'last_refresh': last_refresh_time
    })

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=5000)